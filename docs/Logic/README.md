# Dossier logic - Cinevault APP

Ce dossier contient les **contrôleurs** (Logic) de l’application, responsables de l’orchestration entre les Pages (View) et le Modèle (FilmDataSingletonModel & FilmService). Chaque fichier Logic se concentre sur une fonctionnalité.

## Structure

```
qml/logic/
├── CatalogueLogic.qml    # Contrôleur du catalogue de films
├── RechercheLogic.qml    # Contrôleur de la recherche IMDb (à implémenter)
└── qmldir                # Enregistre ces deux types QML
```

## Pattern général

1. **Import** du namespace Model et du Service.
2. **Instance** des services (ex. `FilmService`).
3. **Propriétés readonly** exposées à la vue:
   - `loading`, `hasData`, `filmCount`, `errorMessage`.
4. **Signaux** pour événements ponctuels (`errorOccurred`, `actionCompleted`).
5. **Connections** aux signaux du Service.
6. **Méthodes publiques** pour déclencher les actions (`refreshCatalogue()`, `useTestData()`).
7. **Transformations** des données reçues.
8. **Aucun élément visuel** dans le Logic.

## Import

```qml
import "../logic" as Logic
```

## Exemple d'utilisation

```qml
AppPage {
    Logic.CatalogueLogic { id: logic }

    Component.onCompleted: logic.refreshCatalogue()

    BusyIndicator { visible: logic.loading }
    GridView { model: Model.FilmDataSingletonModel.films }
    Button { text: "Rafraîchir"; onClicked: logic.refreshCatalogue() }

    Connections { target: logic; onErrorOccurred: errorModal.open() }

    AppModal { id: errorModal; Text { text: logic.errorMessage } }
}
```
