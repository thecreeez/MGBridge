package net.tcz.mc.gmodconnection.enums;

import org.bukkit.entity.EntityType;

public enum BridgeEntityType {
    PLAYER(EntityType.ZOMBIE),
    NPC(EntityType.SKELETON),
    VEHICLE(EntityType.PIG),
    PROP(EntityType.SLIME);

    private final EntityType entityType;

    BridgeEntityType(EntityType entityType) {
        this.entityType = entityType;
    }

    public EntityType getEntityType() {
        return entityType;
    }
}