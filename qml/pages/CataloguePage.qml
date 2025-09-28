import Felgo 4.0
import QtQuick 2.15

AppPage {
    id: cataloguePage
    title: "Mon Catalogue"

    property var filmDataModel: null

    AppText {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: dp(20)
        text: "Debug: " + (filmDataModel ? "Model OK" : "Model NULL")
        // text: filmDataModel
        font.pixelSize: sp(16)

        Component.onCompleted: {
            console.log("=== DEBUG CataloguePage - AppText ===")
            console.log("filmDataModel:", filmDataModel)
            if (filmDataModel) {
                console.log("filmDataModel.films:", filmDataModel.films)
                if (filmDataModel.films) {
                    console.log("films.length:", filmDataModel.films.length)
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

        model: filmDataModel && filmDataModel.films ? filmDataModel.films : []

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
            console.log("filmDataModel:", filmDataModel)
            if (filmDataModel) {
                console.log("filmDataModel.films:", filmDataModel.films)
                if (filmDataModel.films) {
                    console.log("films.length:", filmDataModel.films.length)
                }
            }
            console.log(" ")
        }
    }

    Component.onCompleted: {
        console.log("=== DEBUG CataloguePage ===")
        console.log("filmDataModel:", filmDataModel)
        if (filmDataModel) {
            console.log("filmDataModel.films:", filmDataModel.films)
            if (filmDataModel.films) {
                console.log("films.length:", filmDataModel.films.length)
            }
        }
        console.log(" ")
    }
}
