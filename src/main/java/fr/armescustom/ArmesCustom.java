package fr.armescustom;

import org.bukkit.command.PluginCommand;
import org.bukkit.plugin.java.JavaPlugin;

public final class ArmesCustom extends JavaPlugin {

    private WeaponManager manager;

    @Override
    public void onEnable() {
        saveDefaultConfig();
        manager = new WeaponManager(this);

        getServer().getPluginManager().registerEvents(new WeaponListener(this, manager), this);

        PluginCommand command = getCommand("arme");
        if (command != null) {
            WeaponCommand handler = new WeaponCommand(this, manager);
            command.setExecutor(handler);
            command.setTabCompleter(handler);
        }
    }
}
