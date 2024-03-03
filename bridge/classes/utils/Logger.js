class Logger {
  constructor(name) {
    this._name = name;
  }

  log(...messages) {
    let initiator = 'unknown place';
    try {
      throw new Error();
    } catch (e) {
      if (typeof e.stack === 'string') {
        let isFirst = true;
        for (const line of e.stack.split('\n')) {
          const matches = line.match(/^\s+at\s+(.*)/);
          if (matches) {
            if (!isFirst) {
              initiator = matches[1];
              break;
            }
            isFirst = false;
          }
        }
      }
    }

    let line = initiator.split(`\\`)[initiator.split(`\\`).length - 1].split(")")[0].split(":")[1];

    console.log(`[${this.getTime()}][${line}] [${this._name}]:`, ...messages);
  }

  getTime() {
    return this.getTimeBySpecifiedSeparator();
  }

  getBigTime() {
    let date = new Date();

    let month = date.getMonth() + 1;

    let year = date.getFullYear();
    month = month < 10 ? "0" + month : month;
    let day = date.getDate() < 10 ? "0" + date.getDate() : date.getDate();
    
    let hours = date.getHours() < 10 ? "0" + date.getHours() : date.getHours();
    let minutes = date.getMinutes() < 10 ? "0" + date.getMinutes() : date.getMinutes();
    let seconds = date.getSeconds() < 10 ? "0" + date.getSeconds() : date.getSeconds();

    return `${year}-${month}-${day} ${hours}-${minutes}-${seconds}`;
  }

  getTimeBySpecifiedSeparator(separator = ":") {
    let date = new Date();

    let hours = date.getHours() < 10 ? "0" + date.getHours() : date.getHours();
    let minutes = date.getMinutes() < 10 ? "0" + date.getMinutes() : date.getMinutes();
    let seconds = date.getSeconds() < 10 ? "0" + date.getSeconds() : date.getSeconds();

    return `${hours}${separator}${minutes}${separator}${seconds}`;
  }
}

module.exports = Logger;