const express = require("express");
const app = express();

const bodyParser = require('body-parser');

const MinecraftBridge = require("./modules/MinecraftBridge");
const GmodBridge = require("./modules/GmodBridge");
const GUI = require("./modules/Gui");

const DEFAULT_TIMEOUT = 5000;

global.tcz = {};
global.tcz.library = {
    buttonIndexMap: {},
    buttonPosMap: {},

    searchByIndex(index) {
        return this.buttonIndexMap[index];
    },

    searchByPos(x, y ,z) {
        return this.buttonPosMap[x+"//"+y+"//"+z];
    },

    add(index, entityClass, {x, y, z}) {
        console.log("Добавлен новый Entity в библиотеку: "+index);
        this.buttonIndexMap[index] = {value: x+"//"+y+"//"+z, entityClass: entityClass};
        this.buttonPosMap[x+"//"+y+"//"+z] = {value: index, entityClass: entityClass};
    },
    
    clear() {
        console.log("Библиотека очищена")
        this.buttonIndexMap = {};
        this.buttonPosMap = {};
    }
};

const port = 1820

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static("public"))


app.use('/static', express.static("public"))
app.get("/updateGui", (req,res) => {GUI.update(req, res)})

app.post("/postMinecraftData", (req,res) => {MinecraftBridge.onPost(req,res); res.sendStatus(200)})
app.get("/getMinecraftData", (req,res) => MinecraftBridge.onGet(req,res))

app.post("/postGmodEntities", (req,res) => {GmodBridge.onPostEntities(req, res)})
app.get("/getGmodEntities", (req,res) => {res.send(JSON.stringify(global.tcz.library.buttonIndexMap))})

app.post("/postGmodData", (req,res) => {GmodBridge.onPost(req,res); MinecraftBridge.onGet(req,res)})
app.get("/getGmodData", (req,res) => GmodBridge.onGet(req, res))

app.listen(port, () => {
    console.log("Bridge opened on port "+port);
})

setInterval(update, 1000)

function update() {
    if (MinecraftBridge.lastConnect > DEFAULT_TIMEOUT)
        MinecraftBridge.timeOut();

    if (MinecraftBridge.lastConnect != -1) {
        MinecraftBridge.lastConnect+=1000;
        MinecraftBridge.timeConnected++;
    }

    MinecraftBridge.ups = MinecraftBridge.upsC;
    MinecraftBridge.upsC = 0;

    if (GmodBridge.lastConnect > DEFAULT_TIMEOUT)
        GmodBridge.timeOut();

    if (GmodBridge.lastConnect != -1) {
        GmodBridge.lastConnect+=1000;
        GmodBridge.timeConnected++;
    }

    GmodBridge.ups = GmodBridge.upsC;
    GmodBridge.upsC = 0;
}