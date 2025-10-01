import Felgo 4.0
import QtQuick 2.15
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

    // En-tête simple et épuré
    Rectangle {
        id: headerSection
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: dp(16)
        height: dp(60)
        radius: dp(8)
        color: Theme.colors.backgroundColor

        AppText {
            anchors.centerIn: parent
            text: "Mon Catalogue"
            // text: "Debug: " + (FilmDataSingletonModel ? "Model OK" : "Model NULL") +
            //       " | Colonnes: " + columns + " | Largeur: " + Math.round(cellWidth)
            font.pixelSize: sp(18)
            font.bold: true
            wrapMode: Text.WordWrap
            color: Theme.colors.textColor

            Component.onCompleted: {
                console.log("=== DEBUG CataloguePage - Rectangle - AppText ===")
                console.log("Colonnes calculées:", columns)
                console.log("Largeur cellule:", cellWidth)
                console.log(" ")
            }
        }
    }

    GridView {
        id: filmGridView
        anchors.top: headerSection.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: dp(16)
        anchors.topMargin: dp(8)
        // anchors.fill: parent

        // Utilisation des propriétés calculées
        cellWidth: cataloguePage.cellWidth + itemSpacing
        cellHeight: cataloguePage.cellHeight + itemSpacing  // Utilise le nouveau calcul

        model: FilmDataSingletonModel && FilmDataSingletonModel.films ? FilmDataSingletonModel.films : []

        delegate: Rectangle {
            width: cataloguePage.cellWidth  // Largeur dynamique
            height: cataloguePage.cellHeight - dp(4) // Petite marge interne
            radius: dp(4)
            color: Theme.colors.backgroundColor
            border.color: Theme.colors.dividerColor
            border.width: dp(0.5)


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
