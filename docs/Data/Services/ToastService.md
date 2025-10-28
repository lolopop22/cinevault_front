# Documentation ToastService - Système de Notifications Globales

## Vue d'ensemble

Le système de notifications Toast de Cinevault APP implémente un mécanisme global de notifications visuelles (toasts/snackbars) conforme aux guidelines Material Design et iOS HIG. Il utilise le **pattern Singleton hybride** pour combiner les avantages d'un service global avec la nécessité d'un rendu visuel.

---

## Architecture du Système

### Pattern Singleton Hybride

```
┌─────────────────────────────────────────┐
│  ToastService (Singleton logique)       │
│  - pragma Singleton                     │
│  - API publique                         │
│  - Accessible partout                   │
└──────────────┬──────────────────────────┘
               │ référence (_manager)
               ↓
┌─────────────────────────────────────────┐
│  ToastManager (Instance visuelle)       │
│  - Item avec ListView                   │
│  - Parent: Overlay.overlay              │
│  - Implémentation concrète              │
└──────────────┬──────────────────────────┘
               │ crée dynamiquement
               ↓
┌─────────────────────────────────────────┐
│  ToastDelegate (Rendu individuel)       │
│  - Rectangle animé                      │
│  - Fade in/out                          │
│  - Auto-destruction                     │
└─────────────────────────────────────────┘
```

### Pourquoi ce pattern ?

**Problème** : Les Singletons QML ne peuvent pas être des composants visuels car ils n'ont pas de parent dans la hiérarchie visuelle.

**Solution** :
1. **ToastService** (Singleton logique) → API publique accessible partout
2. **ToastManager** (Instance visuelle) → Implémentation avec parent
3. **Main.qml** initialise : `ToastService.initialize(ToastManager)`

**Avantages** :
- ✅ Service global accessible sans dépendance sur `app`
- ✅ Protection contre duplication (Qt)
- ✅ Testable (peut être mocké)
- ✅ Cohérent avec FilmDataSingletonModel

---

## Composants du Système

### 1. ToastService.qml (Singleton logique)

**Localisation** : `qml/services/ToastService.qml`

**Type** : Singleton QML (`pragma Singleton`)

**Responsabilités** :
- Fournir une API publique pour afficher des toasts
- Déléguer tous les appels à ToastManager
- Valider l'initialisation avant chaque appel

#### Propriétés

```qml
property var _manager: null  // Référence privée à ToastManager
```

#### Méthodes publiques

##### initialize(managerInstance)
Initialise le service avec l'instance visuelle de ToastManager.

```qml
// Main.qml
Component.onCompleted: {
    ToastService.initialize(globalToastManager)
}
```

##### show(text, type, duration)
Affiche un toast avec type et durée personnalisés.

```qml
Services.ToastService.show("Message", "warning", 5000)
```

