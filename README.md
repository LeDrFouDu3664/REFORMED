# REFORMED - Bot de Tickets & Modération Discord

Un bot professionnel et complet pour la gestion des tickets, du recrutement et de la modération, développé en Node.js 24 (ESM).

## Fonctionnalités
- **Système de Tickets Avancé** :
    - Catégories dynamiques par mois (ex: "Tickets - Mars 2026").
    - Boutons interactifs (Claim, Add/Remove, Reopen, Close).
    - Priorités personnalisables (/priority).
    - Statistiques globales et par staff (/stats_tickets, /staff_stats).
    - Blacklist d'utilisateurs (/blacklist).
    - Fermeture automatique des tickets inactifs.
    - Transcriptions HTML envoyées en DM et loguées.
- **Système de Recrutement** :
    - Workflow Accept/Reject avec boutons.
    - Attribution automatique de rôles et création de salons de bienvenue.
- **Système de Modération** :
    - Commandes slash : `/warn`, `/warnings`, `/kick`, `/ban`, `/timeout`, `/clear`, `/mod_history`.
    - Historique persistant en base de données.
    - Logs détaillés dans un salon dédié.

## Prérequis
- **Node.js v24.13.1** ou supérieur.
- Un token de bot Discord (avec Intents activés).
- Configuration des IDs dans le fichier `.env`.

## Installation
1. Clonez le dépôt.
2. Installez les dépendances :
   ```bash
   npm install
   ```
3. Configurez le fichier `.env` :
    - Remplacez le token factice (`0000...`) par votre vrai token.
    - Remplissez les IDs de votre serveur (Guild ID, Role IDs, Channel IDs).
4. Lancez le bot :
   ```bash
   npm start
   ```

## Configuration Critique
Dans le **Discord Developer Portal**, vous devez impérativement activer :
- **Server Members Intent** (pour le recrutement et la modération)
- **Message Content Intent** (pour le suivi d'activité et les transcriptions)

## Commandes Initiales
Utilisez `/setup_tickets` pour initialiser le message d'ouverture dans le salon de votre choix.
