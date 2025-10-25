import Felgo 4.0
import QtQuick 2.15
import QtQuick.Controls 2.15

/**
 * ToastManager - Gestionnaire visuel de notifications toast
 *
 * ⚠️ Ce n'est PAS un Singleton (pas de pragma Singleton)
 *
 * Architecture :
 * - Composant visuel (ListView, Rectangle, animations)
 * - Instance unique créée dans Main.qml
 * - Accessible via ToastService (Singleton)
 *
 * Responsabilités :
 * - Gérer la ListView des toasts (Model-driven (efficace))
 * - Animer les entrées/sorties (displaceAnimation automatique)
 * - Empiler les toasts (BottomToTop: VerticalLayoutDirection.BottomToTop natif)
 *
 * Justification :
 * - Composants visuels ont besoin d'un parent
 * - Singletons QML n'ont pas de parent automatique
 * - Solution : Instance + Service Singleton
 *
 * Références :
 * - Qt 6.7 docs: "Singletons are ideal for styling or theming"
 * - Qt 6.5+: "Use singletons instead of context properties"
 * - QML Guide: "Singleton useful for services"
 *
 * Usage :
 * import "../components" as Components
 *
 * Components.ToastManager.showError("Erreur")
 * Components.ToastManager.showSuccess("Succès")

 * Note importante : dp() et sp() ne sont pas disponibles dans les Singletons
 * Solution : Utiliser Theme.dp() et Theme.sp() à la place
 */
Item {
    id: toastManager

    anchors.fill: parent
    z: Infinity

    // ============================================
    // MODÈLE DE DONNÉES - Stockage des toasts
    // ============================================

    /**
     * ListModel pour stocker les toasts actifs
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
    // CONFIGURATION DES TYPES
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
     * Couleurs Material Design
     */
    readonly property var toastColors: {
        "success": "#4CAF50",   // Green 500
        "error": "#F44336",     // Red 500
        "warning": "#FF9800",   // Orange 500
        "info": "#2196F3"       // Blue 500
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
            bottom: parent.bottom  // Bas du VIEWPORT

            /**
             * Marge en bas : 80dp
             *
             * Justification :
             * - Au-dessus de la bottom navigation (48dp)
             * - Marge supplémentaire (32dp) pour éviter chevauchement
             * - Total : 80dp (convention Material Design)
             */
            bottomMargin: Theme.dp(80)
        }

        // Hauteur = somme des hauteurs des toasts + espacements
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
        spacing: Theme.dp(8)

        /**
         * Animation de déplacement
         *
         * - Quand un toast disparaît remove), les autres se déplacent
         * - displaced assure une transition fluide
         * - Sans ça : saut abrupt vers le bas
         * - Avec ça : glissement animé (meilleure UX)
         *
         * Properties :
         * - y : Position verticale (seule propriété animée)
         * - duration : 250ms (ni trop lent, ni trop rapide)
         * - easing : OutQuad (décélération douce, naturelle)
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
         * Accès aux propriétés du model via model.XXX:
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
     *
     * Flow :
     * 1. Validation des paramètres (valeurs par défaut)
     * 2. Ajout au ListModel (append)
     * 3. ListView crée automatiquement le delegate
     * 4. ToastDelegate s'affiche avec animation
     * 5. Timer démarre (auto-hide après duration)
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

        console.log("📣 ToastManager Singleton.show():", text, "- Type:", type)

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

    Component.onCompleted: {
        console.log("✅ ToastManager initialisé")
        console.log("📍 Parent:", parent)
        console.log("📐 Taille:", width, "x", height)
    }
}
