class EventBus {
  static GMOD_SYNC = "gm_sync";
  static MINECRAFT_SYNC = "mс_sync";

  /**
   * Реализация вызова и подписки на ивенты
   */
  static _events = {};

  // Подписка на ивент с именем eventType (работает автоматически через поиск в папке events)
  static subscribe(eventType, event) {
    if (!this._events[eventType]) {
      this._events[eventType] = [];
    }

    this._events[eventType].push(event);
  }

  // Вызов всех функций подписанных на eventType
  static invoke(eventType, data) {
    if (!this._events[eventType]) {
      return;
    }

    data.bRunning = true;

    for (let i = 0; i < this._events[eventType].length; i++) {
      if (data.bRunning) {
        this._events[eventType][i].run(data);
      }
    }
  }

  static async asyncInvoke(eventType, data) {
    if (!this._events[eventType]) {
      return;
    }

    data.bRunning = true;

    for (let i = 0; i < this._events[eventType].length; i++) {
      if (data.bRunning) {
        await this._events[eventType][i].run(data);
      }
    }
  }

  static hasEvents(eventType) {
    return !!this._events[eventType];
  }
}

module.exports = EventBus;