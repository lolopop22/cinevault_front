import Felgo 4.0
import QtQuick 2.15
import Qt5Compat.GraphicalEffects
import "../logic" as Logic
import "../model" as Model

AppPage {
    id: cataloguePage
    title: "Mon Catalogue"

    // Taille fixe des cartes (ne changent plus avec la fenêtre)
    readonly property real fixedCardWidth: dp(100)    // Largeur fixe des cartes
    readonly property real itemSpacing: dp(0)         // Espacement fixe

    // Ajout du ratio d'affiche cinéma
    readonly property real posterAspectRatio: 1.5  // Hauteur = largeur * 1.5 (ratio 2:3)
    readonly property real titleHeight: dp(35)     // Espace réservé pour le titre

    // Calcul dynamique du nombre de colonnes, ajoutant une colonne si possible
    readonly property int columns: {
        var availableWidth = width - dp(16)  // marge totale gauche/droite
        var cardWithSpacing = fixedCardWidth + itemSpacing
        var maxColumns = Math.floor(availableWidth / cardWithSpacing)
        var leftover = availableWidth - (maxColumns * cardWithSpacing)

        // Si espace restant suffisant pour une carte, ajoute une colonne
        if (leftover >= fixedCardWidth) {
            maxColumns = Math.min(maxColumns + 1, 4)  // limite max 4 colonnes
        }
        return Math.max(1, maxColumns)  // au moins 1 colonne
    }

    readonly property real gridTotalWidth: (fixedCardWidth * columns) + (itemSpacing * (columns - 1))
    readonly property real cellHeight: (fixedCardWidth * posterAspectRatio) + titleHeight

    Logic.CatalogueLogic{
        id: logic
    }

    // // === LOGIQUE INTÉGRÉE ===
    // Logic.CatalogueLogic {
    //     id: logic
    // }


    // Header fixe au-dessus de tout
    Rectangle {
        id: fixedHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: dp(5)
        anchors.leftMargin: dp(20)
        anchors.rightMargin: dp(20)

        height: dp(60)
        radius: dp(8)
        color: Theme.colors.backgroundColor
        z: 100 // Z-index élevé pour rester au-dessus

        // Effet d'ombre pour détacher visuellement
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: dp(5)
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

        anchors.top: fixedHeader.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        // anchors.margins: dp(16)
        anchors.topMargin: dp(10) // Marge pour éviter le header

        width: gridTotalWidth
        height: parent.height - fixedHeader.height - dp(32)

        // CellWidth/Height fixes + espacement géré dans les cellules
        cellWidth: fixedCardWidth
        cellHeight: cataloguePage.cellHeight

        clip: true

        // A décommenter lorsqu'on aura de gros volume de films à afficher
        // cacheBuffer: cellHeight * 2
        // reuseItems: true

        model: Model.FilmDataSingletonModel && Model.FilmDataSingletonModel.films ? Model.FilmDataSingletonModel.films : []

        delegate: Rectangle {
            width: fixedCardWidth  // Largeur dynamique
            height: cataloguePage.cellHeight - dp(4) // Petite marge interne
            radius: dp(6)
            color: Theme.colors.backgroundColor
            border.color: Theme.colors.dividerColor
            border.width: dp(0.5)

            property real padding: dp(3)
            Column {
                anchors.fill: parent
                anchors.margins: parent.padding
                spacing: dp(4)

                // Zone affiche avec largeur FIXE
                Rectangle {
                    width: parent.width
                    height: parent.width * posterAspectRatio // Respect du ratio cinéma et utilisation de la largeur fixe
                    radius: dp(4)
                    color: {
                        var colors = ["#e3f2fd", "#f3e5f5", "#e8f5e8", "#fff3e0", "#fce4ec"]
                        return colors[index % colors.length]
                    }

                    AppText {
                        anchors.centerIn: parent
                        text: "🎬"
                        font.pixelSize: sp(20)
                    }
                }

                // Zone titre (fixe)
                AppText {
                    width: parent.width
                    height: titleHeight - dp(8)
                    text: modelData ? modelData.title : sp("?")
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
    }

    Component.onCompleted: {
        console.log("=== DEBUG CataloguePage avec cartes fixes ===")
        console.log("Colonnes:", columns)
        console.log("Largeur carte fixe:", fixedCardWidth)
        console.log("Largeur grille totale:", gridTotalWidth)
        console.log("Largeur écran:", width)
        console.log("Espace restant:", (width - gridTotalWidth - dp(32)))
        console.log("filmDataModel:", Model.FilmDataSingletonModel)
        if (Model.FilmDataSingletonModel) {
            console.log("filmDataModel.films:", Model.FilmDataSingletonModel.films)
            if (Model.FilmDataSingletonModel.films) {
                console.log("films.length:", Model.FilmDataSingletonModel.films.length)
            }
        }
    }
}
