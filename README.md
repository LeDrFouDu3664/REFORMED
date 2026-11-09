# ArmesCustom — plugin Paper 26.3

Armes personnalisées 100 % configurables (config.yml) : dégâts bonus, feu, foudre,
vol de vie, recul, effets de potion, capacités au clic droit (dash, soin, foudre
ciblée, boule de feu), nom/lore MiniMessage, item-model / custom-model-data.

## Prérequis
- Serveur **Paper 26.3** (api-version 26.3)
- **Java 25**

## Compilation
    ./gradlew build        (ou: gradle build)
Le jar est dans `build/libs/ArmesCustom-1.0.0.jar` → à mettre dans `plugins/`.

## Commandes
- `/arme list`
- `/arme give <arme> [joueur]`   (armescustom.give)
- `/arme reload`                 (armescustom.reload)

## Ajouter une arme
Copie un bloc dans `weapons:` de `plugins/ArmesCustom/config.yml`, change l'id, puis `/arme reload`.
