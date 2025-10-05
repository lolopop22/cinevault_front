import QtQuick 2.15
import Felgo 4.0
import "../model" as Model

Item {
    id: catalogueLogic

    // Indicateur d’état de chargement
    property bool loading: false

    // Signal pour propager les erreurs à la vue
    signal errorOccurred(string message)

    // Instance du service HTTP
    Model.FilmService {
        id: filmService
    }

    // Connexion explicite aux signaux du service
    Connections {
        target: filmService

        // Traitement du résultat positif
        function onFilmsFetched(films) {
            loading = false
            Model.FilmDataSingletonModel.films = films.map(function(f) {
                return {
                    id: f.id,
                    title: f.title,
                    poster_url: f.poster_url
                }
            })
        }

        // Gestion des erreurs
        function onFetchError(errorMessage) {
            loading = false
            errorOccurred(errorMessage)
        }
    }

    /**
     * Déclenche la récupération des films et affiche le loader
     */
    function refreshCatalogue() {
        loading = true
        filmService.fetchAllFilms()
    }

    // Chargement initial à l’affichage de la page
    Component.onCompleted: refreshCatalogue()

}
