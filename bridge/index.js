const Application = require("./classes/Application");
const Room = require("./classes/room/Room");

const TPS = 30;

async function start() {
  await Application.__initEvents();
  await Application.__initEndpoints();

  let application = new Application();

  setInterval(updatePerSecond, 1000);
  setInterval(updateTick, 1000 / TPS);

  function updatePerSecond() {
    application.updatePerSecond();
  }

  function updateTick() {
    application.updateTick();
  }

  // Create room here
  new Room(application.RoomController, { bDebug: true, maxTPS: 1, code: "test", gmodUnitsPerBlock: 64, forcedGenerateMap: true, allowedGeneratingMap: true, bPrivate: false });
}

['log', 'warn', 'error'].forEach((methodName) => {
  const originalMethod = console[methodName];
  console[methodName] = (...args) => {
    let initiator = 'unknown place';
    try {
      throw new Error();
    } catch (e) {
      if (typeof e.stack === 'string') {
        let isFirst = true;
        for (const line of e.stack.split('\n')) {
          const matches = line.match(/^\s+at\s+(.*)/);
          if (matches) {
            if (!isFirst) { // first line - current function
              // second line - caller (what we are looking for)
              initiator = matches[1];
              break;
            }
            isFirst = false;
          }
        }
      }
    }

    let fileAndClass = initiator.split(`\\`)[initiator.split(`\\`).length - 1].split(")")[0];

    if (!fileAndClass.toLowerCase().includes("logger"))
      originalMethod.apply(console, [`[${fileAndClass}] [Default]:`, ...args]);
    else
      originalMethod.apply(console, [...args]);
  };
});

start();