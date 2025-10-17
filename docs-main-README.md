# Cinevault APP - Documentation

## Vue d'ensemble
Application multi-plateforme de gestion de catalogue de films développée avec Felgo 4.

---

## 📚 Organisation de la documentation

### Architecture
Comprenez la structure globale de l'application
- [Vue d'ensemble](architecture/overview.md) - Schémas et composants principaux
- [Pattern MVC](architecture/mvc-pattern.md) - Adaptation MVC pour QML/Felgo
- [Flux de données](architecture/data-flow.md) - Diagrammes de séquence détaillés

### Composants
Éléments réutilisables de l'interface utilisateur
- [Guide des composants](components/README.md) - Principes et conventions
- [PosterImage](components/PosterImage.md) - Affichage optimisé des posters
- [Guidelines](components/guidelines.md) - Créer de nouveaux composants

### Pages et Navigation
Pages principales de l'application
- [Pages principales](pages/README.md) - Index et navigation
- [CataloguePage](pages/CataloguePage.md) - Grille de films avec lazy loading
- [Navigation système](pages/navigation.md) - Bottom Navigation et flux

### Modèle de Données (Model)
Gestion de l'état global et communication réseau
- [Vue d'ensemble Model](data/README.md) - Principes et patterns
- [FilmDataSingletonModel](data/FilmDataSingletonModel.md) - État global Singleton
- [FilmService](data/FilmService.md) - Service API REST Django

### Logique Métier (Logic)
Contrôleurs orchestrant Model et Vue
- [Vue d'ensemble Logic](logic/README.md) - Rôle des contrôleurs
- [CatalogueLogic](logic/CatalogueLogic.md) - Orchestration du catalogue

### Fonctionnalités avancées
Features et optimisations spécifiques
- [Lazy Loading](features/lazy-loading.md) - Chargement optimisé des images
- [Optimisation images](features/image-optimization.md) - Gestion mémoire et performance
- [Gestion d'erreurs](features/error-handling.md) - Patterns de résilience
- [Responsive design](features/responsive-design.md) - Adaptation multi-écrans

### Développement
Guides pour développeurs
- [Configuration](development/setup.md) - Installation et environnement
- [Standards de code](development/coding-standards.md) - Conventions QML/Felgo
- [Tests](development/testing.md) - Stratégie de tests
- [Debug](development/debugging.md) - Outils et techniques

### Déploiement
Build et distribution
- [Build process](deployment/build.md) - Compilation multi-plateformes
- [Plateformes](deployment/platforms.md) - iOS, Android, Windows, macOS
- [Performance](deployment/performance.md) - Optimisations production

---

## 🚀 Démarrage rapide

### Pour nouveaux développeurs
1. [Architecture overview](architecture/overview.md) - Vue d'ensemble
2. [Pattern MVC](architecture/mvc-pattern.md) - Comprendre la structure
3. [Setup guide](development/setup.md) - Configurer l'environnement
4. [Coding standards](development/coding-standards.md) - Conventions

### Pour créer un composant
1. [Components guidelines](components/guidelines.md) - Template et checklist
2. [PosterImage](components/PosterImage.md) - Exemple de référence
3. Suivre les conventions de nommage et structure

### Pour ajouter une fonctionnalité
1. [Pattern MVC](architecture/mvc-pattern.md) - Respecter l'architecture
2. [Data flow](architecture/data-flow.md) - Comprendre les flux
3. Créer Logic + Service si nécessaire
4. Tester et documenter

---

## 📖 Index par rôle

### Frontend
- [Components](components/README.md)
- [Pages](pages/README.md)
- [Responsive design](features/responsive-design.md)

### Backend
- [FilmService](data/FilmService.md)
- [API integration](data/README.md#communication-entre-composants)

### Architecte
- [Architecture overview](architecture/overview.md)
- [MVC pattern](architecture/mvc-pattern.md)
- [Data flow](architecture/data-flow.md)

### QA / Testeur
- [Testing guide](development/testing.md)
- [Error handling](features/error-handling.md)

---

## 🎯 Guides par tâche

### Afficher des données
1. Ajouter propriétés dans `FilmDataSingletonModel`
2. Créer/modifier service pour récupérer données
3. Créer/modifier Logic pour orchestration
4. Binder données dans la Vue

### Ajouter une page
1. Créer fichier dans `qml/pages/`
2. Créer Logic associé dans `qml/logic/`
3. Ajouter dans `Main.qml` NavigationItem
4. Documenter dans `docs/pages/`

### Optimiser performance
1. [Lazy loading](features/lazy-loading.md)
2. [Image optimization](features/image-optimization.md)
3. [Performance guide](deployment/performance.md)

---

## 🔗 Références externes

- [Documentation Felgo](https://felgo.com/doc/)
- [Qt Quick Best Practices](https://doc.qt.io/qt-6/qtquick-bestpractices.html)
- [Material Design](https://material.io/)
- [Django REST Framework](https://www.django-rest-framework.org/)

---

## 📝 Conventions

### Nommage fichiers
- **QML** : PascalCase (ex: `CataloguePage.qml`)
- **Documentation** : kebab-case (ex: `lazy-loading.md`)
- **IDs** : camelCase (ex: `id: filmGrid`)

### Organisation code
```qml
// 1. Imports
// 2. Documentation
// 3. Item racine
// 4. Propriétés publiques
// 5. Signaux
// 6. Propriétés internes
// 7. Contenu visuel
// 8. Fonctions
// 9. Initialisation
```

### Messages de commit
```
feat: ajouter lazy loading au PosterImage
fix: corriger erreur chargement images
docs: documenter CatalogueLogic
perf: optimiser mémoire GridView
refactor: restructurer FilmService
```

---

## 🤝 Contribution

### Avant de commit
- [ ] Code respecte les [standards](development/coding-standards.md)
- [ ] Tests passent
- [ ] Documentation mise à jour
- [ ] Pas de warnings console
- [ ] Code review fait

### Ajouter documentation
1. Créer fichier `.md` dans dossier approprié
2. Suivre template existant
3. Ajouter lien dans README du dossier
4. Ajouter lien dans ce README principal

---

## 📊 État du projet

### Fonctionnalités implémentées
✅ Architecture MVC  
✅ Navigation Bottom Navigation  
✅ Catalogue avec grille responsive  
✅ PosterImage avec lazy loading  
✅ Chargement API avec FilmService  
✅ Gestion d'erreurs  

### En cours
🔄 Recherche IMDb 
🔄 Page détails film  
🔄 Filtres avancés  

### À venir 
⏳ Mode hors ligne  
⏳ Synchronisation  
⏳ Authentification  

---

## ❓ Support

### Problème avec la documentation ?
Créer une issue GitHub avec tag `documentation`

### Question sur l'architecture ?
Consulter [Architecture overview](architecture/overview.md) ou demander au Lead Dev

### Bug dans le code ?
Suivre le [guide debugging](development/debugging.md)

