const uuid = require('uuid');

module.exports = {
  run(data) {
    let configLoader = data.room
      .getRoomController()
      .getApplication()
      .getConfigManager();

    if (data.version && configLoader.getFromMainConfig("minVersion") < data.version) {
      data.result = {
        bSuccessfull: false,
        reason: `versions on main server and client is not compatible. (You can update it on: ${"domen.com/download"})`
      }
      return data.bRunning = false;
    }

    if (data.type != "gmod" && data.type != "minecraft") {
      data.result = {
        bSuccessfull: false,
        reason: "type is not identified..."
      };
      return data.bRunning = false;
    }
  }
}