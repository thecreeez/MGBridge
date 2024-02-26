package net.tcz.mc.gmodconnection.events;

import net.tcz.mc.gmodconnection.Gmodconnection;
import net.tcz.mc.gmodconnection.controllers.BridgeEntitiesController;
import net.tcz.mc.gmodconnection.controllers.ColorController;
import net.tcz.mc.gmodconnection.effects.PhysGunEffect;
import net.tcz.mc.gmodconnection.entity.BridgeEntity;
import net.tcz.mc.gmodconnection.entity.BridgeHumanPlayerEntity;
import org.bukkit.*;
import org.bukkit.block.Block;
import org.bukkit.block.BlockState;
import org.bukkit.block.data.type.Switch;
import org.bukkit.entity.LivingEntity;
import org.bukkit.entity.Player;
import org.bukkit.inventory.ItemStack;
import org.json.simple.JSONObject;

import java.util.UUID;

public class BridgeEvents {

    private static long STONE_BUTTON_PRESS_DURATION = 60l;

    public static void handle(Object o) {
        JSONObject event = (JSONObject) o;

        switch (event.get("type").toString()) {
            case "func_button": {
                World world = Bukkit.getWorlds().get(0);

                int x = Integer.parseInt((String) event.get("x"));
                int y = Integer.parseInt((String) event.get("y"));
                int z = Integer.parseInt((String) event.get("z"));

                Block block = world.getBlockAt(x,y,z);
                BlockState state = block.getState();
                Switch data = (Switch) block.getBlockData();
                data.setPowered(true);
                state.setBlockData(data);
                state.update();

                world.playSound(block.getLocation(), Sound.BLOCK_STONE_BUTTON_CLICK_ON, 1F, 0.6F);



                Bukkit.getScheduler().runTaskLaterAsynchronously(Gmodconnection.getInstance(), new Runnable() {
                    @Override
                    public void run() {
                        Bukkit.getScheduler().runTask(Gmodconnection.getInstance(), new Runnable() {
                            @Override
                            public void run() {
                                data.setPowered(false);
                                state.setBlockData(data);
                                state.update();

                                world.playSound(block.getLocation(), Sound.BLOCK_STONE_BUTTON_CLICK_OFF, 1F, 0.6F);
                            }
                        });
                    }
                }, STONE_BUTTON_PRESS_DURATION);

                break;
            }

            case "Damage": {
                if (event.get("targetUuid").toString().startsWith("STEAM"))
                    return;

                Bukkit.getPlayer(UUID.fromString(event.get("targetUuid").toString())).damage(Double.parseDouble(event.get("value").toString()) * 0.2);
                break;
            }

            case "ChatMessage": {
                for (Player onlinePlayer : Bukkit.getOnlinePlayers()) {
                    onlinePlayer.sendMessage("<"+BridgeEntitiesController.getEntities().get(event.get("targetUuid").toString()).getName()+"> "+event.get("value").toString());
                }
                break;
            }

            case "Freeze": {
                Particle.DustOptions dustOptions = new Particle.DustOptions(ColorController.getColorFromData(event), 5f);
                PhysGunEffect.freezeEffect(BridgeEntitiesController.getEntities().get(event.get("targetUuid").toString()).getEntity().getLocation(), dustOptions);
                break;
            }

            case "Flashlight": {
                Particle.DustOptions dustOptions = new Particle.DustOptions(Color.WHITE, 5f);
                BridgeEntity target = BridgeEntitiesController.getEntities().get(event.get("targetUuid").toString());

                if (target.getEntity() instanceof LivingEntity && target instanceof BridgeHumanPlayerEntity) {
                    LivingEntity entity = (LivingEntity) target.getEntity();
                    BridgeHumanPlayerEntity targetPlayer = (BridgeHumanPlayerEntity) target;

                    Sound sound = Sound.BLOCK_LANTERN_PLACE;

                    if (event.get("value").toString().equals("false"))
                        sound = Sound.BLOCK_LANTERN_BREAK;

                    target.getEntity().getLocation().getWorld().playSound(target.getEntity().getLocation(), sound, 1f, (float) Math.random());

                    if (event.get("value").toString().equals("true")) {
                        target.getEntity().getLocation().getWorld().spawnParticle(Particle.REDSTONE, entity.getEyeLocation().add(entity.getEyeLocation().getDirection().normalize()), 1, dustOptions);

                        if (!entity.getEquipment().getItemInOffHand().getType().equals(Material.TORCH))
                            entity.getEquipment().setItemInOffHand(new ItemStack(Material.TORCH, 1));
                    } else {
                        if (entity.getEquipment().getItemInOffHand().getType().equals(Material.TORCH))
                            entity.getEquipment().setItemInOffHand(null);
                    }
                }
                break;
            }

            case "Explosion": {
                World world = Bukkit.getWorlds().get(0);

                Particle particle = Particle.EXPLOSION_HUGE;
                Location location = new Location(world, Float.parseFloat(event.get("x").toString()), Float.parseFloat(event.get("y").toString()), Float.parseFloat(event.get("z").toString()));

                System.out.println("Explosion event handled. pos: "+location.getX()+","+location.getY()+","+location.getZ());

                world.spawnParticle(particle, location, 5, 0.001, 0.001, 0.001);
                world.playSound(location, Sound.ENTITY_GENERIC_EXPLODE, 1f, (float) Math.random());
                break;
            }

            case "gmodBlockBreak": {
                World world = Bukkit.getWorlds().get(0);

                Block toBreak = world.getBlockAt(Integer.parseInt(event.get("x").toString()), Integer.parseInt(event.get("y").toString()), Integer.parseInt(event.get("z").toString()));

                if (toBreak == null)
                    return;

                world.spawnParticle(Particle.BLOCK_CRACK, Integer.parseInt(event.get("x").toString()) + 0.5, Integer.parseInt(event.get("y").toString()) + 0.5, Integer.parseInt(event.get("z").toString()) + 0.5, 20,  0.01, 0.01, 0.01, toBreak.getBlockData());

                Sound sound = toBreak.getBlockData().getSoundGroup().getBreakSound();
                world.playSound(toBreak.getLocation(), sound, 1, (float) Math.random());

                toBreak.setType(Material.AIR);
                break;
            }

            default: {
                System.out.println("cant handle unknown event: "+event.get("type").toString());
            }
        }
    }
}
