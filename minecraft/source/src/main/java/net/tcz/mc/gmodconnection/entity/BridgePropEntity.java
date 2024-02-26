package net.tcz.mc.gmodconnection.entity;

import net.tcz.mc.gmodconnection.enums.BridgeEntityType;
import org.bukkit.*;
import org.bukkit.entity.Slime;

import java.util.HashMap;
import java.util.logging.Level;

public class BridgePropEntity extends BridgeEntity {
    public BridgePropEntity(World world, HashMap<String, Object> e) {
        super(world, BridgeEntityType.PROP, e, Sound.ENTITY_ARMOR_STAND_PLACE);
        respawnEffect = new Particle.DustOptions(Color.GREEN, 0.5f);

        if (entity instanceof Slime && e.get("size") != null) {
            int size = Integer.parseInt(e.get("size").toString());

            Bukkit.getLogger().log(Level.INFO,"created slime with size: " + size);
            ((Slime) entity).setSize(size);
        }
    }

    @Override
    public void update(HashMap<String, Object> bridgeData) {
        super.update(bridgeData);
    }
}