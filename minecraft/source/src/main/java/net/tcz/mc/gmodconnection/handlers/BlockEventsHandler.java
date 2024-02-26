package net.tcz.mc.gmodconnection.handlers;

import net.tcz.mc.gmodconnection.BridgeScheduler;
import net.tcz.mc.gmodconnection.SchedulersController;
import org.bukkit.Material;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;
import org.bukkit.event.block.BlockBreakEvent;
import org.bukkit.event.block.BlockPlaceEvent;

import java.util.HashMap;

public class BlockEventsHandler implements Listener {

    @EventHandler
    public void blockPlaceEvent(BlockPlaceEvent e) {
        if (!SchedulersController.isSync)
            return;

        HashMap<String, Object> eventParsed = new HashMap<>();

        eventParsed.put("type", "BlockPlace");
        eventParsed.put("targetUuid", e.getPlayer().getUniqueId().toString());
        eventParsed.put("id", e.getBlockPlaced().getType().getKey().toString());
        eventParsed.put("x", e.getBlockPlaced().getX());
        eventParsed.put("y", e.getBlockPlaced().getY());
        eventParsed.put("z", e.getBlockPlaced().getZ());

        BridgeScheduler.getEvents().add(eventParsed);

        if (e.getBlockAgainst().getType().equals(Material.WATER)) {
            HashMap<String, Object> eventWaterParsed = new HashMap<>();

            eventWaterParsed.put("type", "PlayerRemoveWater");
            eventWaterParsed.put("targetUuid", e.getPlayer().getUniqueId().toString());
            eventWaterParsed.put("id", e.getBlockPlaced().getType().getKey().toString());
            eventWaterParsed.put("x", e.getBlockPlaced().getX());
            eventWaterParsed.put("y", e.getBlockPlaced().getY());
            eventWaterParsed.put("z", e.getBlockPlaced().getZ());

            BridgeScheduler.getEvents().add(eventWaterParsed);
        }
    }

    @EventHandler
    public void blockBreakEvent(BlockBreakEvent e) {
        if (!SchedulersController.isSync)
            return;

        HashMap<String, Object> eventParsed = new HashMap<>();

        eventParsed.put("type", "BlockBreak");
        eventParsed.put("targetUuid", e.getPlayer().getUniqueId().toString());
        eventParsed.put("id", e.getBlock().getType().getKey().toString());
        eventParsed.put("x", e.getBlock().getX());
        eventParsed.put("y", e.getBlock().getY());
        eventParsed.put("z", e.getBlock().getZ());

        BridgeScheduler.getEvents().add(eventParsed);
    }
}