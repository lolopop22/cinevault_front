import Felgo 4.0
import QtQuick 2.15
import Qt5Compat.GraphicalEffects


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

    Component.onCompleted: {
        console.log("PosterImage initialisé pour:", source)
    }

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

        // Coins arrondis avec masque (Image ne supporte pas nativement la propirété radius)
        layer.enabled: true  // pour appliquer les effets sur les éléments Qt
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: image.width
                height: image.height
                radius: posterImage.borderRadius
            }
        }

        onStatusChanged: {
            switch (status) {
                case Image.Ready:
                    console.log("✅ Image chargée:", posterImage.source,
                               "Taille rendu:", width + "x" + height,
                               "SourceSize:", sourceSize.width + "x" + sourceSize.height)
                    break
                case Image.Error:
                    console.log("❌ Erreur image:", posterImage.source)
                    break
                case Image.Loading:
                    console.log("⏳ Chargement:", posterImage.source)
                    break
            }
        }

        onProgressChanged: {
            if (status === Image.Loading && progress > 0) {
                console.log("📊 Progression:", Math.round(progress * 100) + "%", source)
            }
        }
    }

    // Placeholder pendant le chargement
    Rectangle {
        id: placeholder
        anchors.fill: parent
        radius: borderRadius
        visible: isLoading || source === ""  // placeholder visible si image en téléchargement ou source pas définier

        gradient: Gradient { // gradient vertical pour de la profondeur
            GradientStop { position: 0.0; color: "#d0d0d0" }
            GradientStop { position: 1.0; color: "#b0b0b0" }
        }

        // Icône cinéma
        AppIcon {
            anchors.centerIn: parent
            iconType: IconType.film
            size: Math.min(parent.width * 0.3, dp(32))  // afin d'éviter les icônes trop grandes
            color: "#bdbdbd"
            z: 2  // Icône cinéma par-dessus le shimmer
        }

        // Animation de chargement
        Rectangle {
            id: shimmer  // shimmer :  effet de "brillance" qui traverse l'élément
            anchors.fill: parent
            radius: parent.radius
            z: 1 // shimmer au-dessus du gradient de fond

            gradient: Gradient { // Transparent -> Blanc semi-transparent -> Transparent
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.25; color: Qt.rgba(1,1,1,0.6) }  // blanc à 60% d'opacité
                GradientStop { position: 0.5; color: Qt.rgba(1,1,1,0.4) }
                GradientStop { position: 0.75; color: Qt.rgba(1,1,1,0.6) }
                GradientStop { position: 1.0; color: "transparent" }
            }

            PropertyAnimation on x {
                running: placeholder.visible && isLoading // animation uniquement quand nécessaire
                from: -parent.width      // commence hors écran à gauche
                to: parent.width * 2  // finit hors écran à droite
                duration: 3000
                loops: Animation.Infinite  // l'animation continue jusqu'à ce que l'image soit chargée
                easing.type: Easing.InOutQuad

                onRunningChanged: {
                    if (running) {
                        console.log("✨ Shimmer démarré pour:", posterImage.source)
                    } else {
                        console.log("🛑 Shimmer arrêté pour:", posterImage.source)
                    }
                }
            }
        }
    }

    // Fallback en cas d'erreur
    Rectangle {
        id: errorFallback
        anchors.fill: parent
        radius: borderRadius
        visible: hasError
        color: "#ffebee"          // Rose très pâle
        border.color: "#ffcdd2"   // Rose clair
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: dp(8)  // standard d'espacement moyen

            AppIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                iconType: IconType.exclamationtriangle
                size: dp(24)
                color: "#f44336"
            }

            AppText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Image indisponible"
                font.pixelSize: sp(10)
                color: "#666"
                horizontalAlignment: Text.AlignHCenter
            }

            AppText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Toucher pour réessayer"
                font.pixelSize: sp(7)
                color: "#999"
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // Possibilité de retry (zone cliquable qui prend toute la zone)
        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.log("🔄 Retry demandé pour:", posterImage.source)

                // Technique de reset
                var originalSource = posterImage.source
                image.source = ""   // reset de l'état de l'image
                // image.source = posterImage.source
                Qt.callLater(function() {
                    image.source = originalSource  // déclenchement d'un nouveau chargement
                })
            }
        }
    }

}

