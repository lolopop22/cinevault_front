import Felgo 4.0
import QtQuick 2.15
import "../model" as Model


AppPage {
    id: cataloguePage
    title: "Mon Catalogue"

    // Références aux composants globaux
    property var filmDataModel

    // AppFlickable est utilisé ici pour permettre le défilement
    AppFlickable {
        id: flickable
        // width: parent.width
        // height: parent.height
        anchors.fill: parent

        // Définit la taille du contenu visible; le défilement assure que tout est consultable
        // contentHeight: dp(350) // Ajustez cette valeur pour s'adapter à votre contenu
        contentHeight: content.height
        contentWidth: parent.width

        Component.onCompleted: console.log("AppFlickable Loaded")

        Column {
            id: content
            width: parent.width
            spacing: dp(16)

            Component.onCompleted: console.log("Column Loaded")

            Item {
                width: parent.width
                height: dp(60)

                AppText {
                    anchors.centerIn: parent
                    text: "Catalogue de Films"
                    font.pixelSize: sp(24)
                    color: Theme.colors.textColor
                }
            }

            AppText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: filmDataModel ?
                      "Films disponibles : " + (filmDataModel.films ? filmDataModel.films.length : 0) :
                      "Chargement du modèle..."
                font.pixelSize: sp(18)
                color: Theme.colors.secondaryTextColor
            }

            // Placeholder pour la future liste de films
            Rectangle {
                width: parent.width - dp(32)
                height: dp(200)
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.colors.backgroundColor
                border.color: Theme.colors.dividerColor
                border.width: dp(1)
                radius: dp(8)

                AppText {
                    anchors.centerIn: parent
                    text: "Zone d'affichage des films\n(Spécification 2)"
                    horizontalAlignment: Text.AlignHCenter
                    color: Theme.colors.disabledColor
                }
            }

        }
    }

}
