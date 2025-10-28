# Documentation des Pages - Cinevault APP v1.2

## Vue d'ensemble

Le dossier `pages` contient les pages principales de l'application qui constituent l'interface utilisateur. Chaque page représente un écran complet accessible via la navigation. Les pages sont organisées selon le pattern MVC avec une séparation stricte entre View (affichage) et Controller (logique).

## Localisation

```
qml/pages/
├── CataloguePage.qml      # Page principale du catalogue ✅
├── FilmDetailPage.qml     # Page de détails d'un film ✨ NOUVEAU
├── RecherchePage.qml      # Page de recherche IMDb (à venir)
└── ProfilPage.qml         # Page profil utilisateur (à venir)
```

## Liste des pages

| Page | Statut | Description | Navigation |
|------|--------|-------------|------------|
| [CataloguePage](CataloguePage.md) | ✅ Implémenté | Grille de films avec lazy loading et navigation | Tab "Catalogue" |
| [FilmDetailPage](FilmDetailPage.md) | ✅ Implémenté | Détails d'un film avec scroll et retour | Push depuis Catalogue |
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
│Catalogue│  │Recherche│  │ Profil  │  ← Pages (Tabs)
│  Page   │  │  Page   │  │  Page   │
└────┬────┘  └─────────┘  └─────────┘
     │
     │ push/pop
     ▼
┌──────────────┐
│ FilmDetail   │  ← Page secondaire
│    Page      │
└──────┬───────┘
       │
       │ utilise
       ▼
┌──────────────┐
│    Logic     │  Logique métier (Controller)
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Model/Service│  Données et API
└──────────────┘
```

### Responsabilités d'une Page (View)

**✅ Affichage**
- Structure visuelle (layout, composants)
- Présentation des données
- Style et thème
- Feedback visuel utilisateur

**✅ Interactions utilisateur**
- Boutons, gestes, navigation
- Délégation des actions à Logic
- Animations et transitions

**✅ Bindings réactifs**
- Liaison automatique avec Model/Logic
- Mise à jour UI automatique
- Écoute des signaux de la Logic

**✅ Navigation** ✨ NOUVEAU
- Push vers pages secondaires
- Passage de paramètres
- Gestion du retour (pop)

**❌ Pas de logique métier**
- Pas de transformation de données
- Pas d'appels API directs
- Pas de calculs complexes
- Pas d'accès direct aux Services

---

## Navigation ✨ NOUVEAU

### Configuration dans Main.qml

```qml
Navigation {
    navigationMode: navigationModeDefault  // Platform-specific
    
    NavigationItem {
        title: "Catalogue"
        iconType: IconType.film
        
        NavigationStack {
            // Instance directe pour initialPage
            initialPage: CataloguePage { }
        }
    }
    
    NavigationItem {
        title: "Recherche"
        iconType: IconType.search
        
        NavigationStack {
            initialPage: RecherchePage { }
        }
    }
    
    NavigationItem {
        title: "Profil"
        iconType: IconType.user
        
        NavigationStack {
            initialPage: ProfilPage { }
        }
    }
}
```

**Note** : `navigationModeDefault` adapte automatiquement la navigation :
- **Android** : Drawer
- **iOS/Desktop** : Tabs

### Pattern NavigationStack

Chaque `NavigationItem` contient un `NavigationStack` permettant :
- ✅ Navigation vers pages de détails (push)
- ✅ Historique de navigation (back button)
- ✅ Transitions animées
- ✅ **Passage de paramètres** ✨ NOUVEAU
- ✅ **Lazy loading des pages secondaires** ✨ NOUVEAU

---

## Passage de Paramètres entre Pages

### initialPage : Instance directe

Pour la page racine d'un NavigationStack, utilisez une instance directe :

```qml
NavigationStack {
    // ✅ Instance directe (pas de Component)
    initialPage: CataloguePage { }
}
```

**Justification** :
- La page est toujours affichée au démarrage
- Pas de bénéfice au lazy loading
- Affichage plus rapide

### push() : Component + paramètres

Pour les pages secondaires, utilisez Component avec lazy loading :

```qml
// Dans CataloguePage.qml

Component {
    id: filmDetailPageComponent
    FilmDetailPage { }
}

delegate: Item {
    MouseArea {
        onClicked: {
            // Validation des données
            if (!modelData || !modelData.id || modelData.id <= 0) {
                console.error("❌ Données film invalides")
                return
            }
            
            // Push avec passage de paramètres
            navigationStack.push(filmDetailPageComponent, {
                filmId: modelData.id
            })
        }
    }
}
```

**Avantages** :
- ✅ Lazy loading : Page créée uniquement si nécessaire
- ✅ Économie mémoire : ~90% si page jamais affichée
- ✅ Destruction automatique au pop()
- ✅ Passage de paramètres dynamiques

---

## Structure type d'une Page

### Template de base (avec navigation)

```qml
import Felgo 4.0
import QtQuick 2.15
import "../logic" as Logic
import "../model" as Model
import "../components" as Components
import "../services" as Services  // ✨ NOUVEAU : Pour ToastService

