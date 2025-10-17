# Pattern MVC - Cinevault APP

## Introduction au pattern MVC

Le pattern **Model-View-Controller (MVC)** est un patron de conception architectural qui sépare une application en trois composants interconnectés. Dans le contexte QML/Felgo, nous avons adapté ce pattern aux spécificités de Qt Quick.

## Adaptation MVC pour QML/Felgo

### Différences avec le MVC classique

| MVC Classique | QML/Felgo | Justification |
|---------------|-----------|---------------|
| Controller manipule directement le Modèle | Logic coordonne entre Service et Model | Séparation réseau/état |
| Vue passive | Vue réactive avec bindings | Paradigme déclaratif QML |
| Controller unique | Logics multiples par fonctionnalité | Modularité |

## Les trois couches

### 1. Model (Modèle de données)

**Localisation** : `qml/model/`

**Responsabilités** :
- Représenter les données de l'application
- Gérer l'état global
- Communiquer avec le backend
- Notifier les changements

**Fichiers** :
```
model/
├── FilmDataSingletonModel.qml   → État global des films
├── FilmService.qml              → Communication API
└── qmldir                       → Enregistrement des modules
```

#### FilmDataSingletonModel.qml (État)

**Rôle** : Source unique de vérité pour les données de films

**Caractéristiques** :
- Pattern **Singleton** : une seule instance globale
- Accessible partout via `import "../model" as Model`
- Propriétés réactives avec bindings automatiques

**Données gérées** :
```qml
films: []           // Liste des films
isLoading: false    // État de chargement
lastError: ""       // Dernière erreur
```

**Méthodes** :
- `startLoading()` : Marque le début d'un chargement
- `updateFromAPI(films)` : Met à jour avec données réelles
- `setError(message)` : Enregistre une erreur
- `useTestData()` : Charge des données de test

**Exemple** :
```qml
// Accès depuis n'importe où
import "../model" as Model

Item {
    Text {
        text: "Films: " + Model.FilmDataSingletonModel.films.length
    }
}
```

#### FilmService.qml (Communication)

**Rôle** : Gérer les appels HTTP vers l'API backend

**Caractéristiques** :
- Instancié dans les Logic
- Émet des signaux pour résultats
- Gère les erreurs réseau

**Signaux** :
```qml
signal filmsFetched(var films)
signal fetchError(string errorMessage)
```

**Méthodes** :
```qml
function fetchAllFilms() {
    HttpRequest.get(apiUrl + "/movies/")
        .then(function(response) {
            filmsFetched(JSON.parse(response))
        })
        .catch(function(error) {
            fetchError("Erreur: " + error)
        })
}
```

### 2. View (Interface utilisateur)

**Localisation** : `qml/pages/`, `qml/components/`

**Responsabilités** :
- Afficher les données
- Capturer les interactions utilisateur
- Déléguer les actions à la logique
- Rester "stupide" (pas de logique métier)

**Structure** :
```
pages/              → Pages principales
├── CataloguePage.qml
├── RecherchePage.qml
└── ProfilPage.qml

components/         → Composants réutilisables
├── PosterImage.qml
├── FilmCard.qml
└── qmldir
```

#### Principes de la Vue

**1. Déclarative, pas impérative**
```qml
// ✅ BON : Déclaratif avec binding
Text {
    text: Model.FilmDataSingletonModel.films.length + " films"
    visible: !logic.loading
}

// ❌ MAUVAIS : Impératif
Text {
    id: filmCount
    Component.onCompleted: {
        updateFilmCount()
    }
}
```

**2. Pas de logique métier**
```qml
// ✅ BON : Délégation à la logique
Button {
    onClicked: logic.refreshCatalogue()
}

// ❌ MAUVAIS : Logique dans la vue
Button {
    onClicked: {
        Model.FilmDataSingletonModel.startLoading()
        filmService.fetchAllFilms()
        // ... transformation de données ...
    }
}
```

**3. Bindings réactifs**
```qml
// Les propriétés se mettent à jour automatiquement
GridView {
    model: Model.FilmDataSingletonModel.films  // Binding automatique
    visible: !logic.loading && logic.hasData
}
```

#### Exemple : CataloguePage.qml

```qml
AppPage {
    id: cataloguePage
    
    // Instance de logique métier
    CatalogueLogic { id: logic }
    
    // Vue : affichage conditionnel
    BusyIndicator {
        visible: logic.loading
    }
    
    GridView {
        model: Model.FilmDataSingletonModel.films
        visible: !logic.loading && logic.hasData
        
        delegate: PosterImage {
            source: modelData.poster_url
            // Délégation des actions
            onClicked: logic.openFilmDetails(modelData.id)
        }
    }
    
    // Gestion d'erreurs via signal
    Connections {
        target: logic
        function onErrorOccurred(message) {
            errorModal.open()
        }
    }
}
```

### 3. Controller/Logic (Logique métier)

