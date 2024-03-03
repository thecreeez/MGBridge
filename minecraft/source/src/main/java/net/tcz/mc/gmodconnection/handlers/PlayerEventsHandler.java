package net.tcz.mc.gmodconnection.handlers;

import net.tcz.mc.gmodconnection.BridgeScheduler;
import net.tcz.mc.gmodconnection.SchedulersController;
import net.tcz.mc.gmodconnection.controllers.BridgeEntitiesController;
import net.tcz.mc.gmodconnection.entity.BridgeEntity;
import org.bukkit.Location;
import org.bukkit.Material;
import org.bukkit.Tag;
import org.bukkit.block.data.type.Switch;
import org.bukkit.entity.Player;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;
import org.bukkit.event.block.Action;
import org.bukkit.event.entity.EntityDamageEvent;
import org.bukkit.event.player.AsyncPlayerChatEvent;
import org.bukkit.event.player.PlayerInteractEvent;

import java.util.HashMap;
import java.util.Objects;

public class PlayerEventsHandler implements Listener {

    @EventHandler
    public void onPlayerInteract(PlayerInteractEvent event) {
        if (!SchedulersController.isSync)
            return;

        Player p = event.getPlayer();

        if (event.getAction() != Action.RIGHT_CLICK_BLOCK)
            return;

        if (event.getItem() != null && event.getItem().getType().equals(Material.WATER_BUCKET)) {
            HashMap<String, Object> eventParsed = new HashMap<>();

            Location l = Objects.requireNonNull(event.getClickedBlock()).getLocation();

            eventParsed.put("type", "PlayerPlaceWater");
            eventParsed.put("x", l.getX());
            eventParsed.put("y", l.getY());
            eventParsed.put("z", l.getZ());
            eventParsed.put("targetUuid", p.getUniqueId().toString());
            eventParsed.put("value", "");

            BridgeScheduler.getEvents().add(eventParsed);
        }

        if (event.getItem() != null && event.getItem().getType().equals(Material.BUCKET)) {
            HashMap<String, Object> eventParsed = new HashMap<>();

            Location l = Objects.requireNonNull(event.getClickedBlock()).getLocation();

            eventParsed.put("type", "PlayerRemoveWater");
            eventParsed.put("x", l.getX());
            eventParsed.put("y", l.getY());
            eventParsed.put("z", l.getZ());
            eventParsed.put("targetUuid", p.getUniqueId().toString());
            eventParsed.put("value", "");

            BridgeScheduler.getEvents().add(eventParsed);
        }

        // Нажатие кнопки
        if (Tag.BUTTONS.isTagged(Objects.requireNonNull(event.getClickedBlock()).getType())) {
            Switch data = (Switch) event.getClickedBlock().getBlockData();

            if (!data.isPowered()) {
                HashMap<String, Object> eventParsed = new HashMap<>();

                Location l = event.getClickedBlock().getLocation();

                eventParsed.put("type", "PlayerInteractButton");
                eventParsed.put("x", l.getX());
                eventParsed.put("y", l.getY());
                eventParsed.put("z", l.getZ());
                eventParsed.put("activator", p.getUniqueId().toString());
                eventParsed.put("value", "");

                BridgeScheduler.getEvents().add(eventParsed);
            }
        }
    }

    @EventHandler
    public void onHit(EntityDamageEvent event) {
        if (!SchedulersController.isSync)
            return;

        HashMap<String, Object> eventParsed = new HashMap<>();
        
        BridgeEntity entityHit = null;

        for (BridgeEntity value : BridgeEntitiesController.getEntities().values()) {
            if (value.getEntity().getUniqueId().equals(event.getEntity().getUniqueId()))
                entityHit = value;
        }

        if (entityHit == null)
            return;

        if (!entityHit.canTakeDamage()) {
            event.setCancelled(true);
            return;
        }

        if (event.getCause() == EntityDamageEvent.DamageCause.CRAMMING) {
            event.setCancelled(true);
            return;
        }

        if (event.getCause() == EntityDamageEvent.DamageCause.SUFFOCATION) {
            event.setCancelled(true);
            return;
        }

        eventParsed.put("type", "Damage");
        eventParsed.put("targetUuid", entityHit.getUuid());
        eventParsed.put("value", event.getFinalDamage());

        BridgeScheduler.getEvents().add(eventParsed);
    }

    @EventHandler
    public void onChatMessage(AsyncPlayerChatEvent e) {
        if (!SchedulersController.isSync)
            return;

        HashMap<String, Object> eventParsed = new HashMap<>();

        eventParsed.put("type", "ChatMessage");
        eventParsed.put("targetUuid", e.getPlayer().getUniqueId().toString());
        eventParsed.put("value", e.getMessage());

        BridgeScheduler.getEvents().add(eventParsed);
    }
}
