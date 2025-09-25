import Felgo 4.0
import QtQuick 2.15
import "../model" as Model


AppPage {
    id: cataloguePage
    title: "Catalogue"

    Rectangle {
        width: parent.width
        height: parent.height
        // color: "red"

        GridView {
            id: filmGridView
            width: parent.width
            height: parent.height

            cellWidth: parent.width / 3 // Ajustement pour avoir 3 colonnes
            cellHeight: 280
            anchors.top: parent.top
            anchors.margins: 0 // Espacement des bords supérieur et inférieur
            anchors.topMargin: 10

            model: Model.FilmDataModel {}

            clip: true // Pour s'assurer que les éléments ne débordent pas

            delegate: Item {
                width: filmGridView.cellWidth
                height: filmGridView.cellHeight

                Column {
                    spacing: 6 // espacement vertical interne entre les éléments
                    anchors.fill: parent // S'assure que la colonne utilise tout l'espace

                    // Image {
                    //     source: model.posterUrl
                    //     width: parent.width
                    //     height: parent.height * 0.8 // 80% de l'élément pour l'affiche
                    //     fillMode: Image.PreserveAspectFit
                    //     horizontalAlignment: Image.AlignHCenter
                    // }


                    Rectangle {
                        width: parent.width * 0.9 // Utilisation partielle de l'espace horizontal
                        height: parent.height * 0.86
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: model.color

                        // Debug : Vérifier que chaque élément Coloré s'initialise
                        Component.onCompleted: console.log("Rectangle Color Loaded: " + model.color)

                    }

                    Text {
                        text: model.title
                        width: parent.width * 0.9 // Ajustement proportionnel à l'élément
                        // width: parent.width - 20
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        font.bold: true
                        // color: "white"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: 0

                        // Debug : Vérifier que chaque titre est assigné
                        Component.onCompleted: console.log("Title Loaded: " + model.title)
                    }
                }
            }
        }
    }
}

