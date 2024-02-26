package net.tcz.mc.gmodconnection.bridge;

import net.md_5.bungee.api.ChatColor;
import net.md_5.bungee.api.ChatMessageType;
import net.md_5.bungee.api.chat.BaseComponent;
import net.md_5.bungee.api.chat.ComponentBuilder;
import net.md_5.bungee.api.chat.TextComponent;
import net.tcz.mc.gmodconnection.controllers.BridgeEntitiesController;
import net.tcz.mc.gmodconnection.effects.PhysGunEffect;
import net.tcz.mc.gmodconnection.events.BridgeEvents;
import org.bukkit.*;
import org.bukkit.block.Block;
import org.bukkit.command.CommandSender;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;

public class BridgeController {
    public static String token = null;
    public static String code = null;
    public static int maxTPS = 0;
    public static boolean allowedGeneratingMap = false;
    public static boolean forcedGenerateMap = false;
    public static float gmodUnitsPerBlock = 64;
    public static float loadMapProgress = 0;
    public static CommandSender sender = null;

    public static ArrayList<Block> changedBlocks = new ArrayList<>();

    public static void clear() {
        token = null;
        maxTPS = 0;
        allowedGeneratingMap = false;
        forcedGenerateMap = false;
        gmodUnitsPerBlock = 64;
        sender = null;
        loadMapProgress = 0;
        code = null;

        Bukkit.getOnlinePlayers().forEach(player -> {
            player.spigot().sendMessage(ChatMessageType.ACTION_BAR, new TextComponent(""));
        });
    }

    public static void clearMap() {
        changedBlocks.forEach(block -> {
            block.setType(Material.AIR);
        });

        changedBlocks.clear();
    }

    public static void handleHandshakeData(JSONObject jo, CommandSender handshakeSender) {
        token = jo.get("token").toString();
        code = jo.get("code").toString();

        JSONObject settings = (JSONObject) jo.get("settings");

        maxTPS = Integer.parseInt(settings.get("maxTPS").toString());
        allowedGeneratingMap = Boolean.parseBoolean(settings.get("allowedGeneratingMap").toString());
        forcedGenerateMap = Boolean.parseBoolean(settings.get("forcedGenerateMap").toString());
        gmodUnitsPerBlock = Float.parseFloat(settings.get("gmodUnitsPerBlock").toString());
        sender = handshakeSender;
    }

    public static void handleUpdateData(JSONObject jo) {
        // ENTITIES
        JSONArray entities = (JSONArray) jo.get("entities");

        for (int i = 0; i < entities.size(); i++) {
            JSONObject entity = (JSONObject) entities.get(i);
            if (!entity.get("type").equals("projectile")) {
                if (!BridgeEntitiesController.isExist(entity.get("uuid").toString())) {
                    BridgeEntitiesController.summonEntity(entity);
                } else {
                    BridgeEntitiesController.updateEntity(entity);
                }
            } else {
                BridgeEntitiesController.handleProjectile(entity);
            }
        }

        BridgeEntitiesController.updateEntities(entities);

        // EVENTS
        JSONArray events = (JSONArray) jo.get("events");

        for (int i = 0; i < events.size(); i++) {
            BridgeEvents.handle(events.get(i));
        }

        // CHUNKS
        if (jo.get("chunk") != null) {
            JSONArray chunkData = (JSONArray) jo.get("chunk");
            handleChunk(chunkData);
        }

        // PROGRESS
        if (jo.get("scanP") != null) {
            loadMapProgress = Integer.parseInt(jo.get("scanP").toString());
        }

        // UPDATE STATE
        Bukkit.getOnlinePlayers().forEach(player -> {
            ComponentBuilder components = new ComponentBuilder();
            BaseComponent state = new TextComponent("Connected to " + code);
            state.setColor(ChatColor.GREEN);

            components.append(state);
            BaseComponent separator = new TextComponent(" | [");
            separator.setColor(ChatColor.GRAY);
            components.append(separator);

            for (float i = 0; i < 10; i++) {
                BaseComponent downloadLine = new TextComponent("=");
                if (loadMapProgress / 100 > i / 10) {
                    downloadLine.setColor(ChatColor.GREEN);
                } else {
                    downloadLine.setColor(ChatColor.RED);
                }
                components.append(downloadLine);
            }

            BaseComponent end = new TextComponent("]");
            end.setColor(ChatColor.GRAY);
            components.append(end);

            player.spigot().sendMessage(ChatMessageType.ACTION_BAR, components.create());
        });
    }

    private static void handleChunk(JSONArray chunkData) {
        for (int i = 0; i < chunkData.size() / 4; i++) {
            int x = Integer.parseInt(chunkData.get(i * 4).toString());
            int y = Integer.parseInt(chunkData.get(i * 4 + 1).toString());
            int z = Integer.parseInt(chunkData.get(i * 4 + 2).toString());
            String id = chunkData.get(i * 4 + 3).toString();

            Material material = Material.matchMaterial(id);

            if (material == null) {
                material = Material.WHITE_CONCRETE;
                System.out.println("Wrong material! "+id);
            }

            Block block = Bukkit.getWorlds().get(0).getBlockAt(x,y,z);

            block.setType(material);
            changedBlocks.add(block);
        }

        sender.sendMessage("Загрузка чанка: ["+chunkData.get(0)+","+chunkData.get(1)+","+chunkData.get(2)+"]");
    }
}