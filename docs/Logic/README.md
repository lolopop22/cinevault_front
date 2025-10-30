# Dossier logic - Cinevault APP v1.2

## Vue d'ensemble

Ce dossier contient les **Contrôleurs (Logic)** de l'application, responsables de l'orchestration entre les Pages (View) et le Modèle (FilmDataSingletonModel & FilmService). Chaque fichier Logic implémente le pattern MVC en séparant strictement la logique métier de l'affichage.

## Localisation

```
qml/logic/
├── CatalogueLogic.qml      # Contrôleur du catalogue de films ✅
├── FilmDetailLogic.qml     # Contrôleur de la page de détails ✨ NOUVEAU
├── RechercheLogic.qml      # Contrôleur de la recherche IMDb (à implémenter)
└── qmldir                  # Enregistrement des types QML
```

## Liste des Logic Controllers

| Controller | Statut | Page associée | Responsabilité |
|------------|--------|---------------|----------------|
| [CatalogueLogic](CatalogueLogic.md) | ✅ Implémenté | CataloguePage | Chargement et gestion du catalogue |
| [FilmDetailLogic](FilmDetailLogic.md) | ✅ Implémenté | FilmDetailPage | Chargement d'un film par ID |
| RechercheLogic | 🔜 À venir | RecherchePage | Recherche IMDb et ajout films |

---

## Rôle des Logic dans l'architecture MVC

### Position dans l'architecture

```
┌──────────────┐
│ Page (View)  │  Affichage, interactions utilisateur
└──────┬───────┘
       │ délègue
       ▼
┌──────────────────┐
│ Logic (Controller)│  Orchestration, transformation, signaux
└──────┬───────────┘
       │ interroge
       ▼
┌──────────────────┐
│ Model + Service  │  Données et API
└──────────────────┘
```

### Responsabilités d'un Logic (Controller)

**✅ Orchestration**
- Coordonner les actions entre View et Model
- Gérer le cycle de vie des données
- Déclencher les appels aux Services

**✅ Transformation**
- Adapter les données du Model pour la View
- Calculer des propriétés dérivées
- Filtrer/trier les données

**✅ État de l'UI**
- Exposer `loading`, `hasData`, `errorMessage`
- Fournir des propriétés calculées
- Gérer les états complexes

**✅ Communication par signaux**
- Émettre des signaux vers la View
- Écouter les signaux du Model/Service
- Pattern réactif et découplé

**✅ Validation** ✨ NOUVEAU
- Valider les paramètres reçus
- Vérifier la cohérence des données
- Gérer les cas d'erreur

**❌ Pas d'éléments visuels**
- Aucun composant QML visuel
- Pas d'anchors, de layout
- Pas de `width`, `height`, `visible`

**❌ Pas d'accès direct à l'UI**
- Pas de référence à `parent`
- Pas de modification directe de composants UI
- Communication uniquement par propriétés/signaux

---

## Pattern général d'un Logic

### Structure type

```qml
import QtQuick 2.15
import Felgo 4.0
import "../model" as Model

/**
 * [NomLogic] - Controller MVC
 * Orchestre la logique métier pour [Page associée]
 */
QtObject {
    id: root
    
    // ===================================
    // PROPRIÉTÉS PUBLIQUES (Readonly)
    // ===================================
    
    // État de chargement
    readonly property bool loading: false
    readonly property bool hasData: data.length > 0
    readonly property string errorMessage: ""
    
    // Données exposées
    readonly property var data: []
    readonly property int dataCount: data.length
    
    // ===================================
    // SIGNAUX PUBLICS
    // ===================================
    
    signal dataLoaded()
    signal errorOccurred(string message)
    
    // ===================================
    // PROPRIÉTÉS PRIVÉES (Internal)
    // ===================================
    
    property bool _loading: false
    property string _errorMessage: ""
    
    // ===================================
    // SERVICE INSTANCES
    // ===================================
    
    property var _service: Model.ServiceName {
        id: service
    }
    
    // ===================================
    // CONNECTIONS AUX SERVICES
    // ===================================
    
    Connections {
        target: service
        
        function onDataReceived(data) {
            // Transformation des données
            _handleDataReceived(data)
        }
        
        function onError(message) {
            _handleError(message)
        }
    }
    
    // ===================================
    // MÉTHODES PUBLIQUES
    // ===================================
    
    function loadData() {
        _loading = true
        service.fetch()
    }
    
    function reset() {
        _loading = false
        _errorMessage = ""
    }
    
    // ===================================
    // MÉTHODES PRIVÉES
    // ===================================
    
    function _handleDataReceived(data) {
        // Transformation
        // Mise à jour du Model
        _loading = false
        dataLoaded()
    }
    
    function _handleError(message) {
        _errorMessage = message
        _loading = false
        errorOccurred(message)
    }
    
    // ===================================
    // INITIALISATION
    // ===================================
    
    Component.onCompleted: {
        console.log("[NomLogic] Initialisé")
        // Auto-chargement optionnel
        loadData()
    }
}
```

