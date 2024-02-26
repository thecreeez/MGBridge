package net.tcz.mc.gmodconnection.controllers;

import net.tcz.mc.gmodconnection.Gmodconnection;
import net.tcz.mc.gmodconnection.effects.PhysGunEffect;
import net.tcz.mc.gmodconnection.entity.*;
import net.tcz.mc.gmodconnection.enums.BridgeEntityType;
import net.tcz.mc.gmodconnection.enums.BridgeProjectileType;
import org.bukkit.*;
import org.bukkit.entity.*;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;

public class BridgeEntitiesController {

    private static World world = Bukkit.getWorlds().get(0);
    private static Map<String, BridgeEntity> entities = new HashMap<>();

    public static void summonEntity(HashMap<String, Object> entity) {
        if (isExist((String) entity.get("uuid")))
            return;

        BridgeEntityType bridgeEntityType = BridgeEntityType.valueOf(entity.get("type").toString().toUpperCase());
        System.out.println(entity.get("type").toString().toUpperCase());

        if (bridgeEntityType == null) {
            Gmodconnection.getInstance().getLogger().log(Level.WARNING, "BridgeEntityType is not defined: "+entity.get("type").toString().toUpperCase());
            return;
        }

        BridgeEntitySummoner.summonEntity(bridgeEntityType, entity);
    }

    public static void updateEntity(HashMap<String, Object> entity) {
        BridgeEntity bridgeEntity = entities.get(entity.get("uuid"));

        bridgeEntity.update(entity);
    }

    public static void updateEntities(JSONArray serverEntities) {
        Object[] entitiesCache = Arrays.copyOf(entities.values().toArray(), entities.values().toArray().length);

        for (Object object : entitiesCache) {
            BridgeEntity bridgeEntity = (BridgeEntity) object;
            boolean isExistOnMain = false;

            for (Object serverEntity : serverEntities) {
                JSONObject serverEntityJSON = (JSONObject) serverEntity;

                if (serverEntityJSON.get("uuid").toString().equals(bridgeEntity.getUuid()))
                    isExistOnMain = true;
            }

            if (!isExistOnMain) {
                entities.remove(bridgeEntity.getUuid());

                if (bridgeEntity instanceof BridgeHumanPlayerEntity) {
                    BridgeHumanPlayerEntity player = (BridgeHumanPlayerEntity) bridgeEntity;
                    for (Player onlinePlayer : Bukkit.getOnlinePlayers()) {
                        onlinePlayer.sendMessage("[Bridge] "+bridgeEntity.getName()+" has left the game.");

                        Location location = bridgeEntity.getEntity().getLocation();
                        Location endLocation = new Location(location.getWorld(), location.getX(), location.getY() + 20, location.getZ());

                        location.getWorld().playSound(location, Sound.BLOCK_BEACON_DEACTIVATE, 0.5f, (float) Math.random());
                        PhysGunEffect.drawRay(location.getWorld(), location, endLocation, new Particle.DustOptions(player.getDustOptions().getColor(), 3f));
                    }
                }

                if (bridgeEntity.getEntity() instanceof Damageable) {
                    bridgeEntity.getEntity().teleport(new Location(bridgeEntity.getEntity().getWorld(), 0, -5000, 0));
                    ((Damageable) bridgeEntity.getEntity()).setHealth(0);
                } else {
                    System.out.println("ну я хз как это убивать...");
                }
            }
        }

        for (Entity entity : world.getEntities()) {
            if (entity.getScoreboardTags().contains("gmodEntitiesSync") && !isOnBridge(entity))
                if ((entity instanceof Damageable))
                    ((Damageable) entity).setHealth(0);
        }
    }

    public static void handleProjectile(HashMap<String, Object> entity) {
        BridgeProjectileType bridgeProjectileType = BridgeProjectileType.valueOf(entity.get("class").toString().toUpperCase());

        Location location = new Location(world,
                Float.parseFloat(entity.get("x").toString()),
                Float.parseFloat(entity.get("y").toString()),
                Float.parseFloat(entity.get("z").toString()));

        if (bridgeProjectileType.getDustOptions() == null)
            world.spawnParticle(bridgeProjectileType.getParticle(), location, 1);
        else
            world.spawnParticle(bridgeProjectileType.getParticle(), location, 1, bridgeProjectileType.getDustOptions());
    }

    public static boolean isOnBridge(Entity entity) {
        boolean isOnBridge = false;

        for (BridgeEntity entityCandidate : entities.values()) {
            if (entityCandidate.getEntity().equals(entity))
                isOnBridge = true;
        }

        return isOnBridge;
    }

    public static Map<String, BridgeEntity> getEntities() {
        return entities;
    }

    public static boolean isExist(String uuid) {
        return entities.containsKey(uuid);
    }
}
