const ConfigLoader = require("./utils/ConfigLoader");
const EventBus = require("./utils/EventBus");
const Logger = require("./utils/Logger");
const RoomController = require("./RoomController");
const fs = require("fs");
const WebController = require("./web/WebController");

class Application {
  static EVENT_APPLICATION_START = "app_start";

  static ENDPOINTS = [];

  static async __initEvents() {
    let events = fs.readdirSync("./events/");

    for (let i = 0; i < events.length; i++) {
      let fileArgs = events[i].split(".");

      if (fileArgs[fileArgs.length - 1] == "js") {
        await import("../events/" + events[i]).then(m => {
          let eventListener = m.default;

          EventBus.subscribe(fileArgs[0], eventListener);
        })
      }
    }
  }

  static async __initEndpoints() {
    let endpoints = fs.readdirSync("./endpoints/");

    for (let i = 0; i < endpoints.length; i++) {
      let fileArgs = endpoints[i].split(".");

      if (fileArgs[fileArgs.length - 1] == "js") {
        await import("../endpoints/" + endpoints[i]).then(m => {
          let endpoint = m.default;

          Application.ENDPOINTS.push(endpoint)
        })
      }
    }
  }

  constructor() {
    let loadStartTime = Date.now()

    this._logger = new Logger("App");
    this.RoomController = new RoomController(this);
    this.ConfigLoader = new ConfigLoader(this);
    this.WebController = new WebController(this, this.ConfigLoader.getFromMainConfig("port"), this.ConfigLoader.getFromMainConfig("webLimit"), Application.ENDPOINTS)

    EventBus.invoke(Application.EVENT_APPLICATION_START, { app: this, time: (Date.now() - loadStartTime) })
    this._lastUpdateTickTime = loadStartTime;
  }

  updateTick() {
    let deltaTime = Date.now() - this._lastUpdateTickTime;

    this.RoomController.updateTick(deltaTime);
    this._lastUpdateTickTime = Date.now();
  }

  updatePerSecond() {
    this.RoomController.updatePerSecond();
    this.WebController.updateSecond();
  }

  getLogger() {
    return this._logger;
  }

  getConfigManager() {
    return this.ConfigLoader;
  }

  getWebController() {
    return this.WebController;
  }
}

module.exports = Application;