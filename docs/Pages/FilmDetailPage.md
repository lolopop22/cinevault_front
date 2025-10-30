# Documentation FilmDetailPage - Page de Détails d'un Film

## Vue d'ensemble

`FilmDetailPage.qml` est la **View** dans l'architecture MVC de la page de détails de film. Elle affiche les informations détaillées d'un film sélectionné depuis le catalogue et gère la navigation de retour.

---

## Type

**FlickablePage** (hérite de Felgo)

Propriétés :
- Scrollable verticalement (contenu > hauteur écran)
- Barre de navigation avec titre et boutons
- Support mobile et desktop

---

## Responsabilités

1. **Affichage** : Présenter les informations du film de manière visuelle
2. **Navigation** : Gérer le bouton retour et la navigation stack
3. **Délégation** : Confier toute logique métier à FilmDetailLogic
4. **Réaction** : Écouter les signaux de la Logic et afficher les toasts

---

## Architecture MVC

```
┌────────────────────────────────────────┐
│  CataloguePage (Navigation)            │
│  navigationStack.push(filmDetailPage,  │
│    { filmId: 5 })                      │
└────────────────┬───────────────────────┘
                 │ crée
                 ↓
┌────────────────────────────────────────┐
│  FilmDetailPage (View)                 │
│  - Affichage du film                   │
│  - Bouton retour                       │
│  - Gestion toasts                      │
└────────────────┬───────────────────────┘
                 │ délègue
                 ↓
┌────────────────────────────────────────┐
│  FilmDetailLogic (Controller)          │
│  - Chargement du film (par ID)         │
│  - Signaux : filmLoaded, loadError     │
└────────────────┬───────────────────────┘
                 │ interroge
                 ↓
┌────────────────────────────────────────┐
│  FilmDataSingletonModel (Model)        │
│  - Films : source de vérité            │
└────────────────────────────────────────┘
```

---

## Flux de Navigation

```
1. Utilisateur clique sur film dans CataloguePage
   ↓
2. navigationStack.push(filmDetailPageComponent, { filmId: 5 })
   ↓
3. FilmDetailPage créée avec filmId: 5
   ↓
4. Component.onCompleted → logic.loadFilm(5)
   ↓
5a. Film trouvé → filmLoaded(film)
    → Toast succès
    → Affichage du film
    
5b. Erreur → loadError(message)
    → Toast erreur
    → Message affiché

6. Utilisateur clique "Retour"
   ↓
7. logic.reset() (nettoyage)
   ↓
8. navigationStack.pop() (retour catalogue)
```

---

## Propriétés Publiques

### filmId
Identifiant du film à afficher (passé lors de la navigation).

```qml
property int filmId: -1
```

**Valeurs** :
- `-1` : Non défini (par défaut)
- `> 0` : ID valide du film

**Réception lors du push** :
```qml
navigationStack.push(filmDetailPageComponent, {
    filmId: modelData.id
})
```

---

## Instances Internes

### logic
Instance de FilmDetailLogic pour gérer le chargement du film.

```qml
FilmDetailLogic {
    id: logic
}
```

**Accès aux propriétés** :
```qml
logic.currentFilm       // Film chargé
logic.loading           // En cours de chargement
logic.errorMessage      // Message d'erreur
```

---

## Barre de Navigation (FlickablePage)

### Titre dynamique

```qml
title: logic.currentFilm ? logic.currentFilm.title : "Détails du film"
```

S'actualise automatiquement quand `logic.currentFilm` change.

### Bouton Retour (leftBarItem)

```qml
leftBarItem: IconButtonBarItem {
    iconType: IconType.arrowleft
    title: "Retour"
    onClicked: {
        logic.reset()
        navigationStack.pop()
    }
}
```

**Comportement par plateforme** :
- **iOS** : Affichage automatique (convention HIG)
- **Android** : Visible dans NavigationBar + geste back système
- **Desktop** : Visible dans NavigationBar

### Bouton Options (rightBarItem)

```qml
rightBarItem: IconButtonBarItem {
    iconType: IconType.ellipsisv
    title: "Options"
    visible: logic.currentFilm !== null
    onClicked: {
        // Futur : menu d'options
    }
}
```

**Visibilité conditionnelle** :
- Caché si film non chargé
- Visible si film chargé

---

## Contenu Scrollable

### Configuration du Flickable

```qml
flickable.contentHeight: contentColumn.height + dp(60)
```

Permet le scroll si contenu > hauteur de la page.

### Column (contentColumn)

Contenu principal de la page :

```qml
Column {
    id: contentColumn
    anchors {
        left: parent.left
        right: parent.right
        top: parent.top
        margins: dp(20)
    }
    spacing: dp(30)
}
```

