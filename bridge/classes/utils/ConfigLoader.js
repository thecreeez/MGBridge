const fs = require("fs");

class ConfigLoader {
  static PATH_TO_MATERIALS = "./materials.json";
  static PATH_TO_CONFIG = "./config.json";
  static PATH_TO_BLOCKLIST = "./blocklist.json"

  constructor(application) {
    console.log("config loading...")
    this._app = application;

    if (!fs.existsSync(ConfigLoader.PATH_TO_MATERIALS)) {
      fs.writeFileSync(ConfigLoader.PATH_TO_MATERIALS, JSON.stringify({ default: "minecraft:white_concrete" }, null, 2));
    }

    if (!fs.existsSync(ConfigLoader.PATH_TO_CONFIG)) {
      fs.writeFileSync(ConfigLoader.PATH_TO_CONFIG, JSON.stringify(ConfigLoader.getDefaultConfig(this._app), null, 2));
    }

    if (!fs.existsSync(ConfigLoader.PATH_TO_BLOCKLIST)) {
      fs.writeFileSync(ConfigLoader.PATH_TO_BLOCKLIST, JSON.stringify([], null, 2));
    }

    this.materials = JSON.parse(fs.readFileSync(ConfigLoader.PATH_TO_MATERIALS));
    this.mainConfig = JSON.parse(fs.readFileSync(ConfigLoader.PATH_TO_CONFIG));

    //console.log(this.materials)
  }

  static getDefaultConfig(application) {
    return {
      "idleRoomLifeTime": 60000,
      "timeOutTime": 10000,
      "maxRooms": 5,
      "maxCallsPerIPPerSecond": 50,

      "port": 1820,
      "webLimit": "100mb",

      "version": "1",
      "minVersion": "1"
    }
  }

  getFromMainConfig(field) {
    return this.mainConfig[field]
  }

  getMaterials() {
    return this.materials;
  }
}

module.exports = ConfigLoader;