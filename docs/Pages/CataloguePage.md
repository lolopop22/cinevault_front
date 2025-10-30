# CataloguePage - Documentation Technique v1.2

## Vue d'ensemble

`CataloguePage` est la page principale de l'application Cinevault APP qui affiche le catalogue de films sous forme de grille responsive avec lazy loading. C'est le premier écran visible lors de l'ouverture de l'application après l'authentification.

## Localisation

```
qml/pages/CataloguePage.qml
```

## Caractéristiques principales

✅ Grille responsive adaptative (2-6 colonnes selon écran)  
✅ Lazy loading des images de posters  
✅ Gestion des états (loading, ready, empty, error)  
✅ Header fixe avec compteur de films dynamique  
✅ Notifications ToastService pour les erreurs  
✅ Navigation vers FilmDetailPage avec feedback visuel  
✅ Optimisation performances (cacheBuffer, reuseItems)  
✅ Cursor pointer sur desktop (PointingHandCursor)  
✅ Validation des données avant navigation  

---

## Structure de la page

### Imports

```qml
import Felgo 4.0
import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import "../logic" as Logic
import "../model" as Model
import "../components" as Components
import "../services" as Services  // ✨ NOUVEAU : Pour ToastService
```

### Hérite de AppPage

```qml
AppPage {
    id: cataloguePage
    title: "Mon Catalogue"
    
    // Propriétés pour layout et calculs
    // Logique métier
    // Éléments visuels
}
```

---

## Propriétés de layout

### Dimensions fixes

#### `fixedCardWidth` (real)
Largeur fixe d'une carte de film.

```qml
readonly property real fixedCardWidth: dp(100)
```

| Propriété | Valeur | Usage |
|-----------|--------|-------|
| Type | `real` | |
| Readonly | ✅ | |
| Valeur | `dp(100)` | Largeur fixe des cartes |

---

#### `itemSpacing` (real)
Espacement horizontal entre les cartes.

```qml
readonly property real itemSpacing: dp(0)
```

| Propriété | Valeur | Usage |
|-----------|--------|-------|
| Type | `real` | |
| Readonly | ✅ | |
| Valeur | `dp(0)` | Pas d'espacement actuellement |

**Note** : Peut être augmenté pour ajouter de l'espace visuel entre les cartes.

---

#### `posterAspectRatio` (real)
Ratio hauteur/largeur d'un poster de cinéma (2:3).

```qml
readonly property real posterAspectRatio: 1.5
```

| Propriété | Valeur | Usage |
|-----------|--------|-------|
| Type | `real` | |
| Readonly | ✅ | |
| Valeur | `1.5` | Ratio 2:3 (cinéma) |
| Calcul | `hauteur = largeur × 1.5` | Dimensions automatiques |

---

#### `titleHeight` (real)
Hauteur réservée pour le titre sous le poster.

```qml
readonly property real titleHeight: dp(35)
```

| Propriété | Valeur | Usage |
|-----------|--------|-------|
| Type | `real` | |
| Readonly | ✅ | |
| Valeur | `dp(35)` | Espace pour titre + marges |

---

#### `visibilityThreshold` (real)
Distance en pixels avant de charger une image (lazy loading).

```qml
property real visibilityThreshold: dp(50)
```

| Propriété | Valeur | Usage |
|-----------|--------|-------|
| Type | `real` | |
| Readonly | ❌ | Configurable |
| Valeur | `dp(50)` | Zone tampon avant/après viewport |

**Optimisation** : Charge l'image avant qu'elle n'apparaisse à l'écran.

---

#### `enableLazyLoadingGlobal` (bool)
Activation/désactivation globale du lazy loading.

```qml
property bool enableLazyLoadingGlobal: true
```

| Propriété | Valeur | Usage |
|-----------|--------|-------|
| Type | `bool` | |
| Readonly | ❌ | Configurable runtime |
| Valeur | `true` | Lazy loading activé |

---