**Localisation** : `qml/logic/`

**Responsabilités** :
- Orchestrer les interactions entre Model et Service
- Transformer les données
- Gérer les flux complexes
- Exposer un API simple à la Vue

**Fichiers** :
```
logic/
├── CatalogueLogic.qml
├── RechercheLogic.qml  (futur)
└── AuthLogic.qml       (futur)
```

#### CatalogueLogic.qml

**Rôle** : Chef d'orchestre du catalogue

**Propriétés exposées** :
```qml
readonly property bool loading         // Indicateur chargement
readonly property bool hasData         // Données disponibles
readonly property int filmCount        // Nombre de films
readonly property string errorMessage  // Message erreur
```

**Signaux** :
```qml
signal errorOccurred(string message)
```

**Méthodes publiques** :
```qml
function refreshCatalogue()  // Recharge depuis API
function useTestData()       // Charge données test
```

**Flux interne** :
```qml
Item {
    id: catalogueLogic
    
    // Service HTTP privé
    FilmService {
        id: filmService
        apiUrl: "https://localhost:8000/api"
    }
    
    // Connexion aux signaux du service
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
            
            // Mise à jour du modèle
            Model.FilmDataSingletonModel.updateFromAPI(transformedFilms)
        }
        
        function onFetchError(errorMessage) {
            Model.FilmDataSingletonModel.setError(errorMessage)
            errorOccurred(errorMessage)  // Propagation à la vue
        }
    }
    
    function refreshCatalogue() {
        Model.FilmDataSingletonModel.startLoading()
        filmService.fetchAllFilms()
    }
}
```

## Flux de communication

### Chargement de données

```
┌──────────────┐
│ Vue          │  1. Action utilisateur
│ (Page)       │     (Component.onCompleted, click, etc.)
└──────┬───────┘
       │
       │ 2. Appel méthode
       ▼
┌──────────────┐
│ Logic        │  3. Démarre chargement
│ (Controller) │     startLoading()
└──────┬───────┘
       │
       │ 4. Appel service
       ▼
┌──────────────┐
│ Service      │  5. HttpRequest → Backend
│ (Model)      │
└──────┬───────┘
       │
       │ 6. Signal filmsFetched
       ▼
┌──────────────┐
│ Logic        │  7. Transformation
│              │     Validation
└──────┬───────┘
       │
       │ 8. updateFromAPI()
       ▼
┌──────────────┐
│ Singleton    │  9. films = newFilms
│ Model        │     isLoading = false
└──────┬───────┘
       │
       │ 10. Binding automatique
       ▼
┌──────────────┐
│ Vue          │  11. Mise à jour automatique
│              │      affichage des films
└──────────────┘
```

### Gestion d'erreur

```
Service (erreur réseau)
    │
    │ fetchError signal
    ▼
Logic (réception)
    │
    ├─> setError() sur Model
    │
    └─> errorOccurred signal
        │
        ▼
    Vue (affiche modal)
```

## Avantages de cette architecture

### 1. Séparation des responsabilités
- **Testabilité** : Chaque couche testable indépendamment
- **Maintenabilité** : Modifications isolées
- **Compréhension** : Rôles clairs

### 2. Réutilisabilité
- Service partagé entre plusieurs Logic
- Model global accessible partout
- Composants Vue réutilisables

### 3. Évolutivité
- Ajout de nouvelles pages facile
- Nouvelles sources de données simples
- Logiques complexes encapsulées

### 4. Performance
- Bindings automatiques optimisés par Qt
- Pas de polling manuel
- Mises à jour granulaires

## Bonnes pratiques

### ✅ À faire

1. **Une Logic par fonctionnalité majeure**
```qml
CatalogueLogic.qml  // Pour le catalogue
RechercheLogic.qml  // Pour la recherche
```

2. **Propriétés readonly exposées**
```qml
readonly property bool loading: Model.FilmDataSingletonModel.isLoading
```

3. **Signaux pour communication Vue ← Logic**
```qml
signal errorOccurred(string message)
signal filmSelected(int filmId)
```

4. **Méthodes pour communication Vue → Logic**
```qml
function refreshCatalogue() { ... }
function deleteFilm(filmId) { ... }
```

### ❌ À éviter

1. **Logique métier dans la Vue**
```qml
// ❌ MAUVAIS
Button {
    onClicked: {
        // Transformation complexe ici
    }
}
```

2. **Accès direct Service dans Vue**
```qml
// ❌ MAUVAIS
FilmService {
    id: service
}
Button {
    onClicked: service.fetchAllFilms()
}
```

3. **Manipulation directe Model depuis Vue**
```qml
// ❌ MAUVAIS
Button {
    onClicked: {
        Model.FilmDataSingletonModel.films.push(newFilm)
    }
}
```

## Références

- [Architecture générale](overview.md)
- [Flux de données détaillé](data-flow.md)
- [CatalogueLogic documentation](../Data/CatalogueLogic.md)
