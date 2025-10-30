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
    // LARGEUR ADAPTATIVE
    // ============================================

    /**
     * Calcul de la largeur maximale selon plateforme et taille d'écran
     *
     * Guidelines :
     *
     * Material Design (Android) :
     * - Mobile : Largeur écran - 32dp (16dp de chaque côté)
     * - Tablet : Maximum 344dp (single-line) ou 456dp (multi-line)
     * - Source : https://m3.material.io/components/snackbar/specs
     *
     * iOS :
     * - iPhone : Largeur écran - marges standard
     * - iPad : Maximum ~400-500pt (centré)
     * - Source : https://developer.apple.com/design/human-interface-guidelines/alerts
     *
     * Desktop :
     * - Maximum : 360px (convention standard)
     * - Pas de pleine largeur (mauvaise UX)
     *
     * Détection :
     * - Taille écran : parent.width
     * - Plateforme : Qt.platform.os
     * - Breakpoint tablet : 600dp (convention Material)
     */
    readonly property real maxToastWidth: {
        var screenWidth = parent ? parent.width : 300

        // IOS
        if (Qt.platform.os === "ios") {
            // iPad (largeur > 600dp)
            if (screenWidth > Theme.dp(600)) {
                // iPad : Max 500pt
                return Math.min(Theme.dp(500), screenWidth - Theme.dp(32))
            }

            // iPhone : Largeur écran - marges
            return screenWidth - Theme.dp(32)
        }

        // ANDROID
        if (Qt.platform.os === "android") {
            // Tablet (largeur > 600dp)
            if (screenWidth > Theme.dp(600)) {
                // Tablet : Max 456dp (multi-line snackbar)
                // Note : 344dp pour single-line, 456dp pour multi-line
                return Math.min(Theme.dp(456), screenWidth - Theme.dp(32))
            }

            // Mobile : Largeur écran - 32dp
            return screenWidth - Theme.dp(32)
        }

        // DESKTOP (Windows, macOS, Linux)
        if (Qt.platform.os === "windows" ||
            Qt.platform.os === "osx" ||
            Qt.platform.os === "linux") {
            // Desktop : Max 360dp (convention UX)
            return Math.min(Theme.dp(360), screenWidth - Theme.dp(32))
        }

        // Fallback : Max 360dp
        return Math.min(Theme.dp(360), screenWidth - Theme.dp(32))
    }

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

    // Centrage horizontal
    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined

    /**
     * Largeur responsive avec maximum (Respect des largeurs max par plateforme)
     *
     * Logic :
     * 1. maxToastWidth = largeur max selon plateforme
     * 2. contentRow.implicitWidth + padding = largeur naturelle du contenu
     * 3. Math.min() = prend le plus petit (ne dépasse jamais maxToastWidth)
     *
     * Exemples :
     * - Message court (50dp contenu) + iPhone : 50dp + 32dp = 82dp
     * - Message long (600dp contenu) + iPhone (375dp) : max 343dp
     * - Message long (600dp contenu) + iPad (768dp) : max 500dp
     * - Message long (600dp contenu) + Desktop : max 360dp
     */
    width: Math.min(toast.maxToastWidth, contentRow.implicitWidth + Theme.dp(32))

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
             * Largeur max du texte
             *
             * Calcul :
             * - maxToastWidth - padding (32dp) - icône (20dp) - spacing (12dp)
             * - Total padding/icône : ~64dp
             * - Largeur texte = maxToastWidth - 64dp
             *
             * Justification :
             * - Empêche le texte de dépasser le toast
             * - Garde des marges internes cohérentes
             * - Permet word wrap si texte trop long
             */
            width: Math.min(
                implicitWidth,
                toast.maxToastWidth - Theme.dp(64)
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
        console.log("📱 Plateforme:", Qt.platform.os)
        console.log("📐 Largeur écran:", parent ? parent.width : "?", "px")
        console.log("📏 Largeur max toast:", maxToastWidth, "px")
        console.log("📊 Largeur réelle toast:", width, "px")
        show()  // Fade in automatique
    }
}
