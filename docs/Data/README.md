# Documentation Modèle de Données - Cinevault APP v1.2 (Corrigée)

## Vue d'ensemble

Le dossier `qml/model/` contient les composants de la **couche Modèle** dans l'architecture MVC. Cette couche est responsable de la gestion centralisée des données et de leur notification réactive. La communication avec le backend est désormais gérée exclusivement par `qml/services/FilmService.qml`.

---

## Structure du dossier (mise à jour v1.2)

### Couche Modèle

```
qml/model/
├── FilmDataSingletonModel.qml     # État global des films (Singleton)
├── qmldir                         # Enregistrement du Singleton
```

### Couche Services (nouveau)

```
qml/services/
├── FilmService.qml                # Service de communication API (DÉPLACÉ)
├── ToastService.qml               # Service notifications (Singleton)
└── qmldir                         # Enregistrement des services
```

### Couche Composants (toasts UI)

```
qml/components/
├── PosterImage.qml                # Affichage des posters
├── ToastManager.qml               # Gestionnaire visuel toasts (composant)
├── ToastDelegate.qml              # Rendu individual toast
└── qmldir                         # Enregistrement des composants
```

### Documentation

```
docs/data/
├── README.md                      # Ce fichier
├── FilmDataSingletonModel.md      # Documentation du Singleton
├── ../services/FilmService.md     # Documentation du Service (nouvel emplacement)
├── ../services/ToastService.md    # Documentation ToastService
└── qmldir-guide.md                # Guide du fichier qmldir
```

---

## Qu'est-ce que la couche Modèle ?

### Définition

La **couche Modèle** dans l'architecture MVC est responsable de :

**✅ Gestion de l'état centralisé**
- Stockage des données (films, états de chargement, erreurs)
- Source unique de vérité pour toute l'application
- Notification automatique des changements via bindings QML

**✅ Accessibilité globale via Singleton**
- Une seule instance dans toute l'application
- Accès identique depuis n'importe quelle page/logic
- Données cohérentes et synchronisées

**❌ Ce que le Modèle ne fait PAS**
- Pas de communication API directe (déléguée au Service)
- Pas de logique métier complexe (transformation, filtrage, etc.)
- Pas d'interface utilisateur
- Pas de gestion de la navigation

### Position dans l'architecture v1.2

```
┌──────────────────────────────────────────────────────────────────┐
│                         VUE (Pages)                              │
│    CataloguePage, FilmDetailPage, etc.                          │
└─────────────▲───────────────────────────┬───────────────────────┘
              │ uses                      │ notifies
              │                           │ (bindings/signals)
              ▼                           │
┌──────────────────────────┐   ┌──────────────────────────┐
│  LOGIC (Contrôleurs)     │   │  GLOBAL SERVICES         │
│  CatalogueLogic          │   │  ToastService (Singleton)│
│  FilmDetailLogic         │   │                          │
└────────┬──────────────────┘   └──────────────────────────┘
         │ reads/writes               │ calls
         ▼                            │
  ┌──────────────────────────────────▼──────────────────────┐
  │         LAYER MODEL: FilmDataSingletonModel             │
  │         • films: []                                     │
  │         • isLoading: bool                               │
  │         • lastError: string                             │
  │         (Singleton - Une seule instance)                │
  └────────┬─────────────────────────┬─────────────────────┘
           │ (property bindings)     │
           ▼                         │
    [Toutes les Vues]              │ (HTTP calls)
                                    ▼
                    ┌──────────────────────────┐
                    │    FilmService (API)     │
                    │    (qml/services/)       │
                    └────────┬──────────────────┘
                             │ HTTP
                             ▼
                    ┌──────────────────────────┐
                    │  Backend API (Django)    │
                    └──────────────────────────┘
```

---

## Les composants principaux

### 1. FilmDataSingletonModel (État Global)

**Type** : Singleton QML  
**Localisation** : `qml/model/FilmDataSingletonModel.qml`  
**Rôle** : Stockage centralisé, notification réactive  
**Pattern** : Observer (bindings QML)

