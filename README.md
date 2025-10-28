# Cinevault APP - Documentation v1.2

Application multi-plateforme de gestion de catalogue de films développée avec **Felgo 4** (Qt/QML).

Architecture **MVC** complète avec services globaux, navigation avancée et optimisations UI.

---

## 📚 Organisation de la documentation

### Architecture & Conception
Comprendre la structure globale et les patterns de l'application

- [Vue d'ensemble](docs/Architecture/overview.md) - Schémas et composants principaux
- [Pattern MVC](docs/Architecture/mvc-pattern.md) - Adaptation MVC pour QML/Felgo
- [Flux de données](docs/Architecture/data-flow.md) - Diagrammes de séquence détaillés  

### Composants UI
Éléments réutilisables de l'interface utilisateur

- [Guide des composants](docs/Components/README-Components-v1.2.md) - Principes, conventions et services
- [PosterImage](docs/Components/PosterImage.md) - Affichage optimisé des posters avec lazy loading
- [ToastService](docs/Services/ToastService.md) - Service notifications global  
- [Guidelines](docs/Components/guidelines.md) - Créer de nouveaux composants

### Pages & Navigation
Pages principales et système de navigation

- [Pages principales](docs/Pages/README.md) - Index et navigation
- [CataloguePage](docs/Pages/CataloguePage.md) - Grille de films avec lazy loading
- [FilmDetailPage](docs/Pages/FilmDetailPage.md) - Détails d'un film  
- [Navigation système](docs/Pages/navigation.md) - Bottom Navigation, NavigationStack et flux

### Modèle de Données (Model)
Gestion de l'état global et communication réseau

- [Vue d'ensemble Model](docs/Data/README.md) - Principes, patterns et architecture
- [FilmDataSingletonModel](docs/Data/FilmDataSingletonModel.md) - État global Singleton
- [FilmService](docs/Services/FilmService.md) - Service API REST Django

### Logique Métier (Logic - Controllers)
Contrôleurs orchestrant Model et Vue

- [Vue d'ensemble Logic](docs/Logic/README.md) - Rôle et responsabilités des logics
- [CatalogueLogic](docs/Logic/CatalogueLogic.md) - Orchestration du catalogue
- [FilmDetailLogic](docs/Logic/FilmDetailLogic.md) - Orchestration détails film  

### Services Globaux (Singletons)
Services applicatifs accessibles partout

- [ToastService](docs/Services/ToastService.md) - Notifications globales non-intrusives  

### Fonctionnalités Avancées (à rédiger)
Features et optimisations spécifiques

- [Lazy Loading](docs/Features/lazy-loading.md) - Chargement optimisé des images
- [Optimisation images](docs/Features/image-optimization.md) - Gestion mémoire et performance
- [Gestion d'erreurs](docs/Features/error-handling.md) - Patterns de résilience et toasts
- [Responsive design](docs/Features/responsive-design.md) - Adaptation multi-écrans

### Outils & Guides
Configuration et développement

- [Configuration](docs/Development/setup.md) - Setup Felgo 4 (à rédiger)
- [Standards de code](docs/Development/coding-standards.md) - Conventions QML (à rédiger)
- [Debug](docs/Development/debugging.md) - Techniques de debugging (à rédiger)
- [qmldir guide](docs/Data/qmldir-guide.md) - Gestion des modules QML

---

## 🚀 Démarrage rapide

### Pour comprendre l'architecture

1. [Architecture overview](docs/Architecture/overview.md) - Vue d'ensemble
2. [Pattern MVC](docs/Architecture/mvc-pattern.md) - Structure MVC
3. [Flux de données](docs/Architecture/data-flow.md) - Flux complets

**Résultat** : Compréhension de la structure générale et des patterns

### Pour créer un composant réutilisable

1. [Components guidelines](docs/Components/guidelines.md) - Template et checklist
2. [PosterImage](docs/Components/PosterImage.md) - Exemple de référence
3. Suivre les conventions de nommage et structure

**Résultat** : Composant prêt à l'emploi et testable

### Pour ajouter une fonctionnalité

1. [Pattern MVC](docs/Architecture/mvc-pattern.md) - Respecter l'architecture
2. [Flux de données](docs/Architecture/data-flow.md) - Comprendre les flux
3. [Logic README](docs/Logic/README.md) - Créer la Logic
4. Ajouter Service si nécessaire
5. Tester et documenter

**Résultat** : Feature cohérente et maintenable

### Pour afficher des données

1. **Model** : Ajouter propriétés dans `FilmDataSingletonModel`
2. **Service** : Créer/modifier pour récupérer données (API)
3. **Logic** : Créer/modifier pour orchestration
4. **Vue** : Binder données via bindings QML

**Flow** : Service → Logic → Model → Vue (via bindings)

### Pour ajouter une page

1. Créer fichier dans `qml/pages/PageName.qml`
2. Créer Logic associé dans `qml/logic/PageNameLogic.qml`
3. Ajouter NavigationItem dans `Main.qml`
4. Documenter dans `docs/Pages/`

**Exemple** : FilmDetailPage + FilmDetailLogic

---

## 📖 Index par rôle

### Développeur Frontend

- [Components](docs/Components/README-Components-v1.2.md) - Composants réutilisables
- [Pages](docs/Pages/README.md) - Pages principales
- [Responsive design](docs/Features/responsive-design.md) - Multi-écrans
- [Lazy loading](docs/Features/lazy-loading.md) - Optimisation UI
- [Navigation système](docs/Pages/navigation.md) - Bottom Navigation

**À savoir** : MVC, Bindings QML, Responsive, Services globaux

### Développeur Backend

- [FilmService](docs/Services/FilmService.md) - Communication API
- [Model Data](docs/Data/README-ModelData-v1.2-Corrected.md) - Architecture data
- [Flux de données](docs/Architecture/data-flow.md) - Intégration API
- [Pattern MVC](docs/Architecture/mvc-pattern.md) - Architecture

**À savoir** : REST API, Signaux QML, JSON parsing, Error handling

### Architecte / Tech Lead

- [Architecture overview](docs/Architecture/overview.md) - Vue générale
- [MVC pattern](docs/Architecture/mvc-pattern.md) - Architecture MVC/Felgo
- [Flux de données](docs/Architecture/data-flow.md) - Diagrammes flux
- [Model Data](docs/Data/README.md) - Modèle données

**À savoir** : Patterns, Scalabilité, Maintenabilité, Standards

### QA / Testeur

- [Testing guide](docs/Development/testing.md) - Tests unitaires
- [Error handling](docs/Features/error-handling.md) - Gestion erreurs
- [Debug](docs/Development/debugging.md) - Debugging techniques
- [Responsive design](docs/Features/responsive-design.md) - Tests multi-écrans

**À savoir** : Patterns de test, Edge cases, Responsive, Erreurs

---

## 🎯 Guides par tâche

### Afficher une liste de données

**Steps** :
1. Ajouter propriétés dans `FilmDataSingletonModel` (état)
2. Créer `FilmService.fetchXXX()` pour récupérer (API)
3. Créer `XXXLogic.refresh()` pour orchestrer
4. Créer View avec `GridView.model: Model.FilmDataSingletonModel.films`

**Exemple** : [Flux de lecture catalogue](docs/Architecture/data-flow.md#1-flux-de-lecture--chargement-du-catalogue)

### Afficher les détails d'un élément

**Steps** :
1. Créer `XXXDetailLogic.loadXXX(id)` pour recherche
2. Créer `XXXDetailPage` avec paramètre `property int xxxId`
3. En `Component.onCompleted`, appeler `logic.loadXXX(xxxId)`
4. Binder les données dans la page

**Exemple** : [FilmDetailPage](docs/Pages/FilmDetailPage.md)

### Afficher une notification (toast)

**Steps** :
1. Dans Logic : détecter succès/erreur
2. Appeler `Services.ToastService.showSuccess/Error/Warning(message)`
3. Toast s'affiche automatiquement en bas (non-bloquant)

**Exemple** : [Flux Toast](docs/Architecture/data-flow.md#4-Flux-de-notifications--Toast)

### Ajouter une page

**Steps** :
1. Créer `qml/pages/NewPage.qml` (FlickablePage)
2. Créer `qml/logic/NewLogic.qml` (QtObject)
3. Ajouter dans `Main.qml` : `NavigationItem { ... }`
4. Documenter dans `docs/pages/README.md`

**Checklist** :
- [ ] Page hérite de FlickablePage
- [ ] Logic hérite de QtObject
- [ ] Propriétés readonly pour exposition
- [ ] Signaux pour communication
- [ ] Connections vers signaux
- [ ] Documentation inline
- [ ] Tests

### Optimiser la performance

**Lazy Loading** :
- [Guide](docs/Features/lazy-loading.md) - Chargement images au scroll

**Image Optimization** :
- [Guide](docs/Features/image-optimization.md) - Gestion mémoire

**Responsive** :
- [Guide](docs/Features/responsive-design.md) - Breakpoints multi-écrans

### Créer un composant réutilisable

**Steps** :
1. Lire [Components guidelines](docs/Components/guidelines.md)
2. Utiliser [PosterImage](docs/Components/PosterImage.md) comme référence
3. Respecter structure MVC (pas de logique métier)
4. Exposer API claire via propriétés
5. Documenter propriétés et signaux
6. Ajouter tests

**Checklist** : Voir [guidelines checklist](docs/Components/guidelines.md#checklist-création-composant)

---

## 📊 État du projet v1.2

### Implémenté ✅

**Architecture & Patterns**
- ✅ Architecture MVC complète (Model/Logic/View)
- ✅ Singleton Pattern pour état global (FilmDataSingletonModel)
- ✅ Services globaux (ToastService) 
- ✅ Pattern Singleton hybride pour toasts 

**Composants UI**
- ✅ PosterImage avec lazy loading
- ✅ ToastService + ToastManager + ToastDelegate 
- ✅ Bottom Navigation
- ✅ NavigationStack pour détails

**Pages**
- ✅ CataloguePage avec grille responsive
- ✅ FilmDetailPage avec navigation 
- ✅ Lazy loading images au scroll

**Données & Services**
- ✅ FilmDataSingletonModel (état global)
- ✅ FilmService (API Django REST)
- ✅ Gestion d'erreurs complète
- ✅ Notifications Toast 

**Logic Controllers**
- ✅ CatalogueLogic
- ✅ FilmDetailLogic 
- ✅ Propriétés readonly et privées 

**Documentation**
- ✅ Architecture documentation
- ✅ Components documentation
- ✅ Services documentation 
- ✅ Data flow documentation 
- ✅ Guidelines & patterns

### En développement 🔄

- 🔄 Recherche IMDb (intégration API IMDb)
- 🔄 Filtres avancés (catégories, réalisateur, acteurs)
- 🔄 Responsive design (breakpoints desktop/tablet)

### Planifié 🚀 (Futures versions)

- ⏳ Mode hors ligne (cache local SQLite)
- ⏳ Synchronisation (sync/conflict resolution)
- ⏳ Authentification (JWT backend)
- ⏳ Favoris (gestion favoris persistants)
- ⏳ Analytics (tracking utilisateur)

---

## 📞 Support & Conventions

### Conventions de nommage

```
Files:     PascalCase.qml        # Composant/Page/Logic
Folders:   lowercase/            # Groupes logiques
Properties: camelCase            # proprietes
Functions: camelCase()           # fonctions
Signals:   camelCase()           # signaux (sans ())
IDs:       camelCase             # ids internes
Constants: SCREAMING_SNAKE_CASE  # constantes

Private:   _privateProperty      # Préfixe underscore
Readonly:  readonly property     # Exposition contrôlée
```

### Standards de code

- [Standards](docs/Development/coding-standards.md) - Conventions QML
- JSDoc style comments pour functions
- Documentation inline obligatoire
- Tests unitaires recommandés

### Debug & Troubleshooting

- [Debug guide](docs/Development/debugging.md) - Techniques debugging
- `console.log()` avec tags pour structuriser logs
- Utiliser émulateur Felgo pour multi-plateforme

---

## 📂 Structure du projet

```
Cinevault/
├── qml/
│   ├── model/               # État global (Singleton)
│   │   └── FilmDataSingletonModel.qml
│   ├── services/            # Services API & globaux 
│   │   ├── FilmService.qml
│   │   └── ToastService.qml
│   ├── logic/               # Controllers
│   │   ├── CatalogueLogic.qml
│   │   └── FilmDetailLogic.qml 
│   ├── pages/               # Vues
│   │   ├── CataloguePage.qml
│   │   └── FilmDetailPage.qml 
│   ├── components/          # Composants réutilisables
│   │   ├── PosterImage.qml
│   │   ├── ToastManager.qml 
│   │   └── ToastDelegate.qml 
│   └── Main.qml
├── docs/                    # Documentation
│   ├── Architecture/
│   ├── Components/
│   ├── Pages/
│   ├── Data/
│   ├── Logic/
│   ├── Services/ 
│   ├── Features/
│   └── Development/
└── README.md               # Ce fichier
```

---

## 🔗 Ressources externes

- [Felgo Documentation](https://felgo.com/doc/) - Framework officiel
- [Qt Quick](https://doc.qt.io/qt-6/qtquick-index.html) - Qt Quick docs
- [Material Design 3](https://m3.material.io/) - Design system
- [Django REST Framework](https://www.django-rest-framework.org/) - Backend

---

## 📝 License & Auteur

**Cinevault APP** - Projet académique  
**Version** : v1.2 (28 octobre 2025)  
**Framework** : Felgo 4 (Qt/QML)  
**Backend** : Django REST Framework  
**Database** : SQLite  
