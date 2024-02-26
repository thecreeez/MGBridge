package net.tcz.mc.gmodconnection.enums;

import org.bukkit.Material;

public enum BridgeItemType {
    PHYS_GUN(Material.PAPER, "weapon_physgun", 1001),
    PISTOL(Material.PAPER, "weapon_pistol", 1002),
    CROSSBOW(Material.PAPER, "weapon_crossbow", 1003),
    CAMERA(Material.PAPER, "gmod_camera", 1004),
    GRENADE(Material.PAPER, "weapon_frag", 1005),
    RPG(Material.PAPER, "weapon_rpg", 1006),
    CROWBAR(Material.PAPER, "weapon_crowbar", 1007),
    TOOL_GUN(Material.PAPER, "gmod_tool", 1008),
    REVOLVER(Material.PAPER, "weapon_357", 1009),
    GRAVITY_GUN(Material.PAPER, "weapon_physcannon", 1010),
    SMG(Material.PAPER, "weapon_smg1", 1011);

    private final Material item;
    private final String bridgeName;
    private final int customModelData;

    BridgeItemType(Material item, String bridgeName, int customModelData) {
        this.item = item;
        this.bridgeName = bridgeName;
        this.customModelData = customModelData;
    }

    public Material getItem() {
        return item;
    }

    public String getBridgeName() {
        return bridgeName;
    }

    public int getCustomModelData() {
        return customModelData;
    }
}