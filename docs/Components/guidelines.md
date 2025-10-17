# Guidelines pour la création de composants

## Introduction

Ce document établit les règles et bonnes pratiques pour créer de nouveaux composants dans Cinevault APP, garantissant cohérence, qualité et maintenabilité.

**N.B:** *Tout ce qui a été noté ici n'a pas été appliqué à la lettre durant ce projet. Cependant, ce fichier a pour but de donner des directives pour des prochains projets.*

---

## Checklist de création

Avant de considérer un composant comme terminé, vérifier :

### Structure et code
- [ ] Nom du fichier en PascalCase (ex: `FilmCard.qml`)
- [ ] Import Felgo 4.0 et QtQuick 2.15
- [ ] Item racine avec id explicite
- [ ] Section commentaires organisée

### API et propriétés
- [ ] Propriétés publiques documentées avec commentaires
- [ ] Propriétés readonly pour les états
- [ ] Valeurs par défaut sensées
- [ ] Pas de propriétés obligatoires (sauf cas exceptionnels)

### États et visibilité
- [ ] Tous les états visuels gérés (loading, ready, error, empty)
- [ ] Transitions fluides entre états
- [ ] Feedback visuel clair pour chaque état

### Performance
- [ ] Utilisation de dp() et sp() pour dimensions et textes
- [ ] Chargement asynchrone si applicable
- [ ] Pas de bindings complexes inutiles
- [ ] Optimisation mémoire (ex: sourceSize pour images)

### Communication
- [ ] Signaux pour événements importants
- [ ] Pas de dépendance à un contexte externe
- [ ] API claire et documentée

### Accessibilité
- [ ] Propriétés Accessible.* définies
- [ ] Textes alternatifs pour images
- [ ] Navigation clavier possible

### Tests et debug
- [ ] Propriété testId pour identification en tests
- [ ] Logs console appropriés (avec conditions)
- [ ] Testable en isolation

### Documentation
- [ ] Commentaires inline sur propriétés/fonctions complexes
- [ ] Fichier .md dans docs/components/
- [ ] Exemples d'utilisation fournis
- [ ] Enregistré dans qmldir

---

## Template de démarrage

```qml
import Felgo 4.0
import QtQuick 2.15

/**
 * [NomComposant] - Description courte
 * 
 * Description détaillée du composant, son usage principal
 * et ses caractéristiques principales.
 * 
 * @example
 * NomComposant {
 *     property1: value1
 *     property2: value2
 * }
 */
Item {
    id: root
    
    // ============================================
    // PROPRIÉTÉS PUBLIQUES - CONFIGURATION
    // ============================================
    
    /**
     * Description de la propriété
     * @type {Type}
     * @default valeurParDefaut
     */
    property string propertyName: "defaultValue"
    
    /**
     * Active/désactive une fonctionnalité
     * @type {boolean}
     * @default true
     */
    property bool enableFeature: true
    
    // ============================================
    // PROPRIÉTÉS PUBLIQUES - ÉTATS (READONLY)
    // ============================================
    
    /**
     * Indique si le composant est dans l'état X
     * @type {boolean}
     * @readonly
     */
    readonly property bool isStateX: internal.stateX
    
    // ============================================
    // SIGNAUX
    // ============================================
    
    /**
     * Émis quand un événement se produit
     * @param {Type} paramName Description du paramètre
     */
    signal eventOccurred(string paramName)
    
    // ============================================
    // PROPRIÉTÉS INTERNES (PRIVÉES)
    // ============================================
    
    QtObject {
        id: internal
        property bool stateX: false
        property var data: null
    }
    
    // ============================================
    // CONTENU VISUEL
    // ============================================
    
    // État 1: Loading
    Rectangle {
        id: loadingState
        anchors.fill: parent
        visible: internal.stateX
        
        BusyIndicator {
            anchors.centerIn: parent
        }
    }
    
    // État 2: Ready
    Rectangle {
        id: readyState
        anchors.fill: parent
        visible: !internal.stateX
        
        // Contenu principal
    }
    
    // État 3: Error (si applicable)
    Rectangle {
        id: errorState
        anchors.fill: parent
        visible: internal.hasError
        
        // Affichage erreur
    }
    
    // ============================================
    // FONCTIONS PUBLIQUES
    // ============================================
    
    /**
     * Description de la fonction
     * @param {Type} paramName Description du paramètre
     * @returns {Type} Description de la valeur retournée
     */
    function publicFunction(paramName) {
        // Implémentation
    }
    
    // ============================================
    // FONCTIONS INTERNES (PRIVÉES)
    // ============================================
    
    function _privateFunction() {
        // Implémentation
    }
    
    // ============================================
    // INITIALISATION
    // ============================================
    
    Component.onCompleted: {
        console.log("[NomComposant] Initialisé")
    }
    
    // ============================================
    // ACCESSIBILITÉ
    // ============================================
    
    Accessible.role: Accessible.Button
    Accessible.name: "Description pour lecteur d'écran"
    Accessible.description: "Description détaillée"
}
```

