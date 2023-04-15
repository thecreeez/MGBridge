class Logger {
    constructor(module) {
        this.module = module;
    }

    log(type, message) {
        console.log(`[${this.module}] [${type}]: ${message}`);
    }
}

module.exports = Logger;