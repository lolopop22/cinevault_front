import QtQuick 2.15
import Felgo 4.0

/**
 * ToastManager v2 - Avec ListView
 *
 * Avantages :
 * - VerticalLayoutDirection.BottomToTop natif
 * - displaceAnimation automatique
 * - Model-driven (efficace)
 * - Pattern Qt standard (ListView)
 *
 * Usage :
 * toastManager.show("Erreur", "error")
 * toastManager.showSuccess("Succès !")
 */
Item {
    id: toastManager
    anchors.fill: parent
    z: Infinity

    // ============================================
    // CONFIGURATION DU LISTMODEL
    // ============================================

    /**
     * ListModel pour stocker les toasts
     *
     * Chaque toast est un objet :
     * {
     *     message: "Texte du toast",
     *     type: "error",  // success, error, warning, info
     *     duration: 3000
     * }
     *
     * Justification :
     * - Model-driven : Les toasts sont des données
     * - ListView réagit automatiquement aux changements
     * - Pas besoin de gestion manuelle d'ajout/suppression
     */
    ListModel {
        id: toastModel
    }

    // ============================================
    // DÉFINITION DES TYPES ET COULEURS
    // ============================================

    /**
     * Enum des types de toasts
     */
    readonly property var toastType: {
        "SUCCESS": "success",
        "ERROR": "error",
        "WARNING": "warning",
        "INFO": "info"
    }

    /**
     * Configuration des couleurs par type
     * Material Design colors
     */
    readonly property var toastColors: {
        "success": "#4CAF50",   // Vert
        "error": "#F44336",     // Rouge
        "warning": "#FF9800",   // Orange
        "info": "#2196F3"       // Bleu
    }

    /**
     * Icônes par type
     */
    readonly property var toastIcons: {
        "success": IconType.checkcircle,
        "error": IconType.exclamationcircle,
        "warning": IconType.exclamationtriangle,
        "info": IconType.infocircle
    }

    // ============================================
    // LISTVIEW - CONTAINER DES TOASTS
    // ============================================

    /**
     * ListView pour gérer la pile de toasts
     *
     * Justification :
     * - verticalLayoutDirection : Contrôle le sens d'ajout (bottom-to-top)
     * - displaceAnimation : Anime les déplacements automatiquement
     * - interactive: false : Pas de scroll/swipe de l'utilisateur
     * - spacing : Écart entre toasts
     */
    ListView {
        id: toastList

        // ============================================
        // POSITIONEMENT ET TAILLE
        // ============================================

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: dp(80)  // Au-dessus de la bottom navigation
        }

        /**
         * Hauteur = somme des hauteurs des toasts + espacements
         */
        height: contentHeight

        // ============================================
        // CONFIGURATION LISTVIEW
        // ============================================

        model: toastModel

        /**
         * NOUVEAU : Direction de layout inversée
         *
         * Justification :
         * - BottomToTop : Nouveaux toasts en bas, anciens poussés vers le haut
         * - Convention standard Qt/QML
         * - Plus efficace que calculs manuels
         * - Behavior automatique sur les déplacements
         */
        verticalLayoutDirection: ListView.BottomToTop

        /**
         * Pas d'interaction utilisateur
         * - Pas de scroll possible
         * - Pas de swipe
         * - Liste en "read-only" visuel
         */
        interactive: false

        /**
         * Espacement entre toasts
         */
        spacing: dp(8)

        /**
         * Animation de déplacement
         *
         * - Quand un toast disparaît, les autres se déplacent
         * - displaceAnimation assure une transition fluide
         * - Sans ça : saut abrupt vers le bas
         * - Avec ça : glissement animé (meilleure UX)
         *
         * Properties :
         * - duration : Temps de l'animation (250ms recommandé)
         * - easing : Courbe d'accélération (OutQuad = naturel)
         */
        displaced: Transition {
            NumberAnimation {
                properties: "y"
                duration: 250
                easing.type: Easing.OutQuad
            }
        }

        // ============================================
        // DELEGATE - UN TOAST PAR ITEM
        // ============================================

        /**
         * Delegate : Définit l'apparence d'un toast
         *
         * Chaque toast du model est rendu avec ce delegate
         * Accès aux propriétés du model via :
         * - model.message
         * - model.type
         * - model.duration
         */
        delegate: ToastDelegate {
            /**
             * Passage des propriétés du manager au delegate
             *
             * Justification :
             * - Delegate a besoin des couleurs et icônes
             * - Le manager centralise la configuration
             * - Découplage : delegate ne connaît pas toastType.ERROR, etc.
             * - Facilite les modifications futures (ex: changer les couleurs)
             */
            width: toastList.width
            toastMessage: model.message
            toastType: model.type
            toastDuration: model.duration
            backgroundColor: toastManager.toastColors[model.type] || toastManager.toastColors["info"]
            iconType: toastManager.toastIcons[model.type] || toastManager.toastIcons["info"]

            // Callback pour supprimer le toast du model
            onCloseRequested: {
                console.log("🗑️ Suppression du toast :", toastMessage)
                toastModel.remove(index)
            }
        }
    }

    // ============================================
    // MÉTHODES PUBLIQUES
    // ============================================

    /**
     * Affiche un toast avec type personnalisé
     *
     * @param {string} text - Message à afficher
     * @param {string} type - Type (success, error, warning, info)
     * @param {int} duration - Durée en ms (optionnel, défaut 3000)
     */
    function show(text, type, duration) {
        // Défaut : info
        if (typeof type === "undefined") {
            type = toastType.INFO
        }

        // Défaut : 3000ms
        if (typeof duration === "undefined") {
            duration = 3000
        }

        console.log("📣 ToastManager.show():", text, "- Type:", type)

        // Ajout à la ListModel
        // BottomToTop signifie : le nouvel item est ajouté comme le DERNIER
        // (derniers = bas de la liste visuelle)
        toastModel.append({
            "message": text,
            "type": type,
            "duration": duration
        })

        console.log("✅ Toast ajouté - Total:", toastModel.count)
    }

    /**
     * Raccourcis pour types courants
     */
    function showSuccess(text, duration) {
        return show(text, toastType.SUCCESS, duration)
    }

    function showError(text, duration) {
        return show(text, toastType.ERROR, duration)
    }

    function showWarning(text, duration) {
        return show(text, toastType.WARNING, duration)
    }

    function showInfo(text, duration) {
        return show(text, toastType.INFO, duration)
    }

    // ============================================
    // INITIALISATION
    // ============================================

    Component.onCompleted: {
        console.log("✅ ToastManager initialisé (ListView version)")
    }
}
