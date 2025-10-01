import Felgo 4.0
import QtQuick 2.15
import Qt5Compat.GraphicalEffects
import "../model"

AppPage {
    id: cataloguePage
    title: "Mon Catalogue"

    // plus besoin de passer par ceci pour le moment dorénavant car le modèle sera accessible
    // via import. On utilise dorénavant le pattern Singleton
    // property var filmDataModel: null

    // Propriétés pour la responsivité (optimisées pour le modèle cible)
    readonly property real minItemWidth: dp(100)   // Plus petit pour plus de films
    readonly property real maxItemWidth: dp(150)   // Limité pour éviter des cartes trop grandes
    readonly property real itemSpacing: dp(8)      // Espacement plus serré

    // Ajout du ratio d'affiche cinéma
    readonly property real posterAspectRatio: 1.5  // Hauteur = largeur * 1.5 (ratio 2:3)
    readonly property real titleHeight: dp(35)     // Espace réservé pour le titre

    // Calcul dynamique du nombre de colonnes (vise 3 colonnes comme le modèle)
    readonly property int columns: {
        var availableWidth = width - dp(32) // Marges gauche/droite
        var minColumns = 2
        var maxColumns = 4
        var calculatedColumns = Math.floor(availableWidth / (minItemWidth + itemSpacing))
        return Math.max(minColumns, Math.min(maxColumns, calculatedColumns))
    }

    // Calcul de la largeur réelle des cellules
    readonly property real cellWidth: {
        var availableWidth = width - dp(32) - ((columns - 1) * itemSpacing)
        return Math.min(maxItemWidth, availableWidth / columns)
    }

    // Calcul de la hauteur des cellules basée sur le ratio
    readonly property real cellHeight: (cellWidth * posterAspectRatio) + titleHeight

    // Header fixe au-dessus de tout
    Rectangle {
        id: fixedHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: dp(16)
        anchors.topMargin: dp(5)
        height: dp(60)
        radius: dp(8)
        color: Theme.colors.backgroundColor
        z: 100 // Z-index élevé pour rester au-dessus

        // Effet d'ombre pour détacher visuellement
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: dp(2)
            radius: dp(4)
            samples: 9
            color: Qt.rgba(0, 0, 0, 0.1)
        }

        AppText {
            anchors.centerIn: parent
            text: "Mon Catalogue"
            font.pixelSize: sp(18)
            font.bold: true
            color: Theme.colors.textColor
        }
    }

    // GridView avec margin top pour éviter le header
    GridView {
        id: filmGridView
        anchors.fill: parent
        anchors.margins: dp(16)
        anchors.topMargin: fixedHeader.height + dp(32) // Marge pour éviter le header

        // Utilisation des propriétés calculées
        cellWidth: cataloguePage.cellWidth + itemSpacing
        cellHeight: cataloguePage.cellHeight + itemSpacing  // Utilise le nouveau calcul

        model: FilmDataSingletonModel && FilmDataSingletonModel.films ? FilmDataSingletonModel.films : []

        delegate: Rectangle {
            width: cataloguePage.cellWidth  // Largeur dynamique
            height: cataloguePage.cellHeight - dp(4) // Petite marge interne
            radius: dp(6)
            color: Theme.colors.backgroundColor
            border.color: Theme.colors.dividerColor
            border.width: dp(0.5)

            Column {
                anchors.fill: parent
                anchors.margins: dp(4)
                spacing: dp(4)

                // Zone affiche (proportionnelle)
                Rectangle {
                    width: parent.width
                    height: parent.width * posterAspectRatio // Respect du ratio cinéma
                    radius: dp(4)
                    color: {
                        var colors = ["#e3f2fd", "#f3e5f5", "#e8f5e8", "#fff3e0", "#fce4ec"]
                        return colors[index % colors.length]
                    }

                    AppText {
                        anchors.centerIn: parent
                        text: "🎬"
                        font.pixelSize: sp(24)
                    }
                }

                // Zone titre (fixe)
                AppText {
                    width: parent.width
                    height: titleHeight - dp(8)
                    text: modelData ? modelData.title : "?"
                    font.pixelSize: sp(9)
                    font.bold: true
                    color: Theme.colors.textColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }
            }
        }

        Component.onCompleted: {
            console.log("=== DEBUG CataloguePage - GridView ===")
            console.log("Configuration GridView - Colonnes:", cataloguePage.columns)
            console.log("CellWidth:", cataloguePage.cellWidth)
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
        console.log("=== CataloguePage Layout Optimisé ===")
        console.log("Colonnes:", columns, "| Largeur cellule:", Math.round(cellWidth))
        console.log(" ")
    }
}
