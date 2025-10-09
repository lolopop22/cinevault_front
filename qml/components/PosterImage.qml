import Felgo 4.0
import QtQuick 2.15

Item {
    id: posterImage

    // Propriétés publiques
    property string source: ""
    property alias fillMode: image.fillMode
    property bool asynchronous: true  // chargement asynchrone: l'image se charge en arrière-plan
    property real borderRadius: dp(6)

    // Propriétés de statut (lecture seule)
    readonly property alias status: image.status
    readonly property alias progress: image.progress
    readonly property bool isLoading: image.status === Image.Loading
    readonly property bool hasError: image.status === Image.Error
    readonly property bool isReady: image.status === Image.Ready

    // Image principale
    Image {
        id: image
        anchors.fill: parent
        source: posterImage.source
        asynchronous: posterImage.asynchronous
        fillMode: Image.PreserveAspectCrop  // Maintient les proportions de l'image

        // Optimisation taille pour éviter la consommation excessive de mémoire
        sourceSize.width: Math.min(width * 2, 400) // Limite à 400px max, retina-ready
        sourceSize.height: Math.min(height * 2, 600)

        visible: isReady   // Masquer l'image pendant chargement ou si erreur
    }

    // Placeholder pendant le chargement
    Rectangle {
        id: placeholder
        anchors.fill: parent
        radius: borderRadius
        visible: isLoading || source === ""  // placeholder visible si image en téléchargement ou source pas définier

        gradient: Gradient { // gradient vertical pour de la profondeur
            GradientStop { position: 0.0; color: "#f5f5f5" }
            GradientStop { position: 1.0; color: "#e0e0e0" }
        }

        // Icône cinéma
        AppIcon {
            anchors.centerIn: parent
            iconType: IconType.film
            size: Math.min(parent.width * 0.3, dp(32))  // afin d'éviter les icônes trop grandes
            color: "#bdbdbd"
        }

        // Animation de chargement
        Rectangle {
            id: shimmer  // shimmer :  effet de "brillance" qui traverse l'élément
            anchors.fill: parent
            radius: parent.radius

            gradient: Gradient { // Transparent -> Blanc semi-transparent -> Transparent
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.3) }  // blanc à 30% d'opacité
                GradientStop { position: 1.0; color: "transparent" }
            }

            PropertyAnimation on x {
                running: placeholder.visible && isLoading // animation uniquement quand nécessaire
                from: -width      // commence hors écran à gauche
                to: parent.width  // finit hors écran à droite
                duration: 1500
                loops: Animation.Infinite  // l'animation continue jusqu'à ce que l'image soit chargée
            }
        }
    }
}