---

## Règles de nommage

### Fichiers
```
✅ PascalCase
✅ Extension .qml
✅ Nom descriptif et concis

Exemples:
✅ PosterImage.qml
✅ FilmCard.qml
✅ FilterPanel.qml
✅ LoadingIndicator.qml

❌ posterimage.qml
❌ film_card.qml
❌ FilterPanel.js
```

### IDs
```qml
✅ camelCase
✅ Descriptif
✅ Pas de underscore

Exemples:
id: posterImage       ✅
id: loadingIndicator  ✅
id: errorFallback     ✅

id: poster_image      ❌
id: img               ❌
id: rectangle1        ❌
```

### Propriétés
```qml
// Booléens d'état
property bool isLoading: false      ✅
property bool hasError: false       ✅
property bool canEdit: true         ✅
property bool shouldLoad: false     ✅

// Données
property string filmTitle: ""       ✅
property var filmData: null         ✅
property real posterWidth: 100      ✅

// À éviter
property bool loading               ❌ (préférer isLoading)
property bool error                 ❌ (préférer hasError)
property string title               ❌ (trop générique)
```

### Fonctions
```qml
// Publiques (camelCase, verbe d'action)
function loadData() { }           ✅
function resetState() { }         ✅
function updateDisplay() { }      ✅

// Privées (préfixe underscore)
function _internalLogic() { }     ✅
function _calculateSize() { }     ✅

// À éviter
function Load() { }               ❌ (PascalCase)
function data() { }               ❌ (pas de verbe)
function fn1() { }                ❌ (pas descriptif)
```

### Signaux
```qml
// Past tense pour événements accomplis
signal clicked()                  ✅
signal imageLoaded()              ✅
signal errorOccurred(string msg)  ✅

// Noms descriptifs avec paramètres typés
signal filmSelected(int filmId)   ✅
signal dataChanged(var newData)   ✅

// À éviter
signal click()                    ❌ (present tense)
signal error()                    ❌ (pas assez descriptif)
signal sig1()                     ❌ (pas descriptif)
```

---

## Organisation du code

### Ordre des sections

1. **Imports**
2. **Documentation principale**
3. **Item racine avec id**
4. **Propriétés publiques - Configuration**
5. **Propriétés publiques - États (readonly)**
6. **Signaux**
7. **Propriétés internes (QtObject)**
8. **Contenu visuel**
9. **Fonctions publiques**
10. **Fonctions internes**
11. **Initialisation (Component.onCompleted)**
12. **Accessibilité**

### Séparateurs de sections

```qml
// ============================================
// SECTION NAME
// ============================================
```

### Commentaires

```qml
/**
 * Commentaire JSDoc pour documentation
 * Multi-lignes avec description détaillée
 * @param, @returns, @type, etc.
 */

// Commentaire simple pour explications courtes

/* Commentaire bloc pour désactiver temporairement
   du code pendant développement */
```

---

## Gestion des états

### Pattern recommandé : États exclusifs

```qml
Item {
    id: root
    
    // État calculé
    readonly property string state: {
        if (internal.loading) return "loading"
        if (internal.error !== "") return "error"
        if (!internal.hasData) return "empty"
        return "ready"
    }
    
    // Visibilité conditionnelle
    Rectangle {
        id: loadingView
        visible: root.state === "loading"
    }
    
    Rectangle {
        id: errorView
        visible: root.state === "error"
    }
    
    Rectangle {
        id: emptyView
        visible: root.state === "empty"
    }
    
    Rectangle {
        id: contentView
        visible: root.state === "ready"
    }
}
```

### Alternative : Loader pour états complexes

```qml
Loader {
    anchors.fill: parent
    sourceComponent: {
        switch (root.state) {
            case "loading": return loadingComponent
            case "error": return errorComponent
            case "empty": return emptyComponent
            default: return contentComponent
        }
    }
}

Component { id: loadingComponent; /* ... */ }
Component { id: errorComponent; /* ... */ }
Component { id: emptyComponent; /* ... */ }
Component { id: contentComponent; /* ... */ }
```

---

## Responsive design

### Unités adaptatives obligatoires

```qml
// ✅ TOUJOURS utiliser dp() pour dimensions
width: dp(100)
height: dp(150)
anchors.margins: dp(16)
radius: dp(8)

// ✅ TOUJOURS utiliser sp() pour textes
Text {
    font.pixelSize: sp(14)
}

// ❌ JAMAIS de valeurs fixes
width: 100      ❌
height: 150     ❌
font.pixelSize: 14  ❌
```

