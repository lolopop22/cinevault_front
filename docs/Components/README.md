# Documentation des Composants - Cinevault APP v1.2 (Corrigée)

## Vue d'ensemble

Les composants sont des éléments réutilisables de l'interface utilisateur qui encapsulent à la fois l'apparence et le comportement. Ils suivent les principes de **modularité**, **réutilisabilité** et **configurabilité**. Cette documentation couvre également les **services globaux** comme le système de notifications Toast.

## Localisation

```
qml/components/
├── PosterImage.qml       # Affichage optimisé posters ✅
├── ToastManager.qml      # Gestionnaire visuel toasts ✨ NOUVEAU
├── ToastDelegate.qml     # Délégué toast individuel ✨ NOUVEAU
└── FilmCard.qml          # Carte complète film (à venir)

qml/services/
└── ToastService.qml      # Service notifications (Singleton) ✨ NOUVEAU
```

## Liste des composants et services

### Composants UI

| Composant | Description | Statut |
|-----------|-------------|--------|
| [PosterImage](PosterImage.md) | Affichage optimisé des posters de films | ✅ Implémenté |
| [ToastManager](ToastManager.md) | Gestionnaire visuel des toasts | ✅ Implémenté |
| [ToastDelegate](ToastDelegate.md) | Rendu individuel d'un toast | ✅ Implémenté |
| FilmCard | Carte complète d'un film | 🔜 À venir |
| FilterPanel | Panneau de filtres avancés | 🔜 À venir |
| SearchBar | Barre de recherche IMDb | 🔜 À venir |

### Services Globaux ✨ NOUVEAU

| Service | Description | Statut | Pattern |
|---------|-------------|--------|---------|
| [ToastService](ToastService.md) | Système de notifications toast | ✅ Implémenté | Singleton hybride |

---

## Services Globaux ✨ NOUVEAU

### ToastService - Système de Notifications

Service global de notifications non-intrusives affichées en bas de l'écran.

**Localisation** : `qml/services/ToastService.qml`

**Pattern** : Singleton hybride
- **ToastService** (Singleton) : API publique
- **ToastManager** (Composant) : Implémentation visuelle
- **ToastDelegate** (Delegate) : Rendu individuel

#### Caractéristiques principales

✅ **API simple et globale**
- `showSuccess(message)` - Toast vert
- `showError(message)` - Toast rouge
- `showWarning(message)` - Toast orange
- `showInfo(message)` - Toast bleu

✅ **Design adaptatif**
- Largeur responsive (mobile/tablet/desktop)
- Positionnement selon plateforme (iOS/Android/Desktop)
- Au-dessus de la navigation mais non-bloquant

✅ **Gestion automatique**
- Auto-destruction après 3 secondes
- File d'attente (multiples toasts)
- Nouveaux toasts apparaissent en bas

#### Usage

```qml
import "../services" as Services

// Dans une Page ou Logic
Connections {
    target: logic
    
    function onDataLoaded() {
        Services.ToastService.showSuccess("Données chargées avec succès")
    }
    
    function onErrorOccurred(message) {
        Services.ToastService.showError(message)
    }
}
```

#### Initialisation (Main.qml)

```qml
App {
    // Instance visuelle unique
    ToastManager {
        id: globalToastManager
        parent: Overlay.overlay
        anchors.fill: parent
        z: 10000
    }
    
    Component.onCompleted: {
        // Enregistrement de l'instance
        ToastService.initialize(globalToastManager)
    }
}
```

**Voir [ToastService.md](ToastService.md) pour la documentation complète**

---

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

### 5. Services globaux (Singleton pattern) ✨ NOUVEAU

Pour les services transversaux (toasts, analytics, etc.) :

**Avantages** :
- ✅ Accès global depuis n'importe où
- ✅ Instance unique garantie
- ✅ API cohérente et simple
- ✅ Pas de prop drilling

**Pattern Singleton hybride** :
```qml
// ToastService.qml (Singleton)
pragma Singleton
import QtQuick 2.15

QtObject {
    property var _manager: null
    
    function initialize(manager) {
        _manager = manager
    }
    
    function showSuccess(text) {
        if (_manager) _manager.showSuccess(text)
    }
}
```

---

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

---

## Conventions de nommage

### Fichiers
- **PascalCase** pour les noms de composants
- Extension `.qml`
- Exemples : `PosterImage.qml`, `ToastManager.qml`, `ToastDelegate.qml`

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
function showToast(message) { }
```

### IDs
```qml
// camelCase, descriptifs
id: posterImage
id: loadingIndicator
id: errorFallback
id: toastManager
```

---

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

---

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

### 4. Services globaux (Singleton) ✨ NOUVEAU

```qml
// ✅ BON : Singleton - Instance unique
Services.ToastService.showSuccess("OK")

