import Felgo 4.0
import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import "../components" as Components
import "../services" as Services
import "../logic" as Logic


/**
 * Page de détails d'un film (placeholder)
 *
 * Cette page sert uniquement à valider la navigation depuis le catalogue.
 * Le contenu détaillé sera implémenté dans une User Story dédiée.
 *
 * Objectifs de cette version :
 * - Recevoir et afficher l'ID du film
 * - Récupérer le film depuis FilmDataSingletonModel
 * - Afficher le poster et le titre (validation visuelle)
 * - Gérer les erreurs de navigation
 * - Valider les transitions de navigation
 * - Utilise ToastService pour afficher les notifications
 * Responsabilités :
 * - Afficher les détails d'un film (titre, poster, description, etc.)
 * - Recevoir le filmId via navigation (push)
 * - Charger le film via FilmDetailLogic
 * - Gérer les erreurs avec ToastService
 * - Fournir bouton retour vers catalogue
 *
 * Pattern MVC :
 * - View : affichage uniquement
 * - Logic : FilmDetailLogic (orchestration, recherche)
 * - Model : FilmDataSingletonModel (données)
 *
 * Architecture :
 * Navigation → FilmDetailPage reçoit filmId → FilmDetailLogic.loadFilm(filmId)
 *          → FilmDetailLogic cherche dans Model
 *          → Émet filmLoaded ou loadError
 *          → Page affiche résultat ou toast erreur
 */