**Caractéristiques** :
- ✅ Une seule instance dans toute l'application (garantie Qt Singleton)
- ✅ Accessible depuis n'importe où via `Model.FilmDataSingletonModel`
- ✅ Mise à jour automatique de toutes les vues (bindings QML)
- ✅ Données persistantes pendant la session

**Propriétés principales** :
```qml
property var films: []           // Liste des films du catalogue
property bool isLoading: false   // État de chargement global
property string lastError: ""    // Dernier message d'erreur
```

**Méthodes principales** :
```qml
function updateFromAPI(newFilms)       // Mise à jour avec données API
function startLoading()                // Marquer le début du chargement
function setError(errorMessage)        // Enregistrer une erreur
function useTestData()                 // Charger les données de test (dev)
```

**Documentation complète** : [FilmDataSingletonModel.md](FilmDataSingletonModel.md)

---

### 2. FilmService (Communication API)

**Type** : QtObject (Service stateless)  
**Localisation** : `qml/services/FilmService.qml` (DÉPLACÉ v1.2)  
**Rôle** : Gérer tous les appels HTTP vers le backend  
**Pattern** : Service avec signaux

**Caractéristiques** :
- ✅ Encapsule tous les appels API
- ✅ Gère les erreurs réseau et parsing
- ✅ Émet des signaux pour résultats asynchrones
- ✅ Aucune transformation de données (remise brute)

**Signaux principaux** :
```qml
signal filmsFetched(var films)        // GET /api/movies/ - Succès
signal fetchError(string message)     // Erreur réseau ou parsing
```

**Méthodes principales** :
```qml
function fetchAllFilms()    // GET /api/movies/
function addFilm(imdbId)    // POST /api/movies/ (futur)
```

**Important** :
- ❌ Accès direct depuis les Pages (toujours via Logic)
- ❌ Transformation de données (délégué à Logic)
- ✅ Pas de stockage d'état

**Documentation complète** : [../services/FilmService.md](../services/FilmService.md)

---

### 3. ToastService (Notifications Globales) ✨ NOUVEAU v1.2

**Type** : Singleton QML  
**Localisation** : `qml/services/ToastService.qml`  
**Rôle** : API globale pour afficher les notifications  
**Pattern** : Singleton hybride (Singleton + Manager visuel)

**Signaux/Méthodes** :
```qml
function showSuccess(text, duration)    // Toast vert
function showError(text, duration)      // Toast rouge
function showWarning(text, duration)    // Toast orange
function showInfo(text, duration)       // Toast bleu
function initialize(manager)            // Enregistrer l'instance ToastManager
```

**Usage** :
```qml
import "../services" as Services

Services.ToastService.showError("Une erreur est survenue")
Services.ToastService.showSuccess("Film ajouté avec succès")
```

**Composants UI associés** :
- `ToastManager` : Gestionnaire visuel (qml/components/)
- `ToastDelegate` : Rendu individual toast (qml/components/)

**Documentation complète** : [../services/ToastService.md](../services/ToastService.md)

---

## Pattern Singleton revisité v1.2

### Qu'est-ce qu'un Singleton QML ?

Un **Singleton** QML (avec `pragma Singleton`) garantit qu'une seule instance existe dans toute l'application, accessible de partout.

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
    // filmData2.films = []  ← Vide ! Données divergentes
}
```

### Solution avec Singleton

```qml
// ✅ BON : Une seule instance partagée garantie

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

### Implémentation

**1. Déclarer le Singleton**

```qml
// FilmDataSingletonModel.qml
pragma Singleton  // ← Activation Singleton QML
import Felgo 4.0
import QtQuick 2.15

QtObject {
    id: filmDataSingletonModel
    
    // Propriétés partagées globalement
    property var films: []
    property bool isLoading: false
    property string lastError: ""
}
```

**2. Enregistrer dans qmldir**

```
# qml/model/qmldir
singleton FilmDataSingletonModel 1.0 FilmDataSingletonModel.qml
```

**3. Utiliser partout**

```qml
import "../model" as Model

Item {
    Text {
        text: Model.FilmDataSingletonModel.films.length + " films"
    }
}
```

---

## Flux de données - Vue d'ensemble

Voir la documentation complète détaillée : [../Architecture/data-flow.md](../Architecture/data-flow.md)

### Chargement du catalogue (Succès)

