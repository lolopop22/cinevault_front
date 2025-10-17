# Documentation des Pages - Cinevault APP

## Vue d'ensemble

Le dossier `pages` contient les pages principales de l'application qui constituent l'interface utilisateur. Chaque page représente un écran complet accessible via la navigation.

## Localisation

```
qml/pages/
├── CataloguePage.qml    # Page principale du catalogue
├── RecherchePage.qml    # Page de recherche IMDb (à venir)
└── ProfilPage.qml       # Page profil utilisateur (à venir)
```

## Liste des pages

| Page | Statut | Description | Navigation |
|------|--------|-------------|------------|
| [CataloguePage](CataloguePage.md) | ✅ Implémenté | Grille de films avec lazy loading | Tab "Catalogue" |
| RecherchePage | 🔜 À venir | Recherche et ajout films IMDb | Tab "Recherche" |
| ProfilPage | 🔜 À venir | Profil utilisateur et paramètres | Tab "Profil" |

---

## Rôle des Pages dans l'architecture MVC

### Position dans l'architecture

```
┌─────────────────────┐
│   Navigation        │  Bottom Navigation (Main.qml)
│   (Main.qml)        │
└──────────┬──────────┘
           │
    ┌──────┴──────┬──────────┐
    ▼             ▼          ▼
┌─────────┐  ┌─────────┐  ┌─────────┐
│Catalogue│  │Recherche│  │ Profil  │  ← Pages
│  Page   │  │  Page   │  │  Page   │
└────┬────┘  └─────────┘  └─────────┘
     │
     │ utilise
     ▼
┌──────────────┐
│    Logic     │  Logique métier
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Model/Service│  Données et API
└──────────────┘
```

### Responsabilités d'une Page

**✅ Affichage**
- Structure visuelle (layout, composants)
- Présentation des données
- Style et thème

**✅ Interactions utilisateur**
- Boutons, gestes, navigation
- Délégation des actions à Logic
- Feedback visuel

**✅ Bindings réactifs**
- Liaison automatique avec Model/Logic
- Mise à jour UI automatique

**❌ Pas de logique métier**
- Pas de transformation de données
- Pas d'appels API directs
- Pas de calculs complexes

---

## Navigation

### Configuration dans Main.qml

```qml
Navigation {
    navigationMode: navigationModeDefault
    
    NavigationItem {
        title: "Catalogue"
        iconType: IconType.film
        
        NavigationStack {
            initialPage: Component {
                CataloguePage { }
            }
        }
    }
    
    NavigationItem {
        title: "Recherche"
        iconType: IconType.search
        
        NavigationStack {
            initialPage: Component {
                RecherchePage { }
            }
        }
    }
    
    NavigationItem {
        title: "Profil"
        iconType: IconType.user
        
        NavigationStack {
            initialPage: Component {
                ProfilPage { }
            }
        }
    }
}
```

### Pattern NavigationStack

Chaque `NavigationItem` contient un `NavigationStack` permettant :
- Navigation vers pages de détails
- Historique de navigation (back button)
- Transitions animées

**Exemple** :
```qml
// Dans CataloguePage
delegate: Item {
    MouseArea {
        onClicked: {
            navigationStack.push(detailPageComponent, {
                filmId: modelData.id
            })
        }
    }
}
```

---

## Structure type d'une Page

### Template de base

