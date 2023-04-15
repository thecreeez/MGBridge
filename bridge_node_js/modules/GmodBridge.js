const Logger = require("./Logger");
const Config = require('./ConfigManager');
const uuid = require('./Uuidv4');

const MINECRAFT_POSITION_SCALING = 1 / Config.get().GmodUnitsPerBlock;

const GMOD_ENTITIES = {
    BUTTON: "func_button"
}

class GmodBridge {
    constructor() {
        this.logger = new Logger("GmodBridge");
        this.data = {
            entities: new Map(),
            events: []
        };

        this.password = false;
        this.lastConnect = -1;

        this.timesDataGet = 0;

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

    onPostEntities(req, res) {
        if (this.password && this.password != req.body.password)
            return res.sendStatus(403);

        if (!req.body)
            return res.sendStatus(402);

        global.tcz.library.clear();

        req.body.forEach((entity) => {
            console.log(entity);
            switch (entity.class) {
                case GMOD_ENTITIES.BUTTON: global.tcz.library.add(entity.index, entity.class, convertPosToMinecraft({x: entity.x, y: entity.y, z: entity.z})); break;
            }
        })

        return res.sendStatus(200);
    }

    onGet(req, res) {
        if (this.password && this.password != req.body.password)
            return res.sendStatus(403)

        this.timesDataGet++;

        const data = {
            entities: [],
            events: [],
            timesGet: this.timesDataGet
        };
    
        this.data.entities.forEach((entity) => {
            data.entities.push(entity);
        })

        
        this.data.events.forEach((event) => {
            switch (event.type) {
                case "Use": {
                    const eventInLib = global.tcz.library.searchByIndex(event.index);

                    if (!eventInLib)
                        return;

                    const pos = eventInLib.value.split("//");

                    data.events.push({
                        x: pos[0],
                        y: pos[1],
                        z: pos[2],
                        type: eventInLib.entityClass
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
            entity.x*=MINECRAFT_POSITION_SCALING;
            entity.y*=MINECRAFT_POSITION_SCALING;
            entity.z*=MINECRAFT_POSITION_SCALING;

            if (entity.height)
                entity.size = Math.ceil(entity.height * MINECRAFT_POSITION_SCALING * 2); // 2 надо подменить под что-то подходящее под слайма

            let sizeBefore = this.data.entities.size;

            this.data.entities.set(entity.uuid, entity);

            if (this.data.entities.size > sizeBefore)
                this.onAddEntity(entity.uuid);
        })

        data.events.forEach((event) => {
            event.uuid = uuid();
            switch (event.type) {
                case "Use": {
                    if (!global.tcz.library.searchByIndex(event.index)) {
                        this.logger.log("WARN", "Event with undefined entity! index: "+event.index);
                    } else {
                        this.logger.log("INFO", "New event registered: ["+event.type+"] Index: "+event.index);
                        this.data.events.push(event);
                    }
                    break;
                }

                case "Explosion": {
                    event.x *= MINECRAFT_POSITION_SCALING;
                    event.y *= MINECRAFT_POSITION_SCALING;
                    event.z *= MINECRAFT_POSITION_SCALING;

                    this.logger.log("INFO", "New event registered: ["+event.type+"] Pos:["+event.x+","+event.y+","+event.z+"]");
                    this.data.events.push(event);
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

                case "Freeze": {
                    this.logger.log("INFO", "Freeze event registered. Invoker: "+event.targetUuid+", Color: "+event.color_r+","+event.color_g+","+event.color_b);
                    this.data.events.push(event);
                    break;
                }

                case "gmodBlockBreak": {
                    event.x *= MINECRAFT_POSITION_SCALING;
                    event.y *= MINECRAFT_POSITION_SCALING;
                    event.z *= MINECRAFT_POSITION_SCALING;

                    this.logger.log("INFO", "New event registered: ["+event.type+"] Pos:["+event.x+","+event.y+","+event.z+"]");
                    this.data.events.push(event);

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

    onAddEntity(entityUUID) {
        this.logger.log("INFO", "Added new entity: "+this.data.entities.get(entityUUID).name);
        console.log(this.data.entities.get(entityUUID));
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

function convertPosToMinecraft({x, y, z}) {
    return {
        x: Math.ceil(x * MINECRAFT_POSITION_SCALING),
        y: Math.floor(y * MINECRAFT_POSITION_SCALING),
        z: Math.floor(z * MINECRAFT_POSITION_SCALING)
    }
}

module.exports = new GmodBridge();