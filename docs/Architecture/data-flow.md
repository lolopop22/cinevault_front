# Flux de données - Cinevault APP

## Introduction

Ce document détaille les différents flux de données dans l'application Cinevault, de l'action utilisateur jusqu'à la mise à jour de l'interface.

## Types de flux

### 1. Flux de lecture (Chargement du catalogue)
### 2. Flux d'écriture (Ajout d'un film)
### 3. Flux d'erreur (Gestion des échecs)
### 4. Flux de mise à jour UI (Bindings réactifs)

---

## 1. Flux de lecture : Chargement du catalogue

### Diagramme de séquence

```
Utilisateur          CataloguePage      CatalogueLogic      FilmService      Backend API      FilmDataSingletonModel      GridView
    │                      │                   │                  │                │                    │                    │
    │  Ouvre l'app         │                   │                  │                │                    │                    │
    ├─────────────────────>│                   │                  │                │                    │                    │
    │                      │                   │                  │                │                    │                    │
    │                      │ Component.        │                  │                │                    │                    │
    │                      │ onCompleted       │                  │                │                    │                    │
    │                      ├──────────────────>│                  │                │                    │                    │
    │                      │                   │                  │                │                    │                    │
    │                      │                   │ refreshCatalogue()│               │                    │                    │
    │                      │                   ├─────────────────>│                │                    │                    │
    │                      │                   │                  │                │                    │                    │
    │                      │                   │ startLoading()   │                │                    │                    │
    │                      │                   ├──────────────────┼────────────────┼───────────────────>│                    │
    │                      │                   │                  │                │   isLoading = true │                    │
    │                      │                   │                  │                │                    ├───────────────────>│
    │                      │                   │                  │                │                    │   visible = false  │
    │                      │  BusyIndicator    │                  │                │                    │                    │
    │                      │<─ visible = true ─┼──────────────────┼────────────────┼────────────────────┤                    │
    │                      │                   │                  │                │                    │                    │
    │                      │                   │ fetchAllFilms()  │                │                    │                    │
    │                      │                   ├─────────────────>│                │                    │                    │
    │                      │                   │                  │                │                    │                    │
    │                      │                   │                  │ GET /movies/   │                    │                    │
    │                      │                   │                  ├───────────────>│                    │                    │
    │                      │                   │                  │                │                    │                    │
    │                      │                   │                  │  JSON response │                    │                    │
    │                      │                   │                  │<───────────────┤                    │                    │
    │                      │                   │                  │                │                    │                    │
    │                      │                   │ filmsFetched     │                │                    │                    │
    │                      │                   │   (signal)       │                │                    │                    │
    │                      │                   │<─────────────────┤                │                    │                    │
    │                      │                   │                  │                │                    │                    │
    │                      │                   │ Transformation   │                │                    │                    │
    │                      │                   │ des données      │                │                    │                    │
    │                      │                   │                  │                │                    │                    │
    │                      │                   │ updateFromAPI()  │                │                    │                    │
    │                      │                   ├──────────────────┼────────────────┼───────────────────>│                    │
    │                      │                   │                  │                │   films = newData  │                    │
    │                      │                   │                  │                │   isLoading = false│                    │
    │                      │                   │                  │                │                    ├───────────────────>│
    │                      │                   │                  │                │                    │  model mis à jour  │
    │                      │  GridView visible │                  │                │                    │                    │
    │                      │  + films affichés │                  │                │                    │                    │
    │<─────────────────────┼───────────────────┼──────────────────┼────────────────┼────────────────────┼────────────────────┤
    │                      │                   │                  │                │                    │                    │
```

### Étapes détaillées

#### Phase 1 : Initialisation
```qml
// CataloguePage.qml
AppPage {
    CatalogueLogic {
        id: logic
        
        Component.onCompleted: {
            Qt.callLater(refreshCatalogue)  // ← Démarrage du flux
        }
    }
}
```

#### Phase 2 : Démarrage du chargement
```qml
// CatalogueLogic.qml
function refreshCatalogue() {
    // 1. Marquer le début du chargement
    Model.FilmDataSingletonModel.startLoading()  // isLoading = true
    
    // 2. Déclencher l'appel API
    filmService.fetchAllFilms()
}
```

**Effet sur l'UI** :
```qml
// CataloguePage.qml - Réaction automatique
BusyIndicator {
    visible: logic.loading  // true car binding sur isLoading
}

GridView {
    visible: !logic.loading  // false, masqué pendant chargement
}
```

