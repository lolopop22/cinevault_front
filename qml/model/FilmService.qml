// qml/model/FilmService.qml
import QtQuick 2.15
import Felgo 4.0

// QtObject dédié aux appels réseau pour les films
QtObject {

    // Signaux émis en cas de succès ou d’erreur
    signal filmsFetched(var films)
    signal fetchError(string errorMessage)

    /**
     * Récupère la liste de tous les films depuis l’API REST.
     * Émet filmsFetched(JSON) ou fetchError(message).
     */
    function fetchAllFilms() {
        var request = new HttpRequest();
        request.url = "https://localhost:8000/api/movies/";
        request.method = "GET";
        request.send();
        request.onCompleted.connect(function(response) {
            if (request.status === 200) {
                try {
                    filmsFetched(JSON.parse(response));
                } catch(e) {
                    fetchError("Réponse JSON invalide");
                }
            } else {
                fetchError("Erreur HTTP : " + request.status);
            }
        });
        request.onError.connect(function() {
            fetchError("Échec de connexion au serveur");
        });
    }
}
