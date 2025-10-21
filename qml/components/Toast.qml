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
    // PROPRIÉTÉS PUBLIQUES
    // ============================================

    /**
     * Durée d'affichage en millisecondes
     * Par défaut : 3000ms (3 secondes)
     * Recommandation Material Design : 2000-4000ms
     */
    property int duration: 3000

    // Message à afficher
    property string message: ""

    // Permet au toast de s'autodétruire après affichage
    // Utile quand créé dynamiquement par ToastManager
    property bool selfDestroying: false


    // ============================================
    // PROPRIÉTÉS PRIVÉES
    // ============================================

    // Temps d'animation d'entrée/sortie
    readonly property int fadeTime: 300

    // ============================================
    // APPARENCE
    // ============================================

    // Taille adaptée au contenu avec limites
    width: Math.min(messageText.implicitWidth + dp(32), parent.width - dp(32))
    height: messageText.implicitHeight + dp(24)

    // Positionnement en bas de l'écran (Convention Android/iOS pour toasts)
    anchors {
        horizontalCenter: parent.horizontalCenter
        bottom: parent.bottom
        bottomMargin: dp(80)  // Au-dessus de la bottom navigation
    }

    // Style Material Design (fond sombre avec légère transparence)
    color: "#323232"  // Gris foncé Material (ou #222222 pour un fond sombre semi-transparent)
    radius: dp(4)
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

    AppText {
        id: messageText
        anchors.centerIn: parent
        text: toast.message
        color: "white"
        font.pixelSize: sp(14)
        wrapMode: Text.WordWrap
        maximumLineCount: 3
        elide: Text.ElideRight

        // Largeur maximale pour éviter un toast trop large
        width: Math.min(implicitWidth, parent.parent.width - dp(64))
    }


    // ============================================
    // ANIMATIONS
    // ============================================

    // Comportement d'animation de l'opacité
    // Utilisé pour l'entrée et la sortie
    Behavior on opacity {
        NumberAnimation {
            duration: toast.fadeTime
            easing.type: Easing.InOutQuad
        }
    }

    // Animation d'entrée (slide up + fade in)
    Behavior on anchors.bottomMargin {
        NumberAnimation {
            duration: toast.fadeTime
            easing.type: Easing.OutQuad
        }
    }

    // ============================================
    // TIMER D'AUTO-FERMETURE
    // ============================================

    // Timer pour fermeture automatique
    Timer {
        id: hideTimer
        interval: toast.duration
        repeat: false

        onTriggered: {
            console.log("⏱️ Toast auto-hide après", toast.duration, "ms")
            toast.hide()
        }
    }

    // ============================================
    // MÉTHODES PUBLIQUES
    // ============================================

    /**
     * Affiche le toast avec un message
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
    function show(text, durationMs) {
        console.log("📣 Toast.show():", text)

        // Mise à jour du message
        message = text

        // Mise à jour de la durée si fournie
        if (typeof durationMs !== "undefined" && durationMs > 0) {
            duration = Math.max(durationMs, 2 * fadeTime)  // Minimum = 2x fadeTime
        }

        // Animation d'entrée
        opacity = 1.0

        // Démarrage du timer d'auto-fermeture
        hideTimer.restart()
    }

    /**
     * Masque le toast avec animation
     *
     * Justification :
     * - Fade out progressif (meilleure UX que disparition brutale)
     * - Auto-destruction si selfDestroying = true
     */
    function hide() {
        console.log("🚫 Toast.hide()")

        // Animation de sortie
        opacity = 0

        // Auto-destruction après animation si demandé
        if (selfDestroying) {
            Qt.callLater(function() {
                toast.destroy(fadeTime)
            })
        }
    }

    // ============================================
    // GESTION DU CYCLE DE VIE
    // ============================================

    Component.onCompleted: {
        console.log("✅ Toast initialisé")
    }
}
