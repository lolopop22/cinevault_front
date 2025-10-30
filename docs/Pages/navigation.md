# Système de Navigation - Cinevault APP

## Vue d'ensemble

Le système de navigation de l'application Cinevault APP repose sur le **pattern Bottom Navigation de Felgo**. Chaque section (Catalogue, Recherche, Profil) dispose de son propre **NavigationStack**, ce qui permet une navigation imbriquée fluide, intuitive et scalable.

## Architecture de navigation

### Structure globale

```
Main.qml
└── App
    └── Navigation (Bottom Navigation)
        ├── NavigationItem "Catalogue"
        │   └── NavigationStack
        │       └── CataloguePage (initialPage)
        │           └── [FilmDetailPage] ✨ NOUVEAU (push avec filmId)
        │
        ├── NavigationItem "Recherche"
        │   └── NavigationStack
        │
        └── NavigationItem "Profil"
            └── NavigationStack
```
**Nouveautés v1.2** :
- ✅ Navigation CataloguePage → FilmDetailPage implémentée
- ✅ Passage de paramètres (filmId)
- ✅ Pattern lazy loading avec Component
- ✅ Validation des paramètres
- ✅ Intégration ToastService pour notifications
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
✅ **Contexte préservé** : chaque section garde son historique

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

## Passage de Paramètres entre Pages

### Syntaxe de base

Pour passer des paramètres lors du push :

```qml
navigationStack.push(pageComponent, {
    param1: value1,
    param2: value2
})
```

### Exemple : CataloguePage → FilmDetailPage

**Émetteur (CataloguePage)** :

```qml
Component {
    id: filmDetailPageComponent
    FilmDetailPage { }
}

MouseArea {
    onClicked: {
        console.log("=== NAVIGATION VERS DÉTAILS ===")
        console.log("🖱️  Clic sur film:", modelData.title)
        console.log("🆔 ID du film:", modelData.id)
        
        // Validation des données avant navigation
        if (!modelData || !modelData.id || modelData.id <= 0) {
            console.error("❌ Données film invalides")
            return
        }
        
        // Navigation avec passage de paramètre
        navigationStack.push(filmDetailPageComponent, {
            filmId: modelData.id
        })
        
        console.log("✅ Navigation déclenchée")
    }
}
```

**Récepteur (FilmDetailPage)** :

```qml
FlickablePage {
    property int filmId: -1  // Propriété reçue du push
    
    Component.onCompleted: {
        console.log("=== DEBUG FilmDetailPage ===")
        console.log("📄 Page de détails chargée")
        console.log("🆔 Film ID reçu:", filmId)
        
        // Validation du paramètre reçu
        if (filmId <= 0) {
            console.error("❌ filmId invalide:", filmId)
            Services.ToastService.showError("ID de film invalide")
            navigationStack.pop()
            return
        }
        
        // Chargement du film
        logic.loadFilm(filmId)
    }
}
```

### Pattern Lazy Loading avec Component

### Pourquoi utiliser Component ?

**Avantages** :
- ✅ **Lazy loading** : Page créée uniquement au premier push
- ✅ **Performance** : Pas de ressources consommées si jamais affichée (économie de mémoire)
- ✅ **Memory management** : Destruction automatique lors du pop
- ✅ **Pattern Felgo recommandé**

### Structure recommandée

```qml
AppPage {
    // Component défini (pas encore instancié)
    Component {
        id: detailPageComponent
        FilmDetailPage { }
    }
    
    AppButton {
        text: "Voir détails"
        onClicked: {
            // Lazy loading : Page créée ici
            navigationStack.push(detailPageComponent, {
                filmId: 5
            })
        }
    }
}
```

### Bonnes Pratiques

✅ **À faire** :
- Utiliser Component pour lazy loading
- Valider les paramètres dans la page cible
- Logger les paramètres reçus (debugging)

❌ **À éviter** :
- Créer la page directement (`FilmDetailPage { visible: false }`)
- Passer des objets complexes (préférer IDs)
- Oublier les valeurs par défaut (`property int filmId: -1`)

### Exemple avec validation

```qml
FlickablePage {
    property int filmId: -1
    
    Component.onCompleted: {
        // Validation du paramètre
        if (filmId <= 0) {
            console.error("❌ filmId invalide:", filmId)
            Services.ToastService.showError("Erreur de navigation")
            navigationStack.pop()
            return
        }
        
        // Paramètre valide, charger le film
        logic.loadFilm(filmId)
    }
}
```

❌ **Ne pas faire** :
```qml
// Mauvais : page créée à l'avance
FilmDetailPage {
    id: detailPage
    visible: false
}

onClicked: {
    detailPage.filmId = modelData.id
    navigationStack.push(detailPage)
}
```

**Problèmes** :
- Page consomme des ressources même si jamais affichée
- Gestion complexe de l'état
- Fuites mémoire potentielles

---

## Flux de Navigation Complet

### CataloguePage → FilmDetailPage

