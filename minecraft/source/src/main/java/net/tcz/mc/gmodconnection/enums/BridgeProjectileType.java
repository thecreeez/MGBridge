package net.tcz.mc.gmodconnection.enums;

import org.bukkit.Color;
import org.bukkit.Particle;

public enum BridgeProjectileType {
    SLAM(Particle.REDSTONE, new Particle.DustOptions(Color.GREEN, 1.5f)),
    GRENADE(Particle.REDSTONE, new Particle.DustOptions(Color.GREEN, 1f)),
    MISSILE(Particle.REDSTONE, new Particle.DustOptions(Color.BLUE, 2f)),
    BOLT(Particle.REDSTONE, new Particle.DustOptions(Color.ORANGE, 1.5f)),
    BALL(Particle.REDSTONE, new Particle.DustOptions(Color.WHITE, 4f)),
    BAIT(Particle.REDSTONE, new Particle.DustOptions(Color.YELLOW, 3f)),
    FLECHETTE(Particle.CRIT);

    private Particle particle;
    private Particle.DustOptions dustOptions;

    BridgeProjectileType(Particle particle, Particle.DustOptions dustOptions) {
        this.particle = particle;
        this.dustOptions = dustOptions;
    }

    BridgeProjectileType(Particle particle) {
        this.particle = particle;
    }

    public Particle getParticle() {
        return particle;
    }

    public Particle.DustOptions getDustOptions() {
        return dustOptions;
    }
}
