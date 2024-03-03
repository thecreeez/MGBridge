package net.tcz.mc.gmodconnection.controllers;

import org.bukkit.Color;

import java.util.HashMap;

public class ColorController {

    private static int multiple = 100;

    public static Color getColorFromData(HashMap<String, Object> e) {
        int[] rgb = {
                Math.round(Float.parseFloat(e.get("hand_color_r").toString()) * multiple),
                Math.round(Float.parseFloat(e.get("hand_color_g").toString()) * multiple),
                Math.round(Float.parseFloat(e.get("hand_color_b").toString()) * multiple)
        };

        if (rgb[0] > 255 || rgb[0] < 0 || rgb[1] > 255 || rgb[1] < 0 || rgb[2] > 255 || rgb[2] < 0) {
            System.out.println("Error creating particle color. rgb: "+rgb[0]+","+rgb[1]+","+rgb[2]);

            rgb[0] = 0;
            rgb[1] = 0;
            rgb[2] = 0;
        }

        Color color = Color.fromRGB(rgb[0], rgb[1], rgb[2]);

        return color;
    }
}