#### Phase 3 : Appel réseau
```qml
// FilmService.qml
function fetchAllFilms() {
    let url = apiUrl + "/movies/"
    
    HttpRequest.get(url)
        .then(function(response) {
            // Succès : parse JSON et émet signal
            filmsFetched(JSON.parse(response))
        })
        .catch(function(error) {
            // Échec : émet signal d'erreur
            fetchError("Erreur: " + error)
        })
}
```

#### Phase 4 : Traitement de la réponse
```qml
// CatalogueLogic.qml
Connections {
    target: filmService
    
    function onFilmsFetched(films) {
        // Transformation : extraire seulement ce dont on a besoin
        var transformedFilms = films.map(function(f) {
            return {
                id: f.id,
                title: f.title,
                poster_url: f.poster_url,
                // Autres champs selon besoin
            }
        })
        
        // Mise à jour du modèle
        Model.FilmDataSingletonModel.updateFromAPI(transformedFilms)
    }
}
```

#### Phase 5 : Mise à jour de l'état global
```qml
// FilmDataSingletonModel.qml
function updateFromAPI(newFilms) {
    internal.films = newFilms      // ← Déclenche bindings
    internal.isLoading = false     // ← Déclenche bindings
    internal.lastError = ""
}
```

#### Phase 6 : Mise à jour automatique de l'UI
```qml
// CataloguePage.qml - Mise à jour automatique grâce aux bindings

BusyIndicator {
    visible: logic.loading  // false → disparaît automatiquement
}

GridView {
    model: Model.FilmDataSingletonModel.films  // Liste mise à jour automatiquement
    visible: !logic.loading && logic.hasData   // true → apparaît
    
    delegate: PosterImage {
        source: modelData.poster_url  // Chaque film affiché
    }
}
```

---

## 2. Flux d'écriture : Ajout d'un film (futur)

### Diagramme simplifié

```
Utilisateur → RecherchePage → RechercheLogic → FilmService → Backend API
                                    │                              │
                                    │                         (POST /movies/)
                                    │                              │
                                    ▼                              ▼
                            FilmDataSingletonModel ← Réponse avec nouveau film
                                    │
                                    ▼
                            CataloguePage mise à jour automatiquement
```

### Exemple de code (futur)

```qml
// RechercheLogic.qml
function addFilmToCatalogue(imdbId) {
    filmService.addFilm(imdbId)
}

Connections {
    target: filmService
    
    function onFilmAdded(newFilm) {
        // Ajouter le film à la liste existante
        var currentFilms = Model.FilmDataSingletonModel.films
        currentFilms.push(newFilm)
        Model.FilmDataSingletonModel.updateFromAPI(currentFilms)
        
        filmAdded(newFilm.id)  // Signal pour la vue
    }
}
```

---

## 3. Flux d'erreur : Gestion des échecs

### Diagramme

```
FilmService (erreur HTTP)
    │
    │ fetchError(message) signal
    ▼
CatalogueLogic (réception)
    │
    ├──> FilmDataSingletonModel.setError(message)
    │        │
    │        └──> lastError = message
    │             isLoading = false
    │
    └──> errorOccurred(message) signal
            │
            ▼
    CataloguePage (Connections)
            │
            └──> errorModal.open()
```

### Code détaillé

```qml
// FilmService.qml
HttpRequest.get(url)
    .catch(function(error) {
        fetchError("Erreur HTTP: " + error)  // ← Signal émis
    })

// CatalogueLogic.qml
Connections {
    target: filmService
    
    function onFetchError(errorMessage) {
        // 1. Enregistrer l'erreur dans le modèle
        Model.FilmDataSingletonModel.setError(errorMessage)
        
        // 2. Propager à la vue
        errorOccurred(errorMessage)  // ← Signal vers CataloguePage
    }
}

// CataloguePage.qml
Connections {
    target: logic
    
    function onErrorOccurred(message) {
        errorText.text = message
        errorModal.open()  // ← Affichage modal d'erreur
    }
}

AppModal {
    id: errorModal
    // ... contenu du modal
}
```

---

## 4. Flux de mise à jour UI : Bindings réactifs

### Principe des bindings QML

Les bindings QML créent des dépendances automatiques entre propriétés.

```qml
// Binding simple
Text {
    text: Model.FilmDataSingletonModel.films.length + " films"
    // ↑ Se met à jour automatiquement quand films change
}

// Binding conditionnel
GridView {
    visible: !logic.loading && logic.hasData
    // ↑ Réévalué quand loading OU hasData change
}

// Binding dans delegate
delegate: Rectangle {
    color: modelData.isSelected ? "blue" : "white"
    // ↑ Chaque item suit son propre état
}
```

### Chaîne de bindings

