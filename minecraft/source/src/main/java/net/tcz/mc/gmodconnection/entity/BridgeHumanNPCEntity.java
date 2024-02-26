package net.tcz.mc.gmodconnection.entity;

import net.tcz.mc.gmodconnection.enums.BridgeEntityType;
import org.bukkit.Sound;
import org.bukkit.World;
import org.bukkit.entity.LivingEntity;

import java.util.HashMap;

public class BridgeHumanNPCEntity extends BridgeHumanEntity {
    public BridgeHumanNPCEntity(World world, HashMap<String, Object> e) {
        super(world, BridgeEntityType.NPC, e, Sound.ENTITY_SKELETON_STEP);
    }

    @Override
    public void update(HashMap<String, Object> bridgeData) {
        super.update(bridgeData);

        updateName(bridgeData);
    }

    protected void updateName(HashMap<String, Object> bridgeData) {
        LivingEntity entity = (LivingEntity) this.entity;

        entity.setCustomName(bridgeData.get("class").toString()+" "+entity.getHealth());
    }
}
