# PosterImage - Documentation technique

## Vue d'ensemble

`PosterImage` est un composant réutilisable qui affiche les posters de films avec gestion avancée du chargement, optimisations performances et gestion d'erreurs robuste.

## Localisation

```
qml/components/PosterImage.qml
```

## Caractéristiques principales

✅ Chargement asynchrone non-bloquant  
✅ Lazy loading optionnel pour optimisation mémoire  
✅ Animation shimmer pendant le chargement  
✅ Fallback élégant en cas d'erreur avec retry  
✅ Optimisation retina/HiDPI automatique  
✅ Coins arrondis avec OpacityMask  
✅ Support multi-résolution  
✅ Gestion complète des états visuels  

---

## Import et utilisation

### Import

```qml
import "../components" as Components
```

### Utilisation basique

```qml
Components.PosterImage {
    width: dp(100)
    height: dp(150)
    source: "https://image.tmdb.org/t/p/w342/poster.jpg"
}
```

### Utilisation avec lazy loading

```qml
Components.PosterImage {
    width: dp(100)
    height: dp(150)
    source: "https://image.tmdb.org/t/p/w342/poster.jpg"
    enableLazyLoading: true
    isVisible: itemIsInViewport
    visibilityThreshold: dp(50)
}
```

---

## Propriétés publiques

### Configuration de base

#### `source` (string)
URL du poster à charger.

**Type** : `string`  
**Défaut** : `""`  
**Exemple** :
```qml
source: "https://image.tmdb.org/t/p/w342/jRXYjXNq0Cs2TcJjLkki24MLp7u.jpg"
```

#### `fillMode` (enumeration)
Mode de remplissage de l'image.

**Type** : `Image.fillMode` (alias)  
**Défaut** : `Image.PreserveAspectCrop`  
**Valeurs possibles** :
- `Image.Stretch` : Étire l'image
- `Image.PreserveAspectFit` : Garde proportions, peut laisser des bandes
- `Image.PreserveAspectCrop` : Garde proportions, coupe les bords
- `Image.Tile` : Répétition en mosaïque

**Exemple** :
```qml
fillMode: Image.PreserveAspectFit
```

#### `asynchronous` (bool)
Active le chargement asynchrone (non-bloquant).

**Type** : `bool`  
**Défaut** : `true`  
**Recommandation** : Toujours laisser à `true` pour performance

**Exemple** :
```qml
asynchronous: true  // Recommandé
```

#### `borderRadius` (real)
Rayon des coins arrondis en density-independent pixels.

**Type** : `real`  
**Défaut** : `dp(6)`  
**Exemple** :
```qml
borderRadius: dp(8)  // Coins plus arrondis
borderRadius: 0      // Coins carrés
```

### Lazy loading

#### `enableLazyLoading` (bool)
Active le système de lazy loading.

**Type** : `bool`  
**Défaut** : `false`  
**Usage** : Activer pour optimiser le chargement dans les listes scrollables

**Exemple** :
```qml
enableLazyLoading: true
```

#### `isVisible` (bool)
Indique si l'image est visible dans le viewport (contrôlé par le parent).

**Type** : `bool`  
**Défaut** : `true`  
**Usage** : Modifié automatiquement par le delegate du GridView/ListView

**Exemple** :
```qml
// Dans un delegate de GridView
isVisible: parent.itemVisible
```

#### `visibilityThreshold` (real)
Seuil en pixels avant/après la zone visible pour précharger l'image.

**Type** : `real`  
**Défaut** : `dp(50)`  
**Explication** : L'image commence à charger quand elle est à cette distance du bord visible

**Exemple** :
```qml
visibilityThreshold: dp(100)  // Précharge 100px avant
```

### Optimisation avancée (rarement modifiées)

#### `cache` (bool)
Active le cache Qt pour l'image décodée.

**Type** : `bool`  
**Défaut** : `true` (implicite dans Qt)

#### `smooth` (bool)
Active l'anti-aliasing pour le redimensionnement.

**Type** : `bool`  
**Défaut** : `true` (implicite dans Qt)

#### `mipmap` (bool)
Génère des mipmaps pour qualité optimale lors du zoom.

