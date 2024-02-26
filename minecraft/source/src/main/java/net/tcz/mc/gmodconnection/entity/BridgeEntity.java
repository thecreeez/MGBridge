package net.tcz.mc.gmodconnection.entity;

import net.tcz.mc.gmodconnection.controllers.BridgeEntitiesController;
import net.tcz.mc.gmodconnection.effects.PhysGunEffect;
import net.tcz.mc.gmodconnection.enums.BridgeEntityType;
import org.bukkit.*;
import org.bukkit.entity.Entity;
import org.bukkit.entity.LivingEntity;

import java.util.HashMap;
import java.util.logging.Level;

public class BridgeEntity {

    protected Entity entity;
    protected BridgeEntityType type;
    protected String uuid;
    protected boolean canTakeDamage = false;

    protected Particle.DustOptions respawnEffect = new Particle.DustOptions(Color.WHITE, 1f);
    protected Sound respawnSound = Sound.ENTITY_ARMOR_STAND_PLACE;

    public BridgeEntity(World world, BridgeEntityType type, HashMap<String, Object> e, Sound sound) {
        Location location = new Location(world, Double.parseDouble(e.get("x").toString()),Double.parseDouble(e.get("y").toString()),Double.parseDouble(e.get("z").toString()));
        location.setPitch(Float.parseFloat(e.get("pitch").toString()));
        location.setYaw(Float.parseFloat(e.get("yaw").toString()));

        Entity entity = world.spawnEntity(location, type.getEntityType());

        entity.addScoreboardTag("gmodEntitiesSync");
        entity.setSilent(true);


        if (entity instanceof LivingEntity)
            ((LivingEntity) entity).setRemoveWhenFarAway(false);

        this.entity = entity;
        this.type = type;
        this.uuid = e.get("uuid").toString();

        if (e.get("name") != null) {
            this.entity.setCustomName(e.get("name").toString());
            this.entity.setCustomNameVisible(true);
        }

        BridgeEntitiesController.getEntities().put(uuid, this);
        Bukkit.getLogger().log(Level.INFO, "Bridge entity "+e.get("uuid").toString()+" summoned. Type: "+type.toString());

        respawnSound = sound;
        renderSpawnEffect();
    }

    public void renderSpawnEffect() {
        Location location = this.entity.getLocation();
        Location endLocation = new Location(location.getWorld(), location.getX(), location.getY() + 20, location.getZ());

        location.getWorld().playSound(location, respawnSound, 0.5f, (float) Math.random());
        PhysGunEffect.drawRay(location.getWorld(), location, endLocation, respawnEffect);
    }

    public void update(HashMap<String, Object> e) {
        updateRotation(e);
        updatePosition(e);
    }

    protected void updatePosition(HashMap<String, Object> bridgeData) {
        double x = Double.parseDouble(bridgeData.get("x").toString());
        double y = Double.parseDouble(bridgeData.get("y").toString());
        double z = Double.parseDouble(bridgeData.get("z").toString());

        float yaw = Float.parseFloat(bridgeData.get("yaw").toString()) - 90;
        float pitch = Float.parseFloat(bridgeData.get("pitch").toString());

        entity.teleport(new Location(entity.getWorld(), x, y ,z , yaw, pitch));
    }

    protected void updateRotation(HashMap<String, Object> bridgeData) {

    }

    public Entity getEntity() {
        return entity;
    }

    public String getUuid() {
        return uuid;
    }

    public boolean canTakeDamage() {
        return canTakeDamage;
    }

    public String getName() {
        return this.uuid;
    }

    protected void respawnEntity() {
        Entity newEntity = entity.getWorld().spawnEntity(entity.getLocation(), entity.getType());

        newEntity.addScoreboardTag("gmodEntitiesSync");
        newEntity.setSilent(true);


        if (newEntity instanceof LivingEntity)
            ((LivingEntity) newEntity).setRemoveWhenFarAway(false);

        this.entity = newEntity;

        this.entity.setCustomName(this.getName());
        this.entity.setCustomNameVisible(true);

        BridgeEntitiesController.getEntities().put(uuid, this);
        Bukkit.getLogger().log(Level.INFO, "Bridge entity "+this.uuid+" respawned.");
    }
}
