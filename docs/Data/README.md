# Documentation Modèle de Données - Cinevault APP

## Vue d'ensemble

Le dossier `qml/model/` contient les composants de la **couche Modèle** dans l'architecture MVC. Cette couche est responsable de la gestion des données et de la communication avec le backend.

## Structure du dossier

```
qml/model/
├── FilmDataSingletonModel.qml     # État global des films (Singleton)
├── FilmService.qml                # Service de communication API
└── qmldir                         # Fichier d'enregistrement des modules
```

## Documentation des fichiers

```
docs/data/
├── README.md                      # Ce fichier
├── FilmDataSingletonModel.md      # Documentation du Singleton
├── FilmService.md                 # Documentation du Service
└── qmldir-guide.md                # Guide du fichier qmldir
```

---

## Qu'est-ce que la couche Modèle ?

### Définition

La **couche Modèle** dans l'architecture MVC est responsable de :

**✅ Gestion de l'état**
- Stockage des données (films, états de chargement, erreurs)
- Source unique de vérité pour toute l'application
- Notification automatique des changements

**✅ Communication réseau**
- Appels HTTP vers l'API backend
- Parsing des réponses JSON
- Gestion des erreurs réseau

**❌ Ce que le Modèle ne fait PAS**
- Pas de logique métier (transformation complexe)
- Pas d'interface utilisateur
- Pas de gestion de la navigation

### Position dans l'architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         VUE (Pages)                          │
│  Affichage, interaction utilisateur, bindings                │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            │ utilise
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      LOGIC (Contrôleur)                      │
│  Orchestration, transformation, logique métier               │
└────────────┬────────────────────────────────┬───────────────┘
             │                                │
             │ lit/écrit                      │ appelle
             ▼                                ▼
┌──────────────────────────┐    ┌──────────────────────────┐
│   FilmDataSingletonModel │    │      FilmService         │
│   (État global)          │    │   (Communication API)    │
│                          │    │                          │
│  • films: []             │    │  • fetchAllFilms()       │
│  • isLoading: bool       │    │  • signal filmsFetched   │
│  • lastError: string     │    │  • signal fetchError     │
└──────────────────────────┘    └───────────┬──────────────┘
                                            │
                                            │ HTTP
                                            ▼
                                ┌─────────────────────────┐
                                │    Backend API          │
                                │   (Django REST)         │
                                └─────────────────────────┘
```

---

## Les deux composants principaux

### 1. FilmDataSingletonModel (État)

**Type** : Singleton QML  
**Rôle** : Stockage centralisé de l'état global  
**Pattern** : Observer (émet des changements via property bindings)

**Caractéristiques** :
- ✅ Une seule instance dans toute l'application
- ✅ Accessible depuis n'importe où via `Model.FilmDataSingletonModel`
- ✅ Mise à jour automatique de toutes les vues (bindings)
- ✅ Données persistantes pendant la session

**Contenu** :
```qml
property var films: []           // Liste des films
property bool isLoading: false   // État de chargement
property string lastError: ""    // Dernier message d'erreur
```

**Documentation complète** : [FilmDataSingletonModel.md](FilmDataSingletonModel.md)

### 2. FilmService (Communication)

**Type** : Composant QML standard  
**Rôle** : Communication HTTP avec l'API backend  
**Pattern** : Observer (émet des signaux pour les résultats)

**Caractéristiques** :
- ✅ Encapsule tous les appels API
- ✅ Gère les erreurs réseau
- ✅ Parse les réponses JSON
- ✅ Émission de signaux pour notifier les résultats

**Méthodes** :
```qml
function fetchAllFilms()  // GET /api/movies/
```

**Signaux** :
```qml
signal filmsFetched(var films)        // Succès
signal fetchError(string message)     // Erreur
```

**Documentation complète** : [FilmService.md](FilmService.md)

---

## Pattern Singleton expliqué

### Qu'est-ce qu'un Singleton ?

Un **Singleton** est un pattern de conception qui garantit qu'une seule instance d'une classe existe dans toute l'application.

### Problème sans Singleton

```qml
// ❌ MAUVAIS : Chaque import crée une nouvelle instance

// Page1.qml
import "../model/FilmData.qml" as FilmData
Item {
    FilmData { id: filmData1 }  // Instance 1
    // filmData1.films = [film1, film2]
}

// Page2.qml
import "../model/FilmData.qml" as FilmData
Item {
    FilmData { id: filmData2 }  // Instance 2 (différente !)
    // filmData2.films = []  ← Vide ! Pas les mêmes données
}
```

**Résultat** : Données incohérentes entre pages

### Solution avec Singleton

```qml
// ✅ BON : Une seule instance partagée

