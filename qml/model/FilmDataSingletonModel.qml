pragma Singleton
import Felgo 4.0
import QtQuick 2.15

Item {
    // Utilisation du Singleton Pattern

    id: filmDataSingletonModel
    readonly property alias films: internal.films

    Item {
        id: internal
        property var films: [
            { id: 1, title: "Avatar", poster_url: "blue" },
            { id: 2, title: "Avengers: Endgame", poster_url: "red" },
            { id: 3, title: "Spider-Man: No Way Home", poster_url: "yellow" },
            { id: 4, title: "Black Panther", poster_url: "blue" },
            { id: 5, title: "Inception", poster_url: "red" },
            { id: 6, title: "The Dark Knight", poster_url: "yellow" },
            { id: 7, title: "Interstellar", poster_url: "blue" },
            { id: 8, title: "Joker", poster_url: "red" },
            { id: 9, title: "Pulp Fiction", poster_url: "yellow" },
            { id: 10, title: "The Matrix", poster_url: "blue" },
            { id: 11, title: "Forrest Gump", poster_url: "red" },
            { id: 12, title: "Gladiator", poster_url: "yellow" }
        ]
    }

    Component.onCompleted: {
        console.log("=== DEBUG FilmDataModel ===")
        console.log("FilmDataSingleton initialisé avec", films.length, "films populaires")
        console.log(" ")
    }
}
