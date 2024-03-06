
# MGBridge

Играй с друзьями в Minecraft и Gmod одновременно.
* Спасибо [TheRealDGrew](https://dgrew.ru) за общий мост.

## Usage/Examples

Чтобы начать играть необязательно устанавливать свой мост, достаточно подключиться командой к изначально установленному в конфиге, в случае с майнкрафтом команды следующие:
- /bridge create [Тикрейт (1-20)] [коэффициент координат (64 по умолчанию)] - Создает комнату
- /bridge start [CODE] - Подключается к комнате
- /bridge stop - Отключает от комнаты
- /bridge clear-map - Очищает карту от созданной ранее gmod-карты

В случае с гмодом (в чате):
- /bridge start [CODE] - Подключиться к комнате
- /bridge stop - Отключает от комнаты
- /bridge help - Вывод существующих команд

Если вы хотите логи в виде текстовых файлов (они доступны только если комната находится в режиме отладки, её можно переключить только в коде моста), нужно создать комнату в файле index.js в функции start:

```javascript
async function start() {
    ...
    // Create room here
    new Room(application.RoomController, { bDebug: true, ... })
}
```
## Installation

### Minecraft
Для установки потребуется Minecraft 1.18.2 сервер на bukkit-подобном ядре (тестировался только purple). Установить [плагин](https://github.com/thecreeez/MGBridge/tree/main/minecraft/server).

При желании на клиентскую часть можно установить Optifine и специальный [ресурс-пак](https://github.com/thecreeez/MGBridge/tree/main/minecraft/client).

Исходный код плагина находится [тут](https://github.com/thecreeez/MGBridge/tree/main/minecraft/source)

### Garry's Mod
Для установки потребуется перенести [файлы](https://github.com/thecreeez/MGBridge/tree/dev%23version2/gmod) в корневую папку игры (Требуется установить только хосту).

### Свой мост
При желании можно развернуть свой мост (Если в данный момент наш недоступен/по любой другой причине). Для этого необходимо иметь [Node.js](https://nodejs.org/en) актуальной версии (Протестирована 16.14.2). Файлы моста находятся [тут](https://github.com/thecreeez/MGBridge/tree/main/bridge).
## Authors

- [@thecreeez](https://github.com/thecreeez) - Bridge/Minecraft side
- [@ScientificWays](https://github.com/ScientificWays) - Gmod side
