# Flux de données - Cinevault APP v1.2 Corrigée

## Introduction

Ce document détaille les différents flux de données dans l'application Cinevault, de l'action utilisateur jusqu'à la mise à jour de l'interface. Il couvre aussi les nouveaux flux liés à la **navigation entre pages** et au **système de notifications Toast**.

## Types de flux

### 1. Flux de lecture (Chargement du catalogue) ✅
### 2. Flux de détails (Chargement d'un film par ID)
### 3. Flux de navigation (Push vers page détails)
### 4. Flux de notifications (Toast)
### 5. Flux d'écriture (Ajout d'un film) 🔜
### 6. Flux d'erreur (Gestion des échecs) ✅
### 7. Flux de mise à jour UI (Bindings réactifs) ✅
### 8. Flux lazy loading (Optimisation du chargement) ✅

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
    │                      │ (appelle useTestData)                │                │                    │                    │
    │                      ├──────────────────>│                  │                │                    │                    │
    │                      │                   │                  │                │                    │                    │
    │                      │                   │ useTestData()    │                │                    │                    │
    │                      │                   ├──────────────────┼────────────────┼───────────────────>│                    │
    │                      │                   │                  │                │   Données test     │                    │
    │                      │                   │                  │                │   isLoading = false│                    │
    │                      │                   │                  │                │                    ├───────────────────>│
    │                      │                   │                  │                │                    │  model mis à jour  │
    │                      │  GridView visible │                  │                │                    │                    │
    │                      │  + films affichés │                  │                │                    │                    │
    │<─────────────────────┼───────────────────┼──────────────────┼────────────────┼────────────────────┼────────────────────┤
    │                      │                   │                  │                │                    │                    │
```

### Étapes détaillées

#### Phase 1 : Initialisation en Component.onCompleted

```qml
// CatalogueLogic.qml
Component.onCompleted: {
    console.log("🚀 Initialisation CatalogueLogic")
    
    // Développement : utiliser données de test
    Qt.callLater(useTestData)
    
    // Production : décommenter pour API réelle
    // Qt.callLater(refreshCatalogue)
}
```

#### Phase 2 : Chargement des données de test

```qml
// CatalogueLogic.qml
function useTestData() {
    console.log("📋 Chargement des données de test")
    Model.FilmDataSingletonModel.useTestData()
}
```

**Effet sur l'UI (bindings automatiques)** :
```qml
// CataloguePage.qml - Réaction automatique des bindings

BusyIndicator {
    visible: logic.loading  // false car pas de chargement async
}

GridView {
    visible: !logic.loading && logic.hasData  // true → apparaît
    model: Model.FilmDataSingletonModel.films  // données affichées
}
```

#### Phase 3 : Alternative API réelle (Production)

Pour passer en mode production, utiliser :

```qml
// CatalogueLogic.qml - alternative
function refreshCatalogue() {
    console.log("🔄 Rafraîchissement du catalogue depuis API")
    Model.FilmDataSingletonModel.startLoading()  // isLoading = true
    filmService.fetchAllFilms()  // HTTP GET /movies/
}

// CatalogueLogic.qml - Connections vers FilmService
Connections {
    target: filmService
    
    function onFilmsFetched(films) {
        Model.FilmDataSingletonModel.updateFromAPI(
            films.map(function(f) {
                return {
                    id: f.id,
                    title: f.title,
                    poster_url: f.poster_url
                }
            })
        )
    }
    
    function onFetchError(errorMessage) {
        Model.FilmDataSingletonModel.setError(errorMessage)
        errorOccurred(errorMessage)  // Signal vers Vue
    }
}
```

---

## 2. Flux de détails : Chargement d'un film par ID ✨ NOUVEAU

### Diagramme de séquence

```
FilmDetailPage          FilmDetailLogic      FilmDataSingletonModel
(Component.onCompleted)        │                     │
        │                      │                     │
        │  loadFilm(filmId)    │                     │
        ├─────────────────────>│                     │
        │                      │                     │
        │                      │  _findFilmById()    │
        │                      ├────────────────────>│
        │                      │  (accès films)      │
        │                      │                     │
        │                      │  film data          │
        │                      │<────────────────────┤
        │                      │                     │
        │  filmLoaded(film)    │                     │
        │  or loadError(msg)   │                     │
        │<─────────────────────┤                     │
        │                      │                     │
        │  Affichage film      │                     │
        │  ou toast erreur     │                     │
        ▼                      ▼                     ▼