```
FilmDataSingletonModel.films (source)
    │
    ├──> CatalogueLogic.filmCount
    │        │
    │        └──> CataloguePage header text
    │
    ├──> CatalogueLogic.hasData
    │        │
    │        └──> GridView.visible
    │
    └──> GridView.model
             │
             └──> Chaque PosterImage.source
```

### Exemple complet

```qml
// FilmDataSingletonModel.qml (source de vérité)
property var films: []

// CatalogueLogic.qml (propriété dérivée)
readonly property int filmCount: Model.FilmDataSingletonModel.films.length
readonly property bool hasData: filmCount > 0

// CataloguePage.qml (UI réactive)
Text {
    text: "Mon Catalogue – " + logic.filmCount + " films"
    // Mise à jour automatique à chaque changement de films
}

GridView {
    model: Model.FilmDataSingletonModel.films
    visible: logic.hasData
    // Apparaît/disparaît automatiquement selon hasData
}
```

---

## 5. Flux lazy loading : Optimisation du chargement

### Diagramme

```
GridView scroll
    │
    │ contentYChanged
    ▼
Timer debounce (100ms)
    │
    │ triggered
    ▼
Calcul itemVisible pour chaque delegate
    │
    ├──> Item 1: visible = true  → PosterImage.shouldLoad = true  → charge
    ├──> Item 2: visible = true  → PosterImage.shouldLoad = true  → charge
    ├──> Item 3: visible = false → PosterImage.shouldLoad = false → ne charge pas
    └──> Item 4: visible = false → PosterImage.shouldLoad = false → ne charge pas
```

### Code détaillé

```qml
// CataloguePage.qml
GridView {
    id: filmGridView
    
    property real viewportTop: contentY
    property real viewportBottom: contentY + height
    
    // Timer pour éviter calculs excessifs
    Timer {
        id: visibilityUpdateTimer
        interval: 100
        repeat: false
        onTriggered: {
            filmGridView.viewportTop = filmGridView.contentY
            filmGridView.viewportBottom = filmGridView.contentY + filmGridView.height
        }
    }
    
    onContentYChanged: {
        visibilityUpdateTimer.restart()  // Debounce
    }
    
    delegate: Rectangle {
        // Calcul de visibilité
        property bool itemVisible: {
            var threshold = cataloguePage.visibilityThreshold
            var top = y
            var bottom = y + height
            return (bottom >= filmGridView.viewportTop - threshold) &&
                   (top <= filmGridView.viewportBottom + threshold)
        }
        
        PosterImage {
            enableLazyLoading: true
            isVisible: parent.itemVisible  // ← Contrôle le chargement
        }
    }
}

// PosterImage.qml
readonly property bool shouldLoad: !enableLazyLoading || isVisible

Image {
    source: posterImage.shouldLoad ? posterImage.source : ""
    // ↑ Charge seulement si shouldLoad = true
}
```

---

## Résumé des patterns de communication

### 1. Vue → Logic (Actions utilisateur)
**Méthode** : Appel de fonctions
```qml
Button {
    onClicked: logic.refreshCatalogue()
}
```

### 2. Logic → Service (Déclenchement)
**Méthode** : Appel de fonctions
```qml
filmService.fetchAllFilms()
```

### 3. Service → Logic (Résultats)
**Méthode** : Signaux
```qml
signal filmsFetched(var films)
signal fetchError(string message)
```

### 4. Logic → Model (Mise à jour état)
**Méthode** : Appel de fonctions
```qml
Model.FilmDataSingletonModel.updateFromAPI(films)
```

### 5. Model → Vue (Notification)
**Méthode** : Bindings automatiques
```qml
GridView {
    model: Model.FilmDataSingletonModel.films  // Binding
}
```

### 6. Logic → Vue (Événements spéciaux)
**Méthode** : Signaux + Connections
```qml
// Logic
signal errorOccurred(string message)

// Vue
Connections {
    target: logic
    function onErrorOccurred(message) { ... }
}
```

---

## Bonnes pratiques

### ✅ Unidirectionnel autant que possible
```
Action → Logic → Model → Vue (via bindings)
```

### ✅ Signaux pour événements ponctuels
```qml
signal filmDeleted(int filmId)
signal errorOccurred(string message)
```

### ✅ Bindings pour état continu
```qml
readonly property bool loading: Model.FilmDataSingletonModel.isLoading
```

### ❌ Éviter les cycles de dépendance
```
Vue ←→ Logic ←→ Model  // MAUVAIS
```

---

## Références

- [Architecture générale](overview.md)
- [Pattern MVC](mvc-pattern.md)
- [CatalogueLogic détaillé](../Data/CatalogueLogic.md)
