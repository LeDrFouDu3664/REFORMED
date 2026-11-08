package fr.armescustom;

import net.kyori.adventure.text.minimessage.MiniMessage;
import org.bukkit.Location;
import org.bukkit.attribute.Attribute;
import org.bukkit.attribute.AttributeInstance;
import org.bukkit.block.Block;
import org.bukkit.entity.Fireball;
import org.bukkit.entity.LivingEntity;
import org.bukkit.entity.Player;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;
import org.bukkit.event.entity.EntityDamageByEntityEvent;
import org.bukkit.event.entity.EntityDamageEvent;
import org.bukkit.event.entity.EntityExplodeEvent;
import org.bukkit.event.player.PlayerInteractEvent;
import org.bukkit.event.player.PlayerQuitEvent;
import org.bukkit.inventory.EquipmentSlot;
import org.bukkit.persistence.PersistentDataType;
import org.bukkit.potion.PotionEffect;
import org.bukkit.util.Vector;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;

public class WeaponListener implements Listener {

    private static final MiniMessage MM = MiniMessage.miniMessage();

    private final ArmesCustom plugin;
    private final WeaponManager manager;
    private final Map<String, Long> cooldowns = new HashMap<>();

    public WeaponListener(ArmesCustom plugin, WeaponManager manager) {
        this.plugin = plugin;
        this.manager = manager;
    }

    // ---------- Effets au coup ----------

    @EventHandler(ignoreCancelled = true)
    public void onHit(EntityDamageByEntityEvent e) {
        if (!(e.getDamager() instanceof Player player)) return;
        if (!(e.getEntity() instanceof LivingEntity target)) return;
        if (e.getCause() != EntityDamageEvent.DamageCause.ENTITY_ATTACK) return;

        Weapon w = manager.fromItem(player.getInventory().getItemInMainHand());
        if (w == null) return;

        e.setDamage(e.getDamage() + w.bonusDamage());

        if (w.fireTicks() > 0) target.setFireTicks(w.fireTicks());

        if (w.lightningChance() > 0 && ThreadLocalRandom.current().nextDouble() < w.lightningChance()) {
            target.getWorld().strikeLightning(target.getLocation());
        }

        if (w.lifesteal() > 0) {
            heal(player, e.getFinalDamage() * w.lifesteal());
        }

        if (w.knockback() > 0) {
            Vector push = target.getLocation().toVector().subtract(player.getLocation().toVector());
            push.setY(0);
            if (push.lengthSquared() > 0) {
                push.normalize().multiply(w.knockback());
                push.setY(0.35);
                target.setVelocity(target.getVelocity().add(push));
            }
        }

        for (PotionEffect effect : w.effects()) {
            target.addPotionEffect(effect);
        }
    }

    // ---------- Capacités (clic droit) ----------

    @EventHandler
    public void onUse(PlayerInteractEvent e) {
        if (e.getHand() != EquipmentSlot.HAND) return;
        org.bukkit.event.block.Action action = e.getAction();
        if (action != org.bukkit.event.block.Action.RIGHT_CLICK_AIR && action != org.bukkit.event.block.Action.RIGHT_CLICK_BLOCK) return;

        Player player = e.getPlayer();
        Weapon w = manager.fromItem(player.getInventory().getItemInMainHand());
        if (w == null || w.abilityType() == Weapon.AbilityType.NONE) return;
        if (!player.hasPermission("armescustom.use")) return;

        e.setCancelled(true);

        String key = player.getUniqueId() + ":" + w.id();
        long now = System.currentTimeMillis();
        long readyAt = cooldowns.getOrDefault(key, 0L);
        if (now < readyAt) {
            double left = (readyAt - now) / 1000.0;
            player.sendActionBar(MM.deserialize("<red>Capacité en recharge : <white>"
                    + String.format("%.1f", left) + "s"));
            return;
        }
        cooldowns.put(key, now + (long) (w.abilityCooldown() * 1000));

        switch (w.abilityType()) {
            case DASH -> {
                Vector dir = player.getEyeLocation().getDirection().normalize().multiply(w.abilityPower());
                player.setVelocity(dir);
            }
            case HEAL -> heal(player, w.abilityPower());
            case LIGHTNING -> {
                Block block = player.getTargetBlockExact(40);
                Location loc = block != null
                        ? block.getLocation().add(0.5, 1, 0.5)
                        : player.getEyeLocation().add(player.getEyeLocation().getDirection().multiply(40));
                player.getWorld().strikeLightning(loc);
            }
            case FIREBALL -> {
                Vector dir = player.getEyeLocation().getDirection();
                Fireball fb = player.launchProjectile(Fireball.class, dir.clone().multiply(1.2));
                fb.setDirection(dir);
                fb.setYield((float) w.abilityPower());
                fb.setIsIncendiary(false);
                fb.getPersistentDataContainer().set(manager.projectileKey(), PersistentDataType.BYTE, (byte) 1);
            }
            default -> { }
        }
    }

    // ---------- Pas de dégâts de blocs (configurable) ----------

    @EventHandler
    public void onExplode(EntityExplodeEvent e) {
        if (plugin.getConfig().getBoolean("block-damage", false)) return;
        if (e.getEntity().getPersistentDataContainer().has(manager.projectileKey(), PersistentDataType.BYTE)) {
            e.blockList().clear();
        }
    }

    @EventHandler
    public void onQuit(PlayerQuitEvent e) {
        String prefix = e.getPlayer().getUniqueId() + ":";
        cooldowns.keySet().removeIf(k -> k.startsWith(prefix));
    }

    private void heal(Player player, double amount) {
        AttributeInstance max = player.getAttribute(Attribute.MAX_HEALTH);
        double maxHealth = max != null ? max.getValue() : 20.0;
        player.setHealth(Math.min(maxHealth, player.getHealth() + amount));
    }
}
