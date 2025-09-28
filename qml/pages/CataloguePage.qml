import Felgo 4.0
import QtQuick 2.15
import "../model"

AppPage {
    id: cataloguePage
    title: "Mon Catalogue"

    // plus besoin de passer par ceci pour le moment dorénavant car le modèle sera accessible
    // via import. On utilise dorénavant le pattern Singleton
    // property var filmDataModel: null

    AppText {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: dp(20)
        text: "Debug: " + (FilmDataSingletonModel ? "Model OK" : "Model NULL")
        // text: filmDataModel
        font.pixelSize: sp(16)

        Component.onCompleted: {
            console.log("=== DEBUG CataloguePage - AppText ===")
            console.log("filmDataModel:", FilmDataSingletonModel)
            if (FilmDataSingletonModel) {
                console.log("FilmDataSingleton.films:", FilmDataSingletonModel.films)
                if (FilmDataSingletonModel.films) {
                    console.log("films.length:", FilmDataSingletonModel.films.length)
                }
            }
            console.log(" ")
        }
    }

    GridView {
        anchors.fill: parent
        anchors.margins: dp(20)
        anchors.topMargin: dp(60)

        cellWidth: dp(120)
        cellHeight: dp(60)

        model: FilmDataSingletonModel && FilmDataSingletonModel.films ? FilmDataSingletonModel.films : []

        delegate: Rectangle {
            width: dp(110)
            height: dp(50)
            color: "lightblue"
            border.color: "blue"

            Text {
                anchors.centerIn: parent
                text: modelData ? modelData.title : "ERROR"
                font.pixelSize: 10
            }
        }

        Component.onCompleted: {
            console.log("=== DEBUG CataloguePage - GridView ===")
            console.log("FilmDataSingleton:", FilmDataSingletonModel)
            if (FilmDataSingletonModel) {
                console.log("filmDataModel.films:", FilmDataSingletonModel.films)
                if (FilmDataSingletonModel.films) {
                    console.log("films.length:", FilmDataSingletonModel.films.length)
                }
            }
            console.log(" ")
        }
    }

    Component.onCompleted: {
        console.log("=== DEBUG CataloguePage ===")
        console.log("filmDataModel:", FilmDataSingletonModel)
        if (FilmDataSingletonModel) {
            console.log("filmDataModel.films:", FilmDataSingletonModel.films)
            if (FilmDataSingletonModel.films) {
                console.log("films.length:", FilmDataSingletonModel.films.length)
            }
        }
        console.log(" ")
    }
}
