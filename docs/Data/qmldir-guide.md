# Guide du fichier qmldir - Cinevault APP

## Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Qu'est-ce que qmldir ?](#quest-ce-que-qmldir)
3. [Localisation](#localisation)
4. [Structure du fichier](#structure-du-fichier)
5. [Syntaxe détaillée](#syntaxe-détaillée)
6. [Types d'enregistrement](#types-denregistrement)
7. [Enregistrement des Singletons](#enregistrement-des-singletons)
8. [Import et utilisation](#import-et-utilisation)
9. [Erreurs courantes](#erreurs-courantes)
10. [Exemples complets](#exemples-complets)
11. [Bonnes pratiques](#bonnes-pratiques)
12. [Debugging](#debugging)

---

## Vue d'ensemble

### Définition

Le fichier `qmldir` est un **fichier de configuration** qui déclare et enregistre les types QML disponibles dans un module. C'est l'équivalent d'un "index" ou "manifest" pour les composants QML.

### Rôle

✅ **Enregistrer les types QML** (composants, singletons)  
✅ **Définir les versions** de chaque type  
✅ **Créer un namespace** pour l'import  
✅ **Rendre les composants importables** depuis d'autres fichiers  

### Localisation dans Cinevault

```
qml/model/qmldir
```

---

## Qu'est-ce que qmldir ?

### Analogie

Imaginez un **répertoire téléphonique** :
- **qmldir** = Le répertoire
- **Noms enregistrés** = Les types QML (FilmDataSingletonModel, FilmService)
- **Numéros** = Les fichiers QML correspondants

Sans le répertoire (qmldir), impossible de "joindre" (importer) les types.

### Pourquoi est-il nécessaire ?

**Sans qmldir** :
```qml
// ❌ NE FONCTIONNE PAS
import "../model" as Model

Item {
    // Erreur : Model.FilmDataSingletonModel is not defined
    Text {
        text: Model.FilmDataSingletonModel.films.length
    }
}
```

**Avec qmldir** :
```qml
// ✅ FONCTIONNE
import "../model" as Model

Item {
    // OK : Type trouvé via qmldir
    Text {
        text: Model.FilmDataSingletonModel.films.length
    }
}
```

---

## Localisation

### Dans le projet Cinevault

```
qml/
├── model/
│   ├── FilmDataSingletonModel.qml
│   └── qmldir                    ← ICI
│
├── logic/
│   ├── CatalogueLogic.qml
│   └── qmldir                    ← Un par dossier
│
├── services/
│   ├── FilmService.qml
│   └── qmldir                    ← Un par dossier
│
├── components/
│   ├── PosterImage.qml
│   └── qmldir                    ← Un par dossier
│
└── pages/
    └── CataloguePage.qml
```

### Règle importante

**Un fichier `qmldir` par dossier de module.**

---

## Structure du fichier

### Contenu du qmldir de model/

```
# qml/model/qmldir

# Enregistrement du Singleton
singleton FilmDataSingletonModel 1.0 FilmDataSingletonModel.qml

# Enregistrement du Service
FilmService 1.0 FilmService.qml
```

### Anatomie d'une ligne

```
singleton FilmDataSingletonModel 1.0 FilmDataSingletonModel.qml
↑         ↑                      ↑   ↑
│         │                      │   └─── Nom du fichier
│         │                      └─────── Version (majeure.mineure)
│         └────────────────────────────── Nom du type exposé
└──────────────────────────────────────── Modificateur (singleton, internal)
```

### Décomposition

| Élément | Description | Obligatoire |
|---------|-------------|-------------|
| `singleton` | Type spécial (une seule instance) | Oui pour Singleton |
| `FilmDataSingletonModel` | Nom utilisé dans import | Oui |
| `1.0` | Version du type | Oui |
| `FilmDataSingletonModel.qml` | Fichier source | Oui |

---

## Syntaxe détaillée

### Format général

```
[modificateur] NomType Version NomFichier.qml
```

### Modificateurs disponibles

| Modificateur | Usage | Exemple |
|--------------|-------|---------|
| *(aucun)* | Type standard | `FilmService 1.0 FilmService.qml` |
| `singleton` | Type Singleton | `singleton FilmDataSingletonModel 1.0 FilmDataSingletonModel.qml` |
| `internal` | Type interne (non exporté) | `internal HelperComponent 1.0 Helper.qml` |

### Version

**Format** : `majeure.mineure`

**Exemples** :
- `1.0` → Version initiale
- `1.1` → Ajout de fonctionnalités (compatible)
- `2.0` → Changements disruptifs (incompatible)

**Usage** :
```qml
// Import version spécifique
import "../model" 1.0 as Model

// Import dernière version compatible
import "../model" as Model
```

---

## Types d'enregistrement

### Type 1 : Composant standard

**Syntaxe** :
```
NomType Version Fichier.qml
```

**Exemple** :
```
FilmService 1.0 FilmService.qml
```

**Utilisation** :
```qml
import "../model" as Model

Item {
    // Instanciation normale
    Model.FilmService {
        id: filmService
        apiUrl: "http://localhost:8000/api"
    }
}
```

**Caractéristiques** :
- ✅ Peut être instancié plusieurs fois
- ✅ Chaque instance est indépendante
- ✅ Utilisation classique d'un composant

### Type 2 : Singleton

**Syntaxe** :
```
singleton NomSingleton Version Fichier.qml
```

**Exemple** :
```
singleton FilmDataSingletonModel 1.0 FilmDataSingletonModel.qml
```

**Utilisation** :
```qml
import "../model" as Model

Item {
    // Accès direct (pas d'instanciation)
    Text {
        text: Model.FilmDataSingletonModel.films.length
    }
}
```

**Caractéristiques** :
- ✅ Une seule instance dans toute l'application
- ✅ Accès direct via namespace (pas d'instanciation)
- ✅ Partagé globalement

**Différence avec composant standard** :

```qml
// Composant standard : Instanciation
Model.FilmService {
    id: service1
}
Model.FilmService {
    id: service2  // Deux instances différentes
}

// Singleton : Accès direct
Model.FilmDataSingletonModel.films.length  // Une seule instance
```

### Type 3 : Composant interne

**Syntaxe** :
```
internal NomInterne Version Fichier.qml
```

**Exemple** :
```
internal FilmCardHelper 1.0 FilmCardHelper.qml
```

**Utilisation** :
```qml
// Utilisable uniquement DANS le même dossier
// PAS importable depuis l'extérieur

// FilmCard.qml (même dossier)
Item {
    FilmCardHelper {  // ✅ OK
        id: helper
    }
}

// CataloguePage.qml (autre dossier)
import "../components" as Components

Item {
    Components.FilmCardHelper { }  // ❌ ERREUR : internal
}
```

**Caractéristiques** :
- ✅ Visible seulement dans le module
- ✅ Pas exporté à l'extérieur
- ✅ Utile pour composants d'implémentation

---

## Enregistrement des Singletons

### Pourquoi enregistrer un Singleton ?

Pour qu'un Singleton soit accessible via import, il **doit** être déclaré dans qmldir avec le mot-clé `singleton`.

### Étapes complètes

**1. Déclarer le fichier QML comme Singleton**

```qml
// FilmDataSingletonModel.qml
pragma Singleton  // ← CRUCIAL
import Felgo 4.0
import QtQuick 2.15

Item {
    id: filmDataSingletonModel
    
    property var films: []
    property bool isLoading: false
}
```

**2. Enregistrer dans qmldir**

```
# qml/model/qmldir
singleton FilmDataSingletonModel 1.0 FilmDataSingletonModel.qml
```

**3. Importer et utiliser**

```qml
// N'importe où dans l'application
import "../model" as Model

Item {
    Text {
        text: Model.FilmDataSingletonModel.films.length + " films"
    }
}
```

### Erreur si qmldir manque

```qml
import "../model" as Model

Item {
    Text {
        // ❌ ERREUR : Model.FilmDataSingletonModel is not defined
        text: Model.FilmDataSingletonModel.films.length
    }
}
```

**Message d'erreur console** :
```
ReferenceError: FilmDataSingletonModel is not defined
```

---

## Import et utilisation

### Import d'un module

**Syntaxe** :
```qml
import "chemin/vers/module" [version] as Namespace
```

**Exemples** :

```qml
// Import avec namespace
import "../model" as Model

// Import avec version spécifique
import "../model" 1.0 as Model

// Import sans namespace (déconseillé)
import "../model"
```

### Utilisation après import

**Composant standard** :
```qml
import "../model" as Model

Item {
    Model.FilmService {
        id: filmService
    }
}
```

**Singleton** :
```qml
import "../model" as Model

Item {
    Text {
        text: Model.FilmDataSingletonModel.films.length
    }
}
```

### Pourquoi utiliser un namespace ?

**Sans namespace (❌)** :
```qml
import "../model"
import "../logic"

Item {
    // Ambiguïté si les deux modules ont un type "DataModel"
    DataModel { }  // ❌ Lequel ?
}
```

**Avec namespace (✅)** :
```qml
import "../model" as Model
import "../logic" as Logic

Item {
    Model.DataModel { }   // ✅ Clair : model
    Logic.DataModel { }   // ✅ Clair : logic
}
```

---

## Erreurs courantes

### Erreur 1 : qmldir manquant

**Symptôme** :
```
ReferenceError: FilmDataSingletonModel is not defined
```

**Cause** :
```
qml/model/
├── FilmDataSingletonModel.qml
└── FilmService.qml
# ❌ Pas de qmldir
```

**Solution** :
```
qml/model/
├── FilmDataSingletonModel.qml
├── FilmService.qml
└── qmldir  ✅ Créer le fichier
```

### Erreur 2 : Nom de fichier incorrect

**qmldir** :
```
singleton FilmDataSingletonModel 1.0 FilmDataModel.qml
                                     ↑
                                     ❌ Nom différent du fichier réel
```

**Fichier réel** :
```
FilmDataSingletonModel.qml  ← Nom correct
```

**Solution** :
```
singleton FilmDataSingletonModel 1.0 FilmDataSingletonModel.qml
                                     ↑
                                     ✅ Nom exact du fichier
```

### Erreur 3 : Oubli du mot-clé singleton

**qmldir** :
```
FilmDataSingletonModel 1.0 FilmDataSingletonModel.qml
❌ Manque "singleton"
```

**Résultat** :
```qml
// Tentative d'instanciation au lieu d'accès direct
Model.FilmDataSingletonModel { }  // ❌ Erreur
```

**Solution** :
```
singleton FilmDataSingletonModel 1.0 FilmDataSingletonModel.qml
✅ Avec "singleton"
```

### Erreur 4 : Oubli de pragma Singleton dans le QML

**qmldir** :
```
singleton FilmDataSingletonModel 1.0 FilmDataSingletonModel.qml
✅ Déclaré comme singleton
```

**FilmDataSingletonModel.qml** :
```qml
// ❌ Manque pragma Singleton
import Felgo 4.0
import QtQuick 2.15

Item {
    property var films: []
}
```

**Message d'erreur** :
```
Singleton Type FilmDataSingletonModel is not a singleton
```

**Solution** :
```qml
pragma Singleton  // ✅ Ajouter
import Felgo 4.0
import QtQuick 2.15

Item {
    property var films: []
}
```

### Erreur 5 : Version manquante

**qmldir** :
```
singleton FilmDataSingletonModel FilmDataSingletonModel.qml
                                 ❌ Manque version
```

**Solution** :
```
singleton FilmDataSingletonModel 1.0 FilmDataSingletonModel.qml
                                 ✅ Version ajoutée
```

---

## Exemples complets

### Exemple 1 : Module model/ complet

**Structure** :
```
qml/model/
├── FilmDataSingletonModel.qml
├── FilmService.qml
├── CategoryModel.qml
└── qmldir
```

**qmldir** :
```
# Module model - Gestion des données
# Version 1.0

# Singletons
singleton FilmDataSingletonModel 1.0 FilmDataSingletonModel.qml
singleton CategoryModel 1.0 CategoryModel.qml

# Services
FilmService 1.0 FilmService.qml
```

**Utilisation** :
```qml
import "../model" as Model

Item {
    // Accès Singletons
    Text {
        text: Model.FilmDataSingletonModel.films.length
    }
    
    Text {
        text: Model.CategoryModel.categories.length
    }
    
    // Instanciation Services
    Model.FilmService {
        id: filmService
        apiUrl: "http://localhost:8000/api"
    }
}
```

### Exemple 2 : Module components/ complet

**Structure** :
```
qml/components/
├── PosterImage.qml
├── FilmCard.qml
├── LoadingIndicator.qml
├── internal/
│   └── ImagePlaceholder.qml
└── qmldir
```

**qmldir** :
```
# Module components - Composants réutilisables
# Version 1.0

# Composants publics
PosterImage 1.0 PosterImage.qml
FilmCard 1.0 FilmCard.qml
LoadingIndicator 1.0 LoadingIndicator.qml

# Composants internes
internal ImagePlaceholder 1.0 internal/ImagePlaceholder.qml
```

**Utilisation** :
```qml
import "../components" as Components

Item {
    // Composants publics : ✅ OK
    Components.PosterImage {
        source: "url"
    }
    
    Components.FilmCard {
        filmData: {...}
    }
    
    // Composant interne : ❌ ERREUR
    Components.ImagePlaceholder { }  // Non accessible
}
```

### Exemple 3 : Module logic/ complet

**Structure** :
```
qml/logic/
├── CatalogueLogic.qml
├── RechercheLogic.qml
└── qmldir
```

**qmldir** :
```
# Module logic - Logique métier
# Version 1.0

CatalogueLogic 1.0 CatalogueLogic.qml
RechercheLogic 1.0 RechercheLogic.qml
```

**Utilisation** :
```qml
import "../logic" as Logic

AppPage {
    Logic.CatalogueLogic {
        id: logic
    }
    
    Button {
        onClicked: logic.refreshCatalogue()
    }
}
```

---

## Bonnes pratiques

### ✅ À faire

**1. Un qmldir par module**
```
qml/
├── model/qmldir      ✅
├── logic/qmldir      ✅
├── components/qmldir ✅
└── pages/qmldir      ✅ (si export nécessaire)
```

**2. Commentaires dans qmldir**
```
# Module model - Gestion des données
# Version 1.0
# Maintenu par : Équipe Cinevault

# Singletons
singleton FilmDataSingletonModel 1.0 FilmDataSingletonModel.qml

# Services
FilmService 1.0 FilmService.qml
```

**3. Versions cohérentes**
```
# Tous en 1.0 initialement
FilmService 1.0 FilmService.qml
FilmDataSingletonModel 1.0 FilmDataSingletonModel.qml

# Pas de mélange 1.0 et 2.0 sans raison
```

**4. Organisation par type**
```
# Singletons
singleton FilmDataSingletonModel 1.0 FilmDataSingletonModel.qml

# Services
FilmService 1.0 FilmService.qml

# Composants
PosterImage 1.0 PosterImage.qml
```

**5. Noms cohérents**
```
# ✅ Nom type = Nom fichier
PosterImage 1.0 PosterImage.qml

# ❌ Noms différents (confusion)
PosterImg 1.0 PosterImage.qml
```

### ❌ À éviter

**1. qmldir dans un mauvais dossier**
```
qml/
├── qmldir  ❌ Trop haut niveau
├── model/
│   ├── FilmDataSingletonModel.qml
│   └── FilmService.qml
```

**2. Types non déclarés**
```
qml/model/
├── FilmDataSingletonModel.qml
├── FilmService.qml
└── qmldir

# qmldir
singleton FilmDataSingletonModel 1.0 FilmDataSingletonModel.qml
# ❌ FilmService non déclaré
```

**3. Versions incohérentes**
```
FilmService 1.0 FilmService.qml
FilmService 2.0 FilmService.qml  # ❌ Doublon avec versions différentes
```

**4. Chemins absolus**
```
# ❌ Chemin absolu
singleton FilmDataSingletonModel 1.0 /absolute/path/FilmDataSingletonModel.qml

# ✅ Chemin relatif au qmldir
singleton FilmDataSingletonModel 1.0 FilmDataSingletonModel.qml
```

---

## Debugging

### Vérifier que qmldir est lu

**Ajouter logs dans le Singleton** :
```qml
// FilmDataSingletonModel.qml
pragma Singleton
import Felgo 4.0
import QtQuick 2.15

Item {
    Component.onCompleted: {
        console.log("✅ FilmDataSingletonModel chargé depuis qmldir")
    }
}
```

**Si log s'affiche** → qmldir est lu ✅  
**Si pas de log** → qmldir n'est pas trouvé ❌

### Vérifier la syntaxe de qmldir

**Outil de validation** :
```bash
# Qt fournit qmllint pour vérifier
qmllint qml/model/qmldir
```

### Erreurs de chargement

**Console output** :
```
qrc:/qml/pages/CataloguePage.qml:5:1: module "../model" is not installed
```

**Causes possibles** :
1. ❌ qmldir manquant
2. ❌ Chemin import incorrect
3. ❌ Syntaxe qmldir invalide

**Vérifications** :
```bash
# 1. Vérifier présence
ls qml/model/qmldir

# 2. Vérifier contenu
cat qml/model/qmldir

# 3. Vérifier syntaxe (pas d'espaces superflus)
```

### Test d'import

**Créer une page de test** :
```qml
// TestImportPage.qml
import Felgo 4.0
import QtQuick 2.15
import "../model" as Model

AppPage {
    Component.onCompleted: {
        console.log("=== Test imports ===")
        console.log("FilmDataSingletonModel:", Model.FilmDataSingletonModel)
        console.log("Films:", Model.FilmDataSingletonModel.films)
        console.log("=== Test OK ===")
    }
}
```

**Si tout fonctionne** :
```
=== Test imports ===
FilmDataSingletonModel: QQuickItem(0x...)
Films: []
=== Test OK ===
```

---

## Résumé

### Checklist qmldir

- [ ] Un fichier qmldir par module (dossier)
- [ ] Tous les types exportés sont déclarés
- [ ] Singletons déclarés avec `singleton`
- [ ] Versions cohérentes (1.0 par défaut)
- [ ] Noms de fichiers exacts
- [ ] Commentaires pour clarté
- [ ] Pas d'espaces superflus
- [ ] Types internes marqués `internal`

### Points clés

| Aspect | Description |
|--------|-------------|
| **Rôle** | Enregistre et expose les types QML d'un module |
| **Localisation** | Un par dossier de module |
| **Syntaxe** | `[modificateur] NomType Version Fichier.qml` |
| **Singleton** | Mot-clé `singleton` + `pragma Singleton` dans QML |
| **Import** | `import "chemin" as Namespace` |

---

## Références

- [Documentation complète du modèle](README.md)
- [FilmDataSingletonModel](FilmDataSingletonModel.md)
- [FilmService](FilmService.md)
- [Qt QML Module Definition](https://doc.qt.io/qt-6/qtqml-modules-qmldir.html)
