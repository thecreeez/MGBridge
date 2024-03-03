package net.tcz.mc.gmodconnection.controllers;

import net.tcz.mc.gmodconnection.entity.BridgeHumanNPCEntity;
import net.tcz.mc.gmodconnection.entity.BridgeHumanPlayerEntity;
import net.tcz.mc.gmodconnection.entity.BridgePropEntity;
import net.tcz.mc.gmodconnection.entity.BridgeTransportEntity;
import net.tcz.mc.gmodconnection.enums.BridgeEntityType;
import org.bukkit.*;

import java.util.HashMap;

public class BridgeEntitySummoner {

    private static World world = Bukkit.getWorlds().get(0);

    public static void summonEntity(BridgeEntityType bridgeEntityType, HashMap<String, Object> entity) {
        switch (bridgeEntityType) {
            case PLAYER: new BridgeHumanPlayerEntity(world, entity); break;
            case VEHICLE: new BridgeTransportEntity(world, entity); break;
            case NPC: new BridgeHumanNPCEntity(world, entity); break;
            case PROP: new BridgePropEntity(world, entity); break;
        }
    }
}
