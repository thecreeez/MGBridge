package net.tcz.mc.gmodconnection.effects;

import net.tcz.mc.gmodconnection.Gmodconnection;
import org.bukkit.*;
import org.bukkit.entity.Entity;
import org.bukkit.entity.LivingEntity;
import org.bukkit.util.Vector;
import org.jetbrains.annotations.NotNull;

import java.util.Collection;

public class PhysGunEffect {
    private static Particle particle = Particle.REDSTONE;

    private static double distance = 0.008d;
    private static double maxRayLength = 30d;

    public static void drawRay(World world, Location lStart, Location lEnd, Particle.DustOptions options) {
        Location lRay = lStart;

        Double[] movePerEffect = {
                (lEnd.getX() - lStart.getX()) * distance,
                (lEnd.getY() - lStart.getY()) * distance,
                (lEnd.getZ() - lStart.getZ()) * distance
        };

        while (lRay.getX() != lEnd.getX() || lRay.getY() != lEnd.getY() || lRay.getZ() != lEnd.getZ()) {
            world.spawnParticle(particle, lRay, 1, options);

            lRay.add(movePerEffect[0], movePerEffect[1], movePerEffect[2]);

            if (lRay.distance(lEnd) < distance * 2)
                lRay.set(lEnd.getX(), lEnd.getY(), lEnd.getZ());
        }
    }

    public static void drawRay(LivingEntity entity, Particle.DustOptions options) {
        Location location = entity.getEyeLocation();

        @NotNull Vector normalizedDirection = location.getDirection().normalize();

        long rayLength = 0;
        Location rayEnd = new Location(location.getWorld(), location.getX(), location.getY(), location.getZ());

        Entity endRayEntity = null;

        while (
                rayEnd.getWorld().getBlockAt(rayEnd).getType() == Material.AIR &&
                rayLength < maxRayLength &&
                endRayEntity == null
        ) {
            rayEnd.setX(rayEnd.getX() + normalizedDirection.getX());
            rayEnd.setY(rayEnd.getY() + normalizedDirection.getY());
            rayEnd.setZ(rayEnd.getZ() + normalizedDirection.getZ());

            rayLength++;

            @NotNull Collection<Entity> entities = location.getWorld().getNearbyEntities(rayEnd, 0.3, 0.3, 0.3, null);
            for (Entity entityCandidate : entities) {
                if (!entityCandidate.equals(entity))
                    endRayEntity = entityCandidate;
            }
        }

        drawRay(
                entity.getWorld(),
                new Location(location.getWorld(), location.getX(), location.getY(), location.getZ()),
                rayEnd,
                options
        );
    }

    public static void drawRay(LivingEntity entity, Entity destination, Particle.DustOptions options) {
        Location location = entity.getEyeLocation();

        drawRay(
                entity.getWorld(),
                new Location(location.getWorld(), location.getX(), location.getY(), location.getZ()),
                destination.getLocation(),
                options
        );
    }

    public static void freezeEffect(Location location, Particle.DustOptions options) {
        location.getWorld().spawnParticle(particle, location, 1, options);
    }
}