package fr.armescustom;

import net.kyori.adventure.text.Component;
import net.kyori.adventure.text.format.TextDecoration;
import net.kyori.adventure.text.minimessage.MiniMessage;
import org.bukkit.Material;
import org.bukkit.NamespacedKey;
import org.bukkit.Registry;
import org.bukkit.configuration.ConfigurationSection;
import org.bukkit.inventory.ItemStack;
import org.bukkit.inventory.meta.components.CustomModelDataComponent;
import org.bukkit.persistence.PersistentDataType;
import org.bukkit.potion.PotionEffect;
import org.bukkit.potion.PotionEffectType;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class WeaponManager {

    private static final MiniMessage MM = MiniMessage.miniMessage();

    private final ArmesCustom plugin;
    private final NamespacedKey weaponKey;
    private final NamespacedKey projectileKey;
    private final Map<String, Weapon> weapons = new LinkedHashMap<>();

    public WeaponManager(ArmesCustom plugin) {
        this.plugin = plugin;
        this.weaponKey = new NamespacedKey(plugin, "weapon_id");
        this.projectileKey = new NamespacedKey(plugin, "weapon_projectile");
        load();
    }

    public NamespacedKey projectileKey() {
        return projectileKey;
    }

    public void load() {
        weapons.clear();
        ConfigurationSection root = plugin.getConfig().getConfigurationSection("weapons");
        if (root == null) return;

        for (String rawId : root.getKeys(false)) {
            ConfigurationSection s = root.getConfigurationSection(rawId);
            if (s == null) continue;
            String id = rawId.toLowerCase(Locale.ROOT);

            Material material = Material.matchMaterial(s.getString("material", "IRON_SWORD"));
            if (material == null || material.isAir()) {
                plugin.getLogger().warning("Arme '" + id + "' : matériau invalide, ignorée.");
                continue;
            }

            List<PotionEffect> effects = new ArrayList<>();
            for (String line : s.getStringList("on-hit.effects")) {
                PotionEffect effect = parseEffect(line);
                if (effect != null) effects.add(effect);
                else plugin.getLogger().warning("Arme '" + id + "' : effet invalide '" + line + "'.");
            }

            Weapon.AbilityType type;
            try {
                type = Weapon.AbilityType.valueOf(s.getString("ability.type", "NONE").toUpperCase(Locale.ROOT));
            } catch (IllegalArgumentException ex) {
                plugin.getLogger().warning("Arme '" + id + "' : capacité inconnue, désactivée.");
                type = Weapon.AbilityType.NONE;
            }

            weapons.put(id, new Weapon(
                    id,
                    material,
                    s.getString("name", id),
                    s.getStringList("lore"),
                    s.getBoolean("unbreakable", false),
                    s.getBoolean("glow", false),
                    s.getString("item-model", ""),
                    s.getInt("custom-model-data", 0),
                    s.getDouble("bonus-damage", 0),
                    s.getInt("on-hit.fire-ticks", 0),
                    s.getDouble("on-hit.lightning-chance", 0),
                    s.getDouble("on-hit.lifesteal", 0),
                    s.getDouble("on-hit.knockback", 0),
                    List.copyOf(effects),
                    type,
                    s.getDouble("ability.cooldown", 10),
                    s.getDouble("ability.power", 1)));
        }
        plugin.getLogger().info(weapons.size() + " arme(s) custom chargée(s).");
    }

    private PotionEffect parseEffect(String line) {
        String[] p = line.split(":");
        if (p.length < 1) return null;
        NamespacedKey key = NamespacedKey.minecraft(p[0].trim().toLowerCase(Locale.ROOT));
        PotionEffectType type = Registry.POTION_EFFECT_TYPE.get(key);
        if (type == null) return null;
        try {
            int seconds = p.length > 1 ? Integer.parseInt(p[1].trim()) : 5;
            int amplifier = p.length > 2 ? Integer.parseInt(p[2].trim()) : 0;
            return new PotionEffect(type, seconds * 20, amplifier);
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    public Map<String, Weapon> all() {
        return weapons;
    }

    public Weapon get(String id) {
        return id == null ? null : weapons.get(id.toLowerCase(Locale.ROOT));
    }

    /** Retourne l'arme custom correspondant à l'item, ou null. */
    public Weapon fromItem(ItemStack item) {
        if (item == null || item.getType().isAir() || !item.hasItemMeta()) return null;
        String id = item.getItemMeta().getPersistentDataContainer().get(weaponKey, PersistentDataType.STRING);
        return get(id);
    }

    public ItemStack createItem(Weapon w) {
        ItemStack item = new ItemStack(w.material());
        item.editMeta(meta -> {
            meta.displayName(MM.deserialize(w.name()).decoration(TextDecoration.ITALIC, false));

            List<Component> lore = new ArrayList<>();
            for (String line : w.lore()) {
                lore.add(MM.deserialize(line).decoration(TextDecoration.ITALIC, false));
            }
            meta.lore(lore);

            meta.setUnbreakable(w.unbreakable());
            if (w.glow()) meta.setEnchantmentGlintOverride(true);

            if (!w.itemModel().isBlank()) {
                NamespacedKey model = NamespacedKey.fromString(w.itemModel());
                if (model != null) meta.setItemModel(model);
            }
            if (w.customModelData() > 0) {
                CustomModelDataComponent cmd = meta.getCustomModelDataComponent();
                cmd.setFloats(List.of((float) w.customModelData()));
                meta.setCustomModelDataComponent(cmd);
            }

            meta.getPersistentDataContainer().set(weaponKey, PersistentDataType.STRING, w.id());
        });
        return item;
    }
}