### Calculs dynamiques

#### `columns` (int)
Nombre de colonnes calculé dynamiquement selon la largeur de l'écran.

```qml
readonly property int columns: {
    var availableWidth = width - dp(16)  // Marges totales
    var cardWithSpacing = fixedCardWidth + itemSpacing
    var maxColumns = Math.floor(availableWidth / cardWithSpacing)
    var leftover = availableWidth - (maxColumns * cardWithSpacing)
    
    // Si espace restant suffisant pour une carte, ajoute une colonne
    if (leftover >= fixedCardWidth) {
        maxColumns = Math.min(maxColumns + 1, 4)  // Max 4 colonnes
    }
    return Math.max(1, maxColumns)  // Min 1 colonne
}
```

**Résultat selon taille écran** :

| Largeur | Colonnes | Cas |
|---------|----------|-----|
| < 400px | 2 | Mobile portrait |
| 400-600px | 2-3 | Mobile landscape |
| 600-900px | 3-4 | Tablette portrait |
| 900-1200px | 4-5 | Tablette landscape |
| > 1200px | 4-6 | Desktop |

---

#### `gridTotalWidth` (real)
Largeur totale de la grille.

```qml
readonly property real gridTotalWidth: 
    (fixedCardWidth * columns) + (itemSpacing * (columns - 1))
```

**Usage** : Centre la grille horizontalement.

---

#### `cellHeight` (real)
Hauteur d'une cellule de la GridView.

```qml
readonly property real cellHeight: 
    (fixedCardWidth * posterAspectRatio) + titleHeight
```

**Exemple** :
```
cellHeight = (100 × 1.5) + 35 = 185dp
```

---

## Logique métier

### Instance CatalogueLogic

```qml
Logic.CatalogueLogic {
    id: logic
}
```

**Propriétés utilisées** :

| Propriété | Type | Usage |
|-----------|------|-------|
| `logic.loading` | bool | État de chargement |
| `logic.hasData` | bool | Présence de films |
| `logic.filmCount` | int | Nombre de films |
| `logic.errorMessage` | string | Message d'erreur |

**Signaux utilisés** :

| Signal | Paramètres | Usage |
|--------|-----------|-------|
| `errorOccurred` | `message` (string) | Erreur pendant chargement |

**Méthodes utilisées** :

| Méthode | Paramètres | Usage |
|---------|-----------|-------|
| `refreshCatalogue()` | Aucun | Recharge le catalogue |

---

## Éléments visuels

### 1. Header fixe

**Position** : Haut de page, fixe (z: 100)  
**Contenu** : Compteur de films ou message d'erreur  
**Marges** : 5dp top, 20dp gauche/droite

```qml
Rectangle {
    id: fixedHeader
    
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.topMargin: dp(5)
    anchors.leftMargin: dp(20)
    anchors.rightMargin: dp(20)
    
    height: dp(60)
    radius: dp(8)
    color: Theme.colors.backgroundColor
    z: 100
    
    layer.enabled: true
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: dp(5)
        radius: dp(4)
        samples: 9
        color: Qt.rgba(0, 0, 0, 0.1)
    }
    
    AppText {
        anchors.centerIn: parent
        text: logic.errorMessage
              ? "Mon Catalogue – Erreur"
              : logic.hasData
                ? "Mon Catalogue – " + logic.filmCount + " films"
                : "Mon Catalogue – Aucun film"
        font.pixelSize: sp(16)
        font.bold: true
        color: Theme.colors.textColor
    }
}
```

**États dynamiques** :
- Erreur : "Mon Catalogue – Erreur"
- Normal : "Mon Catalogue – X films"
- Vide : "Mon Catalogue – Aucun film"

---

### 2. Indicateur de chargement

**Condition** : Visible seulement quand `logic.loading === true`

