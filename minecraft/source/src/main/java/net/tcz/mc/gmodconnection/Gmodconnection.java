package net.tcz.mc.gmodconnection;

import net.tcz.mc.gmodconnection.bridge.BridgeController;
import net.tcz.mc.gmodconnection.bridge.BridgeRequests;
import net.tcz.mc.gmodconnection.handlers.BlockEventsHandler;
import net.tcz.mc.gmodconnection.handlers.EntityEventHandler;
import net.tcz.mc.gmodconnection.handlers.PlayerEventsHandler;
import org.bukkit.command.Command;
import org.bukkit.command.CommandExecutor;
import org.bukkit.command.CommandSender;
import org.bukkit.plugin.java.JavaPlugin;
import org.jetbrains.annotations.NotNull;
import org.json.simple.JSONObject;


public final class Gmodconnection extends JavaPlugin {

    private static Gmodconnection instance;

    @Override
    public void onEnable() {
        instance = this;
        saveDefaultConfig();

        getServer().getPluginManager().registerEvents(new PlayerEventsHandler(), this);
        getServer().getPluginManager().registerEvents(new EntityEventHandler(), this);
        getServer().getPluginManager().registerEvents(new BlockEventsHandler(), this);


        getCommand("bridge").setExecutor(new CommandExecutor() {
            @Override
            public boolean onCommand(@NotNull CommandSender sender, @NotNull Command command, @NotNull String label, @NotNull String[] args) {
                if (args.length < 1) {
                    sender.sendMessage("Not enough args: bridge (start/stop/clear-map)");
                    return false;
                }

                switch (args[0]) {
                    case "start": {
                        if (args.length < 2) {
                            sender.sendMessage("Not enough args: bridge start (code)");
                            return false;
                        }

                        SchedulersController.start(args[1], sender);
                        break;
                    }
                    case "stop": {
                        if (SchedulersController.isSync) {
                            BridgeRequests.disconnect();
                            SchedulersController.stop();
                            BridgeController.clear();
                        } else {
                            sender.sendMessage("[Bridge] You are not connected to any rooms.");
                        }
                        break;
                    }
                    case "clear-map": {
                        BridgeController.clearMap();
                        break;
                    }
                    default: {
                        sender.sendMessage("Command args is shit...");
                        return false;
                    }
                }
                return true;
            }
        });
    }

    public static Gmodconnection getInstance() {
        return instance;
    }
}
