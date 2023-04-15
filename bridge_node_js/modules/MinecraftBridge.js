const Logger = require("./Logger");
const Config = require('./ConfigManager');
const uuid = require('./Uuidv4');

const GMOD_POSITION_SCALING = Config.get().GmodUnitsPerBlock;

class MinecraftBridge {
    constructor() {
        this.logger = new Logger("MineBridge");
        this.data = {
            entities: new Map(),
            events: []
        };

        this.password = false;
        this.lastConnect = -1;

        this.upsC = 0;
        this.ups = 0;
        this.timeConnected = 0;
    }

    onPost(req, res) {
        if (this.password && this.password != req.body.password)
            return res.sendStatus(403)

        if (!req.body.entities) {
            this.logger.log("ERROR", "Post is empty: ",req.body);
            return res.sendStatus(400);
        }

        if (this.lastConnect == -1)
            this.logger.log("INFO", "Successfully connected!");

        this.lastConnect = 0;

        this.synchronize(req.body);

        this.upsC++;
    }

    onGet(req, res) {
        if (this.password && this.password != req.body.password)
            return res.sendStatus(403)

        const data = {
            entities: [],
            events: []
        };
    
    
       this.data.entities.forEach((entity) => {
            data.entities.push(entity);
        })

        this.data.events.forEach((event) => {
            switch (event.type) {
                case "PlayerInteractButton": {
                    const eventInLib = global.tcz.library.searchByPos(event.x, event.y, event.z);

                    if (!eventInLib)
                        return;

                    data.events.push({
                        index: eventInLib.value,
                        type: event.type
                    })

                    break;
                }

                default: {
                    data.events.push(event);
                }
            }

            
        })
    
    
        res.send(JSON.stringify(data));
        this.data.events.length = 0;
    }

    timeOut() {
        this.data.entities.clear();
        this.logger.log("ERROR", "Server timeout. Entities deleted!");
        this.lastConnect = -1;
        this.timeConnected = 0;
    }

    synchronize(data) {

        //Update with new data
        data.entities.forEach((entity) => {

            entity.x*=GMOD_POSITION_SCALING;
            entity.y*=GMOD_POSITION_SCALING;
            entity.z*=GMOD_POSITION_SCALING;

            let sizeBefore = this.data.entities.size;
            
            entity.isSitting = entity.isSitting ? "1" : "0";

            this.data.entities.set(entity.uuid, entity);

            if (this.data.entities.size > sizeBefore)
                this.onAddEntity(entity.uuid);
        })

        data.events.forEach((event) => {
            event.uuid = uuid();
            switch (event.type) {
                case "PlayerInteractButton": {
                    if (!global.tcz.library.searchByPos(event.x,event.y,event.z)) {
                        this.logger.log("WARN", "Event with undefined entity! pos: "+event.x+","+event.y+","+event.z);
                    } else {
                        this.logger.log("INFO", "New event registered: ["+event.type+"] Index: "+global.tcz.library.searchByPos(event.x,event.y,event.z).value);
                        this.data.events.push(event);
                    }
                    break;
                }

                case "Damage": {
                    this.logger.log("INFO", "Damage event registered. Damage: "+event.value+" Target: "+event.targetUuid);
                    this.data.events.push(event);
                    break;
                }

                case "ChatMessage": {
                    this.logger.log("INFO", "ChatMessage event registered. Invoker: "+event.targetUuid+", Message: "+event.value);
                    this.data.events.push(event);
                    break;
                }

                case "BlockPlace": {
                    this.logger.log("INFO", "BlockPlace event registered. Invoker: "+event.targetUuid);

                    this.data.events.push({
                        id: event.id,
                        type: event.type,
                        x: event.x * GMOD_POSITION_SCALING,
                        y: event.y * GMOD_POSITION_SCALING,
                        z: event.z * GMOD_POSITION_SCALING,
                        targetUuid: event.targetUuid
                    });
                    break;
                }

                case "BlockBreak": {
                    this.logger.log("INFO", "BlockBreak event registered. Invoker: "+event.targetUuid);

                    this.data.events.push({
                        type: event.type,
                        x: event.x * GMOD_POSITION_SCALING,
                        y: event.y * GMOD_POSITION_SCALING,
                        z: event.z * GMOD_POSITION_SCALING,
                        targetUuid: event.targetUuid
                    });
                    break;
                }


                default: {
                    this.logger.log("ERROR", "Trying to add undefined event: "+event.type);
                    this.data.events.push(event);
                    break;
                }
            }
            
        })

        //Deleting who doesnt exist on minecraft server
        this.data.entities.forEach((bridgeEntity) => {
            let isExistOnMinecraftServer = false;
    
            data.entities.forEach((minecraftEntity) => {
                if (bridgeEntity.uuid == minecraftEntity.uuid)
                    isExistOnMinecraftServer = true;
            })
    
            if (!isExistOnMinecraftServer) {
                this.data.entities.delete(bridgeEntity.uuid);
                this.onRemoveEntity(bridgeEntity);
            }
        })
    }
    
    getEvents() {
        const BUTTONS_LIBRARY = global.tcz.library;
    }

    onAddEntity(entityUUID) {
        this.logger.log("INFO", "Added new entity: "+this.data.entities.get(entityUUID).name);
    }

    onRemoveEntity(entity) {
        this.logger.log("INFO", "Removed entity: "+entity.name);
    }

    onServerConnected(server) {

    }

    onServerDisconnected(server) {

    }

    setPassword(password) {
        this.password = password;
        this.logger.log("INFO", "Password is changed to: "+password);
    }
}

module.exports = new MinecraftBridge();