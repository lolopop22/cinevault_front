# FilmService - Documentation technique complète

## Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Rôle et responsabilités](#rôle-et-responsabilités)
3. [Configuration](#configuration)
4. [Signaux](#signaux)
5. [Méthodes publiques](#méthodes-publiques)
6. [Gestion des erreurs](#gestion-des-erreurs)
7. [HttpRequest Felgo](#httprequest-felgo)
8. [Flux de communication](#flux-de-communication)
9. [Exemples d'utilisation](#exemples-dutilisation)
10. [Configuration multi-environnement](#configuration-multi-environnement)
11. [Retry automatique](#retry-automatique)
12. [Évolutions futures](#évolutions-futures)
13. [Bonnes pratiques](#bonnes-pratiques)
14. [Testing](#testing)

---

## Vue d'ensemble

### Définition

`FilmService` est un **service réseau** responsable de toutes les communications HTTP avec l'API backend Django REST Framework. Il encapsule la logique de communication et émet des signaux pour notifier les résultats.

### Localisation

```
qml/model/FilmService.qml
```

### Rôle

✅ **Communication HTTP** avec le backend  
✅ **Parsing JSON** des réponses  
✅ **Émission de signaux** pour résultats asynchrones  
✅ **Gestion des erreurs** réseau et HTTP  
✅ **Pas de logique métier** - communication pure  

### Caractéristiques

- **Type** : Composant QML standard (pas Singleton)
- **Instancié dans** : CatalogueLogic
- **Pattern** : Observer (signaux/slots)
- **Asynchrone** : Tous les appels sont non-bloquants

---

## Rôle et responsabilités

### Ce que FilmService FAIT

**✅ Appels HTTP**
```qml
HttpRequest.get(apiUrl + "/movies/")  // GET
HttpRequest.post(apiUrl + "/movies/", data)  // POST (futur)
HttpRequest.put(apiUrl + "/movies/1/", data)  // PUT (futur)
HttpRequest.del(apiUrl + "/movies/1/")  // DELETE (futur)
```

**✅ Parsing JSON**
```qml
.then(function(response) {
    var films = JSON.parse(response)  // String → Object
    filmsFetched(films)
})
```

**✅ Gestion d'erreurs**
```qml
.catch(function(error) {
    fetchError("Erreur: " + error)
})
```

**✅ Émission de signaux**
```qml
signal filmsFetched(var films)
signal fetchError(string message)
```

### Ce que FilmService ne FAIT PAS

**❌ Pas de transformation de données**
```qml
// ❌ MAUVAIS
.then(function(response) {
    var films = JSON.parse(response)
    var sorted = films.sort(...)  // ❌ Logique métier
    filmsFetched(sorted)
})

// ✅ BON
.then(function(response) {
    filmsFetched(JSON.parse(response))  // ✅ Données brutes
})
```

**❌ Pas de stockage d'état**
```qml
// ❌ MAUVAIS
property var cachedFilms: []  // ❌ État dans Service

// ✅ BON : État dans Model
// FilmDataSingletonModel gère l'état
```

**❌ Pas d'accès direct au Model**
```qml
// ❌ MAUVAIS
.then(function(response) {
    FilmDataSingletonModel.films = JSON.parse(response)  // ❌
})

// ✅ BON : Via signal
.then(function(response) {
    filmsFetched(JSON.parse(response))  // ✅ Signal
})
```

---

## Configuration

### Propriété `apiUrl`

**Type** : `string`  
**Défaut** : `"https://localhost:8000/api"`  
**Modifiable** : ✅ Oui  
**Configurable via** : Propriété directe lors de l'instanciation

**Description** : URL de base de l'API backend Django REST.

**Structure d'URL complète** :
```
apiUrl + endpoint
↓
https://localhost:8000/api + /movies/
↓
https://localhost:8000/api/movies/
```

**Déclaration** :

```qml
Item {
    id: filmService
    
    // Configuration
    property string apiUrl: "https://localhost:8000/api"
}
```

**Utilisation dans les méthodes** :

```qml
function fetchAllFilms() {
    let url = apiUrl + "/movies/"  // Concaténation
    
    HttpRequest.get(url)
        .then(...)
        .catch(...)
}
```

**Configuration selon environnement** :

```qml
// Développement
apiUrl: "http://localhost:8000/api"

// Staging
apiUrl: "https://staging.cinevault.com/api"

// Production
apiUrl: "https://api.cinevault.com/api"
```

---

## Signaux

Les signaux sont le mécanisme pour communiquer les résultats asynchrones aux consommateurs du service (généralement les Logic).

### Signal `filmsFetched(var films)`

**Type** : Signal avec paramètre  
**Paramètre** : `films` (array d'objets)  
**Émis quand** : Succès d'un appel API GET /movies/

**Structure du paramètre `films`** :

```javascript
[
    {
        id: number,           // ID unique du film
        title: string,        // Titre du film
        poster_url: string,   // URL du poster
        // ... autres champs selon backend
    },
    // ... autres films
]
```

**Exemple de données réelles** :

```javascript
[
    {
        id: 1,
        title: "Avatar",
        poster_url: "https://image.tmdb.org/t/p/w342/jRXYjXNq0Cs2TcJjLkki24MLp7u.jpg",
        year: 2009,
        duration: 162,
        genres: ["Action", "Adventure", "Fantasy"]
    },
    {
        id: 2,
        title: "Titanic",
        poster_url: "https://image.tmdb.org/t/p/w342/9xjZS2rlVxm8SFx8kPC3aIGCOYQ.jpg",
        year: 1997,
        duration: 194,
        genres: ["Drama", "Romance"]
    }
]
```

**Émission** :

```qml
HttpRequest.get(url)
    .then(function(response) {
        try {
            var films = JSON.parse(response)
            filmsFetched(films)  // ← Émet le signal
        } catch(e) {
            fetchError("Réponse JSON invalide")
        }
    })
```

**Écoute dans Logic** :

```qml
Connections {
    target: filmService
    
    function onFilmsFetched(films) {
        console.log("✅ Reçu", films.length, "films")
        
        // Transformation si nécessaire
        var transformedFilms = films.map(function(f) {
            return {
                id: f.id,
                title: f.title,
                poster_url: f.poster_url
            }
        })
        
        // Stockage dans Model
        Model.FilmDataSingletonModel.updateFromAPI(transformedFilms)
    }
}
```

### Signal `fetchError(string errorMessage)`

**Type** : Signal avec paramètre  
**Paramètre** : `errorMessage` (string)  
**Émis quand** : Échec d'un appel API (erreur réseau, HTTP, ou parsing)

**Types de messages d'erreur** :

| Type | Message | Exemple |
|------|---------|---------|
| Réseau | `"Erreur HTTP et/ou Échec de connexion au serveur : NetworkError"` | Pas de connexion internet |
| HTTP 404 | `"Erreur HTTP et/ou Échec de connexion au serveur : 404"` | Endpoint inexistant |
| HTTP 500 | `"Erreur HTTP et/ou Échec de connexion au serveur : 500"` | Erreur serveur |
| JSON | `"Réponse JSON invalide"` | Réponse non-JSON |

**Émission** :

```qml
HttpRequest.get(url)
    .then(function(response) {
        try {
            filmsFetched(JSON.parse(response))
        } catch(e) {
            fetchError("Réponse JSON invalide")  // ← Émission
            console.warn("Erreur de parsing JSON:", e)
        }
    })
    .catch(function(error) {
        fetchError("Erreur HTTP: " + error)  // ← Émission
        console.error("Erreur récupération films:", error)
    })
```

**Écoute dans Logic** :

```qml
Connections {
    target: filmService
    
    function onFetchError(errorMessage) {
        console.error("❌ Erreur API:", errorMessage)
        
        // 1. Enregistrer dans Model
        Model.FilmDataSingletonModel.setError(errorMessage)
        
        // 2. Propager à la Vue
        errorOccurred(errorMessage)
    }
}
```

---

## Méthodes publiques

### `fetchAllFilms()`

Récupère la liste complète des films depuis l'API backend.

**Paramètres** : Aucun  
**Retour** : `void` (résultat via signaux)  
**Asynchrone** : ✅ Oui (non-bloquant)

**Endpoint appelé** : `GET {apiUrl}/movies/`

**Exemple d'URL complète** :
```
GET https://localhost:8000/api/movies/
```

**Implémentation complète** :

```qml
function fetchAllFilms() {
    // 1. Construction de l'URL
    let url = apiUrl + "/movies/"
    
    console.log("🌐 Appel API:", url)
    
    // 2. Requête HTTP GET
    HttpRequest.get(url)
        .then(function(response) {
            // 3a. Succès : Parse JSON
            try {
                var films = JSON.parse(response)
                console.log("📦 Réponse API:", films.length, "films")
                
                // 4a. Émet signal de succès
                filmsFetched(films)
                
            } catch(e) {
                // 3b. Échec parsing JSON
                console.warn("⚠️ Erreur de parsing JSON:", e)
                fetchError("Réponse JSON invalide")
            }
        })
        .catch(function(error) {
            // 3c. Échec HTTP
            console.error("❌ Erreur HTTP:", error)
            fetchError("Erreur HTTP et/ou Échec de connexion au serveur : " + error)
        })
}
```

**Flux d'exécution** :

```
1. fetchAllFilms() appelé
   ↓
2. Construction URL : apiUrl + "/movies/"
   ↓
3. HttpRequest.get(url)
   ↓
4. Envoi requête HTTP au backend
   ↓
   ┌───────────┬────────────┐
   │           │            │
   ▼           ▼            ▼
Succès      Erreur HTTP  Erreur Réseau
   │           │            │
   ├─ JSON OK  ├─ 404       ├─ NetworkError
   │           ├─ 500       ├─ Timeout
   │           └─ 401       └─ DNS
   │
   ▼
filmsFetched(films)
   OU
fetchError(message)
```

**Appelé par** :

```qml
// Dans CatalogueLogic
function refreshCatalogue() {
    Model.FilmDataSingletonModel.startLoading()
    filmService.fetchAllFilms()  // ← Appel
}
```

**Réponse attendue du backend** :

```json
[
    {
        "id": 1,
        "title": "Avatar",
        "poster_url": "https://image.tmdb.org/t/p/w342/jRXYjXNq0Cs2TcJjLkki24MLp7u.jpg"
    },
    {
        "id": 2,
        "title": "Titanic",
        "poster_url": "https://image.tmdb.org/t/p/w342/9xjZS2rlVxm8SFx8kPC3aIGCOYQ.jpg"
    }
]
```

---

## Gestion des erreurs

FilmService gère **3 types d'erreurs** :

### Type 1 : Erreur réseau

**Causes** :
- Pas de connexion internet
- Timeout de requête
- DNS ne résout pas
- Serveur inaccessible
- Firewall bloque

**Détection** :

```qml
HttpRequest.get(url)
    .catch(function(error) {
        // error contient "NetworkError", "Timeout", etc.
        fetchError("Erreur HTTP et/ou Échec de connexion au serveur : " + error)
    })
```

**Message émis** :
```
"Erreur HTTP et/ou Échec de connexion au serveur : NetworkError"
```

**Exemple de log console** :
```
❌ Erreur récupération films: NetworkError: Connection refused
```

### Type 2 : Erreur HTTP

**Causes** :
- 404 Not Found (endpoint inexistant)
- 500 Internal Server Error (bug backend)
- 401 Unauthorized (pas authentifié)
- 403 Forbidden (pas autorisé)

**Détection** :

```qml
HttpRequest.get(url)
    .catch(function(error) {
        // error contient le code HTTP
        fetchError("Erreur HTTP et/ou Échec de connexion au serveur : " + error)
    })
```

**Messages émis** :
```
"Erreur HTTP et/ou Échec de connexion au serveur : 404"
"Erreur HTTP et/ou Échec de connexion au serveur : 500"
"Erreur HTTP et/ou Échec de connexion au serveur : 401"
```

**Exemple de log console** :
```
❌ Erreur récupération films: HTTP 404 Not Found
```

### Type 3 : Erreur parsing JSON

**Causes** :
- Réponse n'est pas du JSON valide
- Backend retourne du HTML (page d'erreur)
- Réponse vide
- JSON malformé

**Détection** :

```qml
.then(function(response) {
    try {
        var films = JSON.parse(response)  // ← Peut lancer exception
        filmsFetched(films)
    } catch(e) {
        // Exception capturée ici
        fetchError("Réponse JSON invalide")
        console.warn("Erreur de parsing JSON:", e)
    }
})
```

**Message émis** :
```
"Réponse JSON invalide"
```

**Exemple de log console** :
```
⚠️ Erreur de parsing JSON: SyntaxError: Unexpected token < in JSON at position 0
```

**Exemple de réponse causant l'erreur** :
```html
<!DOCTYPE html>
<html>
<head><title>Error 500</title></head>
<body><h1>Internal Server Error</h1></body>
</html>
```

### Propagation des erreurs

```
FilmService.fetchError(message)
          ↓ Signal
CatalogueLogic.onFetchError(message)
          ↓
          ├─> FilmDataSingletonModel.setError(message)
          │   └─> lastError = message
          │
          └─> errorOccurred(message) signal
              ↓
CataloguePage.onErrorOccurred(message)
              ↓
          errorModal.open()
```

---

## HttpRequest Felgo

`HttpRequest` est l'API Felgo pour effectuer des requêtes HTTP. C'est un wrapper autour de `XMLHttpRequest` avec une syntaxe moderne (Promises).

### Méthodes disponibles

```qml
// GET
HttpRequest.get(url)

// POST
HttpRequest.post(url)
    .body(JSON.stringify(data))

// PUT
HttpRequest.put(url)
    .body(JSON.stringify(data))

// DELETE
HttpRequest.del(url)
```

### Syntaxe Promise

```qml
HttpRequest.get(url)
    .then(function(response) {
        // Succès : response est une string
        console.log("Réponse:", response)
    })
    .catch(function(error) {
        // Erreur : error est une string
        console.error("Erreur:", error)
    })
```

### Headers personnalisés

```qml
HttpRequest.get(url)
    .header("Authorization", "Bearer " + token)
    .header("Content-Type", "application/json")
    .then(...)
```

### Timeout

```qml
HttpRequest.get(url)
    .timeout(5000)  // 5 secondes
    .then(...)
```

### Caractéristiques

✅ **Asynchrone** : N'bloque pas l'UI  
✅ **Cross-platform** : iOS, Android, Desktop  
✅ **Gestion automatique** : Encoding, headers par défaut  
✅ **Promise-based** : Syntaxe moderne et lisible  

### Exemple complet

```qml
HttpRequest.get("https://api.example.com/data")
    .header("Authorization", "Bearer abc123")
    .timeout(10000)
    .then(function(response) {
        var data = JSON.parse(response)
        console.log("Data:", data)
    })
    .catch(function(error) {
        console.error("Error:", error)
    })
```

---

## Flux de communication

### Diagramme de séquence complet

```
CatalogueLogic    FilmService     HttpRequest     Backend API     CatalogueLogic    FilmDataSingleton
      │                │               │                │                │                  │
      │ refreshCatalogue()             │                │                │                  │
      ├───────────────>│               │                │                │                  │
      │                │               │                │                │                  │
      │           startLoading()       │                │                │                  │
      ├────────────────────────────────┼────────────────┼────────────────┼─────────────────>│
      │                │               │                │                │   isLoading=true │
      │                │               │                │                │                  │
      │  fetchAllFilms()│               │                │                │                  │
      ├───────────────>│               │                │                │                  │
      │                │               │                │                │                  │
      │                │ get(url)      │                │                │                  │
      │                ├──────────────>│                │                │                  │
      │                │               │                │                │                  │
      │                │               │ GET /movies/   │                │                  │
      │                │               ├───────────────>│                │                  │
      │                │               │                │                │                  │
      │                │               │ JSON response  │                │                  │
      │                │               │<───────────────┤                │                  │
      │                │               │                │                │                  │
      │                │ then(response)│                │                │                  │
      │                │<──────────────┤                │                │                  │
      │                │               │                │                │                  │
      │                │ JSON.parse()  │                │                │                  │
      │                │               │                │                │                  │
      │ filmsFetched   │               │                │                │                  │
      │   (signal)     │               │                │                │                  │
      │<───────────────┤               │                │                │                  │
      │                │               │                │                │                  │
      │ onFilmsFetched()               │                │                │                  │
      │ Transformation │               │                │                │                  │
      │                │               │                │                │                  │
      │                │               │                │          updateFromAPI()          │
      ├────────────────────────────────┼────────────────┼────────────────┼─────────────────>│
      │                │               │                │                │   films=[...]    │
      │                │               │                │                │   isLoading=false│
      │                │               │                │                │                  │
```

### Flux en pseudo-code

```javascript
// 1. Logic démarre
CatalogueLogic.refreshCatalogue() {
    FilmDataSingletonModel.startLoading()
    filmService.fetchAllFilms()
}

// 2. Service fait l'appel
FilmService.fetchAllFilms() {
    HttpRequest.get(apiUrl + "/movies/")
        .then(response => {
            films = JSON.parse(response)
            emit filmsFetched(films)
        })
        .catch(error => {
            emit fetchError("Erreur: " + error)
        })
}

// 3. Logic reçoit résultat
CatalogueLogic.onFilmsFetched(films) {
    transformedFilms = films.map(transform)
    FilmDataSingletonModel.updateFromAPI(transformedFilms)
}

// 4. Model notifie Vue (binding automatique)
FilmDataSingletonModel.updateFromAPI(films) {
    this.films = films
    this.isLoading = false
    // ↑ Déclenche bindings dans toutes les vues
}
```

---

## Exemples d'utilisation

### Exemple 1 : Usage basique dans Logic

```qml
import QtQuick 2.15
import Felgo 4.0
import "../model" as Model

Item {
    id: catalogueLogic
    
    // ═══════════════════════════════════════
    // INSTANCE DU SERVICE
    // ═══════════════════════════════════════
    
    Model.FilmService {
        id: filmService
        apiUrl: "https://localhost:8000/api"
    }
    
    // ═══════════════════════════════════════
    // ÉCOUTE DES SIGNAUX
    // ═══════════════════════════════════════
    
    Connections {
        target: filmService
        
        function onFilmsFetched(films) {
            console.log("✅ Succès:", films.length, "films reçus")
            
            // Transformation
            var transformed = films.map(function(f) {
                return {
                    id: f.id,
                    title: f.title,
                    poster_url: f.poster_url
                }
            })
            
            // Stockage
            Model.FilmDataSingletonModel.updateFromAPI(transformed)
        }
        
        function onFetchError(errorMessage) {
            console.log("❌ Erreur:", errorMessage)
            Model.FilmDataSingletonModel.setError(errorMessage)
            errorOccurred(errorMessage)
        }
    }
    
    // ═══════════════════════════════════════
    // MÉTHODE PUBLIQUE
    // ═══════════════════════════════════════
    
    function refreshCatalogue() {
        Model.FilmDataSingletonModel.startLoading()
        filmService.fetchAllFilms()
    }
}
```

### Exemple 2 : Configuration multi-environnement

```qml
Model.FilmService {
    id: filmService
    
    // Configuration selon environnement
    apiUrl: {
        // Argument ligne de commande : --prod, --staging, --dev
        var args = Qt.application.arguments
        
        if (args.indexOf("--prod") !== -1) {
            return "https://api.cinevault.com/api"
        } else if (args.indexOf("--staging") !== -1) {
            return "https://staging-api.cinevault.com/api"
        } else {
            return "http://localhost:8000/api"  // Dev par défaut
        }
    }
    
    Component.onCompleted: {
        console.log("🔧 FilmService configuré:", apiUrl)
    }
}
```

### Exemple 3 : Retry automatique

```qml
Item {
    id: catalogueLogic
    
    Model.FilmService {
        id: filmService
    }
    
    // ═══════════════════════════════════════
    // PROPRIÉTÉS DE RETRY
    // ═══════════════════════════════════════
    
    property int retryCount: 0
    property int maxRetries: 3
    property int retryDelay: 2000  // 2 secondes
    
    // ═══════════════════════════════════════
    // TIMER DE RETRY
    // ═══════════════════════════════════════
    
    Timer {
        id: retryTimer
        interval: retryDelay
        repeat: false
        onTriggered: {
            console.log("🔄 Retry", retryCount, "/", maxRetries)
            filmService.fetchAllFilms()
        }
    }
    
    // ═══════════════════════════════════════
    // CONNEXIONS AVEC RETRY
    // ═══════════════════════════════════════
    
    Connections {
        target: filmService
        
        function onFilmsFetched(films) {
            // Succès : reset retry count
            retryCount = 0
            
            // Traitement normal
            var transformed = films.map(f => ({
                id: f.id,
                title: f.title,
                poster_url: f.poster_url
            }))
            
            Model.FilmDataSingletonModel.updateFromAPI(transformed)
        }
        
        function onFetchError(errorMessage) {
            if (retryCount < maxRetries) {
                // Retry automatique
                retryCount++
                console.log("⚠️ Erreur, retry dans", retryDelay, "ms...")
                retryTimer.start()
            } else {
                // Max retries atteint
                console.error("❌ Max retries atteint:", errorMessage)
                retryCount = 0
                Model.FilmDataSingletonModel.setError(errorMessage)
                errorOccurred(errorMessage)
            }
        }
    }
    
    // ═══════════════════════════════════════
    // FONCTION PUBLIQUE
    // ═══════════════════════════════════════
    
    function refreshCatalogue() {
        retryCount = 0  // Reset au démarrage manuel
        Model.FilmDataSingletonModel.startLoading()
        filmService.fetchAllFilms()
    }
}
```

### Exemple 4 : Logs détaillés

```qml
Connections {
    target: filmService
    
    function onFilmsFetched(films) {
        console.log("═══════════════════════════════════════")
        console.log("✅ API SUCCESS")
        console.log("Films reçus:", films.length)
        console.log("Premier film:", films[0] ? films[0].title : "N/A")
        console.log("Dernier film:", films[films.length-1] ? films[films.length-1].title : "N/A")
        console.log("═══════════════════════════════════════")
        
        // Traitement
        Model.FilmDataSingletonModel.updateFromAPI(films)
    }
    
    function onFetchError(errorMessage) {
        console.log("═══════════════════════════════════════")
        console.error("❌ API ERROR")
        console.error("Message:", errorMessage)
        console.error("API URL:", filmService.apiUrl)
        console.error("Timestamp:", new Date().toISOString())
        console.log("═══════════════════════════════════════")
        
        // Traitement
        Model.FilmDataSingletonModel.setError(errorMessage)
    }
}
```

---

## Configuration multi-environnement

### Via arguments ligne de commande

```bash
# Développement (défaut)
./CinevaultApp

# Staging
./CinevaultApp --staging

# Production
./CinevaultApp --prod
```

**Implémentation** :

```qml
Model.FilmService {
    id: filmService
    
    property string environment: {
        var args = Qt.application.arguments
        if (args.indexOf("--prod") !== -1) return "production"
        if (args.indexOf("--staging") !== -1) return "staging"
        return "development"
    }
    
    apiUrl: {
        switch(environment) {
            case "production":
                return "https://api.cinevault.com/api"
            case "staging":
                return "https://staging-api.cinevault.com/api"
            case "development":
            default:
                return "http://localhost:8000/api"
        }
    }
    
    Component.onCompleted: {
        console.log("🌍 Environment:", environment)
        console.log("🔗 API URL:", apiUrl)
    }
}
```

### Via fichier de configuration

```qml
// config.json
{
    "api": {
        "development": "http://localhost:8000/api",
        "staging": "https://staging-api.cinevault.com/api",
        "production": "https://api.cinevault.com/api"
    }
}

// FilmService.qml
property var config: JSON.parse(FileUtils.readFile("config.json"))
property string environment: "development"
apiUrl: config.api[environment]
```

---

## Retry automatique

### Stratégie exponentielle

```qml
property int retryCount: 0
property int maxRetries: 5
property int baseDelay: 1000  // 1 seconde

// Délai exponentiel : 1s, 2s, 4s, 8s, 16s
property int retryDelay: baseDelay * Math.pow(2, retryCount)

Timer {
    id: retryTimer
    interval: retryDelay
    onTriggered: {
        filmService.fetchAllFilms()
    }
}
```

### Retry conditionnel

```qml
function onFetchError(errorMessage) {
    // Ne retry que pour erreurs réseau
    if (errorMessage.includes("NetworkError")) {
        if (retryCount < maxRetries) {
            retryCount++
            retryTimer.start()
            return
        }
    }
    
    // Autres erreurs : pas de retry
    Model.FilmDataSingletonModel.setError(errorMessage)
}
```

---

## Évolutions futures

### Méthode POST : Ajouter un film

```qml
function addFilm(filmData) {
    let url = apiUrl + "/movies/"
    
    HttpRequest.post(url)
        .header("Content-Type", "application/json")
        .body(JSON.stringify(filmData))
        .then(function(response) {
            var newFilm = JSON.parse(response)
            filmAdded(newFilm)
        })
        .catch(function(error) {
            fetchError("Erreur ajout: " + error)
        })
}

signal filmAdded(var film)
```

### Méthode PUT : Modifier un film

```qml
function updateFilm(filmId, filmData) {
    let url = apiUrl + "/movies/" + filmId + "/"
    
    HttpRequest.put(url)
        .header("Content-Type", "application/json")
        .body(JSON.stringify(filmData))
        .then(function(response) {
            var updatedFilm = JSON.parse(response)
            filmUpdated(updatedFilm)
        })
        .catch(function(error) {
            fetchError("Erreur modification: " + error)
        })
}

signal filmUpdated(var film)
```

### Méthode DELETE : Supprimer un film

```qml
function deleteFilm(filmId) {
    let url = apiUrl + "/movies/" + filmId + "/"
    
    HttpRequest.del(url)
        .then(function() {
            filmDeleted(filmId)
        })
        .catch(function(error) {
            fetchError("Erreur suppression: " + error)
        })
}

signal filmDeleted(int filmId)
```

### Authentification JWT

```qml
property string authToken: ""

function fetchAllFilms() {
    let url = apiUrl + "/movies/"
    
    HttpRequest.get(url)
        .header("Authorization", "Bearer " + authToken)
        .then(function(response) {
            filmsFetched(JSON.parse(response))
        })
        .catch(function(error) {
            if (error.includes("401")) {
                authenticationRequired()  // Signal spécial
            } else {
                fetchError("Erreur: " + error)
            }
        })
}

signal authenticationRequired()
```

---

## Bonnes pratiques

### ✅ À faire

**1. Instancier dans Logic**
```qml
// ✅ BON
Item {
    id: catalogueLogic
    
    FilmService { id: filmService }
}
```

**2. Écouter signaux dans Logic**
```qml
// ✅ BON
Connections {
    target: filmService
    function onFilmsFetched(films) {
        // Transformation et stockage
    }
}
```

**3. Configurer apiUrl selon environnement**
```qml
// ✅ BON
apiUrl: Qt.application.arguments.indexOf("--prod") !== -1 
    ? "https://api.cinevault.com/api"
    : "http://localhost:8000/api"
```

**4. Logs pour debugging**
```qml
// ✅ BON
console.log("🌐 API call:", url)
console.log("✅ API success:", films.length)
console.error("❌ API error:", error)
```

### ❌ À éviter

**1. Pas de logique métier**
```qml
// ❌ MAUVAIS
function fetchAllFilms() {
    HttpRequest.get(url).then(function(response) {
        var films = JSON.parse(response)
        var filtered = films.filter(f => f.year > 2020)  // ❌
        filmsFetched(filtered)
    })
}

// ✅ BON : Données brutes
function fetchAllFilms() {
    HttpRequest.get(url).then(function(response) {
        filmsFetched(JSON.parse(response))  // ✅
    })
}
```

**2. Pas de manipulation directe du Model**
```qml
// ❌ MAUVAIS
function fetchAllFilms() {
    HttpRequest.get(url).then(function(response) {
        FilmDataSingletonModel.films = JSON.parse(response)  // ❌
    })
}

// ✅ BON : Via signal
function fetchAllFilms() {
    HttpRequest.get(url).then(function(response) {
        filmsFetched(JSON.parse(response))  // ✅ Signal
    })
}
```

**3. Pas d'instanciation dans Vue**
```qml
// ❌ MAUVAIS
CataloguePage {
    FilmService { id: service }
    Button {
        onClicked: service.fetchAllFilms()
    }
}

// ✅ BON : Via Logic
CataloguePage {
    CatalogueLogic { id: logic }
    Button {
        onClicked: logic.refreshCatalogue()
    }
}
```

---

## Testing

### Mock complet

```qml
Item {
    id: mockFilmService
    
    // ═══════════════════════════════════════
    // PROPRIÉTÉS DE TEST
    // ═══════════════════════════════════════
    
    property bool __testMode: true
    property var __mockResponse: [
        {id: 1, title: "Film 1", poster_url: "url1"},
        {id: 2, title: "Film 2", poster_url: "url2"}
    ]
    property bool __mockError: false
    property string __mockErrorMessage: "Test error"
    property int __mockDelay: 100  // ms
    
    // ═══════════════════════════════════════
    // SIGNAUX (identiques au vrai service)
    // ═══════════════════════════════════════
    
    signal filmsFetched(var films)
    signal fetchError(string message)
    
    // ═══════════════════════════════════════
    // MÉTHODE MOCKÉE
    // ═══════════════════════════════════════
    
    function fetchAllFilms() {
        if (!__testMode) {
            // Mode normal (à implémenter si nécessaire)
            return
        }
        
        // Simule délai réseau
        mockTimer.start()
    }
    
    // ═══════════════════════════════════════
    // TIMER POUR SIMULATION
    // ═══════════════════════════════════════
    
    Timer {
        id: mockTimer
        interval: __mockDelay
        repeat: false
        onTriggered: {
            if (__mockError) {
                fetchError(__mockErrorMessage)
            } else {
                filmsFetched(__mockResponse)
            }
        }
    }
}
```

### Tests unitaires

```qml
TestCase {
    name: "FilmServiceTests"
    
    property var service: FilmService {
        apiUrl: "http://localhost:8000/api"
    }
    
    SignalSpy {
        id: fetchedSpy
        target: service
        signalName: "filmsFetched"
    }
    
    SignalSpy {
        id: errorSpy
        target: service
        signalName: "fetchError"
    }
    
    function test_fetchAllFilms_success() {
        fetchedSpy.clear()
        
        // Mock réponse (nécessite mock du backend ou HttpRequest)
        service.__mockResponse = [{id:1, title:"Film"}]
        service.fetchAllFilms()
        
        // Attendre signal
        fetchedSpy.wait(5000)
        
        // Vérifier
        compare(fetchedSpy.count, 1)
        var films = fetchedSpy.signalArguments[0][0]
        compare(films.length, 1)
        compare(films[0].title, "Film")
    }
    
    function test_fetchAllFilms_error() {
        errorSpy.clear()
        
        // Simuler erreur
        service.__mockError = true
        service.fetchAllFilms()
        
        // Attendre signal
        errorSpy.wait(5000)
        
        // Vérifier
        compare(errorSpy.count, 1)
    }
}
```

---

## Références

- [Architecture MVC](../architecture/mvc-pattern.md)
- [Flux de données](../architecture/data-flow.md)
- [FilmDataSingletonModel](FilmDataSingletonModel-detailed.md)
- [CatalogueLogic](../logic/CatalogueLogic.md)
- [Felgo HttpRequest Documentation](https://felgo.com/doc/felgo-httprequest/)
- [Django REST Framework](https://www.django-rest-framework.org/)