```
CatalogueLogic.refreshCatalogue()
    ↓
FilmDataSingletonModel.startLoading()  (isLoading=true)
    ↓ + BusyIndicator s'affiche
FilmService.fetchAllFilms()  (HTTP GET)
    ↓
Backend retourne JSON
    ↓
CatalogueLogic.onFilmsFetched(films)  (transformation)
    ↓
FilmDataSingletonModel.updateFromAPI(transformed)
    ↓
Binding automatique → GridView mis à jour
```

### Chargement du catalogue (Erreur)

```
FilmService HTTP échoue
    ↓
FilmService.fetchError(message)  (signal)
    ↓
CatalogueLogic.onFetchError(message)
    ↓
FilmDataSingletonModel.setError(message)
    ↓ + ToastService.showError(message)
Vue notifiée et affiche toast rouge
```

### Notifications Toast (nouveau v1.2)

```
Logic détecte erreur/succès
    ↓
Services.ToastService.showError/Success(message)  (Singleton)
    ↓
ToastManager.show(message, type)  (qml/components/)
    ↓
toastModel.append({message, type, duration})
    ↓
ListView affiche le toast (TopToBottom)
    ↓ (après 3 secondes)
Auto-destruction du toast
```

---

## Communication entre composants

### Tableau récapitulatif

| Source | Destination | Méthode | Exemple |
|--------|-------------|---------|---------|
| Vue | Logic | Fonction | `logic.refreshCatalogue()` |
| Logic | Model | Fonction | `Model.FilmDataSingletonModel.startLoading()` |
| Logic | Service | Fonction | `filmService.fetchAllFilms()` |
| Service | Logic | Signal | `filmsFetched(films)` |
| Model | Vue | Binding | `model: FilmDataSingletonModel.films` |
| Logic | Vue | Signal | `errorOccurred(message)` |
| Logic/Vue | Global Services | Fonction | `Services.ToastService.showError(msg)` |

### 1. Vue → Logic (Action utilisateur)

```qml
// Vue (CataloguePage)
Button {
    text: "Rafraîchir"
    onClicked: logic.refreshCatalogue()  // ← Appel direct
}

// Logic (CatalogueLogic)
function refreshCatalogue() {
    Model.FilmDataSingletonModel.startLoading()
    filmService.fetchAllFilms()
}
```

### 2. Logic → Model (Mise à jour état)

```qml
// Logic (CatalogueLogic)
Model.FilmDataSingletonModel.startLoading()      // ← Appel direct
Model.FilmDataSingletonModel.updateFromAPI(data) // ← Appel direct

// Model (FilmDataSingletonModel)
function startLoading() {
    internal.isLoading = true
}

function updateFromAPI(newFilms) {
    internal.films = newFilms
    internal.isLoading = false
    internal.lastError = ""
}
```

### 3. Logic → Service (Déclenchement requête)

```qml
// Logic (CatalogueLogic)
filmService.fetchAllFilms()  // ← Appel direct

// Service (FilmService)
function fetchAllFilms() {
    HttpRequest.get(apiUrl + "/movies/")
        .then(onSuccessCallback)
        .catch(onErrorCallback)
}
```

### 4. Service → Logic (Résultat asynchrone)

```qml
// Service (FilmService)
signal filmsFetched(var films)
signal fetchError(string message)

// Logic (CatalogueLogic)
Connections {
    target: filmService
    
    function onFilmsFetched(films) {
        // Traitement et stockage
        Model.FilmDataSingletonModel.updateFromAPI(transformed)
    }
    
    function onFetchError(message) {
        Model.FilmDataSingletonModel.setError(message)
        errorOccurred(message)  // Signal vers Vue
    }
}
```

### 5. Model → Vue (Notification changement)

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

```qml
// Logic (CatalogueLogic)
signal errorOccurred(string message)

// Vue (CataloguePage)
Connections {
    target: logic
    function onErrorOccurred(message) {
        Services.ToastService.showError(message)
    }
}
```

### 7. Vue/Logic → Services Globaux (nouveau v1.2)

```qml
// Partout
import "../services" as Services

Services.ToastService.showSuccess("Film ajouté")
Services.ToastService.showError("Erreur réseau")
```