```qml
Column {
    anchors.centerIn: parent
    spacing: dp(10)
    visible: logic.loading
    
    BusyIndicator {
        anchors.horizontalCenter: parent.horizontalCenter
        running: logic.loading
        width: dp(60)
        height: dp(60)
    }
    
    AppText {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Chargement du catalogue..."
        font.pixelSize: sp(14)
        color: Theme.colors.secondaryTextColor
    }
}
```

---

### 3. GridView des films

#### Structure générale

```qml
Item {
    id: gridContainer
    clip: true
    
    anchors.top: fixedHeader.bottom
    anchors.topMargin: dp(5)
    anchors.horizontalCenter: parent.horizontalCenter
    
    width: gridTotalWidth
    height: parent.height - fixedHeader.height
    
    GridView {
        id: filmGridView
        // Configuration...
    }
}
```

#### Configuration GridView

```qml
GridView {
    id: filmGridView
    anchors.fill: parent
    
    // Dimensions
    cellWidth: fixedCardWidth
    cellHeight: cataloguePage.cellHeight
    
    // Données
    model: Model.FilmDataSingletonModel && 
           Model.FilmDataSingletonModel.films ? 
           Model.FilmDataSingletonModel.films : []
    
    // Visibilité
    visible: !logic.loading && 
             Model.FilmDataSingletonModel.films.length > 0
    
    // Optimisations (décommenter pour gros volumes)
    // cacheBuffer: cellHeight * 2
    // reuseItems: true
}
```

#### Timer pour optimiser les calculs de visibilité

```qml
Timer {
    id: visibilityUpdateTimer
    interval: 100  // 100ms délai
    repeat: false
    onTriggered: {
        filmGridView.viewportTop = filmGridView.contentY
        filmGridView.viewportBottom = filmGridView.contentY + filmGridView.height
    }
}

GridView {
    // ...
    onContentYChanged: {
        visibilityUpdateTimer.restart()
    }
    onHeightChanged: {
        visibilityUpdateTimer.restart()
    }
}
```

**Justification** : Évite les recalculs excessifs pendant le scroll.

---

### 4. Delegate : Carte de film

#### Structure générale

```qml
delegate: Rectangle {
    id: filmCard
    width: fixedCardWidth
    height: cataloguePage.cellHeight - dp(4)
    radius: dp(6)
    color: Theme.colors.backgroundColor
    border.color: Theme.colors.dividerColor
    border.width: dp(0.5)
    
    property bool isPressed: false
    
    scale: isPressed ? 0.95 : 1.0
    opacity: isPressed ? 0.7 : 1.0
    
    // Contenu...
}
```

#### Calcul de visibilité pour lazy loading

```qml
property bool itemVisible: {
    var top = y
    var bottom = y + height
    var vpTop = filmGridView.viewportTop
    var vpBottom = filmGridView.viewportBottom
    
    var visible = (bottom >= vpTop - threshold) && 
                  (top <= vpBottom + threshold)
    
    if (visible !== itemVisible) {
        console.log("👁️", modelData ? modelData.title : "Item", 
                    visible ? "visible" : "caché")
    }
    
    return visible
}
```

---

#### Animations de feedback visuel

```qml
Behavior on opacity {
    NumberAnimation {
        duration: 100
        easing.type: Easing.InOutQuad
    }
}

Behavior on scale {
    NumberAnimation {
        duration: 100
        easing.type: Easing.OutQuad
    }
}
```

**Caractéristiques** :
- Durée : 100ms (imperceptible, perçu comme instantané)
- Easing opacity : InOutQuad (accélération + décélération)
- Easing scale : OutQuad (décélération naturelle)

---

#### Zone cliquable (MouseArea)