```

### Étapes détaillées

#### Phase 1 : Réception et validation du paramètre

```qml
// FilmDetailPage.qml
property int filmId: -1  // Reçu via navigationStack.push(component, {filmId: X})

Component.onCompleted: {
    console.log("🆔 Film ID reçu:", filmId)
    
    // Validation stricte
    if (filmId <= 0) {
        console.error("❌ filmId invalide:", filmId)
        Services.ToastService.showError("ID de film invalide")
        navigationStack.pop()
        return
    }
    
    // Charger le film
    logic.loadFilm(filmId)
}
```

#### Phase 2 : Recherche dans le modèle global

```qml
// FilmDetailLogic.qml - Principal orchestrateur
function loadFilm(filmId) {
    console.log("🔍 Chargement du film ID:", filmId)
    
    // PHASE 1 : Validation ID
    if (filmId <= 0) {
        _handleError("ID de film invalide\n\nL'ID du film doit être un nombre positif.")
        return
    }
    
    // PHASE 2 : Accès au Model
    _loading = true
    _errorMessage = ""
    
    var films = Model.FilmDataSingletonModel.films
    
    if (!films || films.length === 0) {
        _handleError("Catalogue vide\n\nAucun film n'est disponible dans le catalogue.")
        return
    }
    
    // PHASE 3 : Recherche (O(n))
    var film = _findFilmById(filmId, films)
    
    if (film) {
        _currentFilm = film
        _errorMessage = ""
        _loading = false
        filmLoaded(_currentFilm)  // Signal vers Vue
    } else {
        // PHASE 4 : Non trouvé
        var notFoundMsg = "Film introuvable\n\nLe film avec l'ID " + filmId + " n'existe pas."
        _handleError(notFoundMsg)
    }
}

// Méthode privée pour recherche
function _findFilmById(filmId, films) {
    for (var i = 0; i < films.length; i++) {
        if (films[i].id === filmId) {
            return films[i]
        }
    }
    return null
}
```

#### Phase 3 : Affichage des résultats

```qml
// FilmDetailPage.qml
Connections {
    target: logic
    
    // Cas succès
    function onFilmLoaded(film) {
        console.log("🎬 Film chargé:", film.title)
        Services.ToastService.showSuccess("Film chargé avec succès !")
        // Titre dynamique via binding : title: logic.currentFilm ? logic.currentFilm.title : "Détails"
        // Contenu affiché automatiquement via bindings
    }
    
    // Cas erreur
    function onLoadError(message) {
        console.log("⚠️ Erreur :", message)
        Services.ToastService.showError(message)
        // Page affiche "Impossible de charger le film"
    }
}
```

---

## 3. Flux de navigation : Push vers page détails ✨ NOUVEAU

### Diagramme de séquence

```
CataloguePage               FilmDetailPageComponent      FilmDetailPage          FilmDetailLogic
(GridView delegate)                  │                         │                      │
        │                            │                         │                      │
        │  Clic sur film             │                         │                      │
        │  (MouseArea)               │                         │                      │
        │                            │                         │                      │
        │  navigationStack.push()    │                         │                      │
        │  avec filmId               │                         │                      │
        ├───────────────────────────>│                         │                      │
        │                            │                         │                      │
        │                            │  Component.create()     │                      │
        │                            │  filmId = X             │                      │
        │                            ├────────────────────────>│                      │
        │                            │                         │                      │
        │                            │                         │ Component.onCompleted│
        │                            │                         │ validation + load    │
        │                            │                         ├─────────────────────>│
        │                            │                         │                      │
        │                            │                         │ loadFilm(X)         │
        │                            │                         │ (orchestration)      │
        │                            │                         │<─────────────────────┤
        │                            │                         │                      │
        │                            │                         │ filmLoaded/loadError │
        │                            │                         │<─────────────────────┤
        │  Page affichée             │                         │                      │
        │<───────────────────────────┼─────────────────────────┤  UI mise à jour      │
        │                            │                         │  automatique         │
        │                            │                         │                      │
```

### Étapes détaillées

#### Phase 1 : Validation et préparation dans CataloguePage

```qml
// CataloguePage.qml - GridView delegate
Component {
    id: filmDetailPageComponent
    FilmDetailPage { }
}