// Page1.qml
import "../model" as Model
Item {
    Text {
        text: Model.FilmDataSingletonModel.films.length
        // Affiche : 5 films
    }
}

// Page2.qml
import "../model" as Model
Item {
    Text {
        text: Model.FilmDataSingletonModel.films.length
        // Affiche : 5 films (mêmes données !)
    }
}
```

**Résultat** : Source unique de vérité, données cohérentes partout

### Implémentation en QML

**1. Déclarer le Singleton**

```qml
// FilmDataSingletonModel.qml
pragma Singleton  // ← Mot-clé magique
import Felgo 4.0
import QtQuick 2.15

Item {
    id: filmDataSingletonModel
    
    // Propriétés partagées globalement
    property var films: []
    property bool isLoading: false
    property string lastError: ""
}
```

**2. Enregistrer dans qmldir**

```
# qmldir
singleton FilmDataSingletonModel 1.0 FilmDataSingletonModel.qml
```

**3. Utiliser partout**

```qml
import "../model" as Model

Item {
    // Accès direct au Singleton
    Text {
        text: Model.FilmDataSingletonModel.films.length + " films"
    }
}
```

---

## Flux de données complets

### Flux 1 : Chargement du catalogue (Succès)

```
┌─────────────┐
│ Utilisateur │  Ouvre l'application
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│ CataloguePage                                               │
│  Component.onCompleted                                      │
└──────┬──────────────────────────────────────────────────────┘
       │
       │ 1. Initialisation
       ▼
┌─────────────────────────────────────────────────────────────┐
│ CatalogueLogic                                              │
│  refreshCatalogue()                                         │
└──────┬──────────────────────────────────────────────────────┘
       │
       │ 2. Démarre le chargement
       ▼
┌─────────────────────────────────────────────────────────────┐
│ FilmDataSingletonModel                                      │
│  startLoading()                                             │
│  └─> isLoading = true                                       │
│  └─> lastError = ""                                         │
└──────┬──────────────────────────────────────────────────────┘
       │
       │ 3. Binding automatique
       ▼
┌─────────────────────────────────────────────────────────────┐
│ CataloguePage                                               │
│  BusyIndicator.visible = logic.loading (true)               │
│  GridView.visible = false                                   │
└─────────────────────────────────────────────────────────────┘
       
       ┌──────────────────────────────────────────────────────┐
       │ CatalogueLogic                                       │
       │  filmService.fetchAllFilms()                         │
       └──────┬───────────────────────────────────────────────┘
              │
              │ 4. Appel API
              ▼
       ┌──────────────────────────────────────────────────────┐
       │ FilmService                                          │
       │  HttpRequest.get(apiUrl + "/movies/")                │
       └──────┬───────────────────────────────────────────────┘
              │
              │ 5. Requête HTTP
              ▼
       ┌──────────────────────────────────────────────────────┐
       │ Backend API (Django REST)                            │
       │  GET /api/movies/                                    │
       │  Retourne: [                                         │
       │    {id:1, title:"Avatar", poster_url:"..."},         │
       │    {id:2, title:"Titanic", poster_url:"..."}         │
       │  ]                                                   │
       └──────┬───────────────────────────────────────────────┘
              │
              │ 6. Réponse JSON
              ▼
       ┌──────────────────────────────────────────────────────┐
       │ FilmService                                          │
       │  JSON.parse(response)                                │
       │  filmsFetched(films) ← Émet signal                   │
       └──────┬───────────────────────────────────────────────┘
              │
              │ 7. Signal filmsFetched
              ▼
       ┌──────────────────────────────────────────────────────┐
       │ CatalogueLogic                                       │
       │  onFilmsFetched(films) {                             │
       │    // Transformation des données                     │
       │    var transformed = films.map(f => ({               │
       │      id: f.id,                                       │
       │      title: f.title,                                 │
       │      poster_url: f.poster_url                        │
       │    }))                                               │
       │    // Stockage dans le Model                         │
       │    FilmDataSingletonModel.updateFromAPI(transformed) │
       │  }                                                   │
       └──────┬───────────────────────────────────────────────┘
              │
              │ 8. Mise à jour Model
              ▼
       ┌──────────────────────────────────────────────────────┐
       │ FilmDataSingletonModel                               │
       │  updateFromAPI(newFilms) {                           │
       │    films = newFilms                                  │
       │    isLoading = false                                 │
       │    lastError = ""                                    │
       │  }                                                   │
       └──────┬───────────────────────────────────────────────┘
              │
              │ 9. Binding automatique
              ▼
       ┌──────────────────────────────────────────────────────┐
       │ CataloguePage                                        │
       │  BusyIndicator.visible = false                       │
       │  GridView.visible = true                             │
       │  GridView.model = films (2 films affichés)           │
       └──────────────────────────────────────────────────────┘
