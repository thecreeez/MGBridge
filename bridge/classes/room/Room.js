const RoomResults = require("./RoomResults.js");
const RoomLogger = require("../utils/RoomLogger.js");
const MathHelper = require("../utils/MathHelper.js");
const EventBus = require("../utils/EventBus.js");

class Room {
  static EVENT_HANDSHAKE = "room_handshake";
  static EVENT_UPDATE = "room_update";
  static EVENT_UPDATE_MINECRAFT = "mc_update";
  static EVENT_UPDATE_GMOD = "gm_update";

  static EVENT_UPDATE_TICK = "room_update_tick";
  static EVENT_UPDATE_SECOND = "room_update_second";
  static EVENT_REMOVE_ROOM = "room_remove";

  static generateCode(symbolsCount) {
    let symbols = "qwertyuiopasdfghjklzxcvbnm1234567890";
    let code = "";

    for (let i = 0; i < symbolsCount; i++) {
      code += symbols.charAt(MathHelper.randomInt(0, symbols.length));
    }

    return code;
  }

  constructor(roomController, { 
    // Max calls update to client
    maxTPS = 20, 
    // Allowing generate map from gmod (even if map exist on storage context)
    allowedGeneratingMap = false,
    // is Room debug
    bDebug = false,
    // Code to connect to room
    code = Room.generateCode(5),
    gmodUnitsPerBlock = 64, 
    // Need to show room on site
    bPrivate = true, 
    // Force regenerate map from trace
    forcedGenerateMap = false } = {}
  ) {
    this._roomController = roomController;
    this._gmodToken = false;
    this._minecraftToken = false;

    this._timeOutTime = roomController.getApplication().getConfigManager().getFromMainConfig("timeOutTime");
    this._idleRoomLifeTime = roomController.getApplication().getConfigManager().getFromMainConfig("idleRoomLifeTime");

    this._bPrivate = bPrivate;

    this.allowedGeneratingMap = allowedGeneratingMap;
    this.forcedGenerateMap = forcedGenerateMap;
    this.bDebug = bDebug;
    this.currentChunkLoad = 0;

    this._code = code;

    this._logger = new RoomLogger(this);
    this._roomController.addRoom(this);

    let maxCallsOnServer = roomController.getApplication().getConfigManager().getFromMainConfig("maxCallsPerIPPerSecond");
    if (maxTPS > maxCallsOnServer) {
      this._logger.log(`Requested TPS for room is too big: ${maxTPS}. Setting max TPS from config: ${maxCallsOnServer}`);
      maxTPS = maxCallsOnServer
    }

    this._maxTPS = maxTPS;

    this._gmodUnitsPerBlock = gmodUnitsPerBlock;
    this._blockPerGmodUnits = 1 / gmodUnitsPerBlock;
    this._heightOffset = 0;

    this._minecraftTPS = 0;
    this._minecraftTimeOutTime = 0;
    this.__minecraftTPSCount = 0;

    this._gmodTPS = 0;
    this._gmodTimeOutTime = 0;
    this.__gmodTPSCount = 0;

    this._idleTime = 0;

    this._minecraftData = {
      entities: new Map(),
      events: []
    };

    this._gmodData = {
      entities: new Map(),
      globalEntities: [],
      chunks: [],
      events: [],
      materials: {},
      scanP: 0,
    };

    this._logger.log(`Initialized room with settings:`)
    this._logger.log(`gmodUnitsPerBlock: ${this._gmodUnitsPerBlock}`);
    this._logger.log(`maxTPS: ${this._maxTPS}`);
    this._logger.log(`allowedGeneratingMap: ${this.allowedGeneratingMap}`);
    this._logger.log(`forcedGeneratingMap: ${this.forcedGenerateMap}`);
    this._logger.log(`To connect to the room type "/bridge start ${this._code}" on your client.`);
  }

  handshake(data) {
    data.room = this;
    EventBus.invoke(Room.EVENT_HANDSHAKE, data);

    return RoomResults.HandshakeResult(data.result);
  }

  updateSide(data) {
    data.room = this;
    EventBus.invoke(Room.EVENT_UPDATE, data);

    return RoomResults.UpdateResult(data.result);
  }

  disconnect(data) {
    switch (data.side) {
      case "gmod": this._gmodToken = false; this._gmodTPS = 0; break;
      case "minecraft": this._minecraftToken = false; this._minecraftTPS = 0; break;
    }

    this._logger.log(`${data.side} side disconnected from room.`);

    return {
      code: 0
    }
  }

  async updateTick(deltaTime) {
    
  }

  async updatePerSecond() {
    if (this.getGmodToken())
      this._updateSecondGmod();

    if (this.getMinecraftToken())
      this._updateSecondMinecraft();
    
    //console.log(`MC: ${this._minecraftTPS}/${this._maxTPS} GM: ${this._gmodTPS}/${this._maxTPS}`)

    if (!this.getGmodToken() && !this.getMinecraftToken()) {
      this._idleTime += 1000;
    } else if (this._idleTime > 0) {
      this._idleTime = 0;
    }

    if (this._idleRoomLifeTime == -1) {
      return;
    }

    if (this._idleTime > this._idleRoomLifeTime) {
      await EventBus.invoke(Room.EVENT_REMOVE_ROOM, { room: this, reason: "I've been alone more then a " + (this._idleRoomLifeTime / 1000)+" seconds..." })
      this.getLogger().log(`Room removed. Idle time exceeded.`)
      this._roomController.removeRoom(this.getCode());
    }
  }

