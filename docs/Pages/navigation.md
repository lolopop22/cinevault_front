# Système de Navigation - Cinevault APP

## Vue d'ensemble

Le système de navigation de Cinevault APP utilise le **Bottom Navigation pattern** de Felgo pour offrir une navigation principale intuitive entre les sections principales de l'application.

## Architecture de navigation

### Structure globale

```
Main.qml
└── App
    └── Navigation (Bottom Navigation)
        ├── NavigationItem "Catalogue"
        │   └── NavigationStack
        │       └── CataloguePage (initialPage)
        │           └── [FilmDetailPage] (push)
        │
        ├── NavigationItem "Recherche"
        │   └── NavigationStack
        │       └── RecherchePage (initialPage)
        │           └── [AddFilmPage] (push)
        │
        └── NavigationItem "Profil"
            └── NavigationStack
                └── ProfilPage (initialPage)
                    └── [SettingsPage] (push)
```

---

## Bottom Navigation

### Configuration dans Main.qml

```qml
App {
    id: app
    
    Navigation {
        navigationMode: navigationModeDefault  // Bottom Navigation
        
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
                AppPage {
                    title: "Recherche"
                    AppText {
                        anchors.centerIn: parent
                        text: "Page Recherche - À implémenter"
                    }
                }
            }
        }
        
        NavigationItem {
            title: "Profil"
            iconType: IconType.user
            
            NavigationStack {
                AppPage {
                    title: "Profil"
                    AppText {
                        anchors.centerIn: parent
                        text: "Page Profil - À implémenter"
                    }
                }
            }
        }
    }
}
```

### Caractéristiques Bottom Navigation

✅ **Toujours visible** : Barre fixe en bas de l'écran  
✅ **3-5 sections** : Maximum recommandé pour lisibilité  
✅ **Icônes + Labels** : Navigation claire et intuitive  
✅ **État actif** : Section courante mise en évidence  
✅ **Gestes** : Tap pour changer de section  

---

## NavigationStack

### Rôle

Chaque `NavigationItem` contient un `NavigationStack` qui gère :
- La pile de pages (historique)
- Les transitions animées
- Le bouton retour
- Le header avec titre

### Méthodes principales

#### `push(page, properties)`
Empile une nouvelle page.

**Paramètres** :
- `page` : Component ou Item de la page
- `properties` : Objet avec propriétés à passer à la page

**Exemple** :
```qml
// Dans CataloguePage
MouseArea {
    onClicked: {
        navigationStack.push(filmDetailPageComponent, {
            filmId: modelData.id,
            filmTitle: modelData.title
        })
    }
}

Component {
    id: filmDetailPageComponent
    FilmDetailPage { }
}
```

#### `pop()`
Retire la page courante et retourne à la précédente.

**Exemple** :
```qml
// Dans FilmDetailPage
leftBarItem: IconButtonBarItem {
    iconType: IconType.arrowleft
    onClicked: navigationStack.pop()
}

// Ou automatiquement avec back button système
```

#### `popAllExceptFirst()`
Retourne à la page initiale en vidant toute la pile.

**Exemple** :
```qml
Button {
    text: "Retour au catalogue"
    onClicked: navigationStack.popAllExceptFirst()
}
```

---

## Flux de navigation

### Flux principal : Consultation catalogue

```
1. App démarre
   ↓
2. Bottom Navigation affiche "Catalogue" (section par défaut)
   ↓
3. CataloguePage s'affiche (initialPage)
   ↓
4. Utilisateur tape sur un film
   ↓
5. navigationStack.push(FilmDetailPage, {filmId: X})
   ↓
6. FilmDetailPage s'affiche avec transition
   ↓
7. Utilisateur tape "Retour" ou back button
   ↓
8. navigationStack.pop()
   ↓
9. Retour à CataloguePage
```

### Flux secondaire : Recherche et ajout

