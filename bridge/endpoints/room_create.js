const Application = require("../classes/Application");
const Room = require("../classes/room/Room");
const WebController = require("../classes/web/WebController");

module.exports = {
  type: WebController.POST,
  path: "/create-room",

  name: "RoomCreate",
  description: "Endpoint to create a room. Doesn't need anything to create.",
  fields: [],

  /**
   * 
   * @param {Application} application 
   * @param {*} req 
   * @param {*} res 
   */
  run(application, req, res) {
    if (application.RoomController.getRoomsSize() >= application.ConfigLoader.getFromMainConfig("maxRooms")) {
      res.send({
        code: -1,
        message: `Too many rooms already created. Wait until some rooms will be released.`
      })

      return;
    }

    let tps = req.body.tps;

    if (!tps) {
      tps = 10;
    }

    if (Number(tps) > 20 || Number(tps) < 1) {
      res.send({
        code: -1,
        message: `Wrong tps. need [1-20].`
      })

      return;
    }

    if (isNaN(Number(tps))) {
      res.send({
        code: -1,
        message: `TPS is NaN.`
      })

      return;
    }

    let gmodUnitsPerBlock = req.body.gmodUnitsPerBlock;

    if (!gmodUnitsPerBlock) {
      gmodUnitsPerBlock = 64;
    }

    if (isNaN(Number(gmodUnitsPerBlock))) {
      res.send({
        code: -1,
        message: `gmodUnitsPerBlock is NaN.`
      })

      return;
    }

    if (Number(gmodUnitsPerBlock) > 256 || Number(gmodUnitsPerBlock) < 16) {
      res.send({
        code: -1,
        message: `Wrong gmodUnitsPerBlock. need [16-256].`
      })

      return;
    }

    let room = new Room(application.RoomController, { maxTPS: tps, gmodUnitsPerBlock });

    res.send({
      code: 0,
      data: {
        roomCode: room.getCode()
      }
    })
  }
}