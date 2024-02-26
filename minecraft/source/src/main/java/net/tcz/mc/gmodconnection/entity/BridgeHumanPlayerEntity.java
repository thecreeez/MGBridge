package net.tcz.mc.gmodconnection.entity;

import net.md_5.bungee.api.ChatColor;
import net.md_5.bungee.api.chat.BaseComponent;
import net.md_5.bungee.api.chat.ComponentBuilder;
import net.md_5.bungee.api.chat.TextComponent;
import net.md_5.bungee.chat.ComponentSerializer;
import net.tcz.mc.gmodconnection.controllers.BridgeEntitiesController;
import net.tcz.mc.gmodconnection.controllers.ColorController;
import net.tcz.mc.gmodconnection.effects.PhysGunEffect;
import net.tcz.mc.gmodconnection.enums.BridgeEntityType;
import net.tcz.mc.gmodconnection.enums.BridgeItemType;
import org.bukkit.*;
import org.bukkit.Color;
import org.bukkit.block.Block;
import org.bukkit.entity.Item;
import org.bukkit.entity.LivingEntity;
import org.bukkit.entity.Player;
import org.bukkit.inventory.ItemStack;
import org.bukkit.inventory.meta.ItemMeta;

import java.awt.*;
import java.util.ArrayList;
import java.util.HashMap;

public class BridgeHumanPlayerEntity extends BridgeHumanEntity {

    private boolean driving = false;
    private BridgeItemType handItem;
    private String name = null;

    private float pitch;
    private float yaw;

    private Particle.DustOptions dustOptions;

    public BridgeHumanPlayerEntity(World world, HashMap<String, Object> e) {
        super(world, BridgeEntityType.PLAYER, e, Sound.BLOCK_BEACON_ACTIVATE);

        this.dustOptions = new Particle.DustOptions(ColorController.getColorFromData(e), 0.5f);
        this.name = e.get("name").toString();

        this.pitch = 0;
        this.yaw = 0;

        respawnEffect = new Particle.DustOptions(dustOptions.getColor(), 2f);

        for (Player onlinePlayer : Bukkit.getOnlinePlayers()) {
            onlinePlayer.sendMessage("[Bridge] "+e.get("name").toString()+" joined the game.");
        }
    }

    /**
     * TODO: REFACTOR THIS SHIT))
     * @param bridgeData
     */
    @Override
    public void update(HashMap<String, Object> bridgeData) {
        updateRotation(bridgeData);
        updateColor(bridgeData);
        updateName(bridgeData);

        LivingEntity entity = (LivingEntity) this.entity;

        double damage = Math.floor(entity.getHealth() * 100) / 100 - Math.floor(Double.parseDouble(bridgeData.get("health").toString()) * 0.2 * 100) / 100;
        if (damage > 0)
            entity.damage(damage);

        if (entity.isDead() && bridgeData.get("isAlive").toString().equals("true"))
            respawnEntity();

        if (!driving) {
            updatePosition(bridgeData);
        } else {
            this.yaw = Float.parseFloat(bridgeData.get("yaw").toString()) - 90;
            this.pitch = Float.parseFloat(bridgeData.get("pitch").toString());
        }

        if (!driving && (handItem == null || !bridgeData.get("hand").toString().equals(handItem.getBridgeName())))
            setHandItem(bridgeData.get("hand").toString());

        if (driving) {
            if (entity.getEquipment().getItemInMainHand().getType() != Material.AIR) {
                entity.getEquipment().setItemInMainHand(null);
                handItem = null;
            }
            return;
        }

        if (handItem == null)
            return;

        if (Boolean.parseBoolean(bridgeData.get("isUsing").toString())) {
            switch (handItem) {
                case PHYS_GUN: {
                    if (bridgeData.get("target").toString().length() > 0) {
                        PhysGunEffect.drawRay(entity, BridgeEntitiesController.getEntities().get(bridgeData.get("target").toString()).getEntity(), this.dustOptions);
                    } else {
                        PhysGunEffect.drawRay(entity, this.dustOptions);
                    }

                }
            }
        }
    }

    public boolean isDriving() {
        return driving;
    }

    public void setDriving(boolean driving) {
        this.driving = driving;
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

    private void updateColor(HashMap<String, Object> bridgeData) {
        Particle.DustOptions dustOptions = new Particle.DustOptions(ColorController.getColorFromData(bridgeData), 0.5f);

        if (!this.dustOptions.getColor().equals(dustOptions.getColor()))
            this.dustOptions = dustOptions;
    }

    private void updateName(HashMap<String, Object> bridgeData) {
        LivingEntity entity = (LivingEntity) this.entity;

        /*
        TextComponent textComponent = new TextComponent();
        textComponent.setColor(ChatColor.of(String.valueOf(this.dustOptions.getColor())));*/

        entity.setCustomName(bridgeData.get("name").toString()+" "+(Math.floor(entity.getHealth() * 100) / 100));
    }

    @Override
    public String getName() {
        return name;
    }

    @Override
    protected void updatePosition(HashMap<String, Object> bridgeData) {
        super.updatePosition(bridgeData);

        this.yaw = Float.parseFloat(bridgeData.get("yaw").toString()) - 90;
        this.pitch = Float.parseFloat(bridgeData.get("pitch").toString());
    }

    public float getPitch() {
        return pitch;
    }

    public float getYaw() {
        return yaw;
    }

    public Particle.DustOptions getDustOptions() {
        return dustOptions;
    }
}