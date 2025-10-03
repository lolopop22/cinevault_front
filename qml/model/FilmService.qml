// qml/model/FilmService.qml
import QtQuick 2.15
import Felgo 4.0

QtObject {
    signal filmsFetched(var films)
    signal fetchError(string errorMessage)

    function fetchAllFilms() {
        var request = new HttpRequest();
        request.url = "https://api.monapp.com/films/";
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