**Type** : `bool`  
**Défaut** : `false`  
**Coût** : +33% mémoire vidéo

#### `maxSourceWidth` / `maxSourceHeight` (real)
Limite maximale de résolution chargée en mémoire.

**Type** : `real`  
**Défaut** : `800` / `1200`  
**Usage** : Ajuster selon besoins qualité/mémoire

---

## Propriétés en lecture seule (états)

### `status` (enumeration)
État du chargement de l'image (alias direct).

**Type** : `Image.Status`  
**Valeurs** :
- `Image.Null` : Pas de source définie
- `Image.Loading` : Chargement en cours
- `Image.Ready` : Image chargée avec succès
- `Image.Error` : Erreur de chargement

**Exemple** :
```qml
Text {
    text: {
        switch (posterImage.status) {
            case Image.Loading: return "Chargement..."
            case Image.Ready: return "Prêt"
            case Image.Error: return "Erreur"
            default: return "Vide"
        }
    }
}
```

### `progress` (real)
Progression du chargement (0.0 à 1.0).

**Type** : `real` (0.0-1.0)  
**Usage** : Afficher une barre de progression

**Exemple** :
```qml
ProgressBar {
    value: posterImage.progress
    visible: posterImage.isLoading
}
```

### `isLoading` (bool)
Indique si l'image est en cours de chargement.

**Type** : `bool`  
**Calcul** : `status === Image.Loading`

### `hasError` (bool)
Indique si une erreur est survenue lors du chargement.

**Type** : `bool`  
**Calcul** : `status === Image.Error`

### `isReady` (bool)
Indique si l'image est chargée et prête à l'affichage.

**Type** : `bool`  
**Calcul** : `status === Image.Ready`

### `shouldLoad` (bool)
Propriété calculée qui détermine si l'image doit être chargée.

**Type** : `bool`  
**Calcul** : `!enableLazyLoading || isVisible`  
**Usage** : Interne, contrôle le chargement effectif

---

## États visuels

Le composant gère automatiquement 4 états visuels distincts :

### 1. État : Chargement actif
**Condition** : `isLoading === true && shouldLoad === true`

