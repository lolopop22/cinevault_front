# Architecture générale - Cinevault APP

## Vue d'ensemble

Cinevault APP est une application multi-plateforme de gestion de catalogue de films construite selon une architecture **MVC (Model-View-Controller)** adaptée à QML/Felgo.

## Schéma d'architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Main.qml                             │
│                  (Point d'entrée + Navigation)              │
└──────────────────────┬──────────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
        ▼              ▼              ▼
   ┌─────────┐   ┌─────────┐   ┌─────────┐
   │Catalogue│   │Recherche│   │ Profil  │
   │  Page   │   │  Page   │   │  Page   │
   └────┬────┘   └─────────┘   └─────────┘
        │
        │ utilise
        ▼
   ┌──────────────────────────────────────────┐
   │         CatalogueLogic.qml               │
   │         (Logique métier)                 │
   └────┬──────────────────────────┬──────────┘
        │                          │
        │ lit/écrit                │ appelle
        ▼                          ▼
   ┌─────────────────────┐   ┌──────────────┐
   │FilmDataSingletonModel│   │ FilmService  │
   │   (État global)      │   │(Appels API)  │
   └─────────────────────┘   └──────────────┘
                                     │
                                     │ HTTP
                                     ▼
                              ┌────────────────┐
                              │  Backend API   │
                              │ (Django REST)  │
                              └────────────────┘
```

## Composants principaux

### 1. Point d'entrée (Main.qml)
**Responsabilité** : Bootstrap de l'application et navigation principale

- Initialise l'application Felgo
- Configure la navigation Bottom Navigation (3 onglets)
- Instancie les NavigationStack pour chaque section
- Gère le cycle de vie initial

**Technologies** : Felgo Navigation, QML App

### 2. Couche Vue (Pages)
**Responsabilité** : Interface utilisateur et interactions

**Pages principales** :
- `CataloguePage.qml` : Grille de films avec lazy loading
- `RecherchePage.qml` : Recherche et ajout de films via IMDb
- `ProfilPage.qml` : Profil utilisateur et paramètres

**Composants réutilisables** :
- `PosterImage.qml` : Affichage optimisé des posters
- `FilmCard.qml` : Carte de film (futur)
- `FilterPanel.qml` : Panneau de filtres (futur)

### 3. Couche Logique (Logic)
**Responsabilité** : Logique métier et orchestration

**Fichiers principaux** :
- `CatalogueLogic.qml` : Gère le cycle de vie du catalogue
  - Déclenchement des chargements
  - Transformation des données
  - Propagation des erreurs
  - États de chargement

### 4. Couche Modèle (Model)
**Responsabilité** : Gestion de l'état et communication réseau

**Composants** :
- `FilmDataSingletonModel.qml` : 
  - Singleton QML global
  - Stocke la liste des films
  - Gère les états (loading, error)
  - Source unique de vérité pour les données

- `FilmService.qml` :
  - Appels HTTP vers l'API Django
  - Transformation JSON
  - Gestion des erreurs réseau

### 5. Backend (hors projet frontend)
**Responsabilité** : API REST et base de données

- Django REST Framework
- SQLite comme base de données
- Endpoints : `/api/movies/`, etc.

## Flux de données typique

### Exemple : Chargement du catalogue

```
1. CataloguePage.qml
   └─> Créée et affichée par l'utilisateur

2. CatalogueLogic.qml (Component.onCompleted)
   └─> refreshCatalogue() ou useTestData()

3. FilmDataSingletonModel
   └─> startLoading() → isLoading = true

4. FilmService
   └─> fetchAllFilms() → HttpRequest.get()

5. Backend API
   └─> Retourne JSON { films: [...] }

6. FilmService
   └─> Émet signal filmsFetched(films)

7. CatalogueLogic
   └─> Reçoit filmsFetched
   └─> Transforme les données
   └─> Appelle FilmDataSingletonModel.updateFromAPI()

8. FilmDataSingletonModel
   └─> films = newFilms
   └─> isLoading = false

9. CataloguePage.qml
   └─> GridView se met à jour automatiquement (binding)
   └─> Affiche les PosterImage avec les données
```

## Principes architecturaux

### Séparation des responsabilités
- **Vue** : Affichage uniquement, pas de logique métier
- **Logique** : Coordination et transformation des données
- **Modèle** : État et persistance

### Réactivité
- Utilisation des bindings QML pour propagation automatique
- Pattern Observer via les signaux/slots
- État global avec Singleton

### Réutilisabilité
- Composants isolés et configurables
- API claire avec propriétés publiques
- Documentation inline

### Performance
- Lazy loading des images
- Chargement asynchrone
- Optimisation mémoire (sourceSize)

## Technologies utilisées

| Couche | Technologies |
|--------|-------------|
| Framework | Felgo 4, Qt Quick 2.15 |
| Langage | QML, JavaScript |
| Navigation | Felgo Navigation |
| Réseau | Felgo HttpRequest |
| Backend | Django REST Framework, SQLite |
| API externe | IMDbPY |

## Évolution future

### Court terme
- Page de détails film
- Filtres avancés
- Authentification

### Moyen terme
- Cache intelligent
- Mode hors ligne
- Synchronisation

### Long terme (pas sûr ^)
- Multi-utilisateurs
- Recommandations
- Statistiques

## Références

- [Pattern MVC détaillé](mvc-pattern.md)
- [Flux de données complet](data-flow.md)
- [Guide des composants](../Components/README.md)