**Spacing** : 30dp entre sections

---

## Sections de Contenu

### 1. Poster haute résolution

```qml
PosterImage {
    width: Math.min(dp(200), parent.width * 0.6)
    height: width * 1.5  // Ratio cinéma 2:3
    anchors.horizontalCenter: parent.horizontalCenter
    
    source: logic.currentFilm ? logic.currentFilm.poster_url : ""
    borderRadius: dp(12)
    enableLazyLoading: false  // Chargement immédiat
}
```

**Caractéristiques** :
- Largeur responsive : Min(200dp, 60% de la page)
- Ratio 2:3 (standard affiche cinéma)
- Pas de lazy loading (une seule image, prioritaire)
- Centré horizontalement

### 2. Informations de base

```qml
Column {
    // Titre du film
    AppText {
        text: logic.currentFilm ? logic.currentFilm.title : "Film inconnu"
        font.pixelSize: sp(24)
        font.bold: true
        wrapMode: Text.WordWrap
    }
    
    // Séparateur visuel
    Rectangle {
        width: parent.width * 0.5
        height: dp(2)
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.colors.dividerColor
        radius: dp(1)
    }
    
    // ID technique (validation)
    AppText {
        text: "ID du film : " + filmId
        color: Theme.colors.secondaryTextColor
    }
}
```

**Éléments** :
- Titre (24sp, bold, wrap)
- Séparateur (50% largeur, 2dp hauteur)
- ID (texte gris secondaire)

### 3. Placeholder contenu futur

```qml
Rectangle {
    width: parent.width
    height: contentPlaceholder.height + dp(40)
    radius: dp(8)
    color: Theme.colors.backgroundColor
    border.width: dp(2)
    border.color: Theme.colors.tintColor
    
    Column {
        id: contentPlaceholder
        anchors.centerIn: parent
        
        AppIcon {
            iconType: IconType.infocircle
            size: dp(48)
        }
        
        AppText {
            text: "Contenu détaillé à venir"
            font.pixelSize: sp(18)
            font.bold: true
        }
        
        AppText {
            text: "Cette page valide la navigation...\n\nLe contenu complet sera implémenté dans une User Story dédiée."
            wrapMode: Text.WordWrap
        }
    }
}
```

**Justification** : Indique clairement que le contenu complet sera implémenté dans une autre US.

### 4. Bouton retour additionnel

```qml
AppButton {
    width: parent.width
    text: "Retour au catalogue"
    flat: true
    onClicked: {
        logic.reset()
        navigationStack.pop()
    }
}
```

**Justification** : Bouton redondant pour accessibilité et UX (facilite retour sur mobile).

---

## Gestion des Signaux

### Connections avec FilmDetailLogic

```qml
Connections {
    target: logic
    
    function onFilmLoaded(film) {
        console.log("🎬 Film chargé avec succès:", film.title)
        Services.ToastService.showSuccess("Film chargé avec succès !")
    }
    
    function onLoadError(message) {
        console.log("⚠️ Erreur de chargement:", message)
        Services.ToastService.showError(message)
    }
}
```

**Patterns** :
- ✅ Utilise ToastService (Singleton global)
- ✅ Pas de dépendance sur `app`
- ✅ Réaction aux signaux de la Logic
- ✅ Messages utilisateur via toasts

---

## Initialisation

### Component.onCompleted

```qml
Component.onCompleted: {
    console.log("=== DEBUG FilmDetailPage ===")
    console.log("📄 Page de détails chargée")
    console.log("🆔 Film ID reçu:", filmId)
    
    // Délégation à la Logic
    logic.loadFilm(filmId)
}
```

**Flow** :
1. Page chargée
2. ID du film affiché dans les logs
3. Appel à `logic.loadFilm(filmId)`
4. Logic émet `filmLoaded` ou `loadError`

---

## Cycles de Vie

### Ouverture de la page

```
navigationStack.push()
  ↓
FilmDetailPage créée
  ↓
Component.onCompleted
  ↓
logic.loadFilm(filmId)
  ↓
Film chargé (UI actualisée)
```

### Fermeture de la page

```
Utilisateur clique "Retour"
  ↓
logic.reset() (nettoyage)
  ↓
navigationStack.pop()
  ↓
FilmDetailPage détruit
```

---

## Tests de Validation

### Test 1 : Navigation fonctionne

1. Cliquer sur film dans catalogue
2. FilmDetailPage s'affiche

**Attendu** :
- ✅ Page visible
- ✅ Titre change dynamiquement

### Test 2 : Film existant s'affiche

**Setup** : Naviguer vers film ID: 5

**Attendu** :
- ✅ Poster affiché
- ✅ Titre affiché
- ✅ ID affiché
- ✅ Toast succès

