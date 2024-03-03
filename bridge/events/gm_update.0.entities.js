module.exports = {
  run(data) {
    data.entities.forEach((entity) => {

      // Positions
      entity.x = entity.x * data.room.getBlockPerGmodUnits();
      entity.y = entity.y * data.room.getBlockPerGmodUnits() - data.room.getHeightOffset() * data.room.getBlockPerGmodUnits();
      entity.z = entity.z * data.room.getBlockPerGmodUnits();

      // Prop size
      if (entity.height)
        entity.size = Math.ceil(entity.height * data.room.getBlockPerGmodUnits() * 2);

      let entitiesCountInBridgeBefore = data.room.getGmodData().entities.size;

      data.room.getGmodData().entities.set(entity.uuid, entity);

      if (data.room.getMinecraftData().entities.size > entitiesCountInBridgeBefore) {
        data.room.getLogger().log(`New GmodSide entity: `, JSON.stringify(entity, null, 2));
      }
    })

    //Deleting who doesnt exist on minecraft server
    data.room.getGmodData().entities.forEach((bridgeEntity) => {
      let isExistOnMinecraftServer = false;

      data.entities.forEach((gmodEntity) => {
        if (bridgeEntity.uuid == gmodEntity.uuid)
          isExistOnMinecraftServer = true;
      })

      if (!isExistOnMinecraftServer) {
        data.room.getLogger().log(`Removed GmodSide entity: `, JSON.stringify(bridgeEntity, null, 2));
        data.room.getGmodData().entities.delete(bridgeEntity.uuid);
      }
    })
  }
}