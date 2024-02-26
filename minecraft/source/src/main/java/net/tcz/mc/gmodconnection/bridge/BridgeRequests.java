package net.tcz.mc.gmodconnection.bridge;

import net.md_5.bungee.api.ChatMessageType;
import net.md_5.bungee.api.chat.TextComponent;
import net.tcz.mc.gmodconnection.BridgeScheduler;
import net.tcz.mc.gmodconnection.Gmodconnection;
import net.tcz.mc.gmodconnection.SchedulersController;
import org.bukkit.Bukkit;
import org.bukkit.ChatColor;
import org.bukkit.command.CommandSender;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

import java.io.IOException;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Scanner;

public class BridgeRequests {
    private static final String urlAddress = Gmodconnection.getInstance().getConfig().getString("address");

    public static boolean handshake(String code, CommandSender sender) {
        JSONObject data = new JSONObject();
        data.put("type", "minecraft");
        data.put("code", code);

        JSONObject result = postRequest(urlAddress+"/handshake", data);

        int resultCode = Integer.parseInt(result.get("code").toString());

        if (resultCode == -1) {
            sender.sendMessage("[Bridge] Unable to connect to room: "+result.get("message").toString());
            return false;
        }

        BridgeController.handleHandshakeData((JSONObject) result.get("data"), sender);
        sender.sendMessage("[Bridge] Room handshake success!");

        return true;
    }

    public static boolean update(List<HashMap<String, Object>> entityData, List<HashMap<String, Object>> eventsData) {
        JSONObject data = new JSONObject();
        data.put("token", BridgeController.token);
        data.put("entities", entityData);
        data.put("events", eventsData);

        JSONObject result = postRequest(urlAddress+"/update", data);

        if (result == null) {
            BridgeController.sender.sendMessage(ChatColor.RED+"[Bridge] Connection with room closed. Probably because of connection to main server.");

            SchedulersController.stop();
            BridgeController.clear();
            return false;
        }

        if (Integer.parseInt(result.get("code").toString()) == -1) {
            BridgeController.sender.sendMessage(ChatColor.RED+"[Bridge] Connection with room closed. "+result.get("message").toString());

            SchedulersController.stop();
            BridgeController.clear();

            return false;
        }

        BridgeController.handleUpdateData((JSONObject) result.get("data"));
        BridgeScheduler.getEvents().clear();
        return true;
    }

    public static boolean disconnect() {
        JSONObject data = new JSONObject();
        data.put("token", BridgeController.token);

        JSONObject result = postRequest(urlAddress+"/disconnect", data);

        int resultCode = Integer.parseInt(result.get("code").toString());

        if (resultCode == -1) {
            BridgeController.sender.sendMessage("[Bridge] Unable to disconnect room: "+result.get("message").toString());
            return false;
        }

        BridgeController.sender.sendMessage("[Bridge] Room disconnect success!");
        return true;
    }

    public static boolean ping() {
        String result = getRequest(urlAddress+"/ping");

        System.out.println("ping result: "+result);
        return result != null;
    }

    private static JSONObject postRequest(String url, JSONObject data) {
        try {
            String JSONData = data.toString();

            HttpURLConnection con = (HttpURLConnection) new URL(url).openConnection();

            con.setRequestMethod("POST");
            con.setRequestProperty("Content-Type", "application/json");
            con.setRequestProperty("Content-Length", ""+JSONData.length());

            con.setDoOutput(true);

            OutputStream os = con.getOutputStream();
            byte[] input = JSONData.getBytes(StandardCharsets.UTF_8);
            os.write(input, 0, input.length);

            Scanner scanner = new Scanner(con.getInputStream());
            String responseBody = scanner.useDelimiter("\\A").next();

            Object obj = new JSONParser().parse(responseBody);

            return (JSONObject) obj;
        } catch (IOException | ParseException e) {
            e.printStackTrace();

            return null;
        }
    }

    private static String getRequest(String url) {
        try {
            HttpURLConnection con = (HttpURLConnection) new URL(url).openConnection();
            con.setRequestMethod("GET");
            con.setDoOutput(true);
            Scanner scanner = new Scanner(con.getInputStream());
            String responseBody = scanner.useDelimiter("\\A").next();

            return responseBody;
        } catch (IOException e) {
            return null;
        }
    }
}