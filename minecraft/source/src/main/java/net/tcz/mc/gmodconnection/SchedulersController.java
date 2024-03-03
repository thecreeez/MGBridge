package net.tcz.mc.gmodconnection;

import net.tcz.mc.gmodconnection.bridge.BridgeController;
import net.tcz.mc.gmodconnection.bridge.BridgeRequests;
import org.bukkit.ChatColor;
import org.bukkit.Color;
import org.bukkit.command.CommandSender;
import org.bukkit.scheduler.BukkitTask;

import java.io.IOException;
import java.util.logging.Level;

public class SchedulersController {

    private static BukkitTask syncTask = null;
    public static boolean isSync = false;

    public static void start(String code, CommandSender sender) {
        if (syncTask != null && !syncTask.isCancelled())
            syncTask.cancel();

        boolean bServiceAvailable = BridgeRequests.ping();

        if (!bServiceAvailable) {
            sender.sendMessage(ChatColor.RED+"[Bridge] Oops... seems like i can't connect to main server.");
            return;
        }

        boolean handshakeSuccess = BridgeRequests.handshake(code, sender);

        if (handshakeSuccess) {
            syncTask = new BridgeScheduler(Gmodconnection.getInstance()).runTaskTimer(Gmodconnection.getInstance(), 20l, 20l / BridgeController.maxTPS);
            isSync = true;
        }
    }

    public static void stop() {
        if (syncTask != null && !syncTask.isCancelled())
            syncTask.cancel();

        if (BridgeController.sender != null)
            BridgeController.sender.sendMessage("[Bridge] Connection to room now closed.");
        Gmodconnection.getInstance().getLogger().log(Level.INFO, "Update task is canceled...");
        isSync = false;
    }
}