# Documentation FilmDetailLogic - Controller pour FilmDetailPage

## Vue d'ensemble

`FilmDetailLogic.qml` est le **Controller** dans l'architecture MVC de la page de détails de film. Il orchestre le chargement des données d'un film depuis le Model global et communique avec la View via des signaux.

---

## Localisation

```
qml/logic/FilmDetailLogic.qml
```

---

## Responsabilités

1. **Chargement** : Récupérer les données d'un film depuis FilmDataSingletonModel
2. **Validation** : Vérifier que l'ID est valide et que le catalogue n'est pas vide
3. **Recherche** : Trouver le film par ID (recherche linéaire)
4. **Communication** : Émettre des signaux vers la Vue
5. **Gestion d'état** : Maintenir `currentFilm`, `loading`, `errorMessage`

---

## Architecture MVC

```
┌──────────────────────────────────────┐
│  FilmDetailPage (View)               │
│  - Affichage uniquement              │
│  - Écoute signaux de la Logic        │
└──────────────┬───────────────────────┘
               │ délègue
               ↓
┌──────────────────────────────────────┐
│  FilmDetailLogic (Controller)        │
│  - Logique de chargement             │
│  - Validation des données            │
│  - Émission de signaux               │
└──────────────┬───────────────────────┘
               │ interroge
               ↓
┌──────────────────────────────────────┐
│  FilmDataSingletonModel (Model)      │
│  - Source de vérité                  │
│  - Liste des films                   │
└──────────────────────────────────────┘
```

---

## Propriétés Publiques

### currentFilm
Type de film actuellement chargé (ou null).

```qml
property var currentFilm: null
```

**Usage dans la View** :
```qml
title: logic.currentFilm ? logic.currentFilm.title : "Détails"
```

### loading
Indicateur de chargement en cours.

```qml
property bool loading: false
```

### errorMessage
Message d'erreur si chargement échoué.

```qml
property string errorMessage: ""
```

---

## Signaux

### filmLoaded(film)
Émis quand le film est chargé avec succès.

```qml
signal filmLoaded(var film)
```

**Paramètres** :
- `film` (object) : Objet film avec propriétés `id`, `title`, `poster_url`

**Usage dans la View** :
```qml
Connections {
    target: logic
    function onFilmLoaded(film) {
        Services.ToastService.showSuccess("Film chargé !")
    }
}
```

### loadError(message)
Émis en cas d'erreur de chargement.

```qml
signal loadError(string message)
```

**Paramètres** :
- `message` (string) : Message d'erreur descriptif

**Usage dans la View** :
```qml
Connections {
    target: logic
    function onLoadError(message) {
        Services.ToastService.showError(message)
    }
}
```

---

## Méthodes Publiques

### loadFilm(filmId)

Charge les données d'un film depuis le modèle global.

**Algorithme en 4 phases** :

```
PHASE 1 : VALIDATION DE L'ID
  filmId <= 0 ?
    ↓ Oui
    errorMessage = "ID invalide"
    loadError(errorMessage)
    return
    
PHASE 2 : ACCÈS AU MODÈLE
  loading = true
  films = FilmDataSingletonModel.films
  films vide ?
    ↓ Oui
    errorMessage = "Catalogue vide"
    loadError(errorMessage)
    return
    
PHASE 3 : RECHERCHE PAR ID
  for (i = 0; i < films.length; i++)
    films[i].id === filmId ?
      ↓ Oui
      currentFilm = films[i]
      filmLoaded(currentFilm)
      return
      
PHASE 4 : FILM NON TROUVÉ
  errorMessage = "Film introuvable"
  loadError(errorMessage)
```

**Paramètres** :
- `filmId` (int) : ID du film à charger

**Complexité** :
- Temps : O(n) - Linéaire (acceptable pour < 1000 films)
- Espace : O(1) - Constant

**Exemples d'utilisation** :

```qml
// Chargement normal
logic.loadFilm(5)

// ✅ Film trouvé
// → currentFilm = { id: 5, title: "Avatar", poster_url: "..." }
// → filmLoaded(film) émis
```

**Cas d'erreur** :

