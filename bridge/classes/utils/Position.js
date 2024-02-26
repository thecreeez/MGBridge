class Positions {
  static Types = {
    Minecraft: "minecraft",
    Gmod: "gmod"
  }

  constructor(x, y, z, room) {
    this._x = x;
    this._y = y;
    this._z = z;
    this._room = room;
  }

  toArray() {
    return [this._x, this._y, this._z];
  }

  static MinecraftPosition = class MinecraftPositionClass extends Positions {
    static createFromObject(room, object) {
      return new Positions.MinecraftPosition(object.x, object.y, object.z, room);
    }

    constructor(x, y, z, room) {
      super(x,y,z,room);
      this.type = Positions.Types.Minecraft;
    }

    toGmod(bYOffset = false) {
      let x = this._x * room.getGmodUnitsPerBlock();
      let y = this._y * room.getGmodUnitsPerBlock();
      let z = this._z * room.getGmodUnitsPerBlock();

      if (bYOffset) {
        y = y - this._room.getHeightOffset() * room.getGmodUnitsPerBlock();
      }

      return new Positions.GmodPosition(x,y,z, this._room);
    }
  }

  static GmodPosition = class GmodPositionClass extends Positions {
    static createFromObject(room, object) {
      return new Positions.GmodPosition(object.x, object.y, object.z, room);
    }

    constructor(x, y, z, room) {
      super(x, y, z, room);
      this.type = Positions.Types.Gmod;
    }

    toMinecraft(bYOffset = false) {
      let x = this._x * room.getBlockPerGmodUnits();
      let y = this._y * room.getBlockPerGmodUnits();
      let z = this._z * room.getBlockPerGmodUnits();

      if (bYOffset) {
        y += this._room.getHeightOffset();
      }

      return new Positions.MinecraftPosition(x, y, z, this._room);
    }
  }
}

module.exports = Positions;