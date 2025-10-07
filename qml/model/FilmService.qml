// qml/model/FilmService.qml
import QtQuick 2.15
import Felgo 4.0

// QtObject dédié aux appels réseau pour les films
QtObject {

    // Signaux émis en cas de succès ou d’erreur
    signal filmsFetched(var films)
    signal fetchError(string errorMessage)

    // Propriété (paramétrable)
    property string apiUrl: "https://localhost:8000/api"

    /**
     * Récupère la liste de tous les films depuis l’API REST.
     * Émet filmsFetched(JSON) ou fetchError(message).
     */
    function fetchAllFilms() {
        let url = apiUrl + "/movies/";
        HttpRequest.get(url)
        .then(function(res) {
            try {
                filmsFetched(JSON.parse(response));
            } catch(e) {
                // Gestion JSON invalide
                fetchError("Réponse JSON invalide");
                console.warn("Erreur de parsing JSON:", e)
            }
        })
        .catch(function(error) {
            fetchError("Erreur HTTP et/ou Échec de connexion au serveur : " + error);
            console.error("Erreur récupération films:", error)
        })
    }
}
