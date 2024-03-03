const Room = require("./room/Room");
const EventBus = require("./utils/EventBus");
const Logger = require("./utils/Logger");

class RoomController {
  constructor(application) {
    this._application = application;
    this._logger = new Logger(`RoomController`);

    this._rooms = new Map();
  }

  getRoomsSize() {
    return this._rooms.size;
  }

  getPublicRooms({ serialize = false }) {
    let out = [];

    this._rooms.forEach((room) => {
      if (!room.bPrivate()) {
        if (serialize) {
          out.push(room.serializeProperties())
        } else {
          out.push(room);
        }
      }
    })

    return out;
  }

  /**
   * 
   * @param {Room} room 
   */
  addRoom(room) {
    if (this.getRoom(room.getCode())) {
      return false;
    }

    this._logger.log(`Created new room: ${room.getCode()}.`);

    return this._rooms.set(room.getCode(), room);
  }

  getRoomAndSideByToken(token) {
    let out = {
      room: null
    }

    this._rooms.forEach((room) => {
      if (out.room) {
        return;
      }

      if (room.getMinecraftToken() == token) {
        out.room = room;
        out.side = "minecraft";
      }

      if (room.getGmodToken() == token) {
        out.room = room;
        out.side = "gmod";
      }
    })

    return out;
  }

  getRoom(code) {
    return this._rooms.get(code);
  }

  removeRoom(code) {
    return this._rooms.delete(code);
  }

  updateTick(deltaTime) {
    this._rooms.forEach((room, key) => {
      room.updateTick(deltaTime);
    })
  }

  updatePerSecond() {
    this._rooms.forEach((room, key) => {
      room.updatePerSecond();
    })
  }

  getApplication() {
    return this._application;
  }
}

module.exports = RoomController;