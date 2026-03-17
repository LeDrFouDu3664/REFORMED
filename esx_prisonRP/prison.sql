-- Ajout de la colonne pour le temps de prison
ALTER TABLE `users` ADD COLUMN IF NOT EXISTS `jail_time` INT(11) NOT NULL DEFAULT 0;

-- Suivi du premier spawn
ALTER TABLE `users` ADD COLUMN IF NOT EXISTS `first_spawn` TINYINT(1) NOT NULL DEFAULT 1;

-- Création des fonds de société pour le Garde
INSERT INTO `addon_account` (name, label, shared) VALUES ('society_garde', 'Garde Pénitentiaire', 1);
INSERT INTO `addon_inventory` (name, label, shared) VALUES ('society_garde', 'Garde Pénitentiaire', 1);
INSERT INTO `datastore` (name, label, shared) VALUES ('society_garde', 'Garde Pénitentiaire', 1);

-- Stash partagé des prisonniers
INSERT INTO `addon_inventory` (name, label, shared) VALUES ('prison_stash', 'Coffre des Détenus', 1);

-- Création du métier de Garde
INSERT INTO `jobs` (name, label) VALUES ('garde', 'Garde Pénitentiaire');

-- Grades du métier de Garde
INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
('garde', 0, 'recruit', 'Recrue', 1500, '{}', '{}'),
('garde', 1, 'officer', 'Gardien', 2000, '{}', '{}'),
('garde', 2, 'sergeant', 'Chef de Garde', 2500, '{}', '{}'),
('garde', 3, 'boss', 'Directeur', 3500, '{}', '{}');
