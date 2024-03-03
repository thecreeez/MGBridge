module.exports = {
  run(data) {
    data.result = {
      bSuccessfull: true,
      data: {
        entities: [],
        events: []
      }
    }

    data.room.__gmodTPSCount++;

    data.room.getMinecraftData().entities.forEach((entity) => {
      data.result.data.entities.push(entity);
    })

    data.room.getMinecraftData().events.forEach((event) => {
      data.result.data.events.push(event);
    })

    // Clear events
    data.room.getMinecraftData().events.length = 0;
  }
}