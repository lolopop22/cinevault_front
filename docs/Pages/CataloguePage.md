# CataloguePage - Documentation technique

## Vue d'ensemble

`CataloguePage` est la page principale de l'application qui affiche le catalogue de films sous forme de grille responsive avec lazy loading. C'est le premier écran visible lors de l'ouverture de l'application.

## Localisation

```
qml/pages/CataloguePage.qml
```

## Caractéristiques principales

✅ Grille responsive adaptative (2-6 colonnes selon écran)  
✅ Lazy loading des images de posters  
✅ Animation shimmer pendant chargement  
✅ Gestion des états (loading, ready, empty, error)  
✅ Header fixe avec compteur de films  
✅ Modal d'erreur avec retry  
✅ Optimisation performances (cacheBuffer, reuseItems)  

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
```

### Hérite de AppPage

```qml
AppPage {
    id: cataloguePage
    title: "Mon Catalogue"
    
    // ... propriétés et contenu
}
```

---

## Propriétés de layout

### Dimensions fixes

#### `fixedCardWidth` (real)
Largeur fixe d'une carte de film.

**Type** : `real`  
**Readonly** : ✅  
**Valeur** : `dp(100)`  
**Usage** : Base de calcul pour le layout responsive

```qml
readonly property real fixedCardWidth: dp(100)
```

#### `itemSpacing` (real)
Espacement entre les cartes.

**Type** : `real`  
**Readonly** : ✅  
**Valeur** : `dp(0)`  
**Note** : Actuellement à 0, peut être augmenté pour espacement visuel

```qml
readonly property real itemSpacing: dp(0)
```

#### `posterAspectRatio` (real)
Ratio hauteur/largeur d'un poster de cinéma (2:3).

**Type** : `real`  
**Readonly** : ✅  
**Valeur** : `1.5`  
**Calcul** : `hauteur = largeur × 1.5`

```qml
readonly property real posterAspectRatio: 1.5
```

#### `titleHeight` (real)
Hauteur réservée pour le titre sous le poster.

**Type** : `real`  
**Readonly** : ✅  
**Valeur** : `dp(35)`

```qml
readonly property real titleHeight: dp(35)
```

### Calculs dynamiques

#### `columns` (int)
Nombre de colonnes calculé dynamiquement selon la largeur.

**Type** : `int`  
**Readonly** : ✅  
**Calcul** : Adaptatif selon largeur disponible

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
- Mobile : 2 colonnes
- Tablette Portrait : 3-4 colonnes
- Desktop : 4-6 colonnes
- Tablette Landscape : 4-5 colonnes

#### `gridTotalWidth` (real)
Largeur totale de la grille.

**Type** : `real`  
**Readonly** : ✅  
**Calcul** : `(fixedCardWidth × columns) + (itemSpacing × (columns - 1))`

```qml
readonly property real gridTotalWidth: 
    (fixedCardWidth * columns) + (itemSpacing * (columns - 1))
```

#### `cellHeight` (real)
Hauteur d'une cellule de la grille.

**Type** : `real`  
**Readonly** : ✅  
**Calcul** : `(fixedCardWidth × posterAspectRatio) + titleHeight`

```qml
readonly property real cellHeight: 
    (fixedCardWidth * posterAspectRatio) + titleHeight
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
- `logic.loading` : Indicateur de chargement
- `logic.hasData` : Présence de films
- `logic.filmCount` : Nombre de films
- `logic.errorMessage` : Message d'erreur

**Méthodes utilisées** :
- `logic.refreshCatalogue()` : Recharge le catalogue

---

## Éléments visuels

### 1. Header fixe

