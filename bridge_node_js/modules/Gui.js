const MinecraftBridge = require("./MinecraftBridge");
const GmodBridge = require("./GmodBridge");

class GUI {
    constructor() {
        this.x = 0;
    }

    update(req,res) {
        res.json({
            minecraft: {
                entities: Object.fromEntries(MinecraftBridge.data.entities),
                events: MinecraftBridge.data.events,
                lastConnect: MinecraftBridge.lastConnect,
                ups: MinecraftBridge.ups,
                timeConnection: MinecraftBridge.timeConnected
            },
            gmod: {
                entities: Object.fromEntries(GmodBridge.data.entities),
                events: GmodBridge.data.events,
                lastConnect: GmodBridge.lastConnect,
                ups: GmodBridge.ups,
                timeConnection: GmodBridge.timeConnected
            }
        });
    }
}

module.exports = new GUI();