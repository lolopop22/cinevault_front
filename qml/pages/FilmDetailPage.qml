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
 * Utilise ToastService pour afficher les notifications
 */
FlickablePage {
    id: filmDetailPage

    // ============================================
    // PROPRIÉTÉ PUBLIQUE - Interface de navigation
    // ===========================================
    // ID du film à afficher (passé lors du push)
    property int filmId: -1

    // ============================================
    // LOGIQUE MÉTIER - Instance de FilmDetailLogic
    // ============================================
    // Bindings automatiques sur logic.currentFilm, logic.loading, logic.errorMessage
    Logic.FilmDetailLogic {
        id: logic
    }

    // ============================================
    // CONFIGURATION DE LA BARRE DE NAVIGATION
    // ============================================

    // Titre dynamique basé sur le film (binding auto sur logic.currentFilm)
    title: logic.currentFilm ? logic.currentFilm.title : "Détails du film"

    // Bouton retour dans la barre de navigation
    leftBarItem: IconButtonBarItem {
        iconType: IconType.arrowleft
        title: "Retour"
        onClicked: {
            // Retour à la page précédente (CataloguePage)
            console.log("⬅️ Retour au catalogue via NavigationBar")

            // Nettoyage de l'état avant de quitter
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
    // CONFIGURATION DU FLICKABLE INTERNE
    // ============================================

    // Configuration du Flickable intégré de FlickablePage
    flickable.contentHeight: contentColumn.height + dp(60)

    // // ============================================
    // // TOAST MANAGER (ListView version)
    // // ============================================

    // /**
    //  * ToastManager avec ListView
    //  * - BottomToTop : nouveaux en bas
    //  * - displaceAnimation : transition fluide
    //  * - interactive: false : pas de scroll
    //  */
    // Components.ToastManager {
    //     id: toastManager
    // }

    // Optionnel : Configuration avancée du flickable
    // flickable.contentWidth: contentColumn.width  // Par défaut = width de la page
    // flickable.flickableDirection: Flickable.VerticalFlick  // Par défaut

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

        Column {
            width: parent.width
            spacing: dp(16)

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
                text: "ID du film : " + filmId
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
    // GESTION DES TOASTS VIA TOASTSERVICE
    // ============================================

    /**
     * Connexions aux signaux de la Logic
     *
     * Utilisation de ToastService :
     * - Services.ToastService.XXX
     * - Pas de dépendance sur "app"
     * - Singleton QML (protection duplication)
     * - Testable (peut être mocké)
     */
    Connections {
        target: logic

        function onFilmLoaded(film) {
            console.log("🎬 Film chargé avec succès dans la Vue:", film.title)
            Services.ToastService.showSuccess("Film chargé avec succès !")
        }

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

        // ✅ DÉLÉGATION À LA LOGIC (pas de logique métier ici)
        logic.loadFilm(filmId)
    }
}
