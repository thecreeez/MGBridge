const uuid = require('uuid');

module.exports = {
  run(data) {
    let room = data.room;

    if (room.getToken(data.type) != false) {
      data.result = {
        bSuccessfull: false,
        reason: `Another ${data.type}-client already connected to this room`
      };
      return data.bRunning = false;
    }

    let token = uuid.v4()
    room.setToken(data.type, token);

    if (data.type == "gmod") {
      room.setHeightOffset(data.OffsetHeight);
      room.setGmodMaterials(data.Materials);

      room.getLogger().log(`Gmod side connected to the room. Materials: `, JSON.stringify(data.Materials, null, 2));
    }

    this.formSuccessResult(data, room, token);
    room.currentChunkLoad = 0;

    room.getLogger().log(`${data.type} side connected to the room.`)
  },

  formSuccessResult(data, room, token) {
    data.result = {
      bSuccessfull: true,
      data: {
        token,
        code: room.getCode(),
        settings: {
          maxTPS: room.getMaxTPS(),
          allowedGeneratingMap: room.allowedGeneratingMap,
          forcedGenerateMap: room.forcedGenerateMap,
          gmodUnitsPerBlock: room.getGmodUnitsPerBlock(),
        }
      }
    }
  }
}