### Test 3 : Film introuvable

**Setup** : Naviguer vers film ID: 999

**Attendu** :
- ❌ Poster absent
- ❌ Toast erreur affiché
- ❌ Message "Film introuvable"

### Test 4 : Bouton retour fonctionne

1. Afficher FilmDetailPage
2. Cliquer "Retour"

**Attendu** :
- ✅ Retour à CataloguePage
- ✅ État nettoyé (logic.reset)

### Test 5 : Scrolling sur mobile

**Setup** : iOS ou Android

**Attendu** :
- ✅ Contenu scrollable si hauteur > écran
- ✅ Poster visible au scroll
- ✅ Pas de freeze

---

## Bonnes Pratiques Implémentées

### ✅ Séparation stricte View/Controller

```
FilmDetailPage
  → Affichage uniquement
  → Pas de logique métier
  → Délègue à FilmDetailLogic

FilmDetailLogic
  → Logique uniquement
  → Communication via signaux
  → Pas d'appels directs au UI
```

### ✅ Bindings réactifs

```qml
// Titre s'actualise automatiquement
title: logic.currentFilm ? logic.currentFilm.title : "Détails"

// Bouton Options visible si film chargé
rightBarItem.visible: logic.currentFilm !== null
```

### ✅ Reset de l'état

```qml
// Avant retour au catalogue
onClicked: {
    logic.reset()  // Nettoyage
    navigationStack.pop()
}
```

### ✅ Navigation responsive

- Fonctionnalité identique sur iOS, Android, Desktop
- Bouton retour visible partout
- Passage de paramètres sécurisé

---

## Évolutions Futures

### User Story dédiée : Contenu détaillé

À implémenter dans une US séparée :
- Résumé du film (synopsis)
- Casting (liste des acteurs)
- Genres (tags)
- Année de sortie
- Durée

### Prévu : Actions supplémentaires

- Bouton "Ajouter aux favoris"
- Bouton "Partager"
- Menu d'options (ellipsis)

### Prévu : Chargement depuis API

- Appel HTTP via FilmService
- Affichage d'un loading spinner
- Gestion des timeouts

---

## Intégration CataloguePage

### Navigation depuis CataloguePage

```qml
// CataloguePage.qml
GridView {
    delegate: Rectangle {
        MouseArea {
            onClicked: {
                navigationStack.push(filmDetailPageComponent, {
                    filmId: modelData.id
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

**Points clés** :
- ✅ Lazy loading (Component)
- ✅ Passage de filmId
- ✅ Pattern réutilisable

---

## Logs de Debugging

### Démarrage de la page

```
=== DEBUG FilmDetailPage ===
📄 Page de détails chargée
🆔 Film ID reçu: 5
🔍 Chargement du film ID: 5
📊 Catalogue disponible: 14 films
✅ Film trouvé: Avatar
🎬 Film chargé avec succès dans la Vue: Avatar
```

### Erreur

```
⚠️ Erreur de chargement reçue dans la Vue: Film introuvable
❌ Film non trouvé avec ID: 999
IDs disponibles: 1, 2, 3, ..., 14
```

---

## Performance

### Optimisations

- ✅ Lazy loading du Component (FilmDetailPage)
- ✅ Pas de lazy loading du poster (une seule image)
- ✅ Binding réactif (pas de code impératif)
- ✅ Reset de l'état (pas de fuite mémoire)

### Considérations

- FilmDetailPage crée une nouvelle instance à chaque navigation
- Logic réinitialisée à chaque visite (pas de cache)
- Pas de souscription à des signaux persistants

---

## Standards et Conventions

### Naming

- **Page** : `FilmDetailPage.qml` (PascalCase)
- **Logic** : `FilmDetailLogic.qml` (PascalCase)
- **Propriétés** : `filmId`, `currentFilm` (camelCase)
- **Signaux** : `filmLoaded`, `loadError` (camelCase)

### Layout

- **Marges** : 20dp (standard Material)
- **Spacing** : 30dp entre sections
- **Poster** : Ratio 2:3 (cinéma)
- **Titre** : 24sp, bold

### Interactions

- Bouton retour : Toujours visible
- Toast : Succès (vert) ou Erreur (rouge)
- Navigation : Instantanée (pas d'animation manuelle)

---

## Références

### Documentations

- [FilmDetailLogic.md](../Logic/FilmDetailLogic.md) - Controller
- [ToastService.md](../Components/ToastService.md) - Système de notifications
- [navigation.md](./navigation.md) - Navigation et NavigationStack

### Guidelines

- [Felgo FlickablePage](https://felgo.com/api)
- [Material Design](https://m3.material.io/)
- [iOS HIG](https://developer.apple.com/design/human-interface-guidelines/)