```
1. Utilisateur tape sur tab "Recherche"
   ↓
2. Bottom Navigation change de section
   ↓
3. RecherchePage s'affiche
   ↓
4. Utilisateur recherche un film IMDb
   ↓
5. navigationStack.push(IMDbFilmDetailPage, {imdbId: Y})
   ↓
6. Utilisateur tape "Ajouter au catalogue"
   ↓
7. Film ajouté (API call)
   ↓
8. navigationStack.popAllExceptFirst()
   ↓
9. Retour à RecherchePage
```

### Flux entre sections

```
CataloguePage (section Catalogue)
   ↓ Tap sur tab "Recherche"
RecherchePage (section Recherche)
   ↓ Tap sur tab "Profil"
ProfilPage (section Profil)
   ↓ Tap sur tab "Catalogue"
CataloguePage (section Catalogue)

Note : Chaque section garde son propre NavigationStack
```

---

## Transitions animées

### Transitions par défaut

Felgo applique automatiquement des transitions :
- **Push** : Slide de droite à gauche
- **Pop** : Slide de gauche à droite
- **Durée** : ~300ms
- **Easing** : OutQuad

### Personnalisation

```qml
NavigationStack {
    // Désactiver transitions
    navigationBarTransition: 0
    
    // Ou personnaliser
    navigationBarTransition: Transition {
        NumberAnimation {
            property: "opacity"
            duration: 200
        }
    }
}
```

---

## Header et barre de titre

### Configuration automatique

```qml
AppPage {
    title: "Mon Catalogue"  // ← Affiché dans le header
    
    // Boutons dans le header
    leftBarItem: IconButtonBarItem {
        iconType: IconType.arrowleft
        onClicked: navigationStack.pop()
    }
    
    rightBarItem: IconButtonBarItem {
        iconType: IconType.refresh
        onClicked: logic.refreshCatalogue()
    }
}
```

### Masquer le header

```qml
AppPage {
    navigationBarHidden: true  // Cache le header
}
```

---

## Gestion du back button

### Android back button

Felgo gère automatiquement le back button Android :
- **Dans une pile** : `navigationStack.pop()`
- **Page initiale** : Ferme l'application (avec confirmation optionnelle)

### iOS swipe back

Felgo gère automatiquement le swipe depuis le bord gauche :
- Swipe → `navigationStack.pop()`

### Confirmation avant fermeture

```qml
App {
    onBackPressed: {
        if (navigationStack.depth === 1) {
            // Page initiale : demander confirmation
            nativeUtils.displayMessageBox(
                "Quitter l'application ?",
                "",
                2  // Oui/Non
            )
        } else {
            // Retour normal
            navigationStack.pop()
        }
    }
}
```

---

## Exemples d'implémentation

### Exemple 1 : Navigation simple vers détails

```qml
// CataloguePage.qml
AppPage {
    title: "Mon Catalogue"
    
    GridView {
        delegate: Item {
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    navigationStack.push(filmDetailComponent, {
                        filmId: modelData.id
                    })
                }
            }
        }
    }
    
    Component {
        id: filmDetailComponent
        FilmDetailPage { }
    }
}

// FilmDetailPage.qml
AppPage {
    property int filmId: -1
    title: "Détails du film"
    
    leftBarItem: IconButtonBarItem {
        iconType: IconType.arrowleft
        onClicked: navigationStack.pop()
    }
    
    Component.onCompleted: {
        console.log("Film ID:", filmId)
        // Charger détails du film
    }
}
```

### Exemple 2 : Navigation avec confirmation

```qml
// FilmEditPage.qml
AppPage {
    property bool hasUnsavedChanges: false
    
    leftBarItem: IconButtonBarItem {
        iconType: IconType.close
        onClicked: {
            if (hasUnsavedChanges) {
                confirmDialog.open()
            } else {
                navigationStack.pop()
            }
        }
    }
    
    Dialog {
        id: confirmDialog
        title: "Modifications non enregistrées"
        message: "Voulez-vous quitter sans enregistrer ?"
        
        onAccepted: {
            navigationStack.pop()
        }
    }
}
```

### Exemple 3 : Navigation profonde

```qml
// Scénario : Catalogue → Détails → Édition → Confirmation
Button {
    text: "Éditer"
    onClicked: {
        navigationStack.push(filmEditComponent, {
            filmId: currentFilmId
        })
    }
}

// Dans FilmEditPage après sauvegarde
Button {
    text: "Enregistrer"
    onClicked: {
        saveFilm()
        
        // Retour à la page catalogue (2 niveaux)
        navigationStack.pop()  // Retour à FilmDetailPage
        navigationStack.pop()  // Retour à CataloguePage
        
        // Ou en une seule commande
        // navigationStack.popAllExceptFirstAndPush(cataloguePageComponent)
    }
}
```

---

## Deep linking (futur)

### Préparation pour deep links

```qml
App {
    // Gérer les deep links (ex: cinevault://film/123)
    onInitTheme: {
        if (Qt.application.arguments.length > 1) {
            var deepLink = Qt.application.arguments[1]
            handleDeepLink(deepLink)
        }
    }
    
    function handleDeepLink(url) {
        if (url.startsWith("cinevault://film/")) {
            var filmId = parseInt(url.split("/").pop())
            
            // Naviguer vers le film
            navigationStack.popAllExceptFirst()
            navigationStack.push(filmDetailComponent, {
                filmId: filmId
            })
        }
    }
}
```

---

## Bonnes pratiques

### ✅ À faire

1. **Toujours définir initialPage**
```qml
NavigationStack {
    initialPage: Component {
        CataloguePage { }
    }
}
```

2. **Utiliser Component pour les pages push**
```qml
Component {
    id: detailPageComponent
    FilmDetailPage { }
}

navigationStack.push(detailPageComponent, {filmId: 1})
```

3. **Passer des paramètres via properties**
```qml
navigationStack.push(pageComponent, {
    filmId: 123,
    filmTitle: "Avatar"
})
```

4. **Gérer le back button**
```qml
leftBarItem: IconButtonBarItem {
    iconType: IconType.arrowleft
    onClicked: navigationStack.pop()
}
```

### ❌ À éviter

1. **Ne pas instancier directement les pages**
```qml
// ❌ MAUVAIS
navigationStack.push(FilmDetailPage { filmId: 1 })

// ✅ BON
navigationStack.push(filmDetailComponent, { filmId: 1 })
```

2. **Ne pas oublier le back button**
```qml
// ❌ MAUVAIS : Utilisateur bloqué
AppPage {
    title: "Détails"
    // Pas de leftBarItem
}

// ✅ BON
AppPage {
    title: "Détails"
    leftBarItem: IconButtonBarItem {
        iconType: IconType.arrowleft
        onClicked: navigationStack.pop()
    }
}
```

3. **Ne pas abuser des niveaux de navigation**
```qml
// ❌ MAUVAIS : Trop profond
Catalogue → Détails → Édition → Confirmation → Succès → ...

// ✅ BON : Maximum 2-3 niveaux
Catalogue → Détails → Édition (puis pop jusqu'au catalogue)
```

---

## Testing de la navigation

### Test unitaire

```qml
TestCase {
    name: "NavigationTests"
    
    NavigationStack {
        id: testStack
    }
    
    function test_push() {
        testStack.push(Qt.createComponent("TestPage.qml"))
        compare(testStack.depth, 1)
    }
    
    function test_pop() {
        testStack.push(Qt.createComponent("TestPage.qml"))
        testStack.pop()
        compare(testStack.depth, 0)
    }
}
```

### Test d'intégration

```qml
function test_navigationFlow() {
    // Démarrer sur catalogue
    compare(navigation.currentIndex, 0)
    
    // Changer de section
    navigation.currentIndex = 1
    compare(navigation.currentIndex, 1)
    
    // Vérifier page affichée
    verify(recherchePage.visible)
}
```

---

## Références

- [CataloguePage](CataloguePage.md)
- [Architecture MVC](../architecture/mvc-pattern.md)
- [Felgo Navigation](https://felgo.com/doc/felgo-navigation/)
- [Felgo NavigationStack](https://felgo.com/doc/felgo-navigationstack/)
