const express = require("express");
const bodyParser = require("body-parser");
const EventBus = require("../utils/EventBus");
const Application = require("../Application");
const Logger = require("../utils/Logger");

class WebController {
  static POST = "post";
  static GET = "get";

  static EVENT_START_LISTENING = "web_listen";

  static SECURE = true;

  /**
   * 
   * @param {Application} application 
   * @param {*} port 
   * @param {*} limit 
   */
  constructor(application, port = 80, limit = `50mb`, endpoints = []) {
    this._port = port;
    this._application = application;
    
    this._logger = new Logger(`WebController`);

    this._ips = new Map();

    this.__express = express();

    this.__express.use(bodyParser.json({ limit }));
    this.__express.use(bodyParser.urlencoded({ extended: true }));
    this.__express.use("/static", express.static("static"))

    this.__express.set('view engine', 'ejs');

    for (let i = 0; i < endpoints.length; i++) {
      let endpoint = endpoints[i];

      this._logger.log(`Load ${endpoint.type}-endpoint: ${endpoint.name} - ${endpoint.description} - ${endpoint.path}`);
      this.__express[endpoint.type](endpoint.path, (req, res) => { 
        if (WebController.SECURE) {
          let ip = req.ip;
          let time = Date.now();

          if (!this._ips.get(ip)) {
            this._ips.set(ip, [])
          }

          this._ips.set(req.ip, this._ips.get(req.ip).filter(timestamp => time - timestamp < 1000))

          if (this._application.ConfigLoader.getFromMainConfig("maxCallsPerIPPerSecond") < this._ips.get(req.ip).length) {
            res.send({
              code: -2,
              message: "Too many requests."
            })
            return;
          }

          this._ips.get(req.ip).unshift(Date.now());
        }
        
        endpoint.run(application, req, res)
      });
    }

    this.__express.listen(port, () => {
      this._logger.log(`Listening started at port ${port}`)
      EventBus.invoke(WebController.EVENT_START_LISTENING, { controller: this, time: Date.now(), port })
    })
  }

  updateSecond() {

  }

  getApplication() {
    return this._application;
  }
}

module.exports = WebController;