```qml
// ID invalide
logic.loadFilm(-1)
// → errorMessage = "ID invalide..."
// → loadError(message) émis

// Film inexistant
logic.loadFilm(999)
// → errorMessage = "Film introuvable..."
// → loadError(message) émis
```

---

### reset()

Réinitialise l'état de la Logic.

```qml
function reset() {
    currentFilm = null
    errorMessage = ""
    loading = false
}
```

**Usage** :
```qml
// Avant de quitter la page
onClicked: {
    logic.reset()
    navigationStack.pop()
}
```

---

## Gestion des Erreurs

### Matrice des erreurs

| Condition | Message | Signal |
|-----------|---------|--------|
| `filmId <= 0` | "ID de film invalide\n\nL'ID doit être un nombre positif." | loadError |
| `films.length = 0` | "Catalogue vide\n\nAucun film disponible." | loadError |
| Film non trouvé | "Film introuvable\n\nLe film avec l'ID X n'existe pas." | loadError |
| Film trouvé | - | filmLoaded |

### Logs de debugging

```
🔍 Chargement du film ID: 5
📊 Catalogue disponible: 14 films
✅ Film trouvé:
   - Titre: Avatar
   - ID: 5
   - Poster: disponible
```

**Erreur** :
```
❌ Film non trouvé avec ID: 999
   IDs disponibles: 1, 2, 3, ..., 14
```

---

## Intégration avec FilmDataSingletonModel

### Accès au Singleton

```qml
import "../model" as Model

var films = Model.FilmDataSingletonModel.films
```

### Structure d'un film

```javascript
{
    id: 5,
    title: "Avatar",
    poster_url: "https://..."
}
```

---

## Enregistrement qmldir

```
# qml/logic/qmldir
FilmDetailLogic 1.0 FilmDetailLogic.qml
```

---

## Tests de Validation

### Test 1 : Film existant

```qml
logic.loadFilm(5)
```

**Attendu** :
- ✅ `currentFilm` défini
- ✅ `loading` = false
- ✅ `errorMessage` = ""
- ✅ `filmLoaded` émis

### Test 2 : Film inexistant

```qml
logic.loadFilm(999)
```

**Attendu** :
- ❌ `currentFilm` = null
- ❌ `loading` = false
- ❌ `errorMessage` = "Film introuvable..."
- ❌ `loadError` émis

### Test 3 : ID invalide

```qml
logic.loadFilm(-1)
```

**Attendu** :
- ❌ `currentFilm` = null
- ❌ `errorMessage` = "ID invalide..."
- ❌ `loadError` émis

### Test 4 : Catalogue vide

```qml
// FilmDataSingletonModel.films = []
logic.loadFilm(5)
```

**Attendu** :
- ❌ `errorMessage` = "Catalogue vide..."
- ❌ `loadError` émis

---

## Bonnes Pratiques Implémentées

### ✅ Séparation MVC stricte

```
View (FilmDetailPage)
  → Affichage uniquement
  → Pas de logique métier

Controller (FilmDetailLogic)
  → Validation + recherche
  → Communication via signaux

Model (FilmDataSingletonModel)
  → Source de vérité unique
```

### ✅ Validation exhaustive

- ID <= 0 → Erreur
- Catalogue vide → Erreur
- Film non trouvé → Erreur
- Logs détaillés pour debugging

### ✅ Communication par signaux

```qml
// Logic → View (découplage)
filmLoaded(film)   // Succès
loadError(message) // Échec
```

---

## Évolutions Futures

### Prévu : Chargement depuis API

```qml
function loadFilm(filmId) {
    loading = true
    
    // Appel HTTP
    FilmService.fetchFilmById(filmId)
}

Connections {
    target: FilmService
    
    function onFilmFetched(film) {
        currentFilm = film
        filmLoaded(film)
    }
    
    function onFetchError(error) {
        errorMessage = error
        loadError(error)
    }
}
```

### Optimisation : Index par ID

```qml
// Au lieu de recherche linéaire O(n)
var filmIndex = Model.FilmDataSingletonModel.filmIndex
currentFilm = filmIndex[filmId]  // O(1)
```

---

**Date de création** : 26 octobre 2025  
**Version** : 1.0  
**Auteur** : Équipe Cinevault
