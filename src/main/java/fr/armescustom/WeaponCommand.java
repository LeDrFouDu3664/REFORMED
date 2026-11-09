package fr.armescustom;

import net.kyori.adventure.text.minimessage.MiniMessage;
import org.bukkit.Bukkit;
import org.bukkit.command.Command;
import org.bukkit.command.CommandExecutor;
import org.bukkit.command.CommandSender;
import org.bukkit.command.TabCompleter;
import org.bukkit.entity.Player;
import org.bukkit.inventory.ItemStack;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class WeaponCommand implements CommandExecutor, TabCompleter {

    private static final MiniMessage MM = MiniMessage.miniMessage();

    private final ArmesCustom plugin;
    private final WeaponManager manager;

    public WeaponCommand(ArmesCustom plugin, WeaponManager manager) {
        this.plugin = plugin;
        this.manager = manager;
    }

    @Override
    public boolean onCommand(CommandSender sender, Command cmd, String label, String[] args) {
        if (args.length == 0) {
            msg(sender, "<yellow>Usage : /" + label + " <list|give|reload>");
            return true;
        }

        switch (args[0].toLowerCase(Locale.ROOT)) {
            case "list" -> {
                msg(sender, "<gold>Armes disponibles (" + manager.all().size() + ") :");
                manager.all().keySet().forEach(id -> msg(sender, " <gray>- <white>" + id));
            }
            case "give" -> {
                if (!sender.hasPermission("armescustom.give")) {
                    msg(sender, "<red>Permission refusée.");
                    return true;
                }
                if (args.length < 2) {
                    msg(sender, "<yellow>Usage : /" + label + " give <arme> [joueur]");
                    return true;
                }
                Weapon w = manager.get(args[1]);
                if (w == null) {
                    msg(sender, "<red>Arme inconnue : " + args[1]);
                    return true;
                }
                Player target;
                if (args.length >= 3) {
                    target = Bukkit.getPlayerExact(args[2]);
                } else if (sender instanceof Player p) {
                    target = p;
                } else {
                    msg(sender, "<red>Précisez un joueur.");
                    return true;
                }
                if (target == null) {
                    msg(sender, "<red>Joueur introuvable.");
                    return true;
                }
                ItemStack item = manager.createItem(w);
                target.getInventory().addItem(item).values()
                        .forEach(rest -> target.getWorld().dropItemNaturally(target.getLocation(), rest));
                msg(sender, "<green>" + w.id() + " donné à " + target.getName() + ".");
            }
            case "reload" -> {
                if (!sender.hasPermission("armescustom.reload")) {
                    msg(sender, "<red>Permission refusée.");
                    return true;
                }
                plugin.reloadConfig();
                manager.load();
                msg(sender, "<green>Configuration rechargée (" + manager.all().size() + " armes).");
            }
            default -> msg(sender, "<yellow>Usage : /" + label + " <list|give|reload>");
        }
        return true;
    }

    @Override
    public List<String> onTabComplete(CommandSender sender, Command cmd, String alias, String[] args) {
        List<String> out = new ArrayList<>();
        if (args.length == 1) {
            for (String s : List.of("list", "give", "reload")) {
                if (s.startsWith(args[0].toLowerCase(Locale.ROOT))) out.add(s);
            }
        } else if (args.length == 2 && args[0].equalsIgnoreCase("give")) {
            for (String id : manager.all().keySet()) {
                if (id.startsWith(args[1].toLowerCase(Locale.ROOT))) out.add(id);
            }
        } else if (args.length == 3 && args[0].equalsIgnoreCase("give")) {
            for (Player p : Bukkit.getOnlinePlayers()) {
                if (p.getName().toLowerCase(Locale.ROOT).startsWith(args[2].toLowerCase(Locale.ROOT))) out.add(p.getName());
            }
        }
        return out;
    }

    private void msg(CommandSender sender, String miniMessage) {
        sender.sendMessage(MM.deserialize(miniMessage));
    }
}