**Apparence** :
- Placeholder gris clair (#f0f0f0)
- Animation shimmer (bande blanche traversante)
- Icône film (🎬) au centre

**Code** :
```qml
Rectangle {
    id: placeholder
    visible: isLoading || source === "" || (enableLazyLoading && !shouldLoad)
    color: "#f0f0f0"
    
    // Animation shimmer
    Rectangle {
        id: shimmer
        visible: isLoading && shouldLoad
        // ... animation
    }
}
```

### 2. État : En attente lazy loading
**Condition** : `enableLazyLoading === true && shouldLoad === false`

**Apparence** :
- Placeholder gris plus sombre (#e8e8e8)
- Icône œil (👁️) au centre
- Pas d'animation shimmer
- Emoji 💤 dans le coin

**Différenciation** : Indique visuellement qu'on attend de devenir visible

### 3. État : Image chargée
**Condition** : `isReady === true`

**Apparence** :
- Image affichée avec coins arrondis
- Remplissage selon `fillMode`
- OpacityMask pour les coins arrondis

**Code** :
```qml
Image {
    id: image
    visible: isReady
    source: posterImage.shouldLoad ? posterImage.source : ""
    
    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            radius: posterImage.borderRadius
        }
    }
}
```

### 4. État : Erreur
**Condition** : `hasError === true`

**Apparence** :
- Rectangle rose pâle (#ffebee)
- Bordure rose (#ffcdd2)
- Icône triangle d'avertissement (⚠️)
- Texte "Image indisponible"
- Texte "Toucher pour réessayer"

**Interaction** : Tap pour retry

**Code** :
```qml
Rectangle {
    id: errorFallback
    visible: hasError
    color: "#ffebee"
    border.color: "#ffcdd2"
    
    MouseArea {
        onClicked: {
            // Retry logic
            image.source = ""
            image.source = posterImage.source
        }
    }
}
```

---

## Animation shimmer

### Principe
Effet de "brillance" qui traverse l'élément pendant le chargement.

### Paramètres
- **Largeur** : 60% de la largeur du composant
- **Durée** : 1000ms
- **Boucle** : Infinie pendant `isLoading`
- **Mouvement** : De `-shimmer.width * 0.25` à `placeholder.width`
- **Easing** : Linear (constant)

### Gradient
```qml
Gradient {
    orientation: Gradient.Horizontal
    GradientStop { position: 0.0; color: "transparent" }
    GradientStop { position: 0.2; color: Qt.rgba(1,1,1,0.3) }
    GradientStop { position: 0.4; color: Qt.rgba(1,1,1,0.8) }
    GradientStop { position: 0.5; color: Qt.rgba(1,1,1,1.0) }  // Blanc pur
    GradientStop { position: 0.6; color: Qt.rgba(1,1,1,0.8) }
    GradientStop { position: 0.8; color: Qt.rgba(1,1,1,0.3) }
    GradientStop { position: 1.0; color: "transparent" }
}
```

### Optimisation
- **Blur** : FastBlur radius 4 pour adoucir
- **Visible** : Seulement si `isLoading && shouldLoad`
- **Logs** : Console messages pour debugging

---

## Optimisation mémoire et performance

### sourceSize intelligent

Le composant limite automatiquement la résolution chargée :

```qml
sourceSize.width: Math.min(width * 2, 400)   // Max 400px
sourceSize.height: Math.min(height * 2, 600) // Max 600px
```

**Explications** :
- `width * 2` : Support écrans Retina (2x pixel density)
- Limite à 400x600px : Balance qualité/mémoire
- Une image 4K (3840x2160) chargerait ~33MB sans `sourceSize`
- Avec `sourceSize`, max ~960KB (400x600 RGBA)

### Chargement asynchrone

```qml
asynchronous: true
```

- Chargement en thread séparé
- UI reste responsive
- Pas de freeze pendant le décodage

### Lazy loading

```qml
readonly property bool shouldLoad: !enableLazyLoading || isVisible
source: posterImage.shouldLoad ? posterImage.source : ""
```

- Images hors écran ne sont pas chargées
- Économise bande passante et mémoire
- Chargement déclenché dès entrée dans zone visible + threshold

---

## Gestion d'erreurs et retry

### Détection d'erreur

Le composant écoute automatiquement `image.status` :

```qml
onStatusChanged: {
    switch (status) {
        case Image.Error:
            console.log("❌ Erreur image:", posterImage.source)
            break
    }
}
```

### Affichage fallback

Rectangle rose avec icône, message et instruction.

### Mécanisme retry

```qml
MouseArea {
    anchors.fill: errorFallback
    onClicked: {
        console.log("🔄 Retry demandé")
        var originalSource = posterImage.source
        image.source = ""  // Reset
        Qt.callLater(function() {
            image.source = originalSource  // Rechargement
        })
    }
}
```

**Fonctionnement** :
1. Vider la source (`source = ""`)
2. Délai avec `Qt.callLater()`
3. Réassigner la source originale
4. Déclenche nouveau chargement

---

## Exemples d'utilisation

### Exemple 1 : Usage basique

```qml
import "../components" as Components

AppPage {
    Components.PosterImage {
        width: dp(150)
        height: dp(225)
        anchors.centerIn: parent
        source: "https://image.tmdb.org/t/p/w342/avatar.jpg"
    }
}
```

### Exemple 2 : Dans une grille avec lazy loading

```qml
GridView {
    id: filmGrid
    
    property real viewportTop: contentY
    property real viewportBottom: contentY + height
    
    delegate: Rectangle {
        property bool itemVisible: {
            var top = y
            var bottom = y + height
            return (bottom >= filmGrid.viewportTop - dp(50)) &&
                   (top <= filmGrid.viewportBottom + dp(50))
        }
        
        Components.PosterImage {
            anchors.fill: parent
            source: modelData.poster_url
            enableLazyLoading: true
            isVisible: parent.itemVisible
        }
    }
}
```

### Exemple 3 : Personnalisation complète

```qml
Components.PosterImage {
    width: dp(200)
    height: dp(300)
    source: filmData.posterUrl
    
    // Style
    borderRadius: dp(12)
    fillMode: Image.PreserveAspectFit
    
    // Performance
    enableLazyLoading: true
    isVisible: inViewport
    visibilityThreshold: dp(100)
    
    // Interaction
    MouseArea {
        anchors.fill: parent
        onClicked: console.log("Poster cliqué")
    }
}
```

### Exemple 4 : Monitoring des états

```qml
Components.PosterImage {
    id: poster
    source: filmUrl
    
    // Bindings sur états
    onIsLoadingChanged: {
        console.log("Loading:", isLoading)
    }
    
    onIsReadyChanged: {
        if (isReady) {
            console.log("✅ Poster chargé avec succès")
        }
    }
    
    onHasErrorChanged: {
        if (hasError) {
            console.log("❌ Erreur chargement poster")
        }
    }
}

// Affichage conditionnel externe
Text {
    text: poster.isLoading ? "Chargement..." : "Prêt"
}
```

---

## Debugging

### Logs console

Le composant génère automatiquement des logs :

```
PosterImage initialisé pour: https://...poster.jpg
⏳ Chargement: https://...poster.jpg
📊 Progression: 50% https://...poster.jpg
✅ Image chargée: poster.jpg Taille rendu: 100x150 SourceSize: 200x300
```

### Logs shimmer

```
✨ Shimmer démarré pour: https://...poster.jpg - largeur: 60
🛑 Shimmer arrêté pour: https://...poster.jpg
```

### Désactiver les logs en production

```qml
onStatusChanged: {
    if (Qt.application.arguments.indexOf("--debug") !== -1) {
        // Logs seulement avec flag --debug
        console.log("Status:", status)
    }
}
```

---

## Bonnes pratiques

### ✅ À faire

1. **Toujours définir width et height**
```qml
PosterImage {
    width: dp(100)
    height: dp(150)
}
```

2. **Activer lazy loading dans les listes**
```qml
PosterImage {
    enableLazyLoading: true
    isVisible: itemInViewport
}
```

3. **Utiliser dp() pour dimensions**
```qml
borderRadius: dp(8)  // Adaptatif
```

4. **Vérifier la source avant utilisation**
```qml
source: modelData ? modelData.poster_url : ""
```

### ❌ À éviter

1. **Ne pas oublier les dimensions**
```qml
// ❌ MAUVAIS : Pas de dimensions
PosterImage {
    source: url
}
```

2. **Ne pas charger toutes les images d'un coup**
```qml
// ❌ MAUVAIS : Sans lazy loading dans une grande liste
Repeater {
    model: 1000
    PosterImage { source: "..." }  // 1000 images en même temps !
}
```

3. **Ne pas manipuler l'Image interne directement**
```qml
// ❌ MAUVAIS
PosterImage {
    id: poster
    Component.onCompleted: {
        poster.image.source = "..."  // image n'est pas exposé
    }
}
```

---

## Dépendances

### Imports requis

```qml
import Felgo 4.0
import QtQuick 2.15
import Qt5Compat.GraphicalEffects  // Pour OpacityMask
```

### Composants Felgo utilisés

- `AppIcon` : Icônes (film, eye, exclamationtriangle)
- `AppText` : Textes avec thème
- `Theme` : Couleurs et styles

### Effets Qt utilisés

- `OpacityMask` : Coins arrondis de l'image
- `FastBlur` : Adoucissement du shimmer
- `DropShadow` : Ombre (optionnel, commenté)

---

## Performance

### Métriques

| Métrique | Valeur | Contexte |
|----------|--------|----------|
| Mémoire par image | ~960KB max | Avec sourceSize 400x600 RGBA |
| Temps chargement | Variable | Dépend réseau et taille source |
| Impact CPU shimmer | ~2-5% | Animation unique par composant |
| Overhead lazy loading | Négligeable | Calcul simple boolean |

### Optimisations appliquées

✅ `sourceSize` limite mémoire  
✅ `asynchronous` non-bloquant  
✅ `cache` évite rechargements  
✅ Lazy loading économise réseau  
✅ Shimmer désactivé hors chargement  
✅ Bindings optimisés (readonly)  

---

## Références

- [Architecture générale](../Architecture/overview.md)
- [Composants guidelines](README.md)
- [CataloguePage usage](../Pages/CataloguePage.md)
- [Lazy loading feature](../Features/lazy-loading.md)