```qml
MouseArea {
    id: filmCardMouseArea
    anchors.fill: parent
    
    cursorShape: Qt.PointingHandCursor  // Pointer sur desktop
    
    onPressed: {
        console.log("👇 Press sur:", modelData ? modelData.title : "?")
        filmCard.isPressed = true
    }
    
    onReleased: {
        filmCard.isPressed = false
    }
    
    onCanceled: {
        filmCard.isPressed = false
    }
    
    onClicked: {
        // ✨ NOUVEAU : Navigation vers FilmDetailPage
        console.log("=== NAVIGATION VERS DÉTAILS ===")
        console.log("🖱️  Clic sur film:", modelData ? modelData.title : "Inconnu")
        console.log("🆔 ID du film:", modelData ? modelData.id : -1)
        
        // Validation des données
        if (!modelData) {
            console.error("❌ modelData est null, navigation annulée")
            return
        }
        
        if (!modelData.id || modelData.id <= 0) {
            console.error("❌ ID de film invalide:", modelData.id)
            return
        }
        
        // Navigation
        console.log("🚀 Push vers FilmDetailPage avec filmId:", modelData.id)
        navigationStack.push(filmDetailPageComponent, {
            filmId: modelData.id
        })
        
        console.log("✅ Navigation déclenchée\n")
    }
}
```

**Points clés** :
- ✅ Validation complète avant navigation
- ✅ Logs détaillés pour debugging
- ✅ Cursor pointer sur desktop
- ✅ Gestion des cas d'erreur

---

#### Contenu de la carte

```qml
Column {
    id: cardContainer
    anchors.fill: parent
    anchors.margins: dp(3)
    spacing: dp(4)
    
    // Poster
    Components.PosterImage {
        width: parent.width
        height: parent.width * posterAspectRatio
        source: modelData ? modelData.poster_url : ""
        
        enableLazyLoading: cataloguePage.enableLazyLoadingGlobal
        isVisible: parent.parent.itemVisible
        visibilityThreshold: cataloguePage.visibilityThreshold
        
        onIsVisibleChanged: {
            console.log("📱 Item", index, "visible:", isVisible, 
                       "- Source:", source.split('/').pop())
        }
    }
    
    // Titre
    AppText {
        width: parent.width
        height: titleHeight - dp(8)
        text: modelData ? modelData.title : "?"
        font.pixelSize: sp(9)
        font.bold: true
        color: Theme.colors.textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        maximumLineCount: 2
        elide: Text.ElideRight
    }
}
```

---

## Navigation vers FilmDetailPage

### Component de navigation (lazy loading)

```qml
Component {
    id: filmDetailPageComponent
    FilmDetailPage {
        // La page sera créée dynamiquement avec filmId passé lors du push
    }
}
```

**Justification** :
- ✅ Lazy loading : Page créée uniquement au premier push
- ✅ Performance : Pas de ressources consommées si jamais affichée
- ✅ Pattern Felgo recommandé

---

### Flux de navigation complet

```
1. Utilisateur clique sur une carte film
   ↓
2. MouseArea.onPressed → scale: 0.95, opacity: 0.7 (feedback visuel)
   ↓
3. MouseArea.onReleased → scale: 1.0, opacity: 1.0 (retour normal)
   ↓
4. MouseArea.onClicked
   ├─ Logs de debug
   ├─ Validation modelData
   ├─ Validation ID (> 0)
   └─ navigationStack.push(filmDetailPageComponent, {filmId: X})
   ↓
5. FilmDetailPage créée avec filmId reçu
   ↓
6. Component.onCompleted de FilmDetailPage déclenché
   ↓
7. FilmDetailLogic.loadFilm(filmId) appelée
   ↓
8a. Film trouvé
    → FilmDetailLogic.filmLoaded(film) émis
    → Toast succès affiché
    → Film affiché
    
8b. Film non trouvé
    → FilmDetailLogic.loadError(message) émis
    → Toast erreur affiché
    → Retour possible
```

---

## Gestion des erreurs avec ToastService

### Connexion aux signaux de CatalogueLogic

```qml
Connections {
    target: logic
    function onErrorOccurred(message) {
        console.log("⚠️ Erreur reçue dans CataloguePage:", message)
        Services.ToastService.showError(message)  // ✨ NOUVEAU
    }
}
```

