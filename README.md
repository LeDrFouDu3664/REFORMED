# Horizon RP - Site Web Complet (Django / Python)

Site web officiel moderne et complet pour le serveur **Horizon RP** (GTA V Roleplay), développé en Python avec **Django**.

## 🚀 Fonctionnalités

- **Architecture Django Robuste & Modulaire** :
  - Application dédiée `accueil` avec séparation claire des vues, modèles, gabarits et formulaires.
  - Compatible hébergement mutualisé / cPanel / CloudLinux via `passenger_wsgi.py`.
- **Pages Web Complètes & Dynamiques** :
  - **Accueil (`/`)** : Hero section, présentation du serveur, statistiques en temps réel, avantages clés et aperçu boutique.
  - **Règlement (`/reglement/`)** : Charte et règles du serveur (PowerGaming, MetaGaming, FairPlay, Sanctions).
  - **Boutique (`/boutique/`)** : Présentation des packs VIP et véhicules avec tarifs et liste des avantages.
  - **Streamers (`/streamers/`)** : Annuaire des créateurs de contenu partenaires avec indicateur en direct.
  - **Vote (`/vote/`)** : Plateformes de vote officielles et récompenses automatiques en jeu.
  - **Dashboard SPA Interactif (`/dashboard/`)** : Interface gamer tout-en-un sombre avec simulateur de connexion Cfx.re / FiveM, compteurs de joueurs dynamiques et notifications.
- **Modèles de Données & Administration** :
  - `ServerRule` : Gestion dynamique du règlement du serveur.
  - `Streamer` : Gestion des créateurs et statuts de live.
  - `ShopPackage` : Gestion des offres et avantages de la boutique.
  - `VoteSite` : Gestion des liens et récompenses de vote.
  - Espace d'administration Django complet (`/admin/`).

---

## 🛠️ Installation et Démarrage Rapide

### 1. Prérequis
- Python 3.10+
- `pip`

### 2. Installer les dépendances
```bash
pip install django
```

### 3. Initialiser la base de données
```bash
python manage.py migrate
python manage.py populate_data
```

### 4. Créer un compte administrateur (optionnel)
```bash
python manage.py createsuperuser
```

### 5. Démarrer le serveur de développement
```bash
python manage.py runserver
```
Rendez-vous ensuite sur :
- Site Web : `http://127.0.0.1:8000/`
- Dashboard interactif : `http://127.0.0.1:8000/dashboard/`
- Administration Django : `http://127.0.0.1:8000/admin/`

---

## 🧪 Lancer les Tests

Pour exécuter la suite de tests automatisée :
```bash
python manage.py test
```
