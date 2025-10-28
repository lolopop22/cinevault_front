# FilmDataSingletonModel - Documentation    complète

## Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Qu'est-ce qu'un Singleton ?](#quest-ce-quun-singleton)
3. [Structure du fichier](#structure-du-fichier)
4. [Propriétés publiques](#propriétés-publiques)
5. [Méthodes publiques](#méthodes-publiques)
6. [Propriétés internes](#propriétés-internes)
7. [États du modèle](#états-du-modèle)
8. [Flux de données](#flux-de-données)
9. [Bindings automatiques](#bindings-automatiques)
10. [Exemples d'utilisation](#exemples-dutilisation)
11. [Debugging et logs](#debugging-et-logs)
12. [Bonnes pratiques](#bonnes-pratiques)
13. [Testing](#testing)
14. [Évolutions futures](#évolutions-futures)

---

## Vue d'ensemble

### Définition

`FilmDataSingletonModel` est un **Singleton QML** qui représente la **source unique de vérité** pour l'état global des films dans Cinevault APP.

### Localisation

```
qml/model/FilmDataSingletonModel.qml
```

### Rôle

✅ **Stockage centralisé** des données de films  
✅ **État de chargement** partagé par toute l'application  
✅ **Gestion des erreurs** centralisée  
✅ **Notification automatique** via property bindings QML  
✅ **Pas de logique métier** - seulement stockage pur  

### Caractéristiques

- **Type** : Singleton (une seule instance)
- **Accessible depuis** : N'importe où via `Model.FilmDataSingletonModel`
- **Mutabilité** : Propriétés en lecture seule exposées via alias
- **Persistance** : Durant toute la session de l'application

---

## Qu'est-ce qu'un Singleton ?

### Définition du pattern

Un **Singleton** est un pattern de conception qui garantit qu'une classe n'a qu'**une seule instance** dans toute l'application et fournit un **point d'accès global** à cette instance.

### Problème résolu

#### Sans Singleton (❌ Problème)

```qml
// Page 1
import "../model/FilmData.qml" as FilmData

Item {
    FilmData { 
        id: filmData1 
    }
    
    Component.onCompleted: {
        filmData1.films = [
            {id: 1, title: "Avatar"},
            {id: 2, title: "Titanic"}
        ]
        console.log("Page 1 films:", filmData1.films.length)  // 2
    }
}

// Page 2
import "../model/FilmData.qml" as FilmData

Item {
    FilmData { 
        id: filmData2  // ← Instance DIFFÉRENTE !
    }
    
    Component.onCompleted: {
        console.log("Page 2 films:", filmData2.films.length)  // 0 ← Vide !
    }
}
```

**Problème** : Chaque page a ses propres données, pas de synchronisation

#### Avec Singleton (✅ Solution)

```qml
// Page 1
import "../model" as Model

Item {
    Component.onCompleted: {
        Model.FilmDataSingletonModel.films = [
            {id: 1, title: "Avatar"},
            {id: 2, title: "Titanic"}
        ]
        console.log("Page 1:", Model.FilmDataSingletonModel.films.length)  // 2
    }
}

// Page 2
import "../model" as Model

Item {
    Component.onCompleted: {
        console.log("Page 2:", Model.FilmDataSingletonModel.films.length)  // 2 ← Mêmes données !
    }
}
```

**Solution** : Une seule instance, données partagées partout

### Avantages du Singleton

| Avantage | Description |
|----------|-------------|
| **Source unique de vérité** | Toutes les pages voient les mêmes données |
| **Synchronisation automatique** | Une modification = mise à jour partout |
| **Simplicité d'accès** | Pas besoin de passer les données entre composants |
| **Économie mémoire** | Une seule instance au lieu de multiples copies |
| **Cohérence garantie** | Impossible d'avoir des états incohérents |

### Implémentation en QML

**1. Déclaration du Singleton**

```qml
// FilmDataSingletonModel.qml
pragma Singleton  // ← MOT-CLÉ CRUCIAL
import Felgo 4.0
import QtQuick 2.15

Item {
    id: filmDataSingletonModel
    // ... propriétés
}
```

**2. Enregistrement dans qmldir**

```
# qmldir
singleton FilmDataSingletonModel 1.0 FilmDataSingletonModel.qml
          ↑                      ↑    ↑
          │                      │    └─ Nom du fichier
          │                      └────── Version
          └───────────────────────────── Type = singleton
```

**3. Import et utilisation**

```qml
import "../model" as Model

Item {
    Text {
        // Accès direct au Singleton (pas d'instanciation)
        text: Model.FilmDataSingletonModel.films.length + " films"
    }
}
```

---

## Structure du fichier

### Imports

```qml
pragma Singleton
import Felgo 4.0
import QtQuick 2.15
```

### Structure globale

```qml
Item {
    id: filmDataSingletonModel
    
    // ═══════════════════════════════════════════════
    // PROPRIÉTÉS PUBLIQUES (READONLY VIA ALIAS)
    // ═══════════════════════════════════════════════
    
    readonly property alias films: internal.films
    readonly property alias isLoading: internal.isLoading
    readonly property alias lastError: internal.lastError
    
    // ═══════════════════════════════════════════════
    // OBJET INTERNE (STOCKAGE RÉEL)
    // ═══════════════════════════════════════════════
    
    QtObject {
        id: internal
        
        property bool isLoading: false
        property bool hasRealData: false
        property string lastError: ""
        property var testFilms: [...]
        property var films: []
    }
    
    // ═══════════════════════════════════════════════
    // MÉTHODES PUBLIQUES
    // ═══════════════════════════════════════════════
    
    function startLoading() { }
    function updateFromAPI(newFilms) { }
    function setError(errorMessage) { }
    function useTestData() { }
    
    // ═══════════════════════════════════════════════
    // INITIALISATION
    // ═══════════════════════════════════════════════
    
    Component.onCompleted { }
}
```

---

## Propriétés publiques

### 1. `films` (array)

Liste des films du catalogue.

**Type** : `var` (JavaScript array)  
**Lecture seule** : ✅ (via `readonly property alias`)  
**Valeur initiale** : `[]` (array vide)  
**Modifiable via** : `updateFromAPI()` uniquement

**Structure d'un objet film** :

```javascript
{
    id: number,           // Identifiant unique (obligatoire)
    title: string,        // Titre du film (obligatoire)
    poster_url: string,   // URL du poster (obligatoire)
    // Autres champs optionnels selon backend
}
```

**Exemple de données** :

```javascript
[
    {
        id: 1,
        title: "Avatar",
        poster_url: "https://image.tmdb.org/t/p/w342/jRXYjXNq0Cs2TcJjLkki24MLp7u.jpg"
    },
    {
        id: 2,
        title: "Titanic",
        poster_url: "https://image.tmdb.org/t/p/w342/9xjZS2rlVxm8SFx8kPC3aIGCOYQ.jpg"
    }
]
```

**Utilisation** :

```qml
// Affichage dans une GridView
GridView {
    model: Model.FilmDataSingletonModel.films
    delegate: Item {
        Text { text: modelData.title }
        Image { source: modelData.poster_url }
    }
}

// Comptage
Text {
    text: Model.FilmDataSingletonModel.films.length + " films"
}

// Vérification présence
property bool hasFilms: Model.FilmDataSingletonModel.films.length > 0

// Itération
Repeater {
    model: Model.FilmDataSingletonModel.films
    delegate: Text { text: modelData.title }
}
```

**Pourquoi readonly ?**

```qml
// ❌ IMPOSSIBLE : Modification directe
Model.FilmDataSingletonModel.films = [...]  // Erreur: readonly

// ✅ CORRECT : Via méthode publique
Model.FilmDataSingletonModel.updateFromAPI([...])
```

Cela garantit que **seules les méthodes contrôlées** peuvent modifier les données.

---

### 2. `isLoading` (bool)

Indique si un chargement est en cours.

**Type** : `bool`  
**Lecture seule** : ✅  
**Valeur initiale** : `false`  
**Modifiable via** : `startLoading()`, `updateFromAPI()`, `setError()`, `useTestData()`

**États possibles** :

| Valeur | Signification |
|--------|--------------|
| `true` | Chargement en cours (API call active) |
| `false` | Pas de chargement (repos, succès ou erreur) |

**Utilisation** :

```qml
// Indicateur de chargement
BusyIndicator {
    visible: Model.FilmDataSingletonModel.isLoading
    running: Model.FilmDataSingletonModel.isLoading
}

// Masquer contenu pendant chargement
GridView {
    visible: !Model.FilmDataSingletonModel.isLoading
}

// Message de chargement
Text {
    visible: Model.FilmDataSingletonModel.isLoading
    text: "Chargement en cours..."
}

// Désactiver boutons pendant chargement
Button {
    text: "Rafraîchir"
    enabled: !Model.FilmDataSingletonModel.isLoading
}
```

**Cycle de vie** :

```
Initial: isLoading = false
   ↓
startLoading()
   ↓
isLoading = true
   ↓
API call...
   ↓
updateFromAPI() OU setError()
   ↓
isLoading = false
```

---

### 3. `lastError` (string)

Dernier message d'erreur survenu.

**Type** : `string`  
**Lecture seule** : ✅  
**Valeur initiale** : `""` (chaîne vide)  
**Modifiable via** : `setError()`, `startLoading()`, `updateFromAPI()`, `useTestData()`

**États possibles** :

| Valeur | Signification |
|--------|--------------|
| `""` (vide) | Pas d'erreur |
| `"Erreur: ..."` | Erreur présente |

**Types d'erreurs** :

```javascript
// Erreur réseau
"Erreur HTTP et/ou Échec de connexion au serveur : NetworkError"

// Erreur HTTP spécifique
"Erreur HTTP et/ou Échec de connexion au serveur : 404"
"Erreur HTTP et/ou Échec de connexion au serveur : 500"

// Erreur parsing
"Réponse JSON invalide"
```

**Utilisation** :

```qml
// Vérifier présence d'erreur
property bool hasError: Model.FilmDataSingletonModel.lastError !== ""

// Afficher message d'erreur
Text {
    visible: Model.FilmDataSingletonModel.lastError !== ""
    text: Model.FilmDataSingletonModel.lastError
    color: "red"
}

// Modal d'erreur
AppModal {
    visible: Model.FilmDataSingletonModel.lastError !== ""
    
    Text {
        text: Model.FilmDataSingletonModel.lastError
    }
    
    Button {
        text: "OK"
        onClicked: {
            // Effacer l'erreur en relançant
            logic.refreshCatalogue()
        }
    }
}

// Style conditionnel
Rectangle {
    color: Model.FilmDataSingletonModel.lastError !== "" 
        ? "#ffebee"  // Rouge si erreur
        : "#ffffff"  // Blanc sinon
}
```

**Cycle de vie** :

```
Initial: lastError = ""
   ↓
startLoading()
   ↓
lastError = ""  (réinitialisation)
   ↓
setError("message")
   ↓
lastError = "message"
   ↓
startLoading() OU updateFromAPI()
   ↓
lastError = ""  (réinitialisation)
```

---

## Méthodes publiques

### 1. `startLoading()`

Marque le début d'un chargement de données.

**Paramètres** : Aucun  
**Retour** : `void`  
**Appelé par** : CatalogueLogic avant `fetchAllFilms()`

**Effets** :

```javascript
internal.isLoading = true    // ← Active l'indicateur
internal.lastError = ""      // ← Efface erreur précédente
// films reste inchangé
```

**Implémentation** :

```qml
function startLoading() {
    console.log("🔄 Démarrage du chargement des films...")
    internal.isLoading = true
    internal.lastError = ""
}
```

**Cas d'usage** :

```qml
// Dans CatalogueLogic
function refreshCatalogue() {
    // 1. Marquer début du chargement
    Model.FilmDataSingletonModel.startLoading()
    
    // 2. Lancer appel API
    filmService.fetchAllFilms()
}
```

**Effet sur l'UI** :

```qml
// BusyIndicator s'affiche automatiquement
BusyIndicator {
    visible: Model.FilmDataSingletonModel.isLoading  // devient true
}

// GridView se masque automatiquement
GridView {
    visible: !Model.FilmDataSingletonModel.isLoading  // devient false
}
```

---

### 2. `updateFromAPI(newFilms)`

Met à jour la liste des films avec les données de l'API.

**Paramètres** :

- `newFilms` (array) : Nouvelle liste de films

**Retour** : `void`  
**Appelé par** : CatalogueLogic après succès de `fetchAllFilms()`

**Effets** :

```javascript
internal.films = newFilms          // ← Remplace films
internal.isLoading = false         // ← Désactive chargement
internal.lastError = ""            // ← Efface erreur
internal.hasRealData = true        // ← Marque données réelles
```

**Implémentation** :

```qml
function updateFromAPI(newFilms) {
    console.log("✅ Films mis à jour depuis l'API:", newFilms.length, "films chargés")
    internal.films = newFilms
    internal.isLoading = false
    internal.lastError = ""
    internal.hasRealData = true
}
```

**Cas d'usage** :

```qml
// Dans CatalogueLogic
Connections {
    target: filmService
    
    function onFilmsFetched(films) {
        // Transformation des données
        var transformedFilms = films.map(function(f) {
            return {
                id: f.id,
                title: f.title,
                poster_url: f.poster_url
            }
        })
        
        // Mise à jour du Model
        Model.FilmDataSingletonModel.updateFromAPI(transformedFilms)
    }
}
```

**Effet sur l'UI** :

```qml
// GridView se met à jour automatiquement
GridView {
    model: Model.FilmDataSingletonModel.films  // Nouvelles données
    visible: !Model.FilmDataSingletonModel.isLoading  // Devient visible
}

// BusyIndicator disparaît automatiquement
BusyIndicator {
    visible: Model.FilmDataSingletonModel.isLoading  // Devient false
}

// Compteur mis à jour
Text {
    text: Model.FilmDataSingletonModel.films.length + " films"  // Nouveau compte
}
```

---

### 3. `setError(errorMessage)`

Enregistre une erreur lors du chargement.

**Paramètres** :

- `errorMessage` (string) : Message d'erreur descriptif

**Retour** : `void`  
**Appelé par** : CatalogueLogic après échec de `fetchAllFilms()`

**Effets** :

```javascript
internal.isLoading = false               // ← Désactive chargement
internal.lastError = errorMessage        // ← Enregistre message
// films reste inchangé (conserve données précédentes)
```

**Implémentation** :

```qml
function setError(errorMessage) {
    console.log("❌ Erreur de chargement:", errorMessage)
    internal.isLoading = false
    internal.lastError = errorMessage
}
```

**Cas d'usage** :

```qml
// Dans CatalogueLogic
Connections {
    target: filmService
    
    function onFetchError(errorMessage) {
        // Enregistrer l'erreur
        Model.FilmDataSingletonModel.setError(errorMessage)
        
        // Propager à la Vue
        errorOccurred(errorMessage)
    }
}
```

**Effet sur l'UI** :

```qml
// BusyIndicator disparaît
BusyIndicator {
    visible: Model.FilmDataSingletonModel.isLoading  // Devient false
}

// Modal d'erreur s'affiche (via signal errorOccurred)
AppModal {
    Text {
        text: Model.FilmDataSingletonModel.lastError
    }
}

// Films précédents restent affichés
GridView {
    model: Model.FilmDataSingletonModel.films  // Données précédentes conservées
}
```

**Note importante** : Les films existants ne sont **pas effacés** en cas d'erreur. Cela permet de continuer à afficher le catalogue précédent.

---

### 4. `useTestData()`

Charge des données de test pour le développement.

**Paramètres** : Aucun  
**Retour** : `void`  
**Appelé par** : CatalogueLogic en mode développement

**Effets** :

```javascript
internal.films = internal.testFilms  // ← Charge données test
internal.isLoading = false           // ← Pas de chargement
internal.lastError = ""              // ← Pas d'erreur
internal.hasRealData = false         // ← Marque données test
```

**Implémentation** :

```qml
function useTestData() {
    console.log("🧪 Utilisation des données de test:", internal.testFilms.length, "films")
    internal.films = internal.testFilms
    internal.isLoading = false
    internal.lastError = ""
    internal.hasRealData = false
}
```

**Cas d'usage** :

```qml
// Dans CatalogueLogic - Mode développement
Component.onCompleted: {
    // Option 1 : Données de test (développement)
    Qt.callLater(useTestData)
    
    // Option 2 : API réelle (production)
    // Qt.callLater(refreshCatalogue)
}
```

**Avantages** :

✅ Développement sans backend  
✅ Tests d'interface rapides  
✅ Données variées (succès + erreurs)  
✅ Pas besoin de connexion réseau  

---

## Propriétés internes

### Objet `internal`

```qml
QtObject {
    id: internal
    
    property bool isLoading: false
    property bool hasRealData: false
    property string lastError: ""
    property var testFilms: [...]
    property var films: []
}
```

### `internal.hasRealData` (bool)

**Type** : `bool`  
**Usage** : Différencier données réelles (API) des données de test  
**Non exposé** : Propriété privée

**Valeurs** :

| Valeur | Signification |
|--------|--------------|
| `true` | Données proviennent de l'API (updateFromAPI) |
| `false` | Données de test (useTestData) ou initial |

**Utilité future** :

```qml
// Afficher badge "MODE TEST"
Text {
    visible: !internal.hasRealData
    text: "MODE TEST"
    color: "orange"
}
```

### `internal.testFilms` (array)

**Type** : `var` (array)  
**Usage** : Données de test pour développement  
**Contenu** : 12-14 films fictifs avec URLs variées

**Structure** :

```javascript
property var testFilms: [
    // Films avec posters valides
    { 
        id: 1, 
        title: "Avatar", 
        poster_url: "https://image.tmdb.org/t/p/w342/jRXYjXNq0Cs2TcJjLkki24MLp7u.jpg"
    },
    { 
        id: 2, 
        title: "Titanic", 
        poster_url: "https://image.tmdb.org/t/p/w342/9xjZS2rlVxm8SFx8kPC3aIGCOYQ.jpg"
    },
    
    // Films avec URLs invalides (pour tester erreur)
    { 
        id: 999, 
        title: "Test Erreur Image", 
        poster_url: "https://invalid-url.com/notfound.jpg"
    }
]
```

**Variété des tests** :

- ✅ URLs valides (TMDB)
- ✅ URLs invalides (erreur 404)
- ✅ Titres courts et longs
- ✅ Différents genres de films

---

## États du modèle

### Diagramme d'états

```
┌─────────────┐
│   Initial   │  films: [], isLoading: false, lastError: ""
└──────┬──────┘
       │
       │ startLoading()
       ▼
┌─────────────┐
│   Loading   │  films: [...], isLoading: true, lastError: ""
└──────┬──────┘
       │
       ├──────────────┬────────────────┐
       │              │                │
       │ updateFromAPI│ setError       │ (timeout/cancel)
       ▼              ▼                ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│   Success   │  │    Error    │  │   Initial   │
└─────────────┘  └─────────────┘  └─────────────┘
 isLoading:false  isLoading:false  isLoading:false
 films:[new...]   films:[old...]   films:[]
 lastError:""     lastError:"msg"  lastError:""
```

### État 1 : Initial

**Conditions** :

```javascript
{
    films: [],
    isLoading: false,
    lastError: ""
}
```

**Quand** : Au démarrage de l'application, avant tout chargement

**UI correspondante** :
- Pas de BusyIndicator
- Message "Aucun film"
- GridView vide

### État 2 : Loading

**Conditions** :

```javascript
{
    films: [...],        // Films précédents conservés
    isLoading: true,
    lastError: ""
}
```

**Quand** : Après appel de `startLoading()`, pendant l'appel API

**UI correspondante** :
- BusyIndicator visible
- GridView masqué
- Message "Chargement..."

### État 3 : Success

**Conditions** :

```javascript
{
    films: [...newFilms],  // Nouveaux films chargés
    isLoading: false,
    lastError: ""
}
```

**Quand** : Après appel réussi de `updateFromAPI()`

**UI correspondante** :
- BusyIndicator masqué
- GridView visible avec nouveaux films
- Compteur mis à jour

### État 4 : Error

**Conditions** :

```javascript
{
    films: [...],        // Films précédents conservés
    isLoading: false,
    lastError: "Erreur: ..."
}
```

**Quand** : Après appel de `setError()`

**UI correspondante** :
- BusyIndicator masqué
- Modal d'erreur visible
- Films précédents conservés dans GridView

---

## Flux de données

### Flux complet : Chargement réussi

```
1. CataloguePage charge
   Component.onCompleted
        ↓
2. CatalogueLogic.refreshCatalogue()
        ↓
3. FilmDataSingletonModel.startLoading()
   ├─> isLoading = true
   └─> lastError = ""
        ↓
4. Vue réagit (binding)
   ├─> BusyIndicator.visible = true
   └─> GridView.visible = false
        ↓
5. FilmService.fetchAllFilms()
   HttpRequest.get("/movies/")
        ↓
6. Backend répond
   JSON: [{id:1, title:"..."}, ...]
        ↓
7. FilmService émet signal
   filmsFetched(films)
        ↓
8. CatalogueLogic reçoit
   onFilmsFetched(films)
   Transforme les données
        ↓
9. FilmDataSingletonModel.updateFromAPI(transformedFilms)
   ├─> films = transformedFilms
   ├─> isLoading = false
   └─> lastError = ""
        ↓
10. Vue réagit (binding)
    ├─> BusyIndicator.visible = false
    ├─> GridView.visible = true
    └─> GridView.model = films (affiche)
```

### Flux complet : Chargement avec erreur

```
1-4. (Identique jusqu'au chargement)
        ↓
5. FilmService.fetchAllFilms()
   HttpRequest.get("/movies/") échoue
        ↓
6. catch(error)
        ↓
7. FilmService émet signal
   fetchError("Erreur HTTP: ...")
        ↓
8. CatalogueLogic reçoit
   onFetchError(errorMessage)
        ↓
9. FilmDataSingletonModel.setError(errorMessage)
   ├─> isLoading = false
   └─> lastError = errorMessage
        ↓
10. CatalogueLogic propage
    errorOccurred(errorMessage)
        ↓
11. Vue réagit
    ├─> BusyIndicator.visible = false
    ├─> ErrorModal.open()
    └─> GridView conserve films précédents
```

---

## Bindings automatiques

### Qu'est-ce qu'un binding ?

Un **binding** en QML est une liaison automatique entre deux propriétés. Quand la propriété source change, la propriété cible se met à jour automatiquement.

### Exemple simple

```qml
// Source
Model.FilmDataSingletonModel.films = [...]

// Binding automatique
Text {
    text: Model.FilmDataSingletonModel.films.length + " films"
    // ↑ Se met à jour automatiquement quand films change
}
```

### Bindings dans l'application

#### Binding 1 : Affichage du nombre de films

```qml
Text {
    text: Model.FilmDataSingletonModel.films.length + " films"
}

// Quand films change de [] à [{...}, {...}]
// Le texte passe automatiquement de "0 films" à "2 films"
```

#### Binding 2 : Visibilité du BusyIndicator

```qml
BusyIndicator {
    visible: Model.FilmDataSingletonModel.isLoading
}

// Quand isLoading passe de false à true
// Le BusyIndicator apparaît automatiquement
```

#### Binding 3 : Modèle de la GridView

```qml
GridView {
    model: Model.FilmDataSingletonModel.films
}

// Quand films change
// La GridView se repeuple automatiquement avec les nouveaux films
```

#### Binding 4 : Visibilité conditionnelle

```qml
GridView {
    visible: !Model.FilmDataSingletonModel.isLoading && 
             Model.FilmDataSingletonModel.films.length > 0
}

// La GridView est visible seulement si :
// - Pas de chargement en cours (isLoading = false)
// - ET il y a des films (films.length > 0)
```

### Chaîne de bindings

```
FilmDataSingletonModel.films change
           ↓
    ┌──────┴──────┬──────────┬───────────┐
    │             │          │           │
    ▼             ▼          ▼           ▼
GridView.model  Text.text  hasData   filmCount
    │
    └─> Chaque delegate se met à jour
```

Un seul changement dans le Model déclenche automatiquement toutes les mises à jour nécessaires dans l'UI.

---

## Exemples d'utilisation

### Exemple 1 : Affichage simple

```qml
import "../model" as Model

AppPage {
    Text {
        text: "Vous avez " + 
              Model.FilmDataSingletonModel.films.length + 
              " films dans votre catalogue"
    }
}
```

### Exemple 2 : Liste avec GridView

```qml
import "../model" as Model
import "../components" as Components

AppPage {
    GridView {
        anchors.fill: parent
        cellWidth: dp(100)
        cellHeight: dp(150)
        
        model: Model.FilmDataSingletonModel.films
        
        delegate: Components.PosterImage {
            width: GridView.view.cellWidth
            height: GridView.view.cellHeight
            source: modelData.poster_url
        }
    }
}
```

### Exemple 3 : Indicateur de chargement

```qml
import "../model" as Model

AppPage {
    Column {
        anchors.centerIn: parent
        spacing: dp(10)
        visible: Model.FilmDataSingletonModel.isLoading
        
        BusyIndicator {
            anchors.horizontalCenter: parent.horizontalCenter
            running: parent.visible
        }
        
        Text {
            text: "Chargement du catalogue..."
        }
    }
}
```

### Exemple 4 : Gestion des erreurs

```qml
import "../model" as Model

AppPage {
    Rectangle {
        anchors.fill: parent
        visible: Model.FilmDataSingletonModel.lastError !== ""
        color: "#ffebee"
        
        Column {
            anchors.centerIn: parent
            spacing: dp(16)
            
            AppIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                iconType: IconType.exclamationtriangle
                color: "#f44336"
                size: dp(48)
            }
            
            Text {
                text: Model.FilmDataSingletonModel.lastError
                color: "#c62828"
                wrapMode: Text.WordWrap
            }
            
            Button {
                text: "Réessayer"
                onClicked: logic.refreshCatalogue()
            }
        }
    }
}
```

### Exemple 5 : État vide

```qml
import "../model" as Model

AppPage {
    Column {
        anchors.centerIn: parent
        spacing: dp(16)
        visible: !Model.FilmDataSingletonModel.isLoading &&
                 Model.FilmDataSingletonModel.films.length === 0
        
        AppIcon {
            anchors.horizontalCenter: parent.horizontalCenter
            iconType: IconType.inbox
            size: dp(64)
            color: "#9e9e9e"
        }
        
        Text {
            text: "Aucun film dans le catalogue"
            font.pixelSize: sp(18)
        }
        
        Button {
            text: "Ajouter un film"
            onClicked: navigationStack.push(recherchePageComponent)
        }
    }
}
```

### Exemple 6 : Compteur avec style

```qml
import "../model" as Model

Rectangle {
    width: dp(60)
    height: dp(30)
    radius: dp(15)
    color: Theme.colors.tintColor
    
    Text {
        anchors.centerIn: parent
        text: Model.FilmDataSingletonModel.films.length
        color: "white"
        font.bold: true
    }
}
```

---

## Debugging et logs

### Logs automatiques

Le Singleton génère des logs console pour faciliter le debugging :

**startLoading()** :
```
🔄 Démarrage du chargement des films...
```

**updateFromAPI()** :
```
✅ Films mis à jour depuis l'API: 25 films chargés
```

**setError()** :
```
❌ Erreur de chargement: Erreur HTTP et/ou Échec de connexion au serveur : 404
```

**useTestData()** :
```
🧪 Utilisation des données de test: 14 films
```

**Component.onCompleted** :
```
=== DEBUG FilmDataModel ===
FilmDataSingleton initialisé - films: 0
```

### Debug manuel

```qml
// Dans n'importe quelle page
Component.onCompleted: {
    console.log("=== État FilmDataSingletonModel ===")
    console.log("Films:", Model.FilmDataSingletonModel.films.length)
    console.log("Loading:", Model.FilmDataSingletonModel.isLoading)
    console.log("Error:", Model.FilmDataSingletonModel.lastError)
    
    // Détail des films
    for (var i = 0; i < Model.FilmDataSingletonModel.films.length; i++) {
        console.log("Film", i, ":", Model.FilmDataSingletonModel.films[i].title)
    }
}
```

### Debugging en production

Pour désactiver les logs en production :

```qml
property bool __debug: Qt.application.arguments.indexOf("--debug") !== -1

function updateFromAPI(newFilms) {
    if (__debug) {
        console.log("✅ Films mis à jour:", newFilms.length)
    }
    internal.films = newFilms
    internal.isLoading = false
    internal.lastError = ""
}
```

---

## Bonnes pratiques

### ✅ À faire

**1. Toujours accéder via namespace Model**

```qml
// ✅ BON
import "../model" as Model

Item {
    property int filmCount: Model.FilmDataSingletonModel.films.length
}

// ❌ MAUVAIS
import "../model/FilmDataSingletonModel.qml"  // N'existe pas pour Singleton
```

**2. Utiliser pour données partagées**

```qml
// ✅ BON : Plusieurs pages accèdent aux mêmes données
Page1 {
    GridView {
        model: Model.FilmDataSingletonModel.films
    }
}

Page2 {
    Text {
        text: Model.FilmDataSingletonModel.films.length + " films"
    }
}
```

**3. Laisser Logic gérer les mutations**

```qml
// ✅ BON : Via Logic
Button {
    onClicked: logic.refreshCatalogue()
}

// CatalogueLogic appelle FilmDataSingletonModel.updateFromAPI()
```

**4. Bindings pour affichage uniquement**

```qml
// ✅ BON : Binding simple
Text {
    text: Model.FilmDataSingletonModel.films.length + " films"
}
```

### ❌ À éviter

**1. Ne jamais modifier directement depuis la Vue**

```qml
// ❌ MAUVAIS
Button {
    onClicked: {
        Model.FilmDataSingletonModel.films.push(newFilm)  // ❌ Impossible (readonly)
    }
}

// ✅ BON : Via Logic
Button {
    onClicked: logic.addFilm(newFilm)
}
```

**2. Ne pas dupliquer les données**

```qml
// ❌ MAUVAIS : Copie inutile
Item {
    property var myFilms: Model.FilmDataSingletonModel.films
    
    GridView {
        model: myFilms  // ❌ Intermédiaire inutile
    }
}

// ✅ BON : Utilisation directe
Item {
    GridView {
        model: Model.FilmDataSingletonModel.films  // ✅ Direct
    }
}
```

**3. Ne pas ajouter de logique métier**

```qml
// ❌ MAUVAIS : Transformation dans Model
function updateFromAPI(newFilms) {
    // Filtrage, tri, transformation → ❌ À faire dans Logic
    internal.films = newFilms.filter(f => f.year > 2020)
}

// ✅ BON : Données brutes seulement
function updateFromAPI(newFilms) {
    internal.films = newFilms  // ✅ Simple assignation
    internal.isLoading = false
}
```

**4. Ne pas créer d'instance**

```qml
// ❌ MAUVAIS : Tentative d'instanciation
FilmDataSingletonModel {  // ❌ Erreur !
    id: filmData
}

// ✅ BON : Accès direct au Singleton
import "../model" as Model
Text {
    text: Model.FilmDataSingletonModel.films.length  // ✅
}
```

---

## Testing

### Mock pour tests

```qml
// Version test du Singleton
pragma Singleton
import Felgo 4.0
import QtQuick 2.15

Item {
    property bool __testMode: true
    property var __mockFilms: [
        {id: 1, title: "Film Test 1", poster_url: "url1"},
        {id: 2, title: "Film Test 2", poster_url: "url2"}
    ]
    
    readonly property alias films: internal.films
    readonly property alias isLoading: internal.isLoading
    readonly property alias lastError: internal.lastError
    
    QtObject {
        id: internal
        property var films: __testMode ? __mockFilms : []
        property bool isLoading: false
        property string lastError: ""
    }
    
    // ... méthodes de test
}
```

### Tests unitaires

```qml
TestCase {
    name: "FilmDataSingletonModelTests"
    
    function test_initialState() {
        compare(Model.FilmDataSingletonModel.films.length, 0)
        compare(Model.FilmDataSingletonModel.isLoading, false)
        compare(Model.FilmDataSingletonModel.lastError, "")
    }
    
    function test_startLoading() {
        Model.FilmDataSingletonModel.startLoading()
        compare(Model.FilmDataSingletonModel.isLoading, true)
        compare(Model.FilmDataSingletonModel.lastError, "")
    }
    
    function test_updateFromAPI() {
        var testFilms = [
            {id: 1, title: "Film 1", poster_url: "url1"}
        ]
        
        Model.FilmDataSingletonModel.updateFromAPI(testFilms)
        
        compare(Model.FilmDataSingletonModel.films.length, 1)
        compare(Model.FilmDataSingletonModel.films[0].title, "Film 1")
        compare(Model.FilmDataSingletonModel.isLoading, false)
        compare(Model.FilmDataSingletonModel.lastError, "")
    }
    
    function test_setError() {
        var errorMsg = "Test error"
        
        Model.FilmDataSingletonModel.setError(errorMsg)
        
        compare(Model.FilmDataSingletonModel.isLoading, false)
        compare(Model.FilmDataSingletonModel.lastError, errorMsg)
    }
    
    function test_useTestData() {
        Model.FilmDataSingletonModel.useTestData()
        
        verify(Model.FilmDataSingletonModel.films.length > 0)
        compare(Model.FilmDataSingletonModel.isLoading, false)
    }
}
```

### Tests d'intégration

```qml
TestCase {
    name: "FilmDataSingletonIntegrationTests"
    
    CataloguePage {
        id: page
    }
    
    function test_pageDisplaysFilms() {
        // Charger données de test
        Model.FilmDataSingletonModel.useTestData()
        
        // Vérifier affichage
        verify(page.filmGridView.count > 0)
        compare(page.filmGridView.count, Model.FilmDataSingletonModel.films.length)
    }
    
    function test_loadingIndicatorVisible() {
        Model.FilmDataSingletonModel.startLoading()
        
        verify(page.busyIndicator.visible)
        verify(!page.filmGridView.visible)
    }
}
```

---

## Évolutions futures

### Ajout de propriétés

```qml
// Futures propriétés possibles
readonly property alias categories: internal.categories
readonly property alias favorites: internal.favorites
readonly property alias searchQuery: internal.searchQuery
readonly property alias filters: internal.filters

QtObject {
    id: internal
    
    // Existant
    property var films: []
    property bool isLoading: false
    property string lastError: ""
    
    // Nouveaux
    property var categories: []
    property var favorites: []
    property string searchQuery: ""
    property var filters: ({
        category: "",
        year: 0,
        minRating: 0
    })
}
```

### Persistance locale avec Settings

```qml
Settings {
    id: settings
    property string cachedFilms: ""
    property string cacheDate: ""
}

Component.onCompleted: {
    // Restaurer cache au démarrage
    if (settings.cachedFilms !== "") {
        try {
            var cached = JSON.parse(settings.cachedFilms)
            internal.films = cached
            console.log("📦 Cache restauré:", cached.length, "films")
        } catch(e) {
            console.warn("Erreur restauration cache")
        }
    }
}

Component.onDestruction: {
    // Sauvegarder avant fermeture
    settings.cachedFilms = JSON.stringify(internal.films)
    settings.cacheDate = new Date().toISOString()
}
```

### Méthodes de manipulation

```qml
// Ajout d'un film
function addFilm(film) {
    var updatedFilms = internal.films.slice()  // Copie
    updatedFilms.push(film)
    internal.films = updatedFilms
    console.log("➕ Film ajouté:", film.title)
}

// Suppression d'un film
function removeFilm(filmId) {
    var updatedFilms = internal.films.filter(f => f.id !== filmId)
    internal.films = updatedFilms
    console.log("➖ Film supprimé:", filmId)
}

// Mise à jour d'un film
function updateFilm(filmId, updatedData) {
    var updatedFilms = internal.films.map(f => {
        return f.id === filmId ? Object.assign({}, f, updatedData) : f
    })
    internal.films = updatedFilms
    console.log("✏️ Film modifié:", filmId)
}
```

---

## Références

- [Architecture MVC](../Architecture/mvc-pattern.md)
- [Flux de données](../Architecture/data-flow.md)
- [FilmService](./Services/FilmService.md)
- [CatalogueLogic](../Logic/CatalogueLogic.md)
- [CataloguePage](../Pages/CataloguePage.md)
- [Pattern Singleton (Wikipedia)](https://en.wikipedia.org/wiki/Singleton_pattern)
- [QML Singleton Types (Qt Doc)](https://doc.qt.io/qt-6/qtqml-cppintegration-definetypes.html#singleton-objects)
