# Guide d'Installation - zombie_zones

## 📋 Prérequis

- Serveur FiveM (FXServer build récent)
- Framework : ESX, QBCore ou Standalone
- Resource `oxmysql` (recommandé pour la persistance SQL)

---

## 🔧 Étapes d'Installation

1. Extrayez le dossier `zombie_zones` dans votre répertoire `resources/` de votre serveur FiveM.
2. Importez le fichier `schema.sql` dans la base de données SQL de votre serveur.
3. Si vous utilisez ESX ou `ox_inventory`, enregistrez les items post-apocalyptiques :
   ```sql
   INSERT IGNORE INTO `items` (`name`, `label`, `weight`) VALUES
   ('zombie_blood_bag', 'Poche de sang de zombie', 1),
   ('zombie_drug', 'Seringue Virale / Drogue', 1),
   ('weed', 'Feuille de Weed', 1),
   ('pooch', 'Pochon vide', 1);
   ```
4. Ouvrez le fichier `config.lua` et configurez :
   - `Config.Framework` : `'esx'`, `'qbcore'` ou `'standalone'`.
   - `Config.DatabaseType` : `'oxmysql'` ou `'json'`.
   - `Config.AdminCommand` : Nom de la commande d'administration (par défaut : `zombieadmin`).
   - `Config.AdminGroups` : Groupes autorisés à ouvrir le menu (`superadmin`, `admin`, etc.).
5. Ajoutez la ligne suivante dans votre fichier `server.cfg` :
   ```cfg
   ensure zombie_zones
   ```
6. Redémarrez votre serveur FiveM.

---

## 🎮 Utilisation

- **Commande d'administration** : `/zombieadmin` (ouvre le panneau NUI en français).
- **Infection & Transformation** : Les attaques de zombies contaminent les joueurs. Utilisez une `zombie_blood_bag` pour réduire la contamination.
- **Craft de la Drogue Virale** :
  - **Commande / Action** : `/craftzombiedrug`
  - **Ingrédients Requis** : 1x `zombie_blood_bag` + 1x `weed` + 1x `pooch`.
- **Drogue Virale** : Consommer une `zombie_drug` procure une accélération temporaire et un boost d'adrénaline.
- **Fouille de Zombie** : Approchez-vous d'un zombie mort et appuyez sur **E** pour le fouiller.
