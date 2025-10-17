# CatalogueLogic

`CatalogueLogic` orchestre la récupération, la transformation et le stockage du catalogue de films.

## Localisation

```
qml/logic/CatalogueLogic.qml
```

## Propriétés exposées

| Nom           | Type   | Source                                    |
|---------------|--------|-------------------------------------------|
| loading       | bool   | `Model.FilmDataSingletonModel.isLoading`  |
| hasData       | bool   | `Model.FilmDataSingletonModel.films.length > 0` |
| filmCount     | int    | `Model.FilmDataSingletonModel.films.length` |
| errorMessage  | string | `Model.FilmDataSingletonModel.lastError`  |

## Signaux

- `errorOccurred(string message)` — émis en cas d’erreur API
- `actionCompleted()` — émis après un chargement réussi

## Méthodes publiques

- `refreshCatalogue()` :
  1. `Model.FilmDataSingletonModel.startLoading()`
  2. `filmService.fetchAllFilms()`

- `useTestData()` :
  `Model.FilmDataSingletonModel.useTestData()`

## Flux de données

1. Vue appelle `refreshCatalogue()`
2. Modèle passe `loading=true`
3. Service GET `/movies/`
4. **Succès** → `filmsFetched(films)` → transformation → `Model.updateFromAPI()` → `loading=false`
5. **Échec** → `fetchError(msg)` → `Model.setError(msg)` → `errorOccurred(msg)`

## Exemple d’intégration

```qml
import "../logic" as Logic
import "../model" as Model

Item {
    Logic.CatalogueLogic { id: logic }
    Component.onCompleted: logic.refreshCatalogue()

    BusyIndicator { visible: logic.loading }
    GridView { model: Model.FilmDataSingletonModel.films }

    Connections {
        target: logic
        onErrorOccurred: err => {
            // Affiche modal d’erreur
        }
    }
}
```

## Bonnes pratiques

- Ne pas inclure d’UI dans Logic
- Effectuer toutes les transformations ici
- La vue consomme uniquement propriétés & signaux

## Références

- [FilmDataSingletonModel](../data/FilmDataSingletonModel.md)
- [FilmService](../data/FilmService.md)
- [CataloguePage](../pages/CataloguePage.md)
