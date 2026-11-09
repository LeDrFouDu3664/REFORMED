package fr.armescustom;

import org.bukkit.Material;
import org.bukkit.potion.PotionEffect;

import java.util.List;

public record Weapon(
        String id,
        Material material,
        String name,
        List<String> lore,
        boolean unbreakable,
        boolean glow,
        String itemModel,
        int customModelData,
        double bonusDamage,
        int fireTicks,
        double lightningChance,
        double lifesteal,
        double knockback,
        List<PotionEffect> effects,
        AbilityType abilityType,
        double abilityCooldown,
        double abilityPower) {

    public enum AbilityType { NONE, DASH, HEAL, LIGHTNING, FIREBALL }
}
