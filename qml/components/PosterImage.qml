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

    // Permet d'activer ou non le lazy loading
    property bool enableLazyLoading: false  // Désactivé par défaut pour ne pas casser l'existant

    // Indisuq si l'image est visible dans la GridView
    property bool isVisible: true           // Sera contrôlé par le parent (GridView)
    property real visibilityThreshold: 50   // Distance en pixels avant de charger

    // Propriété calculée pour décider du chargement (si on doit charger
    // réellement l'image (true si pas de lazy loading ou si l'image est visible)
    readonly property bool shouldLoad: !enableLazyLoading || isVisible

    // Propriétés de statut (lecture seule)
    readonly property alias status: image.status
    readonly property alias progress: image.progress
    readonly property bool isLoading: image.status === Image.Loading
    readonly property bool hasError: image.status === Image.Error
    readonly property bool isReady: image.status === Image.Ready

    Component.onCompleted: {
        console.log("PosterImage initialisé pour:", source, " - lazy loading:", enableLazyLoading, " visible:", isVisible)
    }

    // Image principale
    Image {
        id: image
        anchors.fill: parent

        // Source conditionnelle selon lazy loading
        source: posterImage.shouldLoad ? posterImage.source : ""

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

        // placeholder visible si image en téléchargement ou source pas défini
        visible: (isLoading || source === "") || (enableLazyLoading && !shouldLoad)

        // Couleur différente pour lazy loading vs chargement
        color: {
            if (enableLazyLoading && !shouldLoad) {
                return "#e8e8e8"  // Gris plus foncé pour lazy loading
            } else {
                return "#f0f0f0"  // Gris standard pour chargement (fond gris clair uniformisé)
            }
        }

        // Icône cinéma
        AppIcon {
            anchors.centerIn: parent

            // Icône oeil pour les images en attente de lazy loading
            iconType: enableLazyLoading && !shouldLoad ? IconType.eye : IconType.film
            size: Math.min(parent.width * 0.3, dp(32))  // afin d'éviter les icônes trop grandes
            color: enableLazyLoading && !shouldLoad ? "#999999" : "#bdbdbd"
            z: 2  // Icône cinéma par-dessus le shimmer
        }

        // ✅ Indicateur lazy loading
        AppText {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: dp(4)
            text: enableLazyLoading && !shouldLoad ? "💤" : ""
            font.pixelSize: sp(12)
            visible: enableLazyLoading && !shouldLoad
        }

        // Animation de chargement (shimmer)
        Rectangle {
            id: shimmer  // shimmer :  effet de "brillance" qui traverse l'élément
            width: parent.width * 0.6  // 60% de la largeur seulement
            height: parent.height
            radius: parent.radius
            visible: isLoading && shouldLoad  // Pas de shimmer si lazy loading inactif (sur les images en attente)
            z: 1

            gradient: Gradient {  // Transparent -> Blanc semi-transparent -> Transparent
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.2; color: Qt.rgba(1,1,1,0.3) }  // blanc à 30% d'opacité
                GradientStop { position: 0.4; color: Qt.rgba(1,1,1,0.8) }
                GradientStop { position: 0.5; color: Qt.rgba(1,1,1,1.0) }  // Blanc pur
                GradientStop { position: 0.6; color: Qt.rgba(1,1,1,0.8) }
                GradientStop { position: 0.8; color: Qt.rgba(1,1,1,0.3) }
                GradientStop { position: 1.0; color: "transparent" }
            }

            // Effet de flou pour adoucir
            layer.enabled: true
            layer.effect: FastBlur {
                radius: 4
            }

            // A décomenter si on veut un effet plus marqué
            // // Bordure brillante pour accentuer l'effet
            // border.width: 1
            // border.color: Qt.rgba(1,1,1,0.5)

            // // Ombre pour plus de profondeur
            // layer.enabled: true
            // layer.effect: DropShadow {
            //     horizontalOffset: 0
            //     verticalOffset: 0
            //     radius: 6
            //     samples: 13
            //     color: Qt.rgba(1,1,1,0.3)
            // }

            PropertyAnimation on x {
                // animation uniquement quand nécessaire (placeholder visible et image en cours de chargement et lazy loading actif)
                running: placeholder.visible && isLoading && shouldLoad  // Chargement actif -> affichage du shimmer)
                from: -shimmer.width * 0.25  // Commence à moitié caché  (// basé sur la largeur du composant)
                to: placeholder.width   // sort complètement à droite
                // from: 0   // ← Bord gauche
                // to: placeholder.width - shimmer.width         // ← Bord droit
                duration: 1000  // Plus rapide -> plus visible
                loops: Animation.Infinite   // l'animation continue jusqu'à ce que l'image soit chargée
                easing.type: Easing.Linear  // Mouvement constant

                onRunningChanged: {
                    if (running) {
                        console.log("✨ Shimmer démarré pour:", posterImage.source, " - largeur: ", shimmer.width)
                    } else {
                        console.log("🛑 Shimmer arrêté pour:", posterImage.source)
                    }
                }

                // Debug des conditions
                Component.onCompleted: {
                    console.log("🔍 Conditions shimmer:")
                    console.log("  - placeholder.visible:", placeholder.visible)
                    console.log("  - isLoading:", isLoading)
                    console.log("  - running:", running)
                }
            }
        }

        // Debug sur les conditions de visibilité du placeholder
        onVisibleChanged: {
            console.log("📦 Placeholder visible:", visible)
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

