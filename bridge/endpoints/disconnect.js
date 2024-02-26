const Application = require("../classes/Application");
const WebController = require("../classes/web/WebController");

module.exports = {
  type: WebController.POST,
  path: "/disconnect",

  name: "RoomDisconnect",
  description: "Endpoint to disconnect from room.",
  fields: ["token"],

  /**
   * 
   * @param {Application} application 
   * @param {*} req 
   * @param {*} res 
   */
  run(application, req, res) {
    let data = req.body;

    console.log(data);
    if (!data.token) {
      res.send({
        code: -1,
        message: "Token didnt present."
      })

      return;
    }

    let roomAndSide = application.RoomController.getRoomAndSideByToken(data.token);

    if (roomAndSide.room == null) {
      res.send({
        code: -1,
        message: "Token isn't right"
      })

      return;
    }

    data.side = roomAndSide.side;

    res.send(roomAndSide.room.disconnect(data))
  }
}