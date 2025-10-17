# Documentation des Composants - Cinevault APP

## Vue d'ensemble

Les composants sont des éléments réutilisables de l'interface utilisateur qui encapsulent à la fois l'apparence et le comportement. Ils suivent les principes de **modularité**, **réutilisabilité** et **configurabilité**.

## Liste des composants

| Composant | Description | Statut |
|-----------|-------------|--------|
| [PosterImage](PosterImage.md) | Affichage optimisé des posters de films | ✅ Implémenté |
| FilmCard | Carte complète d'un film | 🔜 À venir |
| FilterPanel | Panneau de filtres avancés | 🔜 À venir |
| SearchBar | Barre de recherche IMDb | 🔜 À venir |

## Principes de conception

### 1. Composants auto-contenus

Chaque composant doit :
- Gérer ses propres états visuels
- Exposer une API claire via propriétés
- Ne pas dépendre de contexte externe
- Être testable isolément

**Exemple** :
```qml
// ✅ BON : API claire, pas de dépendance externe
PosterImage {
    source: "https://example.com/poster.jpg"
    enableLazyLoading: true
    borderRadius: dp(8)
}

// ❌ MAUVAIS : Dépend de variables externes
PosterImage {
    // Suppose que filmData existe dans le parent
    source: filmData.poster_url
}
```

### 2. Configuration via propriétés

Les composants exposent des propriétés publiques pour la personnalisation :

```qml
Item {
    // Propriétés de configuration
    property string source: ""
    property bool enableLazyLoading: false
    property real borderRadius: dp(6)
    
    // Propriétés d'état (readonly)
    readonly property bool isLoading: image.status === Image.Loading
    readonly property bool hasError: image.status === Image.Error
}
```

### 3. Communication par signaux

Pour les événements et interactions :

```qml
Item {
    // Signaux pour communication parent ← composant
    signal clicked()
    signal imageLoaded()
    signal loadError(string message)
    
    MouseArea {
        onClicked: parent.clicked()
    }
}
```

### 4. États visuels clairs

Chaque état doit être visuellement distinct :

- **Loading** : Placeholder + animation
- **Ready** : Contenu affiché
- **Error** : Fallback avec message
- **Empty** : État vide avec indication

## Structure d'un composant

### Template de base

```qml
import Felgo 4.0
import QtQuick 2.15

Item {
    id: root
    
    // =======================
    // PROPRIÉTÉS PUBLIQUES
    // =======================
    
    // Configuration
    property string source: ""
    property bool enabled: true
    
    // États en lecture seule
    readonly property bool isReady: internal.ready
    readonly property string errorMessage: internal.error
    
    // =======================
    // SIGNAUX
    // =======================
    
    signal clicked()
    signal stateChanged(string newState)
    
    // =======================
    // PROPRIÉTÉS INTERNES
    // =======================
    
    QtObject {
        id: internal
        property bool ready: false
        property string error: ""
    }
    
    // =======================
    // CONTENU VISUEL
    // =======================
    
    Rectangle {
        anchors.fill: parent
        // Contenu du composant
    }
    
    // =======================
    // FONCTIONS PUBLIQUES
    // =======================
    
    function reset() {
        internal.ready = false
        internal.error = ""
    }
    
    // =======================
    // INITIALISATION
    // =======================
    
    Component.onCompleted: {
        console.log("Composant initialisé")
    }
}
```

## Conventions de nommage

### Fichiers
- **PascalCase** pour les noms de composants
- Extension `.qml`
- Exemples : `PosterImage.qml`, `FilmCard.qml`, `FilterPanel.qml`

### Propriétés
```qml
// camelCase pour les propriétés
property string posterUrl: ""
property bool enableLazyLoading: false
property real borderRadius: dp(6)

// Préfixes selon le type
property bool isLoading: false      // is* pour booléens d'état
property bool hasError: false       // has* pour booléens de présence
property bool canEdit: true         // can* pour booléens de capacité
property bool shouldLoad: true      // should* pour booléens de décision
```

### Fonctions
```qml
// camelCase avec verbe d'action
function loadImage() { }
function resetState() { }
function updateDisplay() { }
```

### IDs
```qml
// camelCase, descriptifs
id: posterImage
id: loadingIndicator
id: errorFallback
```

## Gestion des états

### Pattern recommandé

```qml
Item {
    id: root
    
    // États possibles
    readonly property string state: {
        if (loading) return "loading"
        if (error !== "") return "error"
        if (data === null) return "empty"
        return "ready"
    }
    
    // Contenu conditionnel basé sur l'état
    Loader {
        sourceComponent: {
            switch (root.state) {
                case "loading": return loadingComponent
                case "error": return errorComponent
                case "empty": return emptyComponent
                case "ready": return contentComponent
            }
        }
    }
    
    Component { id: loadingComponent; /* ... */ }
    Component { id: errorComponent; /* ... */ }
    Component { id: emptyComponent; /* ... */ }
    Component { id: contentComponent; /* ... */ }
}
```

