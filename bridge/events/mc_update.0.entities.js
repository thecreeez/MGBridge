module.exports = {
  run(data) {
    data.entities.forEach((entity) => {

      // Positions
      entity.x = entity.x * data.room.getGmodUnitsPerBlock();
      entity.y = entity.y * data.room.getGmodUnitsPerBlock() + data.room.getHeightOffset();
      entity.z = entity.z * data.room.getGmodUnitsPerBlock();

      // Sitting
      entity.isSitting = entity.isSitting ? 1 : 0

      let entitiesCountInBridgeBefore = data.room.getMinecraftData().entities.size;

      data.room.getMinecraftData().entities.set(entity.uuid, entity);

      if (data.room.getMinecraftData().entities.size > entitiesCountInBridgeBefore) {
        data.room.getLogger().log(`New MinecraftSide entity: `, JSON.stringify(entity, null, 2));
      }
    })

    //Deleting who doesnt exist on minecraft server
    data.room.getMinecraftData().entities.forEach((bridgeEntity) => {
      let isExistOnMinecraftServer = false;

      data.entities.forEach((minecraftEntity) => {
        if (bridgeEntity.uuid == minecraftEntity.uuid)
          isExistOnMinecraftServer = true;
      })

      if (!isExistOnMinecraftServer) {
        data.room.getLogger().log(`Removed MinecraftSide entity: `, JSON.stringify(bridgeEntity, null, 2));
        data.room.getMinecraftData().entities.delete(bridgeEntity.uuid);
      }
    })
  }
}