---

## Principes de conception

### 1. Propriétés readonly pour exposition

**Bindings automatiques dans la View**
```qml
// Dans Logic
readonly property bool loading: _loading
readonly property int filmCount: Model.FilmDataSingletonModel.films.length

// Dans View (binding automatique)
BusyIndicator { visible: logic.loading }
Text { text: logic.filmCount + " films" }
```

### 2. Signaux pour événements ponctuels

**Communication unidirectionnelle**
```qml
// Dans Logic
signal dataLoaded()
signal errorOccurred(string message)

// Dans View
Connections {
    target: logic
    function onDataLoaded() {
        Services.ToastService.showSuccess("Données chargées")
    }
    function onErrorOccurred(message) {
        Services.ToastService.showError(message)
    }
}
```

### 3. Méthodes publiques pour actions

**API claire pour la View**
```qml
// Dans Logic
function refreshCatalogue() { /* ... */ }
function useTestData() { /* ... */ }
function loadFilm(filmId) { /* ... */ }

// Dans View
Button {
    text: "Rafraîchir"
    onClicked: logic.refreshCatalogue()
}
```

### 4. Propriétés privées (convention _)

**Encapsulation interne**
```qml
// Propriétés internes (non accessibles depuis View)
property bool _loading: false
property var _cachedData: []
property string _errorMessage: ""

// Propriétés publiques (readonly)
readonly property bool loading: _loading
readonly property string errorMessage: _errorMessage
```

---

## Pattern de validation des paramètres ✨ NOUVEAU

### Dans FilmDetailLogic

```qml
function loadFilm(filmId) {
    console.log("🔍 Chargement du film ID:", filmId)
    
    // 1. Validation du paramètre
    if (!filmId || filmId <= 0) {
        var error = "ID de film invalide: " + filmId
        console.error("❌", error)
        _errorMessage = error
        loadError(error)
        return
    }
    
    // 2. Vérification de la disponibilité du Model
    if (!Model.FilmDataSingletonModel) {
        var error = "FilmDataSingletonModel non disponible"
        console.error("❌", error)
        _errorMessage = error
        loadError(error)
        return
    }
    
    // 3. Recherche du film
    var film = _findFilmById(filmId)
    
    // 4. Gestion du résultat
    if (film) {
        _currentFilm = film
        filmLoaded(film)
    } else {
        var error = "Film introuvable avec ID: " + filmId
        console.error("❌", error)
        _errorMessage = error
        loadError(error)
    }
}
```

---

## Import et utilisation

### Import du namespace

```qml
import "../logic" as Logic
```

### Instanciation dans une Page

```qml
AppPage {
    // Instance du Logic Controller
    Logic.CatalogueLogic {
        id: logic
    }
    
    // Utilisation des propriétés
    BusyIndicator { visible: logic.loading }
    GridView { model: Model.FilmDataSingletonModel.films }
    
    // Appel des méthodes
    Button {
        text: "Rafraîchir"
        onClicked: logic.refreshCatalogue()
    }
    
    // Écoute des signaux
    Connections {
        target: logic
        function onErrorOccurred(message) {
            Services.ToastService.showError(message)
        }
    }
}
```

---

## Exemples par cas d'usage

### Cas 1 : CatalogueLogic (Liste de données)

