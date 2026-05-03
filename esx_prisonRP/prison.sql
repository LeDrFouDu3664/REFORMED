-- Ajouter la colonne jail_time à la table users pour ESX
ALTER TABLE `users` ADD IF NOT EXISTS `jail_time` INT(11) NOT NULL DEFAULT 0;
