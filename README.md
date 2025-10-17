# Cinevault APP - Documentation

## Vue d'ensemble
Application multi-plateforme de gestion de catalogue de films développée avec Felgo 4.

---

## 📚 Organisation de la documentation

### Architecture
Comprenez la structure globale de l'application
- [Vue d'ensemble](docs/Architecture/overview.md) - Schémas et composants principaux
- [Pattern MVC](docs/Architecture/mvc-pattern.md) - Adaptation MVC pour QML/Felgo
- [Flux de données](docs/Architecture/data-flow.md) - Diagrammes de séquence détaillés

### Composants
Éléments réutilisables de l'interface utilisateur
- [Guide des composants](docs/Components/README.md) - Principes et conventions
- [PosterImage](docs/Components/PosterImage.md) - Affichage optimisé des posters
- [Guidelines](docs/Components/guidelines.md) - Créer de nouveaux composants

### Pages et Navigation
Pages principales de l'application
- [Pages principales](docs/Pages/README.md) - Index et navigation
- [CataloguePage](docs/Pages/CataloguePage.md) - Grille de films avec lazy loading
- [Navigation système](docs/Pages/navigation.md) - Bottom Navigation et flux

### Modèle de Données (Model)
Gestion de l'état global et communication réseau
- [Vue d'ensemble Model](docs/Data/README.md) - Principes et patterns
- [FilmDataSingletonModel](docs/Data/FilmDataSingletonModel.md) - État global Singleton
- [FilmService](docs/Data/FilmService.md) - Service API REST Django

### Logique Métier (Logic)
Contrôleurs orchestrant Model et Vue
- [Vue d'ensemble Logic](docs/Logic/README.md) - Rôle des contrôleurs
- [CatalogueLogic](docs/Logic/CatalogueLogic.md) - Orchestration du catalogue

### Fonctionnalités avancées
Features et optimisations spécifiques
- [Lazy Loading](docs/Features/lazy-loading.md) - Chargement optimisé des images
- [Optimisation images](docs/Features/image-optimization.md) - Gestion mémoire et performance
- [Gestion d'erreurs](docs/Features/error-handling.md) - Patterns de résilience
- [Responsive design](docs/Features/responsive-design.md) - Adaptation multi-écrans

## Développement
- [Configuration](docs/Development/setup.md)
- [Standards de code](docs/Development/coding-standards.md)
- [Debug](docs/Development/debugging.md)

---

## 🚀 Démarrage rapide

### Overview
1. [Architecture overview](docs/Architecture/overview.md) - Vue d'ensemble
2. [Pattern MVC](docs/Architecture/mvc-pattern.md) - Comprendre la structure
3. [Setup guide](docs/Development/setup.md) - Configurer l'environnement
4. [Coding standards](docs/Development/coding-standards.md) - Conventions

### Pour créer un composant
1. [Components guidelines](docs/Components/guidelines.md) - Template et checklist
2. [PosterImage](docs/Components/PosterImage.md) - Exemple de référence
3. Suivre les conventions de nommage et structure

### Pour ajouter une fonctionnalité
1. [Pattern MVC](docs/Architecture/mvc-pattern.md) - Respecter l'architecture
2. [Data flow](docs/Architecture/data-flow.md) - Comprendre les flux
3. Créer Logic + Service si nécessaire
4. Tester et documenter

---

## 📖 Index par rôle

### Frontend
- [Components](docs/Components/README.md)
- [Pages](docs/Pages/README.md)
- [Responsive design](docs/Features/responsive-design.md)

### Backend
- [FilmService](docs/Data/FilmService.md)
- [API integration](docs/Data/README.md#communication-entre-composants)

### Architecte
- [Architecture overview](docs/Architecture/overview.md)
- [MVC pattern](docs/Architecture/mvc-pattern.md)
- [Data flow](docs/Architecture/data-flow.md)

### QA / Testeur
- [Testing guide](docs/Development/testing.md)
- [Error handling](docs/Features/error-handling.md)

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
1. [Lazy loading](docs/Features/lazy-loading.md)
2. [Image optimization](docs/Features/image-optimization.md)

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