**Pattern** :
1. Erreur survient dans CatalogueLogic
2. Signal `errorOccurred(message)` émis
3. CataloguePage reçoit le signal
4. **ToastService.showError()** appelé (au lieu d'une modal)
5. Toast rouge s'affiche 3 secondes

**Avantages du Toast vs Modal** :
- ✅ Non-intrusif (ne bloque pas l'interface)
- ✅ Apparaît au bas de l'écran
- ✅ Auto-destruction après 3s
- ✅ Service global (cohérent partout)
- ✅ Messages multiples empilables

---

## États de la page

### État 1 : Chargement initial

**Conditions** : `logic.loading === true`

**Affichage** :
- Header : "Mon Catalogue – Chargement..."
- BusyIndicator centré visible
- GridView masqué

**Logs** :
```
=== DEBUG CataloguePage avec cartes fixes ===
Colonnes: X
Largeur carte fixe: 100
Largeur grille totale: XXX
Largeur écran: YYY
Espace restant: ZZZ
```

---

### État 2 : Catalogue affiché (normal)

**Conditions** : `!logic.loading && logic.hasData`

**Affichage** :
- Header : "Mon Catalogue – X films"
- BusyIndicator masqué
- GridView visible avec tous les films
- Films cliquables avec cursor pointer

---

### État 3 : Catalogue vide

**Conditions** : `!logic.loading && !logic.hasData`

**Affichage** :
- Header : "Mon Catalogue – Aucun film"
- BusyIndicator masqué
- GridView masqué
- Message dans header

---

### État 4 : Erreur

**Conditions** : `logic.errorMessage !== ""`

**Affichage** :
- Header : "Mon Catalogue – Erreur"
- Toast d'erreur rouge en bas (via ToastService)
- GridView reste visible (ne bloque pas l'accès)
- Optionnel : Bouton "Rafraîchir" dans le header

---

## Responsive design

### Adaptation selon taille d'écran

| Largeur | Colonnes | Cas | Cartes visibles |
|---------|----------|-----|-----------------|
| < 400px | 2 | Mobile portrait | ~4-6 |
| 400-600px | 2-3 | Mobile landscape | ~6-9 |
| 600-900px | 3-4 | Tablette portrait | ~9-16 |
| 900-1200px | 4-5 | Tablette landscape | ~12-20 |
| > 1200px | 4-6 | Desktop | ~16-30 |

### Calcul automatique détaillé

**Exemple** : Écran 800px de large

```javascript
availableWidth = 800 - 16 = 784px
cardWithSpacing = 100 + 0 = 100px
maxColumns = floor(784 / 100) = 7
leftover = 784 - (7 × 100) = 84px

// leftover (84) < fixedCardWidth (100)
// → pas de colonne supplémentaire
// maxColumns = min(7, 4) = 4 colonnes (limite)

Résultat : columns = 4
```

---

## Performance et optimisations

### Optimisations implémentées

✅ **Lazy loading des images**
- Charge images seulement quand visibles
- Threshold configurable (50dp)
- Utilise propriété `isVisible` du PosterImage

✅ **Dimensions fixes**
- Évite recalculs lors de changements
- Propriétés readonly

✅ **Clipping du container**
- Cache le débordement
- Limite le rendu GPU

✅ **Bindings optimisés**
- Calculs des colonnes une seule fois

✅ **Animations courtes**
- 100ms pour feedback (imperceptible)
- N'impacte pas la performance

✅ **Timer de visibilité**
- Délai de 100ms pour calculs
- Évite flood de recalculs pendant scroll

---

### Optimisations à activer pour gros volumes (> 100 films)

```qml
GridView {
    cacheBuffer: cellHeight * 2   // Cache 2 lignes hors écran
    reuseItems: true              // Réutilise delegates
}
```

**Effet** :
- ↓ Consommation mémoire
- ↓ Latence de scroll
- ↑ Smoothness général

---

## Initialisation

### Component.onCompleted

```qml
Component.onCompleted: {
    console.log("=== DEBUG CataloguePage avec cartes fixes ===")
    console.log("Colonnes:", columns)
    console.log("Largeur carte fixe:", fixedCardWidth)
    console.log("Largeur grille totale:", gridTotalWidth)
    console.log("Largeur écran:", width)
    console.log("Espace restant:", (width - gridTotalWidth - dp(32)))
    console.log("filmDataModel:", Model.FilmDataSingletonModel)
    
    if (Model.FilmDataSingletonModel) {
        console.log("filmDataModel.films:", 
                   Model.FilmDataSingletonModel.films)
        if (Model.FilmDataSingletonModel.films) {
            console.log("films.length:", 
                       Model.FilmDataSingletonModel.films.length)
        }
    }
}
```

**Note** : CatalogueLogic se charge automatiquement des données.

---

## Évolutions futures

### Court terme (v1.2)
- ✅ Navigation vers FilmDetailPage (implémenté)
- ✅ Notifications ToastService (implémenté)

### Moyen terme (v2.0)
- Ajout d'un SearchField dans le header
- Bouton de tri (alphabétique, date, note)
- Filtres avancés (catégories, année)
- Mode liste vs grille

### Long terme (v3.0)
- Animations de transitions entre pages
- Swipe pour supprimer
- Édition rapide (long press)
- Synchronisation API en temps réel

---

## Bonnes pratiques observées

✅ **Séparation des responsabilités**
- Logique métier dans CatalogueLogic
- UI dans CataloguePage
- Services globaux dans ToastService

✅ **Responsive design**
- Calcul dynamique des colonnes
- Adaptation intelligente

✅ **Performance**
- Lazy loading des images
- Dimensions fixes
- Optimisations GridView

✅ **Gestion d'états**
- Loading, ready, empty, error
- Transitions claires

✅ **Accessibilité**
- Utilisation composants Felgo
- Cursor pointer sur desktop
- Feedback visuel clair

✅ **Maintenabilité**
- Propriétés readonly
- Calculs documentés
- Logs détaillés

✅ **Debug**
- Logs exhaustifs au chargement
- Logs de navigation
- Logs de visibilité

✅ **Navigation**
- Lazy loading avec Component
- Feedback visuel (scale + opacity)
- Validation données
- Passage de paramètres sécurisé

✅ **UX**
- Animations smooth
- Feedback instantané
- Notifications non-intrusives (Toast)
- Pas de blocage d'interface

---

## Débogage

### Logs clés à vérifier

```
=== DEBUG CataloguePage avec cartes fixes ===
Colonnes: [✓ doit être 2-6 selon largeur]
Largeur carte fixe: 100 [✓ fixe]
Largeur grille totale: [✓ colonne × largeur]
Largeur écran: [✓ viewport width]
Espace restant: [✓ peut être négatif]
filmDataModel: [✓ doit exister]
films.length: [✓ > 0 si données présentes]

=== NAVIGATION VERS DÉTAILS ===
🖱️  Clic sur film: [✓ titre du film]
🆔 ID du film: [✓ ID valide > 0]
🚀 Push vers FilmDetailPage avec filmId: [✓ ID passé]
✅ Navigation déclenchée

👁️ [Title] visible [✓ visible/caché selon scroll]
📱 Item X visible: [✓ true/false]
```

---

## Références

- [Architecture MVC](../Architecture/mvc-pattern.md)
- [CatalogueLogic](../Logic/CatalogueLogic.md)
- [PosterImage](../Components/PosterImage.md)
- [ToastService](../Components/ToastService.md) ✨ NOUVEAU
- [FilmDetailPage](./FilmDetailPage.md) ✨ NOUVEAU
- [FilmDetailLogic](../Logic/FilmDetailLogic.md) ✨ NOUVEAU
- [FilmDataSingletonModel](../Data/FilmDataSingletonModel.md)
- [Navigation avec paramètres](./navigation.md)
