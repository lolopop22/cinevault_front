import QtQuick 2.15
import Felgo 4.0
import Qt5Compat.GraphicalEffects

/**
 * Toast - Composant de notification temporaire
 *
 * Inspiré de Android Material Snackbar et iOS Banner
 * Basé sur : https://gist.github.com/jonmcclung/bae669101d17b103e94790341301c129
 *
 * Caractéristiques :
 * - Affichage temporaire (auto-dismiss)
 * - Non bloquant (pas de modal)
 * - Animations d'entrée/sortie
 * - File d'attente automatique si plusieurs toasts
 * - Responsive (adapté mobile et desktop)
 *
 * Usage :
 * Toast {
 *     id: myToast
 * }
 *
 * myToast.show("Message d'erreur")
 */
Rectangle {
    id: toast

    // ============================================
    // PROPRIÉTÉS DU DELEGATE
    // ============================================

    /**
     * Propriétés reçues du ToastManager
     *
     * Justification :
     * - Delegate reçoit les données du model (message, type, duration)
     * - Delegate reçoit aussi les configs du manager (colors, icons)
     * - Sépare les responsabilités :
     *   * ToastManager = orchestration + config
     *   * ToastDelegate = affichage + animation
     */
    property string toastMessage: ""
    property string toastType: "info"
    property int toastDuration: 3000
    property color backgroundColor: "#2196F3"  // ou "#323232" (Gris foncé Material) ou #222222 (pour un fond sombre semi-transparent)
    property string iconType: IconType.infocircle

    // Signal de fermeture envoyé au manager pour supprimer de la ListModel
    signal closeRequested()

    // ============================================
    // PROPRIÉTÉS INTERNES
    // ============================================

    // Temps d'animation d'entrée/sortie
    readonly property int fadeTime: 300

    // ============================================
    // APPARENCE
    // ============================================

    // Taille adaptée au contenu
    implicitHeight: contentRow.implicitHeight + dp(24)
    height: implicitHeight
    color: backgroundColor
    radius: dp(4)

    //  Marge horizontale
    anchors.horizontalCenter: parent.horizontalCenter

    // Largeur max (responsive)
    width: Math.min(parent.width - dp(32), contentRow.implicitWidth + dp(32))

    // Opacité pour fade in/out
    opacity: 0  // Invisible par défaut

    // Ombre portée pour détacher du fond
    layer.enabled: true
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: dp(2)
        radius: dp(8)
        samples: 17
        color: Qt.rgba(0, 0, 0, 0.3)
    }

    // ============================================
    // CONTENU
    // ============================================

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: dp(12)

        /**
         * Icône selon le type
         */
        AppIcon {
            id: toastIcon
            iconType: toast.iconType
            size: dp(20)
            color: "white"
            anchors.verticalCenter: parent.verticalCenter
        }

        /**
         * Message
         */
        AppText {
            id: messageText
            text: toast.toastMessage
            color: "white"
            font.pixelSize: sp(14)
            wrapMode: Text.WordWrap
            maximumLineCount: 3
            elide: Text.ElideRight
            width: Math.min(implicitWidth, parent.parent.width - dp(96))
            anchors.verticalCenter: parent.verticalCenter
        }
    }


    // ============================================
    // ANIMATIONS
    // ============================================

    // Comportement d'animation d'opacité (fade in/out)
    // Utilisé pour l'entrée et la sortie
    Behavior on opacity {
        NumberAnimation {
            duration: toast.fadeTime
            easing.type: Easing.InOutQuad
        }
    }

    // Timer pour fermeture automatique
    Timer {
        id: hideTimer
        interval: toast.duration
        repeat: false

        onTriggered: {
            console.log("⏱️ Toast auto-hide après", toast.duration, "ms", "| toast message: ", toast.toastMessage)
            toast.hide()
        }
    }

    // ============================================
    // MÉTHODES PUBLIQUES
    // ============================================

    /**
     * Affiche le toast avec un message (animation fade in)
     *
     * @param {string} text - Message à afficher
     * @param {int} durationMs - Durée optionnelle (par défaut: 3000ms)
     *
     * Justification du flow :
     * 1. Mise à jour du message
     * 2. Fade in (opacity 0 → 1)
     * 3. Slide up (bottomMargin ajusté)
     * 4. Démarrage du timer d'auto-fermeture
     */
    function show() {
        console.log("📣 Toast.show():", toast.toastMessage, "- Type:", toastType)
        opacity = 1.0 // pour l'animation d'entrée
        hideTimer.start()
    }

    /**
     * Masque le toast avec animation et demande la suppression
     *
     * Justification :
     * - Fade out progressif (meilleure UX que disparition brutale)
     * - Auto-destruction si selfDestroying = true
     */
    function hide() {
        console.log("🚫 Toast.hide()")

        // Animation de sortie
        opacity = 0

        // Après l'animation de fade, notifier le manager
        Qt.callLater(function() {
            closeRequested()  // Signal → manager → ListModel.remove()
        }, fadeTime)
    }

    // ============================================
    // GESTION DU CYCLE DE VIE
    // ============================================

    Component.onCompleted: {
        console.log("✅ Toast initialisé")
        show()  // Fade in automatique
    }
}