// ❌ MAUVAIS : Multiple instances
ToastManager { id: toast1 }
ToastManager { id: toast2 }  // Duplication !
```

---

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

### Breakpoints (À implémenter) ⏳

Les breakpoints pour adapter le responsive design selon la taille de l'écran sont en cours de mise en œuvre.

```qml
// Modèle futur
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

---

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

### Accessibilité des toasts ✨ NOUVEAU

```qml
Rectangle {
    Accessible.role: Accessible.Notification
    Accessible.name: "Notification : " + messageText
    Accessible.description: "Message de type " + toastType
}
```

---

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

### Tests ToastService ✨ NOUVEAU

```qml
TestCase {
    name: "ToastServiceTests"
    
    function test_showSuccess() {
        SignalSpy {
            id: spy
            target: toastManager.toastModel
            signalName: "countChanged"
        }
        
        Services.ToastService.showSuccess("Test")
        
        compare(spy.count, 1)
        compare(toastManager.toastModel.get(0).type, "success")
    }
}
```

---

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

/**
 * Affiche un toast de succès
 * @param {string} text - Message à afficher
 * @param {number} duration - Durée en ms (défaut: 3000)
 * @returns {void}
 */
function showSuccess(text, duration) {
    _showToast(text, "success", duration || 3000)
}
```

---

## Enregistrement des composants

### Fichier qmldir (components)

```
# qml/components/qmldir

# Composants publics
PosterImage 1.0 PosterImage.qml
ToastManager 1.0 ToastManager.qml
ToastDelegate 1.0 ToastDelegate.qml
FilmCard 1.0 FilmCard.qml
FilterPanel 1.0 FilterPanel.qml

# Composants internes (non exportés)
internal ImagePlaceholder ImagePlaceholder.qml
```

### Fichier qmldir (services) ✨ NOUVEAU

```
# qml/services/qmldir

# Services (Singletons)
singleton ToastService 1.0 ToastService.qml
```

### Utilisation

```qml
import "../components" as Components
import "../services" as Services

Item {
    // Composant
    Components.PosterImage {
        source: "https://example.com/poster.jpg"
    }
    
    // Service (Singleton)
    Button {
        onClicked: Services.ToastService.showSuccess("OK")
    }
}
```

---

## Checklist création composant

### Composant UI
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

### Service Global (Singleton) ✨ NOUVEAU
- [ ] `pragma Singleton` en début de fichier
- [ ] Hérite de `QtObject`
- [ ] API publique claire et documentée
- [ ] Pattern Singleton hybride si nécessaire
- [ ] Initialisation dans Main.qml
- [ ] Vérification `isInitialized()`
- [ ] Gestion d'erreurs si non initialisé
- [ ] Logs de debug
- [ ] Tests unitaires
- [ ] Enregistré dans qmldir (`singleton`)

---

## Exemples de composants

### Composants UI
1. [PosterImage](PosterImage.md) - Composant complet avec lazy loading, shimmer, fallback
2. [ToastManager](ToastManager.md) - Gestionnaire visuel des toasts
3. [ToastDelegate](ToastDelegate.md) - Rendu individuel d'un toast
4. FilmCard (à venir) - Carte complète d'un film
5. FilterPanel (à venir) - Panneau de filtres

### Services Globaux ✨ NOUVEAU
1. [ToastService](ToastService.md) - Système de notifications toast complet
   - ToastService (Singleton API)
   - ToastManager (Composant visuel)
   - ToastDelegate (Delegate rendu)

---

## Ressources

### Documentation interne
- [PosterImage](PosterImage.md)
- [ToastService](../Data/Services/ToastService.md) ✨ NOUVEAU
- [ToastManager](ToastManager.md) ✨ NOUVEAU
- [ToastDelegate](ToastDelegate.md) ✨ NOUVEAU
- [CataloguePage](../Pages/CataloguePage.md)
- [FilmDetailPage](../Pages/FilmDetailPage.md)
- [Architecture MVC](../Architecture/mvc-pattern.md)

### Documentation externe
- [Guidelines Felgo](https://felgo.com/doc/)
- [Qt Quick Best Practices](https://doc.qt.io/qt-6/qtquick-bestpractices.html)
- [Material Design Components](https://material.io/components)
- [Material Design Snackbars](https://material.io/components/snackbars)

---

## Prochaines étapes

### Court terme
1. ✅ Système de notifications Toast (implémenté)
2. ⏳ **Implémenter breakpoints responsive** (À faire)
3. Créer FilmCard pour affichage détaillé
4. Implémenter FilterPanel pour filtrage

### Moyen terme
5. Ajouter SearchBar pour recherche IMDb
6. Développer LoadingIndicator personnalisé
7. Service Analytics global (Singleton)
8. Adapter toasts à différentes largeurs d'écran

### Long terme
9. Service de gestion du thème (Singleton)
10. Service de localisation i18n (Singleton)
11. Composants d'animation réutilisables
