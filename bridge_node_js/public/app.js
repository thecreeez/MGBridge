class Bridge {
    constructor({name, connectionItem, entitiesCountItem, upsCountItem, entitiesDataItem, timeConnectionItem}) {
        this.connectionItem = connectionItem;
        this.entitiesCountItem = entitiesCountItem;
        this.upsCountItem = upsCountItem;
        this.entitiesDataItem = entitiesDataItem;
        this.timeConnectionItem = timeConnectionItem;
        this.name = name;

        this.entities = new Map();
        this.events = [];
    }

    update(data) {
        if (data.lastConnect > -1 && this.connectionItem.innerHTML == "Не подключено") {
            Logger.addLog("INFO", this.name +" side connected.");

            this.connectionItem.innerHTML = "Подключено";
            this.connectionItem.style.color = "green";
        }

        if (data.lastConnect == -1 && this.connectionItem.innerHTML == "Подключено") {
            Logger.addLog("INFO", this.name +" side disconnected.");

            this.connectionItem.innerHTML = "Не подключено";
            this.connectionItem.style.color = "red";
            this.timeConnectionItem.innerHTML = "";
            this.entitiesDataItem.innerHTML = ""

            this.entities.clear();
        }

        if (data.lastConnect == -1)
            return;

        this.upsCountItem.innerHTML = `UPS: ${data.ups}`
        this.timeConnectionItem.innerHTML = "Time: "+data.timeConnection;

        data.events.forEach(event => {
            let isExist = false;
            this.events.forEach(eventCandidate => {
                if (eventCandidate.uuid == event.uuid)
                    isExist = true;
            })

            if (isExist)
                return;

            this.events.push(event);
            Logger.addLog("INFO", "Added event "+event.type+" from "+this.name, "blue");
        })

        this.events.forEach((event, index) => {
            let isExist = false;
            data.events.forEach(eventCandidate => {
                if (eventCandidate.uuid == event.uuid)
                    isExist = true;
            })

            if (isExist)
                return;


            this.events.splice(index,1);
            Logger.addLog("INFO", "Event "+event.type+" handled.", "blue");
        })

        for (let uuid in data.entities) {
            if (this.entities.get(uuid)) {
                this.updateEntity(this.entities.get(uuid), data.entities[uuid]);
                continue;
            }

            Logger.addLog("INFO", "Registered new "+data.entities[uuid].type+": "+uuid)
            this.entities.set(uuid, data.entities[uuid]);

            let entity = data.entities[uuid];

            let innerHTML = `
            <div class="entity-data" id="${uuid}">`
            innerHTML+=`<div class="uuid"> >${uuid}</div>`

            for (let property in data.entities[uuid]) {
                if (property == "uuid")
                    continue;

                innerHTML += `<div class="${property}">${property}: ${isNaN(entity[property]) ? entity[property] : formNum(entity[property])}</div>`
            }

            innerHTML += `</div>`;

            this.entitiesDataItem.innerHTML += innerHTML
        }

        this.entitiesCountItem.innerHTML = `Entities: ${this.entities.size}`;

        this.entities.forEach(entity => {
            if (!data.entities[entity.uuid])
                this.deleteEntity(entity);
        })
    }

    updateEntity(oldData, newData) {
        let toChange = {};

        for (let property in newData) {
            if (oldData[property] != newData[property])
                toChange[property] = newData[property];
        }

        for (let property in toChange) {
            document.getElementById(oldData.uuid).getElementsByClassName(property)[0].innerHTML = property+": "+(isNaN(toChange[property]) ? toChange[property] : formNum(toChange[property]));
        }

        this.entities.set(oldData.uuid, newData);
    }

    deleteEntity(entity) {
        this.entities.delete(entity.uuid);
        document.getElementById(entity.uuid).remove();

        Logger.addLog("INFO", "Removed "+entity.type+": "+uuid)
    }
}

class LoggerClass {
    constructor({logger}) {
        this.logger = logger;

        this.logs = [];
    }

    drawLogs() {
        this.logger.innerHTML = ""

        this.logs.forEach((log, index) => {
            const LoggerHTML = `
                <li class="logItem" id="${index}">[${log.timestamp}] [${log.type}]: ${log.text}</li>
            `;

            this.logger.innerHTML += LoggerHTML;

            if (log.color)
                document.getElementById(index).style.backgroundColor = log.color;
        })
    }

    addLog(type, text, color) {
        const date = new Date;

        this.logs.unshift({
            timestamp: 
            `${date.getHours() < 10 ? "0"+date.getHours() : date.getHours()}:${date.getMinutes() < 10 ? "0"+date.getMinutes() : date.getMinutes()}:${date.getSeconds() < 10 ? "0"+date.getSeconds() : date.getSeconds()}`,
            type: type,
            text: text,
            color: color
        })

        if (this.logs.length > 40)
            this.removeLog(0);

        this.drawLogs();
    }

    removeLog(index) {
        this.logs.splice(index, 1);
        this.drawLogs();
    }
}

const MineBridge = new Bridge({
    name: "MineBridge",
    connectionItem: document.getElementById("minecraftConnection"),
    entitiesCountItem: document.getElementById("minecraftEntitiesCount"),
    upsCountItem: document.getElementById("minecraftUPS"),
    entitiesDataItem: document.getElementById("minecraftEntities"),
    timeConnectionItem: document.getElementById("minecraftTimeConnection")
})

const GmodBridge = new Bridge({
    name: "GmodBridge",
    connectionItem: document.getElementById("gmodConnection"),
    entitiesCountItem: document.getElementById("gmodEntitiesCount"),
    upsCountItem: document.getElementById("gmodUPS"),
    entitiesDataItem: document.getElementById("gmodEntities"),
    timeConnectionItem: document.getElementById("gmodTimeConnection")
})

const Logger = new LoggerClass({
    logger: document.getElementById("log")
})

let reconnectTryCounter = 0;

async function getData() {
    try {
        let response = await fetch("/updateGui");
        let json = await response.json();

        if (reconnectTryCounter > 0) {
            Logger.addLog("INFO", "Connection established.")
        }

        reconnectTryCounter = 0;

        return json;
    } catch(e) {
        Logger.addLog("ERROR", "Error to connect main server. Trying again...", "red")

        reconnectTryCounter++;

        return false;
    }
}


let ups = 60;
let intervalId = setInterval(update, 1000 / ups);

async function update() {
    let data = await getData();

    if (!data)
        return;

    GmodBridge.update(data.gmod);
    MineBridge.update(data.minecraft);
}

function formNum(num) {
    return Math.floor(num * 100) / 100;
}