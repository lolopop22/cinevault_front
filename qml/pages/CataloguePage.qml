import Felgo 4.0
import QtQuick 2.15
import "../model/FilmDataModel.qml" as FilmModel


AppPage {
    id: cataloguePage
    title: "Catalogue"

    Rectangle {
        width: parent.width
        height: parent.height

        GridView {
            id: filmGridView
            anchors.fill: parent
            model: FilmModel
            cellWidth: 120
            cellHeight: 180
            clip: true // Pour s'assurer que les éléments ne débordent pas

            delegate: Item {
                width: filmGridView.cellWidth
                height: filmGridView.cellHeight
                Column {
                    spacing: 4

                    Image {
                        source: model.posterUrl
                        width: parent.width
                        height: parent.height * 0.8 // 80% de l'élément pour l'affiche
                        fillMode: Image.PreserveAspectFit
                        horizontalAlignment: Image.AlignHCenter
                    }

                    Text {
                        text: model.title
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        font.bold: true
                        color: "white" // Ou choisissez la couleur adaptée
                    }
                }
            }
        }
    }
}

