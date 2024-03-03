package net.tcz.mc.gmodconnection.handlers;

import io.papermc.paper.event.entity.EntityMoveEvent;
import org.bukkit.entity.Entity;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;
import org.bukkit.event.entity.EntityDamageByEntityEvent;
import org.bukkit.event.entity.EntityDamageEvent;
import org.bukkit.event.entity.SlimeSplitEvent;

public class EntityEventHandler implements Listener {

    @EventHandler
    public void entityMoveEvent(EntityMoveEvent e) {
        if (e.getEntity().getScoreboardTags().contains("gmodEntitiesSync"))
            e.setCancelled(true);
    }

    @EventHandler
    public void onHit(EntityDamageByEntityEvent e) {
        if (e.getDamager().getScoreboardTags().contains("gmodEntitiesSync"))
            e.setCancelled(true);
    }

    @EventHandler
    public void slimeSplit(SlimeSplitEvent e) {
        if (e.getEntity().getScoreboardTags().contains("gmodEntitiesSync"))
            e.setCancelled(true);
    }
}