### Alternative : Visibilité conditionnelle

```qml
Item {
    // Loading
    BusyIndicator {
        visible: root.isLoading
    }
    
    // Contenu
    Image {
        visible: root.isReady
    }
    
    // Erreur
    Rectangle {
        visible: root.hasError
    }
}
```

## Optimisation des performances

### 1. Lazy instantiation avec Loader

```qml
Loader {
    active: root.visible  // Charge seulement si visible
    sourceComponent: ExpensiveComponent { }
}
```

### 2. Limitation des bindings

```qml
// ✅ BON : Binding simple
Text {
    text: filmCount + " films"
}

// ❌ MAUVAIS : Binding complexe recalculé souvent
Text {
    text: {
        var result = ""
        for (var i = 0; i < films.length; i++) {
            result += films[i].title + ", "
        }
        return result
    }
}
```

### 3. Utilisation du cache

```qml
Image {
    source: posterUrl
    cache: true  // Cache l'image décodée
    asynchronous: true  // Chargement non-bloquant
}
```

## Responsive design

### Unités adaptatives

```qml
Item {
    // dp() pour les dimensions
    width: dp(100)
    height: dp(150)
    
    // sp() pour les textes
    Text {
        font.pixelSize: sp(14)
    }
    
    // Proportions relatives
    Rectangle {
        width: parent.width * 0.8
        height: width * 1.5  // Ratio constant
    }
}
```

### Breakpoints

```qml
Item {
    readonly property bool isPhone: width < dp(600)
    readonly property bool isTablet: width >= dp(600) && width < dp(1200)
    readonly property bool isDesktop: width >= dp(1200)
    
    // Adaptation selon l'écran
    columns: {
        if (isPhone) return 2
        if (isTablet) return 4
        return 6
    }
}
```

## Accessibilité

### Propriétés importantes

```qml
Item {
    // Description pour lecteurs d'écran
    Accessible.name: "Poster du film Avatar"
    Accessible.description: "Image du poster du film Avatar"
    Accessible.role: Accessible.Button
    
    // État
    Accessible.focusable: true
    Accessible.focused: activeFocus
}
```

## Testing

### Propriétés de test

```qml
Item {
    id: root
    
    // Propriété pour identifier en tests
    property string testId: "poster-image-1"
    
    // Propriété pour forcer un état en test
    property bool __testMode: false
    property string __testState: "ready"
    
    state: __testMode ? __testState : actualState
}
```

### Signaux pour validation

```qml
Item {
    signal testImageLoaded()
    signal testImageError()
    
    Image {
        onStatusChanged: {
            if (status === Image.Ready) testImageLoaded()
            if (status === Image.Error) testImageError()
        }
    }
}
```

## Documentation inline

### Commentaires de propriétés

```qml
Item {
    /**
     * URL du poster à afficher
     * @type {string}
     * @default ""
     * @example "https://example.com/poster.jpg"
     */
    property string source: ""
    
    /**
     * Active le lazy loading pour optimiser les performances
     * @type {boolean}
     * @default false
     */
    property bool enableLazyLoading: false
}
```

### Commentaires de fonctions

```qml
/**
 * Recharge l'image depuis la source
 * Utile après une erreur de chargement
 * @returns {void}
 */
function reloadImage() {
    image.source = ""
    image.source = root.source
}
```

## Enregistrement des composants

### Fichier qmldir

```
# qml/components/qmldir

# Composants publics
PosterImage 1.0 PosterImage.qml
FilmCard 1.0 FilmCard.qml
FilterPanel 1.0 FilterPanel.qml

# Composants internes (non exportés)
internal ImagePlaceholder ImagePlaceholder.qml
```

### Utilisation

```qml
import "../components" as Components

Item {
    Components.PosterImage {
        source: "https://example.com/poster.jpg"
    }
}
```

## Checklist création composant

- [ ] Nom en PascalCase
- [ ] Propriétés publiques documentées
- [ ] Propriétés readonly pour états
- [ ] Signaux pour événements importants
- [ ] Gestion de tous les états visuels
- [ ] Responsive (dp/sp)
- [ ] Optimisation performances
- [ ] Accessibilité
- [ ] Tests possibles
- [ ] Documentation inline
- [ ] Enregistré dans qmldir
- [ ] Exemple d'utilisation

## Exemples de composants

Consultez les documentations détaillées :

1. [PosterImage](PosterImage.md) - Composant complet avec lazy loading, shimmer, fallback
2. FilmCard (à venir) - Carte complète d'un film
3. FilterPanel (à venir) - Panneau de filtres

## Ressources

- [Guidelines Felgo](https://felgo.com/doc/)
- [Qt Quick Best Practices](https://doc.qt.io/qt-6/qtquick-bestpractices.html)
- [Material Design Components](https://material.io/components)

---

## Prochaines étapes

1. Créer FilmCard pour affichage détaillé
2. Implémenter FilterPanel pour filtrage
3. Ajouter SearchBar pour recherche IMDb
4. Développer LoadingIndicator personnalisé