```qml
import Felgo 4.0
import QtQuick 2.15
import "../logic" as Logic
import "../model" as Model
import "../components" as Components

/**
 * [NomPage] - Description
 * Page principale pour [fonctionnalité]
 */
AppPage {
    id: pageName
    title: "Titre de la page"
    
    // ===================================
    // LOGIQUE MÉTIER
    // ===================================
    
    Logic.PageLogic {
        id: logic
    }
    
    // ===================================
    // PROPRIÉTÉS DE LAYOUT
    // ===================================
    
    readonly property real itemSpacing: dp(16)
    readonly property real margins: dp(20)
    
    // ===================================
    // HEADER / BARRE SUPÉRIEURE
    // ===================================
    
    rightBarItem: IconButtonBarItem {
        iconType: IconType.refresh
        onClicked: logic.refresh()
    }
    
    // ===================================
    // CONTENU PRINCIPAL
    // ===================================
    
    // Indicateur de chargement
    BusyIndicator {
        anchors.centerIn: parent
        visible: logic.loading
        running: logic.loading
    }
    
    // Contenu principal
    ScrollView {
        anchors.fill: parent
        visible: !logic.loading && logic.hasData
        
        // Contenu scrollable
    }
    
    // État vide
    Column {
        anchors.centerIn: parent
        visible: !logic.loading && !logic.hasData
        spacing: dp(16)
        
        AppIcon {
            anchors.horizontalCenter: parent.horizontalCenter
            iconType: IconType.inbox
            size: dp(48)
        }
        
        AppText {
            text: "Aucune donnée"
            font.pixelSize: sp(16)
        }
    }
    
    // ===================================
    // GESTION D'ERREURS
    // ===================================
    
    Connections {
        target: logic
        
        function onErrorOccurred(message) {
            errorText.text = message
            errorModal.open()
        }
    }
    
    AppModal {
        id: errorModal
        
        Rectangle {
            width: dp(300)
            height: dp(200)
            radius: dp(12)
            
            Column {
                anchors.fill: parent
                anchors.margins: dp(20)
                spacing: dp(16)
                
                AppText {
                    id: errorText
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
                
                AppButton {
                    text: "OK"
                    onClicked: errorModal.close()
                }
            }
        }
    }
    
    // ===================================
    // INITIALISATION
    // ===================================
    
    Component.onCompleted: {
        console.log("[NomPage] Initialisée")
    }
}
```

---

## Principes de conception

### 1. Responsive Design

**Breakpoints**
```qml
readonly property bool isPhone: width < dp(600)
readonly property bool isTablet: width >= dp(600) && width < dp(1200)
readonly property bool isDesktop: width >= dp(1200)

// Adaptation du layout
columns: {
    if (isPhone) return 2
    if (isTablet) return 4
    return 6
}
```

**Unités adaptatives**
```qml
// ✅ Toujours utiliser dp() et sp()
width: dp(100)
height: dp(150)
margins: dp(16)
font.pixelSize: sp(14)

// ❌ Jamais de valeurs fixes
width: 100  // ❌
```

### 2. États visuels

**Gestion des états**
```qml
// État : Chargement
BusyIndicator {
    visible: logic.loading
}

// État : Contenu disponible
GridView {
    visible: !logic.loading && logic.hasData
}

// État : Vide
Column {
    visible: !logic.loading && !logic.hasData
    // Message "Aucun film"
}

// État : Erreur (via modal)
AppModal {
    // Affiché via signal errorOccurred
}
```

### 3. Performance

**Optimisations essentielles**
```qml
// Lazy loading dans GridView
GridView {
    cacheBuffer: cellHeight * 2  // Cache 2 lignes hors écran
    reuseItems: true              // Réutilise les delegates
    
    delegate: PosterImage {
        enableLazyLoading: true
        isVisible: itemVisible
    }
}

// Loader pour contenu conditionnel
Loader {
    active: visible
    sourceComponent: ExpensiveComponent { }
}
```

### 4. Accessibilité

```qml
AppPage {
    Accessible.role: Accessible.Pane
    Accessible.name: "Page Catalogue"
    Accessible.description: "Affiche la liste des films"
    
    // Pour chaque élément interactif
    Button {
        Accessible.role: Accessible.Button
        Accessible.name: "Rafraîchir le catalogue"
        Accessible.onPressAction: clicked()
    }
}
```

---

## Bonnes pratiques

### ✅ À faire

1. **Utiliser Logic pour orchestration**
```qml
AppPage {
    Logic.CatalogueLogic { id: logic }
    
    Button {
        onClicked: logic.refreshCatalogue()  // ✅
    }
}
```