---

## Responsabilités par couche

### Model : Données pures

✅ **À faire** :
```qml
function updateFromAPI(newFilms) {
    internal.films = newFilms  // ✅ Simple assignation
    internal.isLoading = false
}
```

❌ **À éviter** :
```qml
function updateFromAPI(newFilms) {
    // ❌ Pas de transformation ici !
    internal.films = newFilms.filter(f => f.year > 2020).sort()
}
```

### Service : Communication pure

✅ **À faire** :
```qml
function fetchAllFilms() {
    HttpRequest.get(apiUrl + "/movies/")
        .then(response => filmsFetched(JSON.parse(response)))  // ✅
}
```

❌ **À éviter** :
```qml
function fetchAllFilms() {
    HttpRequest.get(apiUrl + "/movies/")
        .then(response => {
            var films = JSON.parse(response)
            var filtered = films.filter(...)  // ❌ Transformation ici !
            filmsFetched(filtered)
        })
}
```

### Logic : Orchestration et transformation

✅ **À faire** :
```qml
function onFilmsFetched(films) {
    // ✅ Transformation ici (du brut au traité)
    var transformed = films.map(f => ({
        id: f.id,
        title: f.title,
        poster_url: f.poster_url
    }))
    Model.FilmDataSingletonModel.updateFromAPI(transformed)
}
```

### Vue : Affichage seulement

✅ **À faire** :
```qml
import "../model" as Model

Text {
    text: Model.FilmDataSingletonModel.films.length  // ✅ Binding
}

Connections {
    target: logic
    function onErrorOccurred(message) {
        Services.ToastService.showError(message)  // ✅ Toast uniquement
    }
}
```

❌ **À éviter** :
```qml
// ❌ Pas de logique métier dans la Vue !
GridView {
    model: {
        var films = Model.FilmDataSingletonModel.films
        return films.filter(f => f.year > 2020).sort()  // ❌
    }
}
```

---

## Bonnes pratiques générales

### 1. Singleton via namespace

```qml
// ✅ BON : Accès via import namespace
import "../model" as Model
Text {
    text: Model.FilmDataSingletonModel.films.length
}
```

### 2. Unidirectionnalité

```
Vue → Logic → Model
              ↓
              Service → Backend
```

Flux unidirectionnel = prévisible et testable

### 3. Séparation des responsabilités

- **Model** = Données
- **Service** = Réseau
- **Logic** = Orchestration
- **Vue** = Affichage
- **Components** = Composants réutilisables (PosterImage, ToastManager, etc.)

---

## Testing

### Mock du Singleton

```qml
// Pour tests unitaires
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

### Court terme
- FilmDetailLogic implémenté (v1.2) ✅
- ToastService implémenté (v1.2) ✅
- FilmDetailPage avec navigation (v1.2) ✅

### Moyen terme
- `UserModel` : Données utilisateur
- `CategoryModel` : Catégories de films
- `FavoritesModel` : Films favoris
- `AuthService` : Authentification JWT
- `IMDbService` : Recherche IMDb

### Long terme
- Persistance locale (SQLite)
- Synchronisation offline
- Cache intelligent
- Analytics service

---

## Documentation détaillée

- [FilmDataSingletonModel.md](FilmDataSingletonModel.md) - État global Singleton
- [FilmService.md](../Services/FilmService.md) - Service API REST
- [ToastService.md](../Services/ToastService.md) - Service notifications (nouveau)
- [qmldir-guide.md](qmldir-guide.md) - Guide du fichier qmldir

---

## Références

- [mvc-pattern.md](../Architecture/mvc-pattern.md) - Pattern MVC
- [data-flow.md](../Architecture/data-flow.md) - Flux de données détaillés
- [CatalogueLogic.md](../Logic/CatalogueLogic.md) - Controller catalogue
- [FilmDetailLogic.md](../Logic/FilmDetailLogic.md) - Controller détails (nouveau)
- [CataloguePage.md](../Pages/CataloguePage.md) - Page catalogue
- [FilmDetailPage.md](../Pages/FilmDetailPage.md) - Page détails (nouveau)
- [README.md](../Components/README.md) - Composants
