module.exports = {
  run(data) {
    /**
     * BASEMENT
     */
    data.result = {
      bSuccessfull: true,
      data: {
        entities: [],
        events: [],
        scanP: data.room.getGmodData().scanP,
      }
    }

    data.room.__minecraftTPSCount++;

    /**
     * ENTITIES
     */
    data.room.getGmodData().entities.forEach((entity) => {
      data.result.data.entities.push(entity);
    })

    /**
     * EVENTS
     */
    data.room.getGmodData().events.forEach((event) => {
      data.result.data.events.push(event);
    })
    data.room.getGmodData().events.length = 0;

    /**
     * CHUNK
     */
    if (data.room.currentChunkLoad != -1 && data.room.currentChunkLoad < data.room.getGmodData().chunks.length) {
      data.result.data.chunk = data.room.getGmodData().chunks[data.room.currentChunkLoad];
      data.room.currentChunkLoad++;
    }
  }
}