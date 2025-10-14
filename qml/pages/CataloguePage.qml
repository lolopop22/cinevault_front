import Felgo 4.0
import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import "../logic" as Logic
import "../model" as Model
import "../components" as Components


AppPage {
    id: cataloguePage
    title: "Mon Catalogue"

    // Largeur fixe des cartes et espacement (ne changent plus avec la fenêtre)
    readonly property real fixedCardWidth: dp(100)    // Largeur fixe des cartes
    readonly property real itemSpacing: dp(0)         // Espacement fixe

    // Ratio d'affiche de cinéma (2:3) et hauteur pour le titre
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

    // Largeur totale de la grille (pour centrer si besoin)
    readonly property real gridTotalWidth: (fixedCardWidth * columns) + (itemSpacing * (columns - 1))

    // Calcul de la hauteur des cellules selon le ratio et titre
    readonly property real cellHeight: (fixedCardWidth * posterAspectRatio) + titleHeight

    // Distance en pixels avant de charger image
    // permet de déterminer l'espace tampon avan/après la zone visible du viewport de la GridView
    property real visibilityThreshold: dp(50)   // configurable

    // === LOGIQUE MÉTIER INTÉGRÉE (chargement, erreur, comptage) ===
    Logic.CatalogueLogic{
        id: logic
    }

    // === HEADER FIXE ===
    Rectangle {
        id: fixedHeader

        // Ancrages pour positionner et centrer
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

        // Texte qui affiche le nombre de films ou l’erreur
        AppText {
            anchors.centerIn: parent
            text: logic.errorMessage
                  ? "Mon Catalogue – Erreur"
                  : logic.hasData
                    ? "Mon Catalogue – " + logic.filmCount + " films"
                    : "Mon Catalogue – Aucun film"
            font.pixelSize: sp(18)
            font.bold: true
            color: Theme.colors.textColor
        }
    }

    // === INDICATEUR DE CHARGEMENT ===
    Column {
        anchors.centerIn: parent
        spacing: dp(10)
        visible: logic.loading  // ← Visible seulement pendant le chargement

        BusyIndicator {
            anchors.horizontalCenter: parent.horizontalCenter
            running: logic.loading
            width: dp(60)
            height: dp(60)
        }

        AppText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Chargement du catalogue..."
            font.pixelSize: sp(14)
            color: Theme.colors.secondaryTextColor
        }
    }

    // === GRILLE DE FILMS AVEC CLIPPING===
    // GridView avec margin top pour éviter le header
    Item {
        id: gridContainer
        clip: true                                   // Cache tout ce qui sort des limites
        anchors.top: fixedHeader.bottom
        anchors.topMargin: dp(5)                     // Marge pour éviter le header
        anchors.horizontalCenter: parent.horizontalCenter

        width: gridTotalWidth
        height: parent.height - fixedHeader.height - dp(0)

        GridView {
            id: filmGridView
            anchors.fill: parent

            // CellWidth/Height fixes
            cellWidth: fixedCardWidth              // Cartes largeur fixe
            cellHeight: cataloguePage.cellHeight   // Hauteur calculée

            model: Model.FilmDataSingletonModel && Model.FilmDataSingletonModel.films ? Model.FilmDataSingletonModel.films : []

            // ← CONDITION : visible seulement si pas en chargement ET qu'il y a des films
            visible: !logic.loading && Model.FilmDataSingletonModel.films.length > 0

            // Propriétés pour lazy loading
            property real itemHeight: cellHeight
            property real viewportTop: contentY
            property real viewportBottom: contentY + height

            // A décommenter lorsqu'on aura de gros volume de films à afficher
            // cacheBuffer: cellHeight * 2
            // reuseItems: true

            // Opacité réduite pendant le chargement, mais visible
            // opacity: logic.loading ? 0.5 : 1.0

            // Timer pour optimiser les calculs de visibilité
            // Permet d'éviter les calculs excessifs pendant scroll
            Timer {
                id: visibilityUpdateTimer
                interval: 100  // 100ms de délai
                repeat: false
                onTriggered: {
                    // Force la mise à jour des bindings de visibilité
                    filmGridView.viewportTop = filmGridView.contentY
                    filmGridView.viewportBottom = filmGridView.contentY + filmGridView.height
                }
            }

            delegate: Rectangle {
                width: fixedCardWidth  // Largeur dynamique
                height: cataloguePage.cellHeight - dp(4) // Petite marge interne
                radius: dp(6)
                color: Theme.colors.backgroundColor
                border.color: Theme.colors.dividerColor
                border.width: dp(0.5)

                // Calcul de visibilité de cet item
                property real itemTop: y
                property real itemBottom: y + height
                property real threshold: cataloguePage.visibilityThreshold

                // Calcul de visibilité optimisé
                property bool itemVisible: {
                    var top = y
                    var bottom = y + height
                    var vpTop = filmGridView.viewportTop
                    var vpBottom = filmGridView.viewportBottom

                    var visible = (bottom >= vpTop - threshold) && (top <= vpBottom + threshold)

                    // Debug moins verbeux
                    if (visible !== itemVisible) {
                        console.log("👁️", modelData ? modelData.title : "Item", visible ? "visible" : "caché")
                    }

                    return visible
                }


                property real padding: dp(3)
                Column {
                    anchors.fill: parent
                    anchors.margins: parent.padding
                    spacing: dp(4)

                    // Zone affiche avec largeur FIXE
                    Components.PosterImage {
                        width: parent.width
                        height: parent.width * posterAspectRatio // Respect du ratio cinéma et utilisation de la largeur fixe
                        source: modelData ? modelData.poster_url : ""

                        // ✅ Configuration lazy loading (activé pour test)
                        enableLazyLoading: true
                        isVisible: parent.parent.itemVisible  // Référence au delegate
                        visibilityThreshold: cataloguePage.visibilityThreshold

                        // Debug pour voir le comportement
                        onIsVisibleChanged: {
                            console.log("📱 Item", index, "visible:", isVisible, "- Source:", source.split('/').pop())
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

            // Mettre à jour viewportTop et viewportBottom sur scroll
            // Mise à jour de la visibilité lors du scroll
            // Optimisation du scroll
            onContentYChanged: {
                visibilityUpdateTimer.restart()
            }
            onHeightChanged: {
                visibilityUpdateTimer.restart()
            }
        }
    }


    // === MODAL D'ERREUR EN BAS DE FENÊTRE ===
    AppModal {
        id: errorModal

        // Configuration modal partiel en bas
        fullscreen: false
        modalHeight: dp(150)

        // Positionnement en bas (via ancrage du contenu)
        pushBackContent: cataloguePage

        // Fermeture par tap externe
        closeOnBackgroundClick: true
        closeWithBackButton: true

        // Couleur de fond du modal
        backgroundColor: "transparent"

        // === CONTENU DU MODAL D'ERREUR ===
        Rectangle {
            id: modalContainer
            width: Math.min(dp(350), parent.width * 0.9)   // largeur contrôlée et responsive
            height: parent.height

            // Ancré en bas avec marge pour le décaler vers le haut
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: dp(40)

            radius: dp(12)
            color: Theme.colors.backgroundColor

            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: dp(4)
                radius: dp(8)
                samples: 17
                color: Qt.rgba(0, 0, 0, 0.3)
            }

            Column {
                anchors.fill: parent
                anchors.margins: dp(10)
                spacing: dp(12)

                AppIcon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    iconType: IconType.exclamationtriangle
                    color: "#FFA500"
                    size: dp(24)
                }

                AppText {
                    id: errorText
                    width: parent.width
                    text: ""
                    color: Theme.colors.textColor
                    font.pixelSize: sp(14)
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    maximumLineCount: 4
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: dp(20)

                    AppButton {
                        text: "Rejeter"
                        flat: true
                        textColor: Theme.colors.secondaryTextColor
                        onClicked: errorModal.close()
                    }

                    AppButton {
                        text: "Rafraîchir"
                        backgroundColor: Theme.colors.tintColor
                        onClicked: {
                            // errorModal.close()
                            logic.refreshCatalogue()
                        }
                    }
                }
            }
        }
    }

    // === GESTION DES SIGNAUX ===
    Connections {
        target: logic
        function onErrorOccurred(message) {
            errorText.text = message
            errorModal.open()
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