##### showSuccess(text, duration)
Raccourci pour toast de succès (vert, #4CAF50).

```qml
Services.ToastService.showSuccess("Opération réussie")
```

##### showError(text, duration)
Raccourci pour toast d'erreur (rouge, #F44336).

```qml
Services.ToastService.showError("Échec de l'opération")
```

##### showWarning(text, duration)
Raccourci pour toast d'avertissement (orange, #FF9800).

```qml
Services.ToastService.showWarning("Attention requise")
```

##### showInfo(text, duration)
Raccourci pour toast d'information (bleu, #2196F3).

```qml
Services.ToastService.showInfo("Information utile")
```

##### isInitialized()
Vérifie si le service est initialisé.

```qml
if (Services.ToastService.isInitialized()) {
    // Service prêt
}
```

---

### 2. ToastManager.qml (Instance visuelle)

**Localisation** : `qml/components/ToastManager.qml`

**Type** : Item (PAS de `pragma Singleton`)

**Responsabilités** :
- Gérer la ListView des toasts
- Animer les entrées/sorties
- Calculer les marges adaptatives par plateforme
- Configurer les couleurs et icônes

#### Configuration

```qml
// Types de toasts
readonly property var toastType: {
    "SUCCESS": "success",
    "ERROR": "error",
    "WARNING": "warning",
    "INFO": "info"
}

// Couleurs Material Design
readonly property var toastColors: {
    "success": "#4CAF50",   // Green 500
    "error": "#F44336",     // Red 500
    "warning": "#FF9800",   // Orange 500
    "info": "#2196F3"       // Blue 500
}

// Icônes Font Awesome
readonly property var toastIcons: {
    "success": IconType.checkcircle,
    "error": IconType.exclamationcircle,
    "warning": IconType.exclamationtriangle,
    "info": IconType.infocircle
}
```

#### Positionnement adaptatif

```qml
readonly property real adaptiveBottomMargin: {
    // iOS : 80dp (Tab Bar + safe area)
    if (Qt.platform.os === "ios") {
        return Theme.dp(80)
    }
    
    // Android : 50dp (Bottom Navigation + marge)
    if (Qt.platform.os === "android") {
        return Theme.dp(50)
    }
    
    // Desktop : 16dp (marge standard)
    if (Qt.platform.os === "windows" || 
        Qt.platform.os === "osx" || 
        Qt.platform.os === "linux") {
        return Theme.dp(16)
    }
    
    return Theme.dp(16)  // Fallback
}
```

#### ListView BottomToTop

```qml
ListView {
    verticalLayoutDirection: ListView.BottomToTop
    // Nouveaux toasts en BAS, anciens poussés vers le HAUT
    
    interactive: false
    // Pas de scroll utilisateur
    
    spacing: Theme.dp(8)
    
    displaced: Transition {
        NumberAnimation {
            properties: "y"
            duration: 250
            easing.type: Easing.OutQuad
        }
    }
    // Animation fluide lors de la suppression
}
```

---

### 3. ToastDelegate.qml (Rendu individuel)

**Localisation** : `qml/components/ToastDelegate.qml`

**Responsabilités** :
- Afficher le message avec icône et couleur
- Animer l'apparition (fade in 300ms)
- Animer la disparition (fade out 300ms)
- Auto-hide après durée configurée

#### Largeur adaptative

```qml
readonly property real maxToastWidth: {
    var screenWidth = parent ? parent.width : 300
    
    // iOS
    if (Qt.platform.os === "ios") {
        if (screenWidth > Theme.dp(600)) {  // iPad
            return Math.min(Theme.dp(500), screenWidth - Theme.dp(32))
        }
        return screenWidth - Theme.dp(32)  // iPhone
    }
    
    // Android
    if (Qt.platform.os === "android") {
        if (screenWidth > Theme.dp(600)) {  // Tablet
            return Math.min(Theme.dp(456), screenWidth - Theme.dp(32))
        }
        return screenWidth - Theme.dp(32)  // Mobile
    }
    
    // Desktop
    return Math.min(Theme.dp(360), screenWidth - Theme.dp(32))
}
```

#### Cycle de vie

```
1. ListView crée ToastDelegate
   ↓
2. Component.onCompleted → show()
   ↓
3. Fade in (opacity 0→1, 300ms)
   ↓
4. Timer démarre (3000ms par défaut)
   ↓
5. Timer.onTriggered → hide()
   ↓
6. Fade out (opacity 1→0, 300ms)
   ↓
7. Qt.callLater(closeRequested, 300ms)
   ↓
8. ToastManager.remove(index)
   ↓
9. Delegate détruit automatiquement
```

---

## Initialisation dans Main.qml

```qml
App {
    id: app
    
    // Instance visuelle unique
    ToastManager {
        id: globalToastManager
        parent: Overlay.overlay  // Au-dessus de tout
        anchors.fill: parent
        z: 10000                 // Z-order très élevé
    }
    
    // Initialisation du service
    Component.onCompleted: {
        ToastService.initialize(globalToastManager)
        
        if (ToastService.isInitialized()) {
            console.log("✅ ToastService prêt")
        }
    }
}
```

---

## Utilisation dans les Pages

### Import du service

```qml
import "../services" as Services
```

### Affichage de toasts

```qml
// Depuis une page
FlickablePage {
    Connections {
        target: logic
        
        function onDataLoaded() {
            Services.ToastService.showSuccess("Données chargées")
        }
        
        function onError(message) {
            Services.ToastService.showError(message)
        }
    }
}
```

### Exemple FilmDetailPage

```qml
Connections {
    target: logic
    
    function onFilmLoaded(film) {
        Services.ToastService.showSuccess("Film chargé avec succès !")
    }
    
    function onLoadError(message) {
        Services.ToastService.showError(message)
    }
}
```

---

## Guidelines de Design

### Marges par plateforme

| Plateforme | Navigation | Hauteur | Marge toast | Total |
|------------|-----------|---------|-------------|-------|
| iOS | Tab Bar | 49dp | 31dp | 80dp |
| Android | Bottom Nav | 56dp | Variable | 50dp |
| Desktop | Aucune | 0dp | 16dp | 16dp |

### Largeurs maximales

| Contexte | Largeur écran | Largeur max toast | % écran |
|----------|---------------|-------------------|---------|
| iPhone | 375dp | 343dp | 91% |
| Android Phone | 360dp | 328dp | 91% |
| iPad | 768dp | 500dp | 65% |
| Android Tablet | 800dp | 456dp | 57% |
| Desktop | 1920px | 360dp | 19% |

**Références** :
- [Material Design 3 - Snackbar](https://m3.material.io/components/snackbar/specs)
- [iOS HIG - Tab Bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars)

---

## Gestion des Erreurs

### Erreur : Service non initialisé

```qml
if (!_manager) {
    console.error("❌ ToastService non initialisé")
    console.error("→ Appelez ToastService.initialize() depuis Main.qml")
    return
}
```

### Erreur : dp is not defined

**Cause** : Utilisation de `dp()` au lieu de `Theme.dp()` dans un Singleton.

**Solution** :
```qml
// ❌ MAUVAIS
spacing: dp(8)

// ✅ BON
spacing: Theme.dp(8)
```

---

## Enregistrement qmldir

```
# qml/services/qmldir
singleton ToastService 1.0 ToastService.qml

# qml/components/qmldir
ToastManager 1.0 ToastManager.qml
ToastDelegate 1.0 ToastDelegate.qml
```

---

## Tests de Validation

### Test 1 : Toast fonctionne

```qml
Component.onCompleted: {
    Services.ToastService.showSuccess("Test réussi !")
}
```

**Attendu** : Toast vert en bas, disparaît après 3s.

### Test 2 : Toasts multiples

```qml
Services.ToastService.showInfo("Toast 1")
Services.ToastService.showWarning("Toast 2")
Services.ToastService.showError("Toast 3")
```

**Attendu** : 3 toasts empilés, nouveaux en bas.

### Test 3 : Largeurs responsives

- **Mobile** : Largeur ~91% de l'écran
- **Tablet** : Largeur max 456-500dp
- **Desktop** : Largeur max 360dp

---

## Bonnes Pratiques

### ✅ À faire

- Importer le service : `import "../services" as Services`
- Utiliser les raccourcis : `showSuccess()`, `showError()`
- Tester sur iOS, Android, Desktop
- Utiliser `Theme.dp()` dans ToastManager/ToastDelegate

### ❌ À éviter

- Créer plusieurs instances de ToastManager
- Référencer `app.toastManager` directement
- Utiliser `dp()` dans les Singletons
- Forcer `width: parent.width` dans le delegate

---

## Évolutions Futures Possibles

- Toast avec action (bouton "Annuler")
- Toast personnalisables (couleurs custom)
- Position configurable (top/bottom/center)
- Queue avec limite (max 3 toasts simultanés)
