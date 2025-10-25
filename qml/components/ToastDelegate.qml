import QtQuick 2.15
import Felgo 4.0
import Qt5Compat.GraphicalEffects

/**
 * ToastDelegate - Rendu visuel d'un toast individuel
 *
 * Responsabilités :
 * - Afficher le message avec icône et couleur
 * - Animer l'entrée (fade in)
 * - Animer la sortie (fade out)
 * - Auto-hide après durée définie
 *
 * Usage interne uniquement (par ToastManager)
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

    // Taille adaptée au contenu + padding
    implicitHeight: contentRow.implicitHeight + dp(24)
    height: implicitHeight
    color: backgroundColor
    radius: dp(4)

    //  Marge horizontale
    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined

    /**
     * Largeur responsive
     * - Min : Ajuste au contenu + padding
     * - Max : Largeur parent - marges
     */
    width: Math.min(
        parent ? parent.width - Theme.dp(32) : 300,
        contentRow.implicitWidth + Theme.dp(32)
    )

    // Opacité pour fade in/out
    opacity: 0  // Invisible par défaut

    /**
     * Ombre portée pour détacher visuellement
     *
     * Justification :
     * - Donne de la profondeur (Material Design elevation)
     * - Améliore la lisibilité sur fonds clairs/foncés
     */
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
            maximumLineCount: 5
            elide: Text.ElideRight

            /**
             * Largeur max pour éviter un toast trop large
             */
            width: Math.min(
                implicitWidth,
                (parent.parent.parent ? parent.parent.parent.width : 300) - Theme.dp(96)
            )

            anchors.verticalCenter: parent.verticalCenter
        }
    }


    // ============================================
    // ANIMATIONS
    // ============================================

    /**
     * Behavior sur opacity : fade in/out
     *
     * Justification :
     * - Apparition progressive (pas brutal)
     * - Disparition douce (pas brusque)
     * - 300ms = sweet spot (ni trop lent, ni trop rapide)
     */
    Behavior on opacity {
        NumberAnimation {
            duration: toast.fadeTime
            easing.type: Easing.InOutQuad
        }
    }

    // Timer pour fermeture automatique
    Timer {
        id: hideTimer
        interval: toast.toastDuration
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
     * Affiche le toast (animation fade in)
     *
     * Justification du flow :
     * -> Fade in (opacity 0 → 1)
     * -> Démarrage du timer d'auto-fermeture
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
     * -> Fade out progressif (meilleure UX que disparition brutale)
     * -> Demande la suppression dans le ListModel
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
        console.log("✅ ToastDelegate créé:", toastMessage, "- Type:", toastType)
        show()  // Fade in automatique
    }
}
