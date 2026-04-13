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

-- Création du métier de Garde et Unité Incendie
INSERT INTO `jobs` (name, label) VALUES ('garde', 'Pénitentiaire Fédéral');
INSERT INTO `jobs` (name, label) VALUES ('garde_incendie', 'Unité Incendie Pénitentiaire');

-- Grades du métier de Garde Fédéral (Permanente)
INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
('garde', 0, 'recruit', 'Recrue', 1500, '{}', '{}'),
('garde', 1, 'officer', 'Gardien Fédéral', 2000, '{}', '{}'),
('garde', 2, 'sniper', 'Tireur d\'Élite', 2300, '{}', '{}'),
('garde', 3, 'riot', 'Unité Anti-Émeute', 2800, '{}', '{}'),
('garde', 4, 'sergeant', 'Chef de Sécurité', 3200, '{}', '{}'),
('garde', 5, 'boss', 'Directeur de Prison', 5000, '{}', '{}');

-- Grades du métier d'Unité Incendie
INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
('garde_incendie', 0, 'recruit', 'Pompier Stagiaire', 1800, '{}', '{}'),
('garde_incendie', 1, 'officer', 'Pompier Fédéral', 2500, '{}', '{}'),
('garde_incendie', 2, 'boss', 'Chef de Caserne', 3500, '{}', '{}');

-- Création du métier de Prisonnier
INSERT INTO `jobs` (name, label) VALUES ('prisonnier', 'Détenu');

-- Grades du métier de Prisonnier
INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
('prisonnier', 0, 'inmate', 'Prisonnier Fédéral', 0, '{}', '{}');