delegate: Rectangle {
    MouseArea {
        onClicked: {
            console.log("=== NAVIGATION VERS DÉTAILS ===")
            console.log("Film cliqué:", modelData.title)
            console.log("ID:", modelData.id)
            
            // Validation des données AVANT navigation
            if (!modelData || !modelData.id || modelData.id <= 0) {
                console.error("Données film invalides")
                Services.ToastService.showError("Film invalide")
                return  // Ne pas naviguer
            }
            
            // Navigation → Phase 2
            navigationStack.push(filmDetailPageComponent, {
                filmId: modelData.id
            })
        }
    }
}
```

#### Phase 2 : Création du composant avec paramètres

```
Felgo NavigationStack interne :
navigationStack.push(component, {filmId: 5})
  ↓
FilmDetailPage créé avec propriété filmId = 5
  ↓
Component.onCompleted se déclenche
```

#### Phase 3 : Initialisation avec validation et chargement

```qml
// FilmDetailPage.qml
property int filmId: -1  // Reçoit 5

Component.onCompleted: {
    // Validation du paramètre reçu
    if (filmId <= 0) {
        console.error("❌ filmId invalide")
        Services.ToastService.showError("ID de film invalide")
        navigationStack.pop()
        return
    }
    
    // Chargement du film
    logic.loadFilm(filmId)
}
```

#### Phase 4 : Chargement et affichage

Voir section "2. Flux de détails"

---

## 4. Flux de notifications : Toast

### Diagramme de séquence

```
Page/Logic              ToastService             ToastManager      UI (ListView)
(erreur/succès)              │                        │                   │
        │                    │                        │                   │
        │  showError(msg)    │                        │                   │
        ├───────────────────>│                        │                   │
        │                    │  Délégue au manager    │                   │
        │                    ├───────────────────────>│                   │
        │                    │                        │                   │
        │                    │                        │  toastModel.      │
        │                    │                        │  append(...)      │
        │                    │                        │                   │
        │                    │                        │  ListView réagit  │
        │                    │                        ├──────────────────>│
        │                    │                        │                   │
        │                    │                        │  Toast visible    │
        │                    │                        │  (couleur type)   │
        │                    │                        │                   │
        │                    │  (après 3s + Timer)    │                   │
        │                    │<───────────────────────┤                   │
        │                    │                        │                   │
        │                    │                        │  toastModel.      │
        │                    │                        │  remove(index)    │
        │                    │                        │                   │
        │                    │                        │  Toast disparaît  │
        │                    │                        │<──────────────────┤
        │                    │                        │                   │
```

### Étapes détaillées

#### Phase 1 : Détection d'erreur et appel du service

```qml
// CatalogueLogic.qml
Connections {
    target: filmService
    
    function onFetchError(errorMessage) {
        console.error("❌ Erreur API:", errorMessage)
        
        // 1. Enregistrer dans le Model
        Model.FilmDataSingletonModel.setError(errorMessage)
        
        // 2. Propager signal vers Vue
        errorOccurred(errorMessage)  // Signal
    }
}

// CataloguePage.qml
Connections {
    target: logic
    
    function onErrorOccurred(message) {
        // ← Appel du service global (Singleton)
        Services.ToastService.showError(message)
    }
}
```

#### Phase 2 : Délégation du service vers le manager

```qml
// ToastService.qml (Singleton)
function showError(text, duration) {
    if (!_manager) {
        console.error("❌ ToastManager non initialisé")
        return
    }
    
    // Délégue l'appel au manager
    _manager.showError(text, duration)
}

function showSuccess(text, duration) {
    if (!_manager) {
        console.error("❌ ToastManager non initialisé")
        return
    }
    _manager.showSuccess(text, duration)
}
```

#### Phase 3 : Ajout au modèle et gestion du timer

```qml
// ToastManager.qml
function showError(text, duration) {
    return show(text, toastType.ERROR, duration)
}

