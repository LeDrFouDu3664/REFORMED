# Pré-requis d'Installation pour Prison RP (ESX)

Le script `esx_prisonRP` est 100% jouable, mais il nécessite l'installation préalable de l'écosystème de base **ESX Framework** et de **ox_inventory** (pour les fouilles et les coffres).

Il n'est pas possible d'intégrer le framework entier directement dans le dossier du plugin car il s'agit d'un environnement externe géré par des milliers de fichiers Lua. Vous devez installer ces ressources sur votre serveur FiveM.

## Ressources Obligatoires (À télécharger et ajouter à votre dossier `resources`)

1. **ESX Legacy Base** : Fournit `es_extended`, le cœur du framework (Argent, Jobs, Joueurs).
   - [Télécharger ESX Legacy](https://github.com/esx-framework/esx_core)
2. **oxmysql** : Permet la communication avec la base de données SQL (utilisé par ESX et PrisonRP).
   - [Télécharger oxmysql](https://github.com/overextended/oxmysql)
3. **ox_inventory** : Le système d'inventaire le plus avancé (recommandé pour les stashes et la fouille). Remplace également le menu personnel F2.
   - [Télécharger ox_inventory](https://github.com/overextended/ox_inventory)
4. **esx_skin & skinchanger** : Requis pour la création de personnage lors du premier spawn à la prison.
   - Fournis dans le pack officiel `esx_core` (lien n°1).
5. **esx_status & esx_basicneeds** : Gère la faim et la soif. Indispensable pour voir ces statuts descendre sur le HUD et pour les remonter à la cantine.
   - Fournis dans le pack officiel `esx_core` (lien n°1).

## Modules Recommandés (Non Inclus)

Afin d'éviter des conflits de scripts, certaines mécaniques générales de GTA RP ne sont pas incluses de force dans ce script Prison RP :

*   **Voix (pma-voice) :** Pour changer les modes de discussion (Chuchoter, Crier avec `Shift` ou `F11`), vous devez installer `pma-voice`.
*   **Essence (LegacyFuel / ox_fuel) :** Le HUD de PrisonRP affichera l'essence de votre voiture automatiquement, mais il vous faut un script d'essence (comme `LegacyFuel` ou `ox_fuel`) pour ajouter des stations-services sur la carte et consommer l'essence en roulant.
*   **Menus Personnels (F5) :** Utilisez des scripts dédiés comme `esx_menu_default` ou un Radial Menu moderne.

## Ordre de démarrage (Dans votre `server.cfg`)

```cfg
ensure oxmysql
ensure es_extended
ensure ox_inventory
ensure skinchanger
ensure esx_skin
ensure esx_status
ensure esx_basicneeds
ensure esx_prisonRP
```

## Étapes Finales
1. N'oubliez pas d'importer le fichier `esx_prisonRP/prison.sql` dans votre base de données (PhpMyAdmin/HeidiSQL).
2. Modifiez le fichier `esx_prisonRP/config.lua` avec votre ID Discord (dans `Config.StaffDiscordIDs`) pour activer les commandes administrateur `/ck` et `/setjobprison`.