  async _updateSecondGmod() {
    this._gmodTPS = this.__gmodTPSCount;
    this.__gmodTPSCount = 0;

    if (this._gmodTPS == 0) {
      this._gmodTimeOutTime += 1000;
    } else if (this._gmodTPS > 0) {
      this._gmodTimeOutTime = 0;
    }

    if (this._gmodTimeOutTime > this._timeOutTime) {
      this.setGmodToken(false);
      this._gmodTimeOutTime = 0;
      this._gmodData = {
        entities: new Map(),
        globalEntities: [],
        chunks: [],
        events: [],
        materials: {},
        scanP: 0
      };
      this.getLogger().log(`GmodSide disconnected: Timed out.`)
    }
  }

  async _updateSecondMinecraft() {
    this._minecraftTPS = this.__minecraftTPSCount;
    this.__minecraftTPSCount = 0;

    if (this._minecraftTPS == 0) {
      this._minecraftTimeOutTime += 1000;
    } else if (this._minecraftTimeOutTime > 0) {
      this._minecraftTimeOutTime = 0;
    }

    if (this._minecraftTimeOutTime > this._timeOutTime) {
      this.setMinecraftToken(false);
      this._minecraftTimeOutTime = 0;
      this._minecraftData = {
        entities: new Map(),
        events: []
      };
      this.getLogger().log(`MinecraftSide disconnected: Timed out.`)
    }
  }

  getCode() {
    return this._code;
  }

  getGmodUnitsPerBlock() {
    return this._gmodUnitsPerBlock;
  }

  getBlockPerGmodUnits() {
    return this._blockPerGmodUnits;
  }

  setGmodMaterials(materials) {
    for (const name in materials) {
      this._gmodData.materials[materials[name]] = name;
    }
  }

  setHeightOffset(offset) {
    return this._heightOffset = offset;
  }

  getHeightOffset() {
    return this._heightOffset;
  }

  bPrivate() {
    return this._bPrivate;
  }

  bDebug() {
    return this._bDebug;
  }

  getMaxTPS() {
    return this._maxTPS;
  }

  getCountGmodTPS() {
    return this.__gmodTPSCount;
  }

  getCountMinecraftTPS() {
    return this.__minecraftTPSCount;
  }

  getGmodToken() {
    return this._gmodToken;
  }

  setGmodToken(token) {
    this._gmodToken = token;
  }

  getMinecraftToken() {
    return this._minecraftToken;
  }

  setMinecraftToken(token) {
    this._minecraftToken = token;
  }

  getToken(side) {
    if (side == "minecraft") {
      return this._minecraftToken;
    } else if (side == "gmod") {
      return this._gmodToken;
    } else {
      this._logger.log(`Error when getting token: ${side} is not properly.`)
      return null;
    }
  }

  setToken(side, token) {
    if (side == "minecraft") {
      this._minecraftToken = token;
    } else if (side == "gmod") {
      this._gmodToken = token;
    } else {
      this._logger.log(`Error when sending token: ${side} is not properly.`)
    }
  }

  getLogger() {
    return this._logger;
  }

  getMinecraftData() {
    return this._minecraftData;
  }

  getGmodData() {
    return this._gmodData;
  }

  getRoomController() {
    return this._roomController;
  }

  bPrivate() {
    return this._bPrivate;
  }

  serialize() {
    return {
      code: this._code,
      gmodUnitsPerBlock: this._gmodUnitsPerBlock,
      tps: this._maxTPS,
      height: this._heightOffset,
      chunkLoadProgress: this.currentChunkLoad,

      gmodTPS: this._gmodTPS,
      gmodData: this._gmodData,
      bGmodConnected: !!this._gmodToken,

      minecraftTPS: this._minecraftTPS,
      minecraftData: this._minecraftData,
      bMinecraftConnected: !!this._minecraftToken
    }
  }

  /**
   * 
   * @returns Serialized JSON without information about chunks
   */
  lightSerialize() {
    let gmodData = {};

    for (let field in this._gmodData) {
      if (field != "chunks" && field != "materials" && field != "globalEntities")
        gmodData[field] = this._gmodData[field]
    }

    return {
      code: this._code,
      gmodUnitsPerBlock: this._gmodUnitsPerBlock,
      tps: this._maxTPS,
      height: this._heightOffset,
      chunkLoadProgress: this.currentChunkLoad,

      gmodTPS: this._gmodTPS,
      gmodData,
      bGmodConnected: !!this._gmodToken,

      minecraftTPS: this._minecraftTPS,
      minecraftData: this._minecraftData,
      bMinecraftConnected: !!this._minecraftToken
    }
  }

  serializeProperties() {
    return {
      code: this._code,
      gmodUnitsPerBlock: this._gmodUnitsPerBlock,
      tps: this._maxTPS,
      height: this._heightOffset,
      chunkLoadProgress: this.currentChunkLoad,

      gmodTPS: this._gmodTPS,
      bGmodConnected: !!this._gmodToken,

      minecraftTPS: this._minecraftTPS,
      bMinecraftConnected: !!this._minecraftToken
    }
  }
}

module.exports = Room;