```

### Flux 2 : Chargement du catalogue (Erreur)

```
FilmService
  HttpRequest.get() échoue
    │
    │ catch(error)
    ▼
  fetchError("Erreur HTTP: " + error) ← Émet signal
    │
    │ Signal fetchError
    ▼
CatalogueLogic
  onFetchError(errorMessage) {
    │
    ├─> FilmDataSingletonModel.setError(errorMessage)
    │   └─> lastError = errorMessage
    │   └─> isLoading = false
    │
    └─> errorOccurred(errorMessage) ← Émet signal vers Vue
        │
        │ Signal errorOccurred
        ▼
CataloguePage
  Connections {
    onErrorOccurred(message) {
      errorText.text = message
      errorModal.open() ← Affiche modal d'erreur
    }
  }
```

---

## Communication entre composants

### 1. Vue → Logic (Action utilisateur)

**Méthode** : Appel de fonction

```qml
// Vue (CataloguePage)
Button {
    text: "Rafraîchir"
    onClicked: logic.refreshCatalogue()  // ← Appel direct
}

// Logic (CatalogueLogic)
function refreshCatalogue() {
    // Implémentation
}
```

### 2. Logic → Model (Mise à jour état)

**Méthode** : Appel de fonction

```qml
// Logic (CatalogueLogic)
Model.FilmDataSingletonModel.startLoading()      // ← Appel direct
Model.FilmDataSingletonModel.updateFromAPI(data) // ← Appel direct

// Model (FilmDataSingletonModel)
function startLoading() {
    internal.isLoading = true
}
```

### 3. Logic → Service (Déclenchement requête)

**Méthode** : Appel de fonction

```qml
// Logic (CatalogueLogic)
filmService.fetchAllFilms()  // ← Appel direct

// Service (FilmService)
function fetchAllFilms() {
    HttpRequest.get(apiUrl + "/movies/")
}
```

### 4. Service → Logic (Résultat asynchrone)

**Méthode** : Signaux

```qml
// Service (FilmService)
signal filmsFetched(var films)
signal fetchError(string message)

HttpRequest.get(url).then(function(response) {
    filmsFetched(JSON.parse(response))  // ← Émet signal
})

// Logic (CatalogueLogic)
Connections {
    target: filmService
    function onFilmsFetched(films) {  // ← Reçoit signal
        // Traitement
    }
}
```

### 5. Model → Vue (Notification changement)

**Méthode** : Bindings automatiques QML

```qml
// Model (FilmDataSingletonModel)
property var films: []  // ← Change automatiquement

// Vue (CataloguePage)
GridView {
    model: Model.FilmDataSingletonModel.films  // ← Binding
    // Se met à jour automatiquement quand films change
}
```

### 6. Logic → Vue (Événement ponctuel)

**Méthode** : Signaux

```qml
// Logic (CatalogueLogic)
signal errorOccurred(string message)

function onFetchError(errorMessage) {
    errorOccurred(errorMessage)  // ← Émet signal
}

// Vue (CataloguePage)
Connections {
    target: logic
    function onErrorOccurred(message) {  // ← Reçoit signal
        errorModal.open()
    }
}
```

---

## Tableau récapitulatif des communications

| Source | Destination | Méthode | Exemple |
|--------|-------------|---------|---------|
| Vue | Logic | Fonction | `logic.refreshCatalogue()` |
| Logic | Model | Fonction | `Model.FilmDataSingletonModel.startLoading()` |
| Logic | Service | Fonction | `filmService.fetchAllFilms()` |
| Service | Logic | Signal | `filmsFetched(films)` |
| Model | Vue | Binding | `model: FilmDataSingletonModel.films` |
| Logic | Vue | Signal | `errorOccurred(message)` |

---

## Principes de conception

### 1. Séparation des responsabilités

**Model** : Données pures
```qml
// ✅ BON : Seulement stockage
function updateFromAPI(newFilms) {
    films = newFilms
    isLoading = false
}

// ❌ MAUVAIS : Logique métier dans Model
function updateFromAPI(newFilms) {
    films = newFilms.filter(f => f.year > 2020).sort(...)  // ❌
    isLoading = false
}
```

**Service** : Communication pure
```qml
// ✅ BON : Seulement API
function fetchAllFilms() {
    HttpRequest.get(url)
        .then(response => filmsFetched(JSON.parse(response)))
}

// ❌ MAUVAIS : Transformation dans Service
function fetchAllFilms() {
    HttpRequest.get(url)
        .then(response => {
            var films = JSON.parse(response)
            var filtered = films.filter(...)  // ❌ Logique métier
            filmsFetched(filtered)
        })
}
```

### 2. Unidirectionnalité

```
Vue → Logic → Service → Backend
                ↓
              Model
                ↓
              Vue (bindings)
```

Flux unidirectionnel = prévisible et testable

### 3. Réactivité

Les bindings QML créent une réactivité automatique :

```qml
// Model change
films = newFilms

// Toutes les vues se mettent à jour automatiquement
GridView { model: films }  // ← Mise à jour auto
Text { text: films.length }  // ← Mise à jour auto
```

---

## Bonnes pratiques

### ✅ À faire

**1. Model : Données pures seulement**
```qml
function updateFromAPI(newFilms) {
    internal.films = newFilms  // ✅ Simple assignation
    internal.isLoading = false
}
```

**2. Service : Communication pure**
```qml
function fetchAllFilms() {
    HttpRequest.get(apiUrl + "/movies/")
        .then(response => filmsFetched(JSON.parse(response)))  // ✅
}
```

**3. Logic : Transformation et orchestration**
```qml
function onFilmsFetched(films) {
    var transformed = films.map(f => ({  // ✅ Transformation ici
        id: f.id,
        title: f.title.toUpperCase()
    }))
    Model.FilmDataSingletonModel.updateFromAPI(transformed)
}
```

**4. Utiliser le Singleton via namespace**
```qml
import "../model" as Model

Text {
    text: Model.FilmDataSingletonModel.films.length  // ✅
}
```

### ❌ À éviter

**1. Pas de logique métier dans Model**
```qml
// ❌ MAUVAIS
function updateFromAPI(newFilms) {
    films = newFilms.filter(f => f.year > 2020)  // ❌
}
```

**2. Pas de transformation dans Service**
```qml
// ❌ MAUVAIS
function fetchAllFilms() {
    HttpRequest.get(url).then(response => {
        var films = JSON.parse(response)
        var sorted = films.sort(...)  // ❌
        filmsFetched(sorted)
    })
}
```

**3. Pas d'accès direct Service dans Vue**
```qml
// ❌ MAUVAIS
CataloguePage {
    FilmService { id: service }
    Button {
        onClicked: service.fetchAllFilms()  // ❌
    }
}

// ✅ BON
CataloguePage {
    CatalogueLogic { id: logic }
    Button {
        onClicked: logic.refreshCatalogue()  // ✅
    }
}
```

---

## Testing

### Mock du Singleton

```qml
// Pour tests
FilmDataSingletonModel {
    property bool __testMode: true
    
    Component.onCompleted: {
        if (__testMode) {
            useTestData()
        }
    }
}
```

### Mock du Service

```qml
FilmService {
    property bool __testMode: false
    property var __mockResponse: []
    
    function fetchAllFilms() {
        if (__testMode) {
            filmsFetched(__mockResponse)
            return
        }
        // Vraie implémentation
    }
}
```

### Tests unitaires

```qml
TestCase {
    function test_modelUpdate() {
        var testData = [{id: 1, title: "Film"}]
        FilmDataSingletonModel.updateFromAPI(testData)
        
        compare(FilmDataSingletonModel.films.length, 1)
        compare(FilmDataSingletonModel.isLoading, false)
    }
}
```

---

## Évolutions futures

### Nouveaux modèles
- `UserModel` : Données utilisateur
- `CategoryModel` : Catégories de films
- `FavoritesModel` : Films favoris

### Nouveaux services
- `AuthService` : Authentification JWT
- `IMDbService` : Recherche IMDb
- `SyncService` : Synchronisation offline

### Persistance locale
```qml
Settings {
    property string cachedFilms: ""
    
    Component.onDestruction: {
        cachedFilms = JSON.stringify(FilmDataSingletonModel.films)
    }
}
```

---

## Documentation détaillée par fichier

- [FilmDataSingletonModel.md](FilmDataSingletonModel.md) - État global Singleton
- [FilmService.md](FilmService.md) - Service API REST
- [qmldir-guide.md](qmldir-guide.md) - Guide du fichier qmldir

---

## Références

- [Architecture MVC](../Architecture/mvc-pattern.md)
- [Flux de données](../Architecture/data-flow.md)
- [CatalogueLogic](../Logic/CatalogueLogic.md)
- [CataloguePage](../Pages/CataloguePage.md)
