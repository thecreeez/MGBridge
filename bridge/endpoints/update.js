const Application = require("../classes/Application");
const WebController = require("../classes/web/WebController");

module.exports = {
  type: WebController.POST,
  path: "/update",

  name: "RoomUpdate",
  description: "Endpoint to update the room.",
  fields: ["token"],

  /**
   * 
   * @param {Application} application 
   * @param {*} req 
   * @param {*} res 
   */
  async run(application, req, res) {
    let data = req.body;

    if (!data.token) {
      res.send({
        code: -1,
        message: "Token didn't present."
      })

      return;
    }
    
    let roomAndSide = application.RoomController.getRoomAndSideByToken(data.token);

    if (roomAndSide.room == null) {
      res.send({
        code: -1,
        message: "Token didn't right"
      })

      return;
    }

    data.side = roomAndSide.side;

    res.send(await roomAndSide.room.updateSide(data))
  }
}