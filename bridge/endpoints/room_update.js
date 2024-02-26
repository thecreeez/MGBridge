const Application = require("../classes/Application");
const WebController = require("../classes/web/WebController");

module.exports = {
  type: WebController.GET,
  path: "/room-update/:code",

  name: "RoomUpdate",
  description: "Endpoint to update show room.",
  fields: [],

  /**
   * 
   * @param {Application} application 
   * @param {*} req 
   * @param {*} res 
   */
  run(application, req, res) {
    let data = req.params;
    let room = application.RoomController.getRoom(data.code);

    if (!data.code || !room) {
      res.send({
        code: -1,
        message: "Room with this code doesn't exist."
      })
      return;
    }

    res.send({
      code: 0,
      data: { room: room.lightSerialize() }
    })
  }
}