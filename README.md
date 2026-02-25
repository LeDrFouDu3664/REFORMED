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
    - Logs détaillés (incluant messages supprimés/modifiés).
- **Aide Intégrée** : `/help` pour voir toutes les commandes.

## Prérequis
- **Node.js v24.13.1** ou supérieur.
- Un token de bot Discord.
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

## Configuration Critique (Intents)
Pour que le bot puisse fonctionner, vous **devez** activer les Intents Privilégiés dans le portail développeur :

1. Allez sur le [Discord Developer Portal](https://discord.com/developers/applications).
2. Sélectionnez votre application (le bot).
3. Cliquez sur l'onglet **"Bot"** dans le menu à gauche.
4. Faites défiler jusqu'à la section **"Privileged Gateway Intents"**.
5. Activez les interrupteurs suivants :
    - [x] **Server Members Intent** (Nécessaire pour le recrutement et la modération).
    - [x] **Message Content Intent** (Nécessaire pour le suivi d'activité et les transcriptions).
6. Cliquez sur **"Save Changes"**.

## Résolution des Problèmes (Troubleshooting)
### Le bot ne démarre pas (Erreur d'Intents)
Si vous voyez l'erreur `Used disallowed intents`, cela signifie que vous avez oublié l'étape ci-dessus. Le bot **ne peut pas** démarrer sans ces permissions car il doit suivre l'activité des tickets et gérer les membres.

### Les commandes ne s'affichent pas
Les commandes slash peuvent prendre jusqu'à quelques minutes pour apparaître. Essayez de redémarrer votre client Discord (Ctrl+R).

## Commandes Initiales
Utilisez `/setup_tickets` pour initialiser le message d'ouverture dans le salon de votre choix.
