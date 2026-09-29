# Guide d'Installation - zombie_zones

## 📋 Prérequis

- Serveur FiveM (FXServer build récent)
- Framework : ESX, QBCore ou Standalone
- Resource `oxmysql` (recommandé pour ESX/QBCore si nécessaire, bien que les zones soient sauvegardées en JSON serveur)

---

## 🔧 Étapes d'Installation

1. Extrayez le dossier `zombie_zones` dans votre répertoire `resources/` de votre serveur FiveM.
2. Ouvrez le fichier `config.lua` et configurez :
   - `Config.Framework` : `'esx'`, `'qbcore'` ou `'standalone'`.
   - `Config.AdminCommand` : Nom de la commande d'administration (par défaut : `zombieadmin`).
   - `Config.AdminGroups` : Groupes autorisés à ouvrir le menu (`superadmin`, `admin`, etc.).
3. Ajoutez la ligne suivante dans votre fichier `server.cfg` :
   ```cfg
   ensure zombie_zones
   ```
4. Redémarrez votre serveur FiveM.

---

## 🎮 Utilisation de la Commande Admin

En jeu, si vous possédez les permissions administratives requises, tapez la commande :
```text
/zombieadmin
```

L'interface NUI s'ouvrira en français et vous permettra de :
- Créer une nouvelle zone à votre position actuelle.
- Définir le rayon, la santé des zombies, leur vitesse et leurs dégâts.
- Placer des véhicules abandonnés à votre position et orientation.
- Activer / Désactiver la Nuit d'Halloween globale ou par zone.
- Supprimer ou désactiver des zones en temps réel sans redémarrage.