/**
 * [NomPage] - Description
 * Page pour [fonctionnalité]
 */
AppPage {
    id: pageName
    title: "Titre de la page"
    
    // ===================================
    // LOGIQUE MÉTIER (Controller)
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
    // NAVIGATION (si applicable)
    // ===================================
    
    // Component pour pages secondaires (lazy loading)
    Component {
        id: detailPageComponent
        DetailPage { }
    }
    
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
        
        // Contenu scrollable avec navigation
        GridView {
            model: logic.data
            
            delegate: Item {
                MouseArea {
                    onClicked: {
                        // Navigation vers détails
                        navigationStack.push(detailPageComponent, {
                            itemId: modelData.id
                        })
                    }
                }
            }
        }
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
    // GESTION D'ERREURS (ToastService)
    // ===================================
    
    Connections {
        target: logic
        
        function onErrorOccurred(message) {
            // ✨ NOUVEAU : Utilisation de ToastService
            Services.ToastService.showError(message)
        }
        
        function onDataLoaded() {
            Services.ToastService.showSuccess("Données chargées")
        }
    }
    
    // ===================================
    // INITIALISATION
    // ===================================
    
    Component.onCompleted: {
        console.log("[NomPage] Initialisée")
        // La Logic se charge des données automatiquement
    }
}
```

---

## Template Page Secondaire (avec paramètres)

```qml
import Felgo 4.0
import QtQuick 2.15
import "../logic" as Logic
import "../services" as Services

/**
 * DetailPage - Page de détails
 * Reçoit un ID en paramètre
 */