```qml
QtObject {
    id: root
    
    // Propriétés exposées
    readonly property bool loading: Model.FilmDataSingletonModel.loading
    readonly property bool hasData: Model.FilmDataSingletonModel.films.length > 0
    readonly property int filmCount: Model.FilmDataSingletonModel.films.length
    readonly property string errorMessage: _errorMessage
    
    // Signal d'erreur
    signal errorOccurred(string message)
    
    // Service
    property var _filmService: Model.FilmService {
        id: filmService
    }
    
    // Méthode de chargement
    function refreshCatalogue() {
        console.log("🔄 Rafraîchissement du catalogue")
        Model.FilmDataSingletonModel.startLoading()
        filmService.fetchAllFilms()
    }
    
    // Connections
    Connections {
        target: filmService
        function onFilmsReceived(filmsArray) {
            Model.FilmDataSingletonModel.setFilms(filmsArray)
        }
        function onError(message) {
            _errorMessage = message
            errorOccurred(message)
        }
    }
}
```

### Cas 2 : FilmDetailLogic (Détail avec paramètre) ✨ NOUVEAU

```qml
QtObject {
    id: root
    
    // Propriétés exposées
    readonly property var currentFilm: _currentFilm
    readonly property bool loading: _loading
    readonly property string errorMessage: _errorMessage
    
    // Signaux
    signal filmLoaded(var film)
    signal loadError(string message)
    
    // Propriétés internes
    property var _currentFilm: null
    property bool _loading: false
    property string _errorMessage: ""
    
    // Méthode de chargement par ID
    function loadFilm(filmId) {
        _loading = true
        _errorMessage = ""
        
        // Validation
        if (filmId <= 0) {
            _handleError("ID invalide: " + filmId)
            return
        }
        
        // Recherche dans le Model
        var film = _findFilmById(filmId)
        
        if (film) {
            _currentFilm = film
            _loading = false
            filmLoaded(film)
        } else {
            _handleError("Film introuvable")
        }
    }
    
    function reset() {
        _currentFilm = null
        _loading = false
        _errorMessage = ""
    }
    
    // Recherche privée
    function _findFilmById(filmId) {
        var films = Model.FilmDataSingletonModel.films
        for (var i = 0; i < films.length; i++) {
            if (films[i].id === filmId) {
                return films[i]
            }
        }
        return null
    }
    
    function _handleError(message) {
        _errorMessage = message
        _loading = false
        loadError(message)
    }
}
```

---

## Bonnes pratiques

### ✅ À faire

1. **Hériter de QtObject**
```qml
QtObject {
    id: root
    // ...
}
```

2. **Propriétés readonly pour exposition**
```qml
readonly property bool loading: _loading
readonly property var data: _data
```

3. **Convention _ pour propriétés privées**
```qml
property bool _loading: false
property string _errorMessage: ""
```

4. **Signaux pour événements ponctuels**
```qml
signal dataLoaded()
signal errorOccurred(string message)
```

5. **Validation des paramètres**
```qml
function loadItem(itemId) {
    if (itemId <= 0) {
        _handleError("ID invalide")
        return
    }
    // ...
}
```

6. **Logs détaillés**
```qml
console.log("🔄 Rafraîchissement...")
console.log("✅ Données chargées:", data.length)
console.error("❌ Erreur:", message)
```

7. **Nettoyage avec reset()**
```qml
function reset() {
    _loading = false
    _errorMessage = ""
    _data = []
}
```

---

### ❌ À éviter

1. **Pas d'éléments visuels**
```qml
// ❌ MAUVAIS
QtObject {
    Rectangle { /* ... */ }  // Interdit !
    Text { /* ... */ }       // Interdit !
}

// ✅ BON
QtObject {
    readonly property string displayText: "Texte"
}
```

2. **Pas d'accès direct à parent**
```qml
// ❌ MAUVAIS
function doSomething() {
    parent.width = 100  // Interdit !
}

// ✅ BON : Communication par signaux
signal widthChanged(int newWidth)
```

3. **Pas de propriétés publiques mutables**
```qml
// ❌ MAUVAIS
property bool loading: false  // Mutable depuis l'extérieur

// ✅ BON
readonly property bool loading: _loading
property bool _loading: false  // Privée
```

