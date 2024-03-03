const Logger = require("./Logger");
const fs = require('fs');

class RoomLogger extends Logger {
  constructor(room) {
    super(room.getCode())
    
    this._room = room;
    this._logName = `${this.getBigTime()}-room-${room.getCode()}-log`;
  }

  log(...messages) {
    let message = `[${this.getTime()}][Room-${this._name}]: ${messages.join(" ")}`;
    console.log(message);

    if (this._room.bDebug) {
      let data = ``;
      if (fs.existsSync(`./log/${this._logName}.log`)) {
        data = fs.readFileSync(`./log/${this._logName}.log`) + "\n";
      }
      fs.writeFileSync(`./log/${this._logName}.log`, data + message, null, 2);
    }
  }
}

module.exports = RoomLogger;