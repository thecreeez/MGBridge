const fs = require('fs');
const { exit } = require('process');

class ConfigManager {
    constructor() {
        this.path = "./config.json";

        this.data = null;
    }

    read() {
        try {
            let rawdata = fs.readFileSync(this.path);
            let data = JSON.parse(rawdata);

            console.log("Config loaded. version: "+data.version+". GmodUnitsPerBlock: "+data.GmodUnitsPerBlock);
            return data;
        } catch(e) {
            console.log("Config loaded with errors: ",e);

            return false;
        }
    }

    setProperty(property, value) {
        console.log("Мне влом щас реализовывать сори...");
    }

    get() {
        if (!this.data) {
            const data = this.read();

            if (data)
                this.data = data;
            else
                exit(1);
        }

        return this.data;
    }
}

module.exports = new ConfigManager();