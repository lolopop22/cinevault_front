import Felgo 4.0
import QtQuick 2.15
import "model"
import "pages"
import "components"
import "services"

/**
 * Point d'entrée de l'application
 *
 * Responsabilités :
 * - Créer l'instance visuelle de ToastManager
 * - Initialiser ToastService avec cette instance
 * - Configurer la navigation
 */
App {
    id: app

    // ============================================
    // TOAST MANAGER - Instance visuelle unique
    // ============================================

    /**
     * ToastManager - Gestionnaire visuel des toasts
     *
     * Architecture :
     * - Instance unique (Singleton pattern)
     * - Parent : Overlay.overlay (toujours visible)
     * - Accessible via ToastService (indirection)
     *
     * Justification :
     * - ToastManager est un composant visuel
     * - Besoin d'un parent dans la hiérarchie visuelle
     * - Overlay.overlay disponible uniquement ici (App/ApplicationWindow)
     *
     * ⚠️ Ne PAS référencer directement dans les pages
     *    Utiliser ToastService à la place
     */
    ToastManager {
        id: globalToastManager

        /**
         * Parent : Overlay de l'application
         *
         * Overlay.overlay :
         * - Couche au-dessus de tout le contenu
         * - Fournie par ApplicationWindow (dont App hérite)
         * - Toujours visible, même pendant transitions de pages
         *
         * Justification :
         * - Toasts doivent être visibles partout
         * - Au-dessus de la navigation (z-order élevé)
         * - Persistent pendant changements de pages
         */
        parent: Overlay.overlay

        /**
         * Remplit tout l'overlay
         *
         * Justification :
         * - Permet positionnement des toasts en bas
         * - Responsive (s'adapte à la taille de fenêtre)
         */
        anchors.fill: parent

        /**
         * Z-index très élevé
         *
         * Justification :
         * - Au-dessus de tous les autres composants
         * - Même au-dessus des dialogs (z < 10000)
         * - Garantit visibilité en toute circonstance
         */
        z: 10000
    }

    // ============================================
    // INITIALISATION TOASTSERVICE
    // ============================================

    /**
     * Initialisation du ToastService Singleton
     *
     * Flow :
     * 1. App démarre → Main.qml chargé
     * 2. globalToastManager créé (avec parent visuel)
     * 3. Component.onCompleted déclenché
     * 4. ToastService.initialize(globalToastManager)
     * 5. ToastService stocke la référence
     * 6. ToastService prêt à être utilisé partout
     *
     * Justification :
     * - Inversion de contrôle (IoC pattern)
     * - Main.qml = responsable de l'assemblage
     * - ToastService = indépendant de l'implémentation
     */
    Component.onCompleted: {
        console.log("=== INITIALISATION APPLICATION ===")
        console.log("🔧 Initialisation ToastService...")

        // Enregistrement de l'instance visuelle
        ToastService.initialize(globalToastManager)

        // Validation
        if (ToastService.isInitialized()) {
            console.log("✅ ToastService prêt à l'emploi")
        } else {
            console.error("❌ ToastService n'a pas pu être initialisé")
        }

        // Le modèle est maintenant sûrement prêt
        console.log("Films disponibles:", FilmDataSingletonModel.films.length)
        console.log(" ")

        // Chargement initial des données (sera implémenté plus tard)

        console.log("=== APPLICATION PRÊTE ===")
    }

    // ============================================
    // NAVIGATION
    // ============================================

    // Navigation principale avec Bottom Navigation
    Navigation {
        navigationMode: navigationModeDefault

        NavigationItem {
            title: "Catalogue"
            iconType: IconType.film

            NavigationStack {
                // Attendre que le modèle soit prêt avant de créer la page
                initialPage: Component {
                    CataloguePage {
                        /* Plus besoin de passer le modèle, il sera accessible via import car on passe maintenant par le pattern Singleton */
                    }
                }
            }

            Component.onCompleted: {
                console.log("=== DEBUG App - NavigationItem - Catalogue ===")
                console.log(" ")
            }
        }


        NavigationItem {
            title: "Recherche"
            iconType: IconType.search

            NavigationStack {
                AppPage {
                    title: "Recherche"
                    AppText {
                        anchors.centerIn: parent
                        text: "Page Recherche - À implémenter"
                    }
                }
            }

            Component.onCompleted: {
                console.log("=== DEBUG App - NavigationItem - Recherche ===")
                console.log(" ")
            }
        }

        NavigationItem {
            title: "Profil"
            iconType: IconType.user

            NavigationStack {
                AppPage {
                    title: "Profil"
                    AppText {
                        anchors.centerIn: parent
                        text: "Page Profil - À implémenter"
                    }
                }
            }

            Component.onCompleted: {
                console.log("=== DEBUG App - NavigationItem - Profil ===")
                console.log(" ")
            }
        }
    }
}