**Position** : Haut de page, fixe (z: 100)  
**Contenu** : Compteur de films ou message d'erreur

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
    
    // Effet d'ombre
    layer.enabled: true
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: dp(5)
        radius: dp(4)
        samples: 9
        color: Qt.rgba(0, 0, 0, 0.1)
    }
    
    // Texte dynamique
    AppText {
        anchors.centerIn: parent
        text: logic.errorMessage
              ? "Mon Catalogue – Erreur"
              : logic.hasData
                ? "Mon Catalogue – " + logic.filmCount + " films"
                : "Mon Catalogue – Aucun film"
        font.pixelSize: sp(18)
        font.bold: true
        color: Theme.colors.textColor
    }
}
```

### 2. Indicateur de chargement

**Condition** : Visible seulement pendant `logic.loading`

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

### 3. Grille de films (GridView)

**Container avec clipping**

```qml
Item {
    id: gridContainer
    clip: true  // Cache débordements
    
    anchors.top: fixedHeader.bottom
    anchors.topMargin: dp(5)
    anchors.horizontalCenter: parent.horizontalCenter
    
    width: gridTotalWidth
    height: parent.height - fixedHeader.height
    
    GridView {
        id: filmGridView
        anchors.fill: parent
        
        // Dimensions des cellules
        cellWidth: fixedCardWidth
        cellHeight: cataloguePage.cellHeight
        
        // Modèle de données
        model: Model.FilmDataSingletonModel.films
        
        // Visibilité conditionnelle
        visible: !logic.loading && Model.FilmDataSingletonModel.films.length > 0
        
        // Optimisations (décommenter pour gros volumes)
        // cacheBuffer: cellHeight * 2
        // reuseItems: true
        
        // Delegate : une carte de film
        delegate: Rectangle {
            width: fixedCardWidth
            height: cataloguePage.cellHeight - dp(4)
            radius: dp(6)
            color: Theme.colors.backgroundColor
            border.color: Theme.colors.dividerColor
            border.width: dp(0.5)
            
            property real padding: dp(3)
            
            Column {
                anchors.fill: parent
                anchors.margins: parent.padding
                spacing: dp(4)
                
                // Poster avec lazy loading
                Components.PosterImage {
                    width: parent.width
                    height: parent.width * posterAspectRatio
                    source: modelData ? modelData.poster_url : ""
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
        }
    }
}
```

### 4. Modal d'erreur

**Position** : Bas de l'écran  
**Déclencheur** : Signal `logic.errorOccurred`

```qml
AppModal {
    id: errorModal
    
    fullscreen: false
    modalHeight: dp(150)
    pushBackContent: cataloguePage
    closeOnBackgroundClick: true
    closeWithBackButton: true
    backgroundColor: "transparent"
    
    Rectangle {
        id: modalContainer
        width: Math.min(dp(350), parent.width * 0.9)
        height: parent.height
        
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: dp(40)
        
        radius: dp(12)
        color: Theme.colors.backgroundColor
        
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: dp(4)
            radius: dp(8)
            samples: 17
            color: Qt.rgba(0, 0, 0, 0.3)
        }
        
        Column {
            anchors.fill: parent
            anchors.margins: dp(10)
            spacing: dp(12)
            
            // Icône d'avertissement
            AppIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                iconType: IconType.exclamationtriangle
                color: "#FFA500"
                size: dp(24)
            }
            
            // Message d'erreur
            AppText {
                id: errorText
                width: parent.width
                text: ""
                color: Theme.colors.textColor
                font.pixelSize: sp(14)
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 4
            }
            
            // Boutons d'action
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: dp(20)
                
                AppButton {
                    text: "Rejeter"
                    flat: true
                    textColor: Theme.colors.secondaryTextColor
                    onClicked: errorModal.close()
                }
                
                AppButton {
                    text: "Rafraîchir"
                    backgroundColor: Theme.colors.tintColor
                    onClicked: {
                        logic.refreshCatalogue()
                    }
                }
            }
        }
    }
}
```

---

## Gestion des signaux

### Connexion à CatalogueLogic

```qml
Connections {
    target: logic
    
    function onErrorOccurred(message) {
        errorText.text = message
        errorModal.open()
    }
}
```

**Flux** :
1. Erreur survient dans `FilmService`
2. `CatalogueLogic` émet `errorOccurred(message)`
3. `CataloguePage` reçoit le signal
4. Affiche la modal avec le message

---

## États de la page

### État 1 : Chargement initial

**Conditions** : `logic.loading === true`

**Affichage** :
- Header : "Mon Catalogue – Chargement..."
- BusyIndicator centré visible
- GridView masqué

### État 2 : Catalogue affiché

**Conditions** : `!logic.loading && logic.hasData`

**Affichage** :
- Header : "Mon Catalogue – X films"
- BusyIndicator masqué
- GridView visible avec films

### État 3 : Catalogue vide

**Conditions** : `!logic.loading && !logic.hasData`

**Affichage** :
- Header : "Mon Catalogue – Aucun film"
- BusyIndicator masqué
- GridView masqué
- Message "Aucun film" (peut être ajouté)

### État 4 : Erreur

**Conditions** : `logic.errorMessage !== ""`

**Affichage** :
- Header : "Mon Catalogue – Erreur"
- Modal d'erreur ouverte en bas
- Options : Rejeter ou Rafraîchir

---

## Responsive design

### Adaptation selon taille d'écran

| Taille écran | Largeur | Colonnes | Cartes visibles |
|--------------|---------|----------|-----------------|
| Mobile Portrait | < 400px | 2 | ~4-6 |
| Mobile Landscape | 400-600px | 2-3 | ~6-9 |
| Tablette Portrait | 600-900px | 3-4 | ~9-16 |
| Tablette Landscape | 900-1200px | 4-5 | ~12-20 |
| Desktop | > 1200px | 4-6 | ~16-30 |

### Calcul automatique

```javascript
// Exemple : Écran 800px de large
availableWidth = 800 - 16 = 784px
cardWithSpacing = 100 + 0 = 100px
maxColumns = floor(784 / 100) = 7
leftover = 784 - (7 × 100) = 84px