2. **Bindings pour affichage**
```qml
Text {
    text: logic.filmCount + " films"  // ✅ Binding automatique
}
```

3. **Gérer tous les états**
```qml
// Loading, Ready, Empty, Error
BusyIndicator { visible: logic.loading }
GridView { visible: !logic.loading && logic.hasData }
Text { visible: !logic.loading && !logic.hasData }
AppModal { /* erreur */ }
```

4. **Structure claire**
```qml
AppPage {
    // 1. Logic
    // 2. Propriétés layout
    // 3. Header
    // 4. Contenu principal
    // 5. Gestion erreurs
    // 6. Initialisation
}
```

### ❌ À éviter

1. **Pas de logique métier**
```qml
// ❌ MAUVAIS
Button {
    onClicked: {
        Model.FilmDataSingletonModel.startLoading()
        filmService.fetchAllFilms()
    }
}

// ✅ BON
Button {
    onClicked: logic.refreshCatalogue()
}
```

2. **Pas d'accès direct aux Services**
```qml
// ❌ MAUVAIS
FilmService {
    id: filmService
}

// ✅ BON : Service dans Logic
CatalogueLogic { id: logic }
```

3. **Pas de calculs complexes dans bindings**
```qml
// ❌ MAUVAIS
Text {
    text: {
        var result = ""
        for (var i = 0; i < films.length; i++) {
            result += films[i].title + ", "
        }
        return result
    }
}

// ✅ BON : Propriété calculée dans Logic
Text {
    text: logic.filmTitles
}
```

---

## Navigation entre pages

### Push vers page détails

```qml
// Dans CataloguePage
GridView {
    delegate: Item {
        MouseArea {
            onClicked: {
                navigationStack.push(filmDetailPageComponent, {
                    filmId: modelData.id,
                    filmTitle: modelData.title
                })
            }
        }
    }
}

Component {
    id: filmDetailPageComponent
    FilmDetailPage { }
}
```

### Pop (retour)

```qml
// Dans FilmDetailPage
leftBarItem: IconButtonBarItem {
    iconType: IconType.arrowleft
    onClicked: navigationStack.pop()
}

// Ou automatiquement avec le back button système
```

---

## Testing

### Tests d'interface

```qml
TestCase {
    name: "CataloguePageTests"
    
    CataloguePage {
        id: page
    }
    
    function test_initialState() {
        compare(page.title, "Mon Catalogue")
        verify(page.logic !== null)
    }
    
    function test_loadingState() {
        page.logic.loading = true
        verify(page.busyIndicator.visible)
        verify(!page.gridView.visible)
    }
}
```

### Tests d'intégration

```qml
function test_refreshFlow() {
    SignalSpy {
        id: spy
        target: page.logic
        signalName: "errorOccurred"
    }
    
    page.refreshButton.clicked()
    
    // Vérifier que Logic a été appelé
    tryCompare(page.logic, "loading", true)
}
```

---

## Checklist création page

- [ ] Nom en PascalCase (ex: `CataloguePage.qml`)
- [ ] Hérite de `AppPage`
- [ ] Import Logic associé
- [ ] Propriétés responsive (breakpoints)
- [ ] Gestion des 4 états (loading, ready, empty, error)
- [ ] Utilisation dp()/sp()
- [ ] Accessibilité (Accessible.*)
- [ ] Pas de logique métier
- [ ] Navigation configurée dans Main.qml
- [ ] Documentation créée dans docs/pages/
- [ ] Tests UI créés

---

## Documentation détaillée

- [CataloguePage](CataloguePage.md) - Page catalogue avec grille responsive

---

## Références

- [Architecture MVC](../Architecture/mvc-pattern.md)
- [Navigation système](navigation.md)
- [Responsive design](../Features/responsive-design.md)
- [CatalogueLogic](../Logic/CatalogueLogic.md)