FlickablePage {
    id: filmDetailPage

    // Titre dynamique basé sur le film (binding auto sur logic.currentFilm)
    title: logic.currentFilm ? logic.currentFilm.title : "Détails du film"

    // ============================================
    // PARAMÈTRES REÇUS VIA NAVIGATION
    // ============================================

    /**
     * ID du film à afficher
     *
     * Reçu via : navigationStack.push(component, {filmId: X})
     * Valeur par défaut : -1 (invalide)
     *
     * Utilisé dans Component.onCompleted pour validation et chargement
     */
    property int filmId: -1

    // ============================================
    // LOGIQUE MÉTIER
    // ============================================

    /**
     * Controller pour la page de détails
     *
     * Responsabilités :
     * - Charger le film par ID depuis le Model
     * - Émettre signaux filmLoaded/loadError
     * - Gérer l'état (loading, errorMessage, currentFilm)
     */
    Logic.FilmDetailLogic {
        id: logic
    }

    // ============================================
    // HEADER
    // ============================================

    /**
     * Bouton retour vers le catalogue
     *
     * Plateforme : iOS / Android / Desktop
     * - iOS : swipe from left + bouton
     * - Android : back button hardware + bouton
     * - Desktop : bouton uniquement
     *
     * Best practice : toujours inclure le bouton pour cohérence
     */
    leftBarItem: IconButtonBarItem {
        iconType: IconType.arrowleft
        title: "Retour"
        onClicked: {
            // Nettoyage optionnel avant retour
            logic.reset()
            navigationStack.pop()
        }
    }

    // Bouton d'action optionnel (futur : partager, éditer, etc.)
    rightBarItem: IconButtonBarItem {
        iconType: IconType.ellipsisv
        title: "Options"
        visible: logic.currentFilm !== null
        onClicked: {
            // Futur : afficher un menu d'options
            console.log("hello ⚙️ Options pour le film:", filmId)
        }
    }

    // ============================================
    // CONTENU SCROLLABLE
    // ============================================

    /**
     * Configuration de la zone scrollable
     *
     * flickable.contentHeight = hauteur du contenu
     * Permet scroll automatique si contenu > écran
     */
    flickable.contentHeight: contentColumn.height + dp(60)

    // ============================================
    // CONTENU SCROLLABLE (enfants directs de FlickablePage)
    // ============================================

    Column {
        id: contentColumn
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: dp(20)
        }
        spacing: dp(30)


        // ============================================
        // SECTION 1 : POSTER HAUTE RÉSOLUTION
        // ============================================

        /**
         * Poster centré et agrandi
         */
        Components.PosterImage {
            width: Math.min(dp(200), parent.width * 0.6)  // Responsive
            height: width * 1.5  // Ratio cinéma 2:3
            anchors.horizontalCenter: parent.horizontalCenter

            // Binding sur logic.currentFilm (pas d'accès direct au Model)
            source: logic.currentFilm ? logic.currentFilm.poster_url : ""
            borderRadius: dp(12)

            // Pas de lazy loading (une seule image, chargement immédiat)
            enableLazyLoading: false
        }

        // ============================================
        // SECTION 2 : INFORMATIONS DE BASE
        // ============================================
        // État : Film chargé avec succès
        Column {
            width: parent.width
            spacing: dp(16)

            visible: !logic.loading && logic.currentFilm !== null

            // Titre du film
            AppText {
                width: parent.width

                // Binding sur logic.currentFilm
                text: logic.currentFilm ? logic.currentFilm.title : "Film inconnu"

                font.pixelSize: sp(24)
                font.bold: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                color: Theme.colors.textColor
            }

            // Séparateur visuel
            Rectangle {
                width: parent.width * 0.5
                height: dp(2)
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.colors.dividerColor
                radius: dp(1)
            }

            // ID du film (pour validation technique)
            AppText {
                width: parent.width
                text: "ID: " + (logic.currentFilm ? logic.currentFilm.id : "N/A")
                font.pixelSize: sp(14)
                color: Theme.colors.secondaryTextColor
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // ============================================
        // SECTION 3 : PLACEHOLDER POUR CONTENU FUTUR
        // ============================================

        /**
         * Card avec message explicatif
         * Justification : Indiquer clairement que le contenu complet
         *                 sera implémenté dans une autre US
         */
        Rectangle {
            width: parent.width
            height: contentPlaceholder.height + dp(40)
            radius: dp(8)
            color: Theme.colors.backgroundColor
            border.width: dp(2)
            border.color: Theme.colors.tintColor

            visible: !logic.loading && logic.currentFilm !== null

            Column {
                id: contentPlaceholder
                anchors {
                    centerIn: parent
                    margins: dp(20)
                }
                spacing: dp(12)
                width: parent.width - dp(40)

                AppIcon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    iconType: IconType.infocircle
                    size: dp(48)
                    color: Theme.colors.tintColor
                }

                AppText {
                    width: parent.width
                    text: "Contenu détaillé à venir"
                    font.pixelSize: sp(18)
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    color: Theme.colors.textColor
                }

                AppText {
                    width: parent.width
                    text: "Cette page valide la navigation vers les détails d'un film.\n\nLe contenu complet (résumé, casting, genres, etc.) sera implémenté dans une User Story dédiée."
                    font.pixelSize: sp(14)
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    color: Theme.colors.secondaryTextColor
                }
            }
        }

        // État : Erreur
        Column {
            visible: !logic.loading && logic.currentFilm === null
            width: parent.width
            spacing: dp(12)

            AppIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                iconType: IconType.exclamationcircle
                size: dp(48)
                color: "#F44336"
            }

            AppText {
                width: parent.width
                text: "Impossible de charger le film"
                font.bold: true
                font.pixelSize: sp(16)
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
        }

        // ============================================
        // BOUTON RETOUR
        // ============================================

        AppButton {
            width: parent.width
            text: "Retour au catalogue"
            flat: true

            onClicked: {
                console.log("⬅️ Retour au catalogue via bouton")
                logic.reset()
                navigationStack.pop()
            }
        }
    }

    // ============================================
    // CONNECTIONS - RÉACTION AUX SIGNAUX DE LOGIC
    // ============================================

    /**
     * Écoute les signaux émis par FilmDetailLogic
     *
     * Communication : Logic → View
     * - filmLoaded(film) : Succès, show toast
     * - loadError(message) : Erreur, show toast erreur
     *
     * Justification Connections :
     * - Découplage : View ne connaît pas les détails de Logic
     * - Pattern Observer : réaction aux changements d'état
     * - Alternative à binding complexe
     */
    Connections {
        target: logic

        /**
         * Réaction au succès du chargement
         *
         * Actions :
         * - Toast de succès (optionnel, peut être retiré)
         * - Logs pour debugging
         *
         * Limitation actuelle :
         * - Page très simple, pas encore d'affichage d'image/description
         * - Ces éléments seront ajoutés lors de la complexification
         * - Pour maintenant : affichage titre uniquement
         */
        function onFilmLoaded(film) {
            console.log("🎬 Film chargé avec succès dans la Vue:", film.title)
            Services.ToastService.showSuccess("Film chargé avec succès !")
        }

        /**
         * Réaction en cas d'erreur
         *
         * Actions :
         * - Toast d'erreur
         * - Logs pour debugging
         *
         * À noter :
         * - La page reste affichée (pas de fermeture auto)
         * - L'utilisateur peut cliquer retour
         * - Page affiche "Impossible de charger le film"
         */
        function onLoadError(message) {
            console.log("⚠️ Erreur de chargement reçue dans la Vue:", message)
            Services.ToastService.showError(message)
        }
    }


    // ============================================
    // INITIALISATION - Délégation à la Logic
    // ============================================

    Component.onCompleted: {
        console.log("=== DEBUG FilmDetailPage ===")
        console.log("📄 Page de détails chargée")
        console.log("🆔 Film ID reçu:", filmId)

        // Validation
        if (filmId <= 0) {
            Services.ToastService.showError("ID de film invalide")
            navigationStack.pop()
            return
        }

        // ✅ DÉLÉGATION À LA LOGIC (pas de logique métier ici)
        // Chargement du film
        console.log("📂 Chargement du film...")
        logic.loadFilm(filmId)
    }
}
