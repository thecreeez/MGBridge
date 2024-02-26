package net.tcz.mc.gmodconnection.entity;

import net.tcz.mc.gmodconnection.controllers.BridgeEntitiesController;
import net.tcz.mc.gmodconnection.effects.PhysGunEffect;
import net.tcz.mc.gmodconnection.enums.BridgeEntityType;
import net.tcz.mc.gmodconnection.enums.BridgeItemType;
import org.bukkit.*;
import org.bukkit.entity.LivingEntity;
import org.bukkit.inventory.ItemStack;
import org.bukkit.inventory.meta.ItemMeta;

import java.util.HashMap;

public class BridgeHumanEntity extends BridgeEntity {

    private BridgeItemType handItem;

    public BridgeHumanEntity(World world, BridgeEntityType type, HashMap<String, Object> e, Sound sound) {
        super(world, type, e, sound);


        this.canTakeDamage = true;
        respawnEffect = new Particle.DustOptions(Color.BLUE, 2f);
    }

    @Override
    public void update(HashMap<String, Object> bridgeData) {
        updateRotation(bridgeData);
        updatePosition(bridgeData);

        LivingEntity entity = (LivingEntity) this.entity;

        double damage = entity.getHealth() - Double.parseDouble(bridgeData.get("health").toString()) * 0.2;
        if (damage > 0)
            entity.damage(damage);

        if (handItem == null || !bridgeData.get("hand").toString().equals(handItem.getBridgeName()))
            setHandItem(bridgeData.get("hand").toString());

        if (handItem == null)
            return;
    }

    private void updateName(HashMap<String, Object> bridgeData) {
        LivingEntity entity = (LivingEntity) this.entity;

        entity.setCustomName(bridgeData.get("uuid").toString());
    }

    private void setHandItem(String bridgeName) {
        BridgeItemType[] bridgeItemTypes = BridgeItemType.values();
        BridgeItemType newHandItem = null;

        LivingEntity entity = (LivingEntity) this.entity;

        for (int i = 0; i < bridgeItemTypes.length; i++) {
            if (bridgeItemTypes[i].getBridgeName().equals(bridgeName))
                newHandItem = bridgeItemTypes[i];
        }

        if (newHandItem == null) {
            handItem = null;
            entity.getEquipment().setItemInMainHand(new ItemStack(Material.AIR, 1));
            return;
        }

        handItem = newHandItem;

        ItemStack itemStack = new ItemStack(newHandItem.getItem(), 1);
        ItemMeta itemMeta = itemStack.getItemMeta();
        itemMeta.setCustomModelData(newHandItem.getCustomModelData());
        itemStack.setItemMeta(itemMeta);
        entity.getEquipment().setItemInMainHand(itemStack);
    }
}
