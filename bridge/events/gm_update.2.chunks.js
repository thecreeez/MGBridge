module.exports = {
  run(data) {
    if (data.chunk && data.chunk.points) {
      let chunk = data.chunk;

      let amountOfDataPerBlock = 4;
      for (let i = 0; i < chunk.points.length / amountOfDataPerBlock; i++) {
        chunk.points[i * amountOfDataPerBlock] = Math.round(data.room.getBlockPerGmodUnits() * chunk.points[i * 4]);
        chunk.points[i * amountOfDataPerBlock + 1] = Math.round(data.room.getBlockPerGmodUnits() * chunk.points[i * 4 + 1] - data.room.getHeightOffset() * data.room.getBlockPerGmodUnits());
        chunk.points[i * amountOfDataPerBlock + 2] = Math.round(data.room.getBlockPerGmodUnits() * chunk.points[i * 4 + 2]);
        
        chunk.points[i * amountOfDataPerBlock + 3] = this.getMinecraftIdByMaterial(data, chunk.points[i * 4 + 3]);
      }
      data.room.getGmodData().chunks.push(chunk.points);
      data.room.getLogger().log(`Added chunk: [${data.chunk.scanP}%] (${chunk.points.length / amountOfDataPerBlock} blocks)`)

      data.room.getGmodData().scanP = data.chunk.scanP;
    }
  },

  getMinecraftIdByMaterial(data, materialId) {
    let materials = data.room
      .getRoomController()
      .getApplication()
      .getConfigManager()
      .getMaterials();

    let material = materials[data.room.getGmodData().materials[materialId]];

    if (!material) {
      return materials.default;
    }

    return material;
  }
}