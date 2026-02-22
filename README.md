# REFORMED - Bot de Tickets Discord

Un bot complet de gestion de tickets et de recrutement pour Discord, développé en Node.js (ESM).

## Fonctionnalités
- **Catégories de tickets claires** : Commande, Direction, Partenariat, Recrutement, Modération.
- **Gestion simplifiée** : Boutons pour Claim, Ajouter/Retirer des membres, Réouvrir et Fermer (avec raison obligatoire).
- **Recrutement automatisé** : Workflow dédié avec boutons Accepter/Refuser, attribution de rôles et création de salons.
- **Logs et Traçabilité** : Enregistrement de toutes les actions et génération de transcriptions HTML complètes.
- **Sécurité** : Limite d'un ticket par utilisateur et cooldown configurable.

## Prérequis
- **Node.js v24.13.1** ou supérieur.
- Un token de bot Discord.
- Les IDs des rôles et catégories configurés dans le fichier `.env`.

## Installation
1. Clonez le dépôt.
2. Installez les dépendances :
   ```bash
   npm install
   ```
3. Configurez le fichier `.env` (utilisez `.env.example` comme modèle).
4. Lancez le bot :
   ```bash
   npm start
   ```

## Configuration
Le bot utilise des commandes slash. Lors du premier lancement, utilisez `/setup_tickets` dans le salon où vous souhaitez afficher le message d'ouverture des tickets.