4. **Pas de logique dans les bindings complexes**
```qml
// ❌ MAUVAIS (dans View)
Text {
    text: {
        var result = ""
        for (var i = 0; i < films.length; i++) {
            result += films[i].title + ", "
        }
        return result
    }
}

// ✅ BON (dans Logic)
readonly property string filmTitles: _computeFilmTitles()

function _computeFilmTitles() {
    var result = ""
    var films = Model.FilmDataSingletonModel.films
    for (var i = 0; i < films.length; i++) {
        result += films[i].title + ", "
    }
    return result
}
```

---

## Communication Logic ↔ View

### Pattern réactif recommandé

```
┌──────────────┐
│   Logic      │
│              │
│  readonly    │
│  properties  │───────► Bindings automatiques
│              │
│   signals    │───────► Connections
│              │
│   methods    │◄─────── Appels directs
└──────────────┘
```

### Exemple complet

```qml
// Logic
QtObject {
    readonly property bool loading: _loading
    readonly property int count: _count
    
    signal dataLoaded()
    signal errorOccurred(string message)
    
    function refresh() { /* ... */ }
}

// View
AppPage {
    Logic.MyLogic { id: logic }
    
    // 1. Bindings automatiques (propriétés readonly)
    BusyIndicator { visible: logic.loading }
    Text { text: logic.count + " items" }
    
    // 2. Appels de méthodes
    Button {
        onClicked: logic.refresh()
    }
    
    // 3. Connections aux signaux
    Connections {
        target: logic
        function onDataLoaded() {
            Services.ToastService.showSuccess("OK")
        }
        function onErrorOccurred(message) {
            Services.ToastService.showError(message)
        }
    }
}
```

---

## Testing

### Tests unitaires

```qml
TestCase {
    name: "CatalogueLogicTests"
    
    Logic.CatalogueLogic {
        id: logic
    }
    
    function test_initialState() {
        compare(logic.loading, false)
        compare(logic.hasData, false)
    }
    
    function test_refreshCatalogue() {
        SignalSpy {
            id: errorSpy
            target: logic
            signalName: "errorOccurred"
        }
        
        logic.refreshCatalogue()
        
        // Vérifier que le chargement démarre
        verify(logic.loading || errorSpy.count > 0)
    }
}
```

### Tests de validation

```qml
function test_loadFilm_invalidId() {
    SignalSpy {
        id: errorSpy
        target: logic
        signalName: "loadError"
    }
    
    logic.loadFilm(-1)
    
    compare(errorSpy.count, 1)
    verify(logic.errorMessage.length > 0)
}
```

---

## Checklist création Logic

- [ ] Nom en PascalCase + "Logic" (ex: `FilmDetailLogic.qml`)
- [ ] Hérite de `QtObject`
- [ ] Import du namespace Model
- [ ] Propriétés readonly pour exposition
- [ ] Propriétés privées préfixées par `_`
- [ ] Signaux pour événements ponctuels
- [ ] Méthodes publiques documentées
- [ ] Méthodes privées préfixées par `_`
- [ ] Validation des paramètres
- [ ] Gestion d'erreurs complète
- [ ] Logs détaillés
- [ ] Méthode `reset()` si nécessaire
- [ ] Aucun élément visuel
- [ ] Pas d'accès à `parent`
- [ ] Documentation créée dans docs/logic/
- [ ] Tests unitaires créés
- [ ] Enregistré dans qmldir

---

## Documentation détaillée

### Logic Controllers implémentés
- [CatalogueLogic](CatalogueLogic.md) - Controller pour la page catalogue
- [FilmDetailLogic](FilmDetailLogic.md) - Controller pour la page de détails ✨ NOUVEAU

---

## Références

### Documentation interne
- [Architecture MVC](../Architecture/mvc-pattern.md)
- [CataloguePage](../Pages/CataloguePage.md)
- [FilmDetailPage](../Pages/FilmDetailPage.md)
- [FilmDataSingletonModel](../Model/FilmDataSingletonModel.md)
- [FilmService](../Model/FilmService.md)
- [ToastService](../Components/ToastService.md)

### Documentation externe
- [Qt QtObject](https://doc.qt.io/qt-6/qml-qtqml-qtobject.html)
- [QML Signals](https://doc.qt.io/qt-6/qtqml-syntax-signals.html)
- [Property Binding](https://doc.qt.io/qt-6/qtqml-syntax-propertybinding.html)
