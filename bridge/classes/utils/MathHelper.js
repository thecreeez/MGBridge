class MathHelper {
  static randomInt(min, max) {
    return Math.random() * (max - min) - min;
  }
}

module.exports = MathHelper;