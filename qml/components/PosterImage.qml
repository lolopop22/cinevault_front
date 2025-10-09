import Felgo 4.0
import QtQuick 2.15

Item {
    id: posterImage

    // Propriétés publiques
    property string source: ""
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
        fillMode: Image.PreserveAspectCrop  // Maintient les proportions de l'image

        // Optimisation taille pour éviter la consommation excessive de mémoire
        sourceSize.width: Math.min(width * 2, 400) // Limite à 400px max, retina-ready
        sourceSize.height: Math.min(height * 2, 600)
    }
}

