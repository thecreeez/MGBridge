const Application = require("../classes/Application");
const Room = require("../classes/room/Room");
const WebController = require("../classes/web/WebController");

module.exports = {
  type: WebController.POST,
  path: "/handshake",

  name: "RoomHandshake",
  description: "Endpoint to handshake with room.",
  fields: ["type", "code"],

  /**
   * 
   * @param {Application} application 
   * @param {*} req 
   * @param {*} res 
   */
  run(application, req, res) {
    let data = req.body;
    if (!data.code || !application.RoomController.getRoom(data.code)) {
      res.send({
        code: -1,
        message: "Room with this code doesn't exist."
      })
      return;
    }

    res.send(application.RoomController.getRoom(data.code).handshake(data))
  }
}