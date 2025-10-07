import QtQuick 2.15
import Felgo 4.0
import "../model" as Model

Item {
    id: catalogueLogic

    // Propriétés exposées à la vue
    readonly property bool loading: Model.FilmDataSingletonModel.isLoading        // Indicateur d’état de chargement
    property bool hasData: Model.FilmDataSingletonModel.films && Model.FilmDataSingletonModel.films.length > 0
    readonly property string errorMessage: Model.FilmDataSingletonModel.lastError
    readonly property int filmCount: Model.FilmDataSingletonModel.films.length

    // Signal pour propager les erreurs à la vue
    signal errorOccurred(string message)

    // Instance du service HTTP
    Model.FilmService {
        id: filmService
        apiUrl: "https://localhost:8000/api"
    }

    // Connexion explicite aux signaux du service
    Connections {
        target: filmService

        // Traitement du résultat positif à la réception du signal
        function onFilmsFetched(films) {
            Model.FilmDataSingletonModel.updateFromAPI(
                films.map(function(f) {
                    return {
                        id: f.id,
                        title: f.title,
                        poster_url: f.poster_url
                    }
                })
            )
        }

        // Gestion des erreurs
        function onFetchError(errorMessage) {
            Model.FilmDataSingletonModel.setError(errorMessage)
            errorOccurred(errorMessage)
        }
    }

    // Timer {
    //     id: refreshTimer
    //     interval: 30000   // Délai en ms (ici 0,8 seconde)
    //     repeat: false
    //     onTriggered: {
    //         Model.FilmDataSingletonModel.startLoading();
    //         filmService.fetchAllFilms();
    //     }
    // }

    /**
     * Déclenche la récupération des films et affiche le loader
     */
    /**
     * Lance le chargement des films depuis l'API
     */
    function refreshCatalogue() {
        Model.FilmDataSingletonModel.startLoading()
        filmService.fetchAllFilms()
        // refreshTimer.start();
    }

    /**
     * Utilise les données de test (pour développement)
     */
    function useTestData() {
        Model.FilmDataSingletonModel.useTestData()
        // Forcer une mise à jour immédiate
        filmCount = Model.FilmDataSingletonModel.films.length
        hasData = filmCount > 0
        errorMessage = ""
    }

    // Chargement automatique au démarrage
    Component.onCompleted: {
        // Charger depuis l'API
        // Qt.callLater(refreshCatalogue)

        // Utiliser les données de test (pour développement)
        Qt.callLater(useTestData)
    }

    // Chargement initial à l’affichage de la page
    // Component.onCompleted: refreshCatalogue()

}