function show(text, type, duration) {
    // Défauts
    if (typeof type === "undefined") type = toastType.INFO
    if (typeof duration === "undefined") duration = 3000
    
    console.log("📣 ToastManager.show():", text, "- Type:", type)
    
    // ← Phase 3 : Ajout à la ListModel
    toastModel.append({
        "message": text,
        "type": type,
        "duration": duration
    })
    
    console.log("✅ Toast ajouté - Total:", toastModel.count)
}
```

#### Phase 4 : Affichage via ListView et auto-destruction

```qml
// ToastManager.qml
ListView {
    id: toastList
    model: toastModel  // ListModel observable
    verticalLayoutDirection: ListView.BottomToTop  // Nouveaux en bas
    interactive: false  // Pas de scroll
    
    delegate: ToastDelegate {
        toastMessage: model.message
        toastType: model.type
        backgroundColor: toastManager.toastColors[model.type]
        iconType: toastManager.toastIcons[model.type]
        
        // Callback : suppression du toast
        onCloseRequested: {
            console.log("🗑️ Suppression du toast")
            toastModel.remove(index)  // Auto-hide après timer
        }
    }
}

// ToastDelegate.qml
Rectangle {
    id: toastItem
    
    color: backgroundColor  // Couleur selon type
    
    // Timer pour auto-hide (via Loader ou Timer interne)
    // Après toastDuration : emit closeRequested()
}
```

---

## 5. Flux d'écriture : Ajout d'un film (futur) 🔜

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
                                (via bindings)
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
        
        // Notification
        Services.ToastService.showSuccess("Film ajouté avec succès")
        
        filmAdded(newFilm.id)
    }
}
```

---

## 6. Flux d'erreur : Gestion des échecs

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
            └──> Services.ToastService.showError()
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
        // 1. Enregistrer dans le Model
        Model.FilmDataSingletonModel.setError(errorMessage)
        
        // 2. Propager vers Vue
        errorOccurred(errorMessage)
    }
}

// CataloguePage.qml
Connections {
    target: logic
    
    function onErrorOccurred(message) {
        // ✨ NOUVEAU : Toast au lieu de modal
        Services.ToastService.showError(message)
    }
}
```

---

## 7. Flux de mise à jour UI : Bindings réactifs

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

// CatalogueLogic.qml (propriété dérivée - readonly)
readonly property int filmCount: Model.FilmDataSingletonModel.films.length
readonly property bool hasData: filmCount > 0

// CataloguePage.qml (UI réactive via bindings)
Text {
    text: "Mon Catalogue – " + logic.filmCount + " films"
    // Mise à jour automatique chaque changement de films
}

GridView {
    model: Model.FilmDataSingletonModel.films
    visible: logic.hasData
    // Apparaît/disparaît automatiquement
}
```

---

## 8. Flux lazy loading : Optimisation du chargement

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

### 7. Page → Service Global (Notifications) ✨ NOUVEAU
**Méthode** : Appel direct au Singleton
```qml
Services.ToastService.showError(message)
```

### 8. Page → NavigationStack (Navigation) ✨ NOUVEAU
**Méthode** : Push avec paramètres
```qml
navigationStack.push(pageComponent, {
    filmId: modelData.id
})
```

---

## Bonnes pratiques

### ✅ Unidirectionnel autant que possible
```
Action → Logic → Model → Vue (via bindings)
Navigation → Nouvelle page → Chargement des données
```

### ✅ Signaux pour événements ponctuels
```qml
signal filmDeleted(int filmId)
signal errorOccurred(string message)
signal filmLoaded(var film)
```

### ✅ Bindings pour état continu
```qml
readonly property bool loading: Model.FilmDataSingletonModel.isLoading
```

### ✅ Services globaux pour contexte transversal
```qml
Services.ToastService.showSuccess("OK")
```

### ✅ Validation des paramètres à la réception
```qml
Component.onCompleted: {
    if (filmId <= 0) {
        Services.ToastService.showError("ID invalide")
        navigationStack.pop()
        return
    }
    logic.loadFilm(filmId)
}
```

### ✅ Propriétés readonly pour exposition, privées (_) pour état interne
```qml
// Privé
property bool _loading: false
property string _errorMessage: ""

// Public
readonly property bool loading: _loading
readonly property string errorMessage: _errorMessage
```

### ❌ Éviter les cycles de dépendance
```
Vue ←→ Logic ←→ Model  // MAUVAIS
```

---

## Références

- [Architecture générale](overview.md)
- [Pattern MVC](mvc-pattern.md)
- [Navigation système](../Pages/navigation.md)
- [CataloguePage détaillé](../Pages/CataloguePage.md)
- [FilmDetailPage détaillé](../Pages/FilmDetailPage.md)
- [CatalogueLogic](../Logic/CatalogueLogic.md)
- [FilmDetailLogic](../Logic/FilmDetailLogic.md)
- [ToastService](../Components/ToastService.md)
