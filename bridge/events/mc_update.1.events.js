const uuid = require("uuid");

module.exports = {
  run(data) {
    data.events.forEach((event) => {
      event.uuid = uuid.v4();

      if (event.x || event.y || event.z) {
        event.x = event.x * data.room.getGmodUnitsPerBlock();
        event.y = event.y * data.room.getGmodUnitsPerBlock() + data.room.getHeightOffset();
        event.z = event.z * data.room.getGmodUnitsPerBlock();
      }

      data.room.getMinecraftData().events.push(event);
      data.room.getLogger().log(`New MinecraftSide event: `, JSON.stringify(event, null, 2));

      switch (event.type) {
        case "PlayerInteractButton": {
          //if (!global.tcz.library.searchByPos(event.x, event.y, event.z)) {
          //  data.room.getLogger().log("WARN", "Event with undefined entity! pos: " + event.x + "," + event.y + "," + event.z);
          //} else {
          //  data.room.getLogger().log("INFO", "New event registered: [" + event.type + "] Index: " + global.tcz.library.searchByPos(event.x, event.y, event.z).value);
          //  this.data.events.push(event);
          //}

          console.log(`TO-DO: MAKE PLAYER INTERACT BUTTON WORKS...`);
          break;
        }
      }
    })
  }
}