```
1. Utilisateur clique sur une carte film dans le catalogue
   ↓
2. MouseArea.onPressed → Feedback visuel (scale: 0.95, opacity: 0.7)
   ↓
3. MouseArea.onReleased → Retour normal (scale: 1.0, opacity: 1.0)
   ↓
4. MouseArea.onClicked
   ├─ Logs de debug ("=== NAVIGATION VERS DÉTAILS ===")
   ├─ Validation modelData (non null)
   ├─ Validation ID (> 0)
   └─ navigationStack.push(filmDetailPageComponent, {filmId: X})
   ↓
5. FilmDetailPage créée dynamiquement avec filmId injecté
   ↓
6. Component.onCompleted de FilmDetailPage déclenché
   ├─ Validation filmId reçu
   ├─ Si invalide → ToastService.showError() + pop()
   └─ Si valide → logic.loadFilm(filmId)
   ↓
7. FilmDetailLogic traite le chargement
   ├─ Film trouvé → filmLoaded(film) → Toast succès + affichage
   └─ Film non trouvé → loadError(message) → Toast erreur
```

### FilmDetailPage → CataloguePage (retour)

```
1. Utilisateur clique bouton "Retour" (leftBarItem)
   ↓
2. logic.reset() (nettoyage de l'état)
   ↓
3. navigationStack.pop()
   ↓
4. FilmDetailPage détruite automatiquement
   ↓
5. CataloguePage ré-affichée (état du catalogue conservé)
```

### Flux secondaire : Recherche et ajout (Futur)

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

## Validation des Paramètres ✨ NOUVEAU

### Pattern de validation recommandé

```qml
FlickablePage {
    property int filmId: -1
    property string filmTitle: ""
    
    Component.onCompleted: {
        // Validation complète des paramètres
        if (filmId <= 0) {
            console.error("❌ filmId invalide:", filmId)
            Services.ToastService.showError("Paramètre filmId manquant ou invalide")
            navigationStack.pop()
            return
        }
        
        // Paramètre valide, procéder au chargement
        logic.loadFilm(filmId)
    }
}
```

### Exemples de validation

#### Validation ID numérique
```qml
if (!filmId || filmId <= 0) {
    Services.ToastService.showError("ID de film invalide")
    navigationStack.pop()
    return
}
```

#### Validation string non vide
```qml
if (!filmTitle || filmTitle.trim() === "") {
    Services.ToastService.showError("Titre de film manquant")
    navigationStack.pop()
    return
}
```

#### Validation objet complexe
```qml
if (!filmData || typeof filmData !== "object") {
    Services.ToastService.showError("Données film invalides")
    navigationStack.pop()
    return
}
```

---

## Gestion des Erreurs avec ToastService ✨ NOUVEAU

### Pattern d'erreur de navigation

```qml
// Dans la page réceptrice
Component.onCompleted: {
    if (paramètre_invalide) {
        Services.ToastService.showError("Message d'erreur clair")
        navigationStack.pop()  // Retour immédiat
        return
    }
    
    // Continuer si paramètres valides
}
```

### Intégration avec les Connections

```qml
Connections {
    target: logic
    
    function onDataLoaded() {
        Services.ToastService.showSuccess("Données chargées avec succès")
    }
    
    function onLoadError(message) {
        Services.ToastService.showError(message)
        // Optionnel : retour automatique si erreur critique
        // navigationStack.pop()
    }
}
```

---

## Transitions animées

### Transitions par défaut

Felgo applique automatiquement des transitions :
- **iOS** : Slide horizontal (droite vers gauche)
- **Android** : Material Design transitions
- **Desktop** : Fade + scale
- **Push** : Slide de droite à gauche
- **Pop** : Slide de gauche à droite
- **Durée** : ~300ms
- **Easing** : OutQuad

### Durée des animations

```
Push : ~300ms
Pop : ~250ms
```
**Note** : Les transitions sont optimisées par plateforme et ne nécessitent pas de configuration manuelle.

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

## Gestion du back button et Gesture Navigation

### Android back button

Felgo gère automatiquement le back button Android :
- **Dans une pile** : `navigationStack.pop()`
- **Page initiale** : Ferme l'application (avec confirmation optionnelle)
- Bouton back hardware/software
- Swipe depuis le bord gauche
- Gestion automatique par NavigationStack

### iOS swipe back

Felgo gère automatiquement le swipe depuis le bord gauche :
- Swipe → `navigationStack.pop()`
- Swipe depuis le bord gauche (edge swipe)
- Animation slide droite
- Gestion automatique par NavigationStack

**Desktop** :
- Bouton explicit dans la barre de titre
- Raccourcis clavier (Alt+Left, Escape)

### leftBarItem (recommandé)

```qml
FlickablePage {
    leftBarItem: IconButtonBarItem {
        iconType: IconType.arrowleft
        title: "Retour"
        onClicked: {
            logic.reset()  // Nettoyage optionnel
            navigationStack.pop()
        }
    }
}
```

### Comportement par plateforme

| Plateforme | Bouton retour | Gesture back | Bouton système |
|------------|---------------|--------------|----------------|
| **iOS** | ✅ Visible | ✅ Swipe droite | ❌ |
| **Android** | ✅ Visible | ✅ Swipe droite | ✅ Back button |
| **Desktop** | ✅ Visible | ❌ | ❌ |

**Recommandation** : Toujours implémenter `leftBarItem` pour cohérence cross-platform.

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

### Configuration additionnelle (optionelle)

```qml
NavigationStack {
    // Désactiver gesture si nécessaire
    popGestureEnabled: false
    
    // Animation personnalisée
    pushTransition: Transition {
        PropertyAnimation {
            property: "x"
            duration: 300
            easing.type: Easing.OutCubic
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

### Exemple 4 : Navigation avec multiples paramètres

```qml
navigationStack.push(filmDetailPageComponent, {
    filmId: modelData.id,
    filmTitle: modelData.title,
    fromPage: "catalogue"
})
```

### Exemple 5 : Navigation conditionnelle

```qml
onClicked: {
    if (modelData.isAvailable) {
        navigationStack.push(filmDetailPageComponent, {
            filmId: modelData.id
        })
    } else {
        Services.ToastService.showWarning("Film non disponible")
    }
}
```

### Exemple 6 : Navigation avec callback

```qml
navigationStack.push(editPageComponent, {
    filmId: modelData.id,
    onSaveCompleted: function(savedFilm) {
        // Callback exécuté après sauvegarde
        Services.ToastService.showSuccess("Film sauvegardé")
        // Optionnel : rafraîchir catalogue
        logic.refreshCatalogue()
    }
})
```
---

## Cas d'Usage Avancés

### Navigation profonde avec état partagé

```qml
// Passer un objet de contexte
navigationStack.push(editPageComponent, {
    filmData: modelData,
    editMode: "update",
    onFinished: function(result) {
        if (result.saved) {
            Services.ToastService.showSuccess("Modifications sauvegardées")
            logic.refreshCatalogue()
        }
        navigationStack.pop()
    }
})
```

### Navigation avec confirmation

```qml
onClicked: {
    if (modelData.requiresConfirmation) {
        confirmDialog.filmId = modelData.id
        confirmDialog.open()
    } else {
        navigationStack.push(filmDetailPageComponent, {
            filmId: modelData.id
        })
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

## Performance et Optimisations

### Lazy Loading Benefits

**Mémoire** :
- FilmDetailPage : ~50-100KB par instance
- Component : ~5KB (définition seulement)
- **Économie** : 90%+ si page jamais affichée

**Temps de démarrage** :
- Création différée jusqu'au premier push
- Initialisation plus rapide de l'app
- Meilleure responsiveness

### Destruction automatique

```qml
// Lors du pop(), la page est automatiquement détruite
navigationStack.pop()  // FilmDetailPage libérée de la mémoire
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

2. **Utiliser Component pour les pages push (pour bénéficier du lazy loading)**
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

5. **Utiliser ToastService pour les erreurs**
```qml
Services.ToastService.showError("Erreur de navigation")
```

6. **Valider tous les paramètres reçus**
```qml
if (filmId <= 0) { /* erreur */ }
```

7. **Nettoyer l'état avant retour**
```qml
onClicked: { logic.reset(); navigationStack.pop() }
```

### ❌ À éviter

1. **Ne pas instancier directement les pages (Ne famais les créer à l'avance)**
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

## Troubleshooting

### Problème : Paramètre non reçu

**Symptôme** : `filmId` est `undefined` dans la page réceptrice

**Solution** :
```qml
// Vérifier la syntaxe du push
navigationStack.push(pageComponent, {
    filmId: modelData.id  // Assurer que modelData.id existe
})

// Vérifier la propriété dans la page
property int filmId: -1  // Valeur par défaut
```

### Problème : Page ne se charge pas

**Symptôme** : NavigationStack ne push pas

**Solutions** :
1. Vérifier que `pageComponent` est un Component valide
2. Vérifier les logs d'erreur QML
3. Tester avec une page simple

```qml
// Test minimal
Component {
    id: testComponent
    AppPage { title: "Test" }
}
```

### Problème : Fuite mémoire

**Symptôme** : Pages s'accumulent en mémoire

**Solutions** :
1. Utiliser Component (pas d'instance directe)
2. Appeler `pop()` pour nettoyer
3. Éviter les références circulaires

---

## Références

### Documentation

- [CataloguePage](CataloguePage.md) - Page catalogue avec navigation
- [Architecture MVC](../Architecture/mvc-pattern.md) - Architecture de l'application
- [FilmDetailPage](./FilmDetailPage.md) - Page de détails avec paramètres
- [FilmDetailLogic](../Logic/FilmDetailLogic.md) - Controller MVC
- [ToastService](../Components/ToastService.md) - Notifications globales

### Liens externes

- [Felgo NavigationStack](https://felgo.com/doc/felgo-navigationstack/)
- [Felgo Bottom Navigation](https://felgo.com/doc/felgo-navigation/)
- [QML Component](https://doc.qt.io/qt-6/qml-qtqml-component.html)