// leftover (84) < fixedCardWidth (100) → pas de colonne supplémentaire
// maxColumns = min(7, 4) = 4 colonnes (limite à 4)

columns = 4
```

---

## Performance

### Optimisations implémentées

✅ **Lazy loading des images** via `PosterImage`  
✅ **Dimensions fixes** pour éviter recalculs  
✅ **Clipping** du container pour limiter le rendu  
✅ **Bindings optimisés** (readonly properties)  

### Optimisations à activer pour gros volumes

```qml
GridView {
    // Décommenter pour > 100 films
    cacheBuffer: cellHeight * 2   // Cache 2 lignes hors écran
    reuseItems: true              // Réutilise delegates
}
```

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
        console.log("filmDataModel.films:", Model.FilmDataSingletonModel.films)
        if (Model.FilmDataSingletonModel.films) {
            console.log("films.length:", Model.FilmDataSingletonModel.films.length)
        }
    }
}
```

**Note** : CatalogueLogic se charge automatiquement des données via son propre `Component.onCompleted`

---

## Exemples d'utilisation

### Exemple 1 : Ajout d'un bouton refresh dans le header

```qml
AppPage {
    rightBarItem: IconButtonBarItem {
        iconType: IconType.refresh
        onClicked: logic.refreshCatalogue()
    }
}
```

### Exemple 2 : Pull-to-refresh

```qml
// Remplacer Item container par AppListView
AppListView {
    anchors.fill: parent
    
    PullToRefresh {
        onRefresh: {
            logic.refreshCatalogue()
        }
    }
    
    // GridView comme contentItem
}
```

### Exemple 3 : Navigation vers détails film

```qml
delegate: Rectangle {
    // ... contenu carte
    
    MouseArea {
        anchors.fill: parent
        onClicked: {
            navigationStack.push(filmDetailPageComponent, {
                filmId: modelData.id,
                filmTitle: modelData.title
            })
        }
    }
}

Component {
    id: filmDetailPageComponent
    FilmDetailPage { }
}
```

---

## Évolutions futures

### Court terme
- Ajout d'un SearchField dans le header
- Bouton de tri (alphabétique, date, note)
- Navigation vers page de détails film

### Moyen terme
- Filtres avancés (catégories, année, note)
- Sections par catégories
- Mode liste vs grille

### Long terme
- Animations de transitions
- Swipe pour supprimer
- Édition rapide (long press)

---

## Bonnes pratiques observées

✅ **Séparation des responsabilités** : Logique dans CatalogueLogic, UI dans la page  
✅ **Responsive** : Calcul dynamique des colonnes  
✅ **Performance** : Lazy loading, optimisations GridView  
✅ **États gérés** : Loading, ready, empty, error  
✅ **Accessibilité** : Utilisation d'AppText, AppButton, AppIcon  
✅ **Maintenabilité** : Propriétés readonly pour les calculs  
✅ **Debug** : Logs détaillés pour troubleshooting  

---

## Références

- [Architecture MVC](../Architecture/mvc-pattern.md)
- [CatalogueLogic](../Logic/CatalogueLogic.md)
- [PosterImage](../Components/PosterImage.md)
- [FilmDataSingletonModel](../Data/FilmDataSingletonModel.md)
- [Responsive design](../Features/responsive-design.md)
- [Lazy loading](../Features/lazy-loading.md)