### Breakpoints

```qml
Item {
    readonly property bool isSmallScreen: width < dp(600)
    readonly property bool isMediumScreen: width >= dp(600) && width < dp(1200)
    readonly property bool isLargeScreen: width >= dp(1200)
    
    // Adaptation
    columns: {
        if (isSmallScreen) return 2
        if (isMediumScreen) return 4
        return 6
    }
}
```

### Proportions relatives

```qml
Rectangle {
    width: parent.width * 0.8    // 80% du parent
    height: width * 1.5           // Ratio constant
}
```

---

## Performance

### Optimisations obligatoires

#### Images
```qml
Image {
    source: url
    asynchronous: true           // ✅ Non-bloquant
    cache: true                  // ✅ Cache mémoire
    
    // ✅ Limite résolution
    sourceSize.width: Math.min(width * 2, 400)
    sourceSize.height: Math.min(height * 2, 600)
}
```

#### Bindings
```qml
// ✅ BON : Simple et direct
Text {
    text: filmCount + " films"
}

// ❌ MAUVAIS : Complexe, recalculé souvent
Text {
    text: {
        var result = ""
        for (var i = 0; i < films.length; i++) {
            result += films[i].title + ", "
        }
        return result.slice(0, -2)
    }
}

// ✅ SOLUTION : Propriété calculée une fois
readonly property string filmTitles: {
    return films.map(f => f.title).join(", ")
}
```

#### Loader lazy

```qml
Loader {
    active: root.visible    // ✅ Charge seulement si visible
    asynchronous: true      // ✅ Non-bloquant
    sourceComponent: ExpensiveComponent { }
}
```

---

## Accessibilité

### Propriétés obligatoires

```qml
Item {
    // Rôle du composant
    Accessible.role: Accessible.Button
    
    // Nom court
    Accessible.name: "Poster Avatar"
    
    // Description détaillée
    Accessible.description: "Affiche le poster du film Avatar. Toucher pour voir les détails."
    
    // État focusable
    Accessible.focusable: true
    Accessible.focused: activeFocus
}
```

### Rôles courants

```qml
Accessible.Button         // Bouton cliquable
Accessible.Image          // Image informative
Accessible.StaticText     // Texte statique
Accessible.EditableText   // Champ éditable
Accessible.List           // Liste d'éléments
Accessible.ListItem       // Item dans une liste
```

---

## Tests

### Propriétés de test

```qml
Item {
    id: root
    
    // ID unique pour tests automatisés
    property string testId: ""
    
    // Mode test pour forcer états
    property bool __testMode: false
    property string __forcedState: "ready"
    
    readonly property string actualState: {
        if (__testMode) return __forcedState
        // ... calcul normal
    }
}
```

### Signaux de test

```qml
Item {
    // Signaux pour validation en tests
    signal __testImageLoaded()
    signal __testImageError()
    signal __testStateChanged(string newState)
    
    Image {
        onStatusChanged: {
            if (status === Image.Ready) __testImageLoaded()
            if (status === Image.Error) __testImageError()
        }
    }
}
```

---

## Documentation

### Commentaires de propriété

```qml
/**
 * URL du poster à afficher
 * @type {string}
 * @default ""
 * @example "https://example.com/poster.jpg"
 */
property string source: ""
```

### Commentaires de fonction

```qml
/**
 * Recharge l'image depuis la source
 * Utile après une erreur de chargement
 * @returns {void}
 * @example
 * posterImage.reloadImage()
 */
function reloadImage() {
    image.source = ""
    image.source = root.source
}
```

### Fichier markdown

Créer `docs/components/NomComposant.md` avec :
- Vue d'ensemble
- Import et utilisation
- Toutes les propriétés documentées
- États visuels
- Exemples d'utilisation
- Bonnes pratiques

---

## Enregistrement

### qmldir

```
# qml/components/qmldir

# Composants publics
PosterImage 1.0 PosterImage.qml
FilmCard 1.0 FilmCard.qml

# Composants internes (non exportés)
internal ImagePlaceholder ImagePlaceholder.qml
```

---

## Validation finale non appliqué dans ce projet :-

Avant de merger :

1. ✅ Code review par un pair
2. ✅ Tests manuels sur 3 plateformes minimum
3. ✅ Tests automatisés si applicable
4. ✅ Documentation complète
5. ✅ Pas de warnings console
6. ✅ Performance acceptable (< 16ms frame time)
7. ✅ Accessibilité validée

---

## Références

- [Documentation PosterImage](PosterImage.md) - Exemple de référence
- [Architecture MVC](../Architecture/mvc-pattern.md)
- [Felgo Best Practices](https://felgo.com/doc/)