FlickablePage {
    id: detailPage
    
    // ===================================
    // PARAMÈTRES REÇUS
    // ===================================
    
    property int itemId: -1  // Paramètre passé lors du push
    
    // ===================================
    // LOGIQUE MÉTIER
    // ===================================
    
    Logic.DetailLogic {
        id: logic
    }
    
    // ===================================
    // TITRE DYNAMIQUE
    // ===================================
    
    title: logic.currentItem ? logic.currentItem.title : "Détails"
    
    // ===================================
    // BOUTON RETOUR
    // ===================================
    
    leftBarItem: IconButtonBarItem {
        iconType: IconType.arrowleft
        title: "Retour"
        onClicked: {
            logic.reset()  // Nettoyage optionnel
            navigationStack.pop()
        }
    }
    
    // ===================================
    // CONTENU SCROLLABLE
    // ===================================
    
    flickable.contentHeight: contentColumn.height + dp(60)
    
    Column {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: dp(20)
        spacing: dp(20)
        
        // Contenu détaillé...
    }
    
    // ===================================
    // GESTION DES SIGNAUX
    // ===================================
    
    Connections {
        target: logic
        
        function onItemLoaded(item) {
            Services.ToastService.showSuccess("Données chargées")
        }
        
        function onLoadError(message) {
            Services.ToastService.showError(message)
        }
    }
    
    // ===================================
    // INITIALISATION ET VALIDATION
    // ===================================
    
    Component.onCompleted: {
        console.log("=== DEBUG DetailPage ===")
        console.log("📄 Page de détails chargée")
        console.log("🆔 Item ID reçu:", itemId)
        
        // Validation du paramètre
        if (itemId <= 0) {
            console.error("❌ itemId invalide:", itemId)
            Services.ToastService.showError("Paramètre manquant")
            navigationStack.pop()
            return
        }
        
        // Chargement des données
        logic.loadItem(itemId)
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

// État : Erreur (via ToastService)
Connections {
    target: logic
    function onErrorOccurred(message) {
        Services.ToastService.showError(message)
    }
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

// Component pour pages secondaires
Component {
    id: detailComponent
    DetailPage { }  // Créée uniquement au push
}
```

### 4. Accessibilité

```qml
AppPage {
    Accessible.role: Accessible.Pane
    Accessible.name: "Page Catalogue"
    Accessible.description: "Affiche la liste des films"
    
    // Pour chaque élément interactif
    MouseArea {
        Accessible.role: Accessible.Button
        Accessible.name: "Voir détails du film"
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

2. **Bindings réactifs pour affichage**
```qml
Text {
    text: logic.filmCount + " films"  // ✅ Binding automatique
}

title: logic.currentFilm ? logic.currentFilm.title : "Détails"  // ✅
```

3. **Gérer tous les états**
```qml
// Loading, Ready, Empty, Error
BusyIndicator { visible: logic.loading }
GridView { visible: !logic.loading && logic.hasData }
Column { visible: !logic.loading && !logic.hasData }
// Erreurs via ToastService
```

4. **Valider les paramètres reçus**
```qml
property int itemId: -1

Component.onCompleted: {
    if (itemId <= 0) {
        Services.ToastService.showError("Paramètre invalide")
        navigationStack.pop()
        return
    }
    logic.loadItem(itemId)
}
```

5. **Utiliser ToastService pour notifications**
```qml
Connections {
    target: logic
    function onErrorOccurred(message) {
        Services.ToastService.showError(message)
    }
}
```

6. **Structure claire et organisée**
```qml
AppPage {
    // 1. Paramètres reçus
    // 2. Logic
    // 3. Propriétés layout
    // 4. Navigation (Components)
    // 5. Header
    // 6. Contenu principal
    // 7. Gestion signaux
    // 8. Initialisation
}
```

### ❌ À éviter

1. **Pas de logique métier dans la View**
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

4. **Ne pas créer les pages à l'avance**
```qml
// ❌ MAUVAIS
DetailPage {
    id: detailPage
    visible: false
}

// ✅ BON : Component lazy loading
Component {
    id: detailComponent
    DetailPage { }
}
```

5. **Ne pas oublier la validation des paramètres**
```qml
// ❌ MAUVAIS
Component.onCompleted: {
    logic.loadFilm(filmId)  // Pas de validation
}

// ✅ BON
Component.onCompleted: {
    if (filmId <= 0) {
        Services.ToastService.showError("ID invalide")
        navigationStack.pop()
        return
    }
    logic.loadFilm(filmId)
}
```

---

## Navigation entre pages

### Push vers page de détails

```qml
// Dans CataloguePage
Component {
    id: filmDetailPageComponent
    FilmDetailPage { }
}

GridView {
    delegate: Rectangle {
        MouseArea {
            onClicked: {
                console.log("Navigation vers film:", modelData.id)
                
                // Validation avant navigation
                if (!modelData || !modelData.id) {
                    console.error("Données invalides")
                    return
                }
                
                // Push avec paramètres
                navigationStack.push(filmDetailPageComponent, {
                    filmId: modelData.id
                })
            }
        }
    }
}
```

### Pop (retour)

```qml
// Dans FilmDetailPage
leftBarItem: IconButtonBarItem {
    iconType: IconType.arrowleft
    title: "Retour"
    onClicked: {
        logic.reset()  // Nettoyage optionnel
        navigationStack.pop()
    }
}

// Ou automatiquement avec le back button système (Android)
```

### Navigation avec validation

```qml
onClicked: {
    // Validation des données
    if (!modelData || modelData.id <= 0) {
        Services.ToastService.showError("Film invalide")
        return
    }
    
    // Validation de l'état
    if (!networkAvailable) {
        Services.ToastService.showWarning("Pas de connexion")
        return
    }
    
    // Navigation si tout est OK
    navigationStack.push(detailComponent, {
        filmId: modelData.id
    })
}
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
    
    function test_navigation() {
        // Simuler un clic
        mouseClick(page.filmCard, 10, 10)
        
        // Vérifier navigation
        compare(navigationStack.depth, 2)
    }
}
```

### Tests de navigation

```qml
function test_pushWithParameters() {
    var testFilmId = 5
    
    // Act
    navigationStack.push(filmDetailComponent, {
        filmId: testFilmId
    })
    
    // Assert
    compare(navigationStack.depth, 2)
    compare(navigationStack.currentItem.filmId, testFilmId)
}
```

---

## Checklist création page

### Page principale (Tab)
- [ ] Nom en PascalCase (ex: `CataloguePage.qml`)
- [ ] Hérite de `AppPage` ou `FlickablePage`
- [ ] Import Logic associé
- [ ] Propriétés responsive (breakpoints)
- [ ] Gestion des 4 états (loading, ready, empty, error)
- [ ] Utilisation dp()/sp()
- [ ] Accessibilité (Accessible.*)
- [ ] Pas de logique métier
- [ ] ToastService pour notifications
- [ ] Component pour pages secondaires
- [ ] Navigation configurée dans Main.qml (instance directe)
- [ ] Documentation créée dans docs/pages/
- [ ] Tests UI créés

### Page secondaire (Push)
- [ ] Component défini dans page émettrice
- [ ] Propriétés pour paramètres reçus
- [ ] Valeurs par défaut pour paramètres
- [ ] Validation des paramètres dans Component.onCompleted
- [ ] leftBarItem avec bouton retour
- [ ] Titre dynamique (binding avec Logic)
- [ ] Nettoyage (reset) avant pop()
- [ ] ToastService pour erreurs
- [ ] Pas de logique métier
- [ ] Documentation créée
- [ ] Tests de navigation

---

## Documentation détaillée

### Pages implémentées
- [CataloguePage](CataloguePage.md) - Page catalogue avec grille responsive et navigation
- [FilmDetailPage](FilmDetailPage.md) - Page de détails avec paramètres et scroll

### Navigation
- [Système de Navigation](navigation.md) - Documentation complète du système de navigation

---

## Références

### Documentation interne
- [Architecture MVC](../Architecture/mvc-pattern.md)
- [Navigation système](navigation.md)
- [Responsive design](../Features/responsive-design.md)
- [CatalogueLogic](../Logic/CatalogueLogic.md)
- [FilmDetailLogic](../Logic/FilmDetailLogic.md)
- [ToastService](../Components/ToastService.md)

### Documentation externe
- [Felgo NavigationStack](https://felgo.com/doc/felgo-navigationstack/)
- [Felgo Bottom Navigation](https://felgo.com/doc/felgo-navigation/)
- [QML Component](https://doc.qt.io/qt-6/qml-qtqml-component.html)
