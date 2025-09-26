import Felgo 4.0
import QtQuick 2.15


Item {
    id: filmDataModel

    QtObject {
        id: internal

        property var films: [
            {
                id: 1,
                title: "Film Rouge",
                poster_url: "red"
            },
            {
                id: 2,
                title: "Film Bleu",
                poster_url: "blue"
            },
            {
                id: 3,
                title: "Film Jaune",
                poster_url: "yellow"
            },
            {
                id: 4,
                title: "Film Rouge",
                poster_url: "red"
            },
            {
                id: 5,
                title: "Film Bleu",
                poster_url: "blue"
            },
            {
                id: 6,
                title: "Film Jaune",
                poster_url: "yellow"
            },
            {
                id: 7,
                title: "Film Rouge",
                poster_url: "red"
            },
            {
                id: 8,
                title: "Film Bleu",
                poster_url: "blue"
            },
            {
                id: 9,
                title: "Film Jaune",
                poster_url: "yellow"
            },


        ]
    }
}
