pragma Singleton
import Felgo 4.0
import QtQuick 2.15

Item {
    // Utilisation du Singleton Pattern

    id: filmDataSingletonModel
    readonly property alias films: internal.films

    // État de chargement initial
    readonly property bool isLoading: internal.isLoading
    readonly property alias lastError: internal.lastError

    QtObject {
        id: internal

        property bool isLoading: false
        property bool hasRealData: false     // ← Indique si on a des vraies données API
        property string lastError: ""        // ← Dernière erreur rencontrée

        // Données de test
        property var testFilms: [
            { id: 1, title: "Avatar", poster_url: "https://image.tmdb.org/t/p/w342/jRXYjXNq0Cs2TcJjLkki24MLp7u.jpg" },
            { id: 2, title: "Avengers: Endgame", poster_url: "https://image.tmdb.org/t/p/w342/or06FN3Dka5tukK1e9sl16pB3iy.jpg" },
            { id: 3, title: "Spider-Man: No Way Home", poster_url: "https://image.tmdb.org/t/p/w342/1g0dhYtq4irTY1GPXvft6k4YLjm.jpg" },
            { id: 4, title: "Test Erreur", poster_url: "https://invalid-url.com/notfound.jpg" },
            { id: 5, title: "Pas d'image", poster_url: "" },
            { id: 6, title: "Timout test", poster_url: "https://httpbin.org/delay/10" },
            { id: 7, title: "Spider-man", poster_url: "https://image.tmdb.org/t/p/w342/1g0dhYtq4irTY1GPXvft6k4YLjm.jpg" },
            { id: 8, title: "URL invalide", poster_url: "https://invalid-domain-test.xyz/notfound.jpg" },
            { id: 9, title: "Interstellar", poster_url: "https://image.tmdb.org/t/p/w342/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg" },
            { id: 10, title: "The Dark Knight", poster_url: "https://image.tmdb.org/t/p/w342/qJ2tW6WMUDux911r6m7haRef0WH.jpg" },
            { id: 11, title: "Pulp Fiction", poster_url: "https://image.tmdb.org/t/p/w342/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg" },
            { id: 12, title: "The Matrix", poster_url: "blue" },
            { id: 13, title: "Forrest Gump", poster_url: "red" },
            { id: 14, title: "Gladiator", poster_url: "yellow" }
        ]

        // Films actuels (vide au départ, rempli par l'API)
        property var films: []  // ← Vide au démarrage !
    }

    /**
     * Met à jour les films depuis l'API et marque comme "vraies données"
     */
    function updateFromAPI(newFilms) {
        internal.films = newFilms
        internal.isLoading = false
        internal.lastError = ""
        console.log("Films mis à jour depuis l'API:", newFilms.length, "films chargés")
    }

    /**
     * Gère une erreur de chargement
     */
    function setError(errorMessage) {
        internal.isLoading = false
        internal.lastError = errorMessage
        // En cas d'erreur, on peut optionnellement garder les films existants
        // ou utiliser les données de test comme fallback
        console.log("Erreur de chargement:", errorMessage)
    }

    /**
     * Démarre le chargement
     */
    function startLoading() {
        internal.isLoading = true
        internal.lastError = ""
        console.log("Démarrage du chargement des films...")
    }

    /**
     * Utilise les données de test (pour développement/fallback)
     */
    function useTestData() {
        internal.films = internal.testFilms
        internal.isLoading = false
        console.log("Utilisation des données de test:", internal.testFilms.length, "films")
    }

    Component.onCompleted: {
        console.log("=== DEBUG FilmDataModel ===")
        console.log("FilmDataSingleton initialisé - films:", films.length)
        console.log("En attente de chargement API...")
        console.log(" ")
    }
}
