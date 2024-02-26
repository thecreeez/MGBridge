package net.tcz.mc.gmodconnection;

import net.tcz.mc.gmodconnection.bridge.BridgeRequests;
import org.bukkit.Bukkit;
import org.bukkit.Material;
import org.bukkit.entity.Entity;
import org.bukkit.entity.Player;
import org.bukkit.entity.Projectile;
import org.bukkit.plugin.java.JavaPlugin;
import org.bukkit.scheduler.BukkitRunnable;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class BridgeScheduler extends BukkitRunnable {

    private final JavaPlugin plugin;
    private static List<HashMap<String, Object>> events = new ArrayList<>();

    public BridgeScheduler(JavaPlugin plugin) {
        this.plugin = plugin;
    }

    @Override
    public void run() {
        List<Player> players = (List<Player>) Bukkit.getOnlinePlayers();

        List<HashMap<String, Object>> entityDataList = new ArrayList<>();

        for (Player p : players) {
            HashMap<String, Object> entityData = new HashMap<>();

            entityData.put("name", p.getName());

            entityData.put("x", p.getLocation().getX());
            entityData.put("y", p.getLocation().getY());
            entityData.put("z", p.getLocation().getZ());

            entityData.put("health", p.getHealth());

            entityData.put("uuid", p.getUniqueId().toString());

            entityData.put("pitch", p.getLocation().getPitch());
            entityData.put("yaw", p.getLocation().getYaw());

            entityData.put("isAlive", !p.isDead());
            entityData.put("isSitting", p.isSneaking());
            entityData.put("hand", p.getInventory().getItemInMainHand().getType().getKey().asString());

            boolean isUsingFlashlight = false;

            if (p.getInventory().getItemInOffHand().getType().equals(Material.TORCH))
                isUsingFlashlight = true;

            entityData.put("bFlashlight", isUsingFlashlight);

            entityData.put("type", "Player");

            entityDataList.add(entityData);
        }

        List<Entity> projectiles = Bukkit.getWorlds().get(0).getEntities();

        for (Entity projectile : projectiles) {
            if (projectile instanceof Projectile) {
                HashMap<String, Object> entityData = new HashMap<>();

                Projectile entity = (Projectile) projectile;

                entityData.put("name", entity.getName());

                entityData.put("x", entity.getLocation().getX());
                entityData.put("y", entity.getLocation().getY());
                entityData.put("z", entity.getLocation().getZ());

                entityData.put("uuid", entity.getUniqueId().toString());

                entityData.put("pitch", entity.getLocation().getPitch());
                entityData.put("yaw", entity.getLocation().getYaw());

                entityData.put("type", "Projectile");
                entityData.put("class", entity.getName());

                entityDataList.add(entityData);
            }
        }

        BridgeRequests.update(entityDataList, events);
    }

    public static List<HashMap<String, Object>> getEvents() {
        return events;
    }

    public static void setEvents(List<HashMap<String, Object>> events) {
        BridgeScheduler.events = events;
    }
}
