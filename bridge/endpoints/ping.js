const Application = require("../classes/Application");
const Room = require("../classes/room/Room");
const WebController = require("../classes/web/WebController");

module.exports = {
  type: WebController.GET,
  path: "/ping",

  name: "PingService",
  description: "Endpoint to check available.",
  fields: [],

  /**
   * 
   * @param {Application} application 
   * @param {*} req 
   * @param {*} res 
   */
  run(application, req, res) {
    res.sendStatus(200);
  }
}