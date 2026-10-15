# Script de Zones d'Infection Zombie - FiveM

Un script complet et hautement personnalisable de zones d'infection zombie pour FiveM (GTA V).
Transformez n'importe quelle partie de la carte en une zone de survie apocalyptique contrôlée avec des zombies agressifs, des véhicules abandonnés, une ambiance visuelle/sonore ténébreuse et un événement spécial Nuit d'Halloween.

---

## 🌟 Fonctionnalités

1. **Création et Gestion dynamique des Zones** :
   - Création, modification, déplacement, activation/désactivation et suppression de zones sans redémarrer le serveur.
   - Sauvegarde persistante des zones dans `data/zones.json`.
   - Limites nettes de zone avec transitions fluides entre la zone d'infection et la zone sécurisée.

2. **Comportement Avancé des Zombies** :
   - Suppression des PNJ humains classiques dans les zones d'infection.
   - Attaque et poursuite dynamique des joueurs à proximité.
   - Réglages personnalisables : santé, vitesse de déplacement, dégâts de mêlée, modèles de PNJ, styles de marche et temps de réapparition.
   - Triage et maintien des zombies dans le périmètre de la zone définis.

3. **Véhicules Abandonnés & Circulation** :
   - Neutralisation automatique de la circulation PNJ habituelle dans les zones infectées.
   - Placement manuel de véhicules abandonnés / accidentés avec déformations visuelles, pneus crevés, fumée et moteur H.S.
   - Sauvegarde persistante des véhicules placés.

4. **Ambiance Post-Apocalyptique & Effets Sonores** :
   - Météo sombre (`HALLOWEEN`, `FOGGY`), effets visuels post-processus (`spectator5`, `m_blackout`).
   - Effets sonores d'ambiance dynamiques (cris, grognements, vent, explosions).

5. **Événement Spécial "Nuit d'Halloween"** :
   - Basculement instantané en mode nuit d'Halloween avec obscurité totale, augmentation de la population zombie, dégâts accrus et effets visuels terrifiants.

6. **Interface d'Administration NUI (100% en Français)** :
   - Panneau de commande accessible en jeu (`/zombieadmin`) avec design glassmorphism épuré.
   - Gestion des zones, réglages zombies, véhicules abandonnés, météo et événement Halloween.

---

## 🚀 Installation & Commandes

Consultez le fichier `INSTALLATION.md` pour le guide d'installation étape par étape.

- **Commande d'administration** : `/zombieadmin` (nécessite le groupe `admin`, `superadmin` ou la permission ACE appropriée).
