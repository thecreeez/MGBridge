const Room = require("../classes/room/Room")
const EventBus = require("../classes/utils/EventBus")

module.exports = {
  run(data) {
    switch (data.side) {
      case "minecraft": EventBus.invoke(Room.EVENT_UPDATE_MINECRAFT, data); break;
      case "gmod": EventBus.invoke(Room.EVENT_UPDATE_GMOD, data); break;
    }
  }
}