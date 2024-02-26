package net.tcz.mc.gmodconnection.entity;

import net.tcz.mc.gmodconnection.controllers.BridgeEntitiesController;
import net.tcz.mc.gmodconnection.enums.BridgeEntityType;
import org.bukkit.*;
import org.bukkit.util.Vector;

import java.util.HashMap;

public class BridgeTransportEntity extends BridgeEntity {

    private BridgeHumanPlayerEntity driver = null;
    private float speed = 0;

    public BridgeTransportEntity(World world, HashMap<String, Object> e) {
        super(world, BridgeEntityType.VEHICLE, e, Sound.ENTITY_ARMOR_STAND_PLACE);

        respawnEffect = new Particle.DustOptions(Color.BLUE, 10f);
    }

    @Override
    public void update(HashMap<String, Object> bridgeData) {
        if (driver != null)
            updatePositionWithDriver(bridgeData);
        else
            super.update(bridgeData);


        boolean bridgeSideDriverExist = !bridgeData.get("driver").toString().equals("none");

        if (bridgeSideDriverExist && driver == null)
            setDriver((BridgeHumanPlayerEntity) BridgeEntitiesController.getEntities().get(bridgeData.get("driver").toString()));

        if (!bridgeSideDriverExist && driver != null)
            removeDriver();
    }

    public void setDriver(BridgeHumanPlayerEntity driver) {
        entity.addPassenger(driver.getEntity());

        System.out.println(entity.getName()+" now had driver: "+driver.getEntity().getName());

        driver.setDriving(true);
        this.driver = driver;
    }

    public void removeDriver() {
        if (driver == null)
            return;

        System.out.println(entity.getName()+" now empty.");

        entity.removePassenger(driver.getEntity());
        driver.setDriving(false);
        driver = null;
    }

    private void updatePositionWithDriver(HashMap<String, Object> bridgeData) {
        entity.removePassenger(driver.getEntity());

        updatePosition(bridgeData);
        driver.getEntity().teleport(new Location(driver.getEntity().getWorld(), driver.getEntity().getLocation().getX(),driver.getEntity().getLocation().getY(),driver.getEntity().getLocation().getZ(), driver.getYaw(), driver.getPitch()));

        entity.addPassenger(driver.getEntity());
    }

    @Override
    protected void updatePosition(HashMap<String, Object> bridgeData) {
        // Получение данных из моста
        double x = Double.parseDouble(bridgeData.get("x").toString());
        double y = Double.parseDouble(bridgeData.get("y").toString());
        double z = Double.parseDouble(bridgeData.get("z").toString());

        float yaw = Float.parseFloat(bridgeData.get("yaw").toString()) + 90;
        float steer = (float) Math.floor(Float.parseFloat(bridgeData.get("steering").toString()) * 15);

        double[] prevPos = { this.entity.getLocation().getX(), this.entity.getLocation().getY(), this.entity.getLocation().getZ() };
        Vector moveDirection = new Vector( x - prevPos[0], y - prevPos[1], z - prevPos[2]).normalize();
        Vector carDirection = entity.getLocation().getDirection().normalize();

        if (driver != null && !Double.isNaN(moveDirection.getX()) && !Double.isNaN(moveDirection.getY()) && !Double.isNaN(moveDirection.getZ())) {
            speed = (float) moveDirection.dot(carDirection);
        }

        // Отправка скорости для модели Optifine
        if (speed < 0) {
            if (steer > 0)
                steer += 20;
            else
                steer -= 20;
        }


        // to-do: FIX SHIT
        Location location = new Location(entity.getWorld(), x, y ,z , yaw, steer);
        //Location centeredLocation = new Location(entity.getWorld(), 20 * 0.07143, 0, -41.5 * 0.07143, yaw, steer);

        //location.add(centeredLocation);

        entity.teleport(location);
    }
}
