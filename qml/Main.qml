import Felgo 4.0
import QtQuick 2.15
import "model"
import "pages"
import "components"
import "services"
import "tests"
import "config"


/**
* Point d'entrée de l'application
*
* Responsabilités :
*  - Initialiser ResponsiveConfig avec dimensions
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
    * 1. App démarre -> Main.qml chargé
    * 2. globalToastManager créé (avec parent visuel)
    * 3. Component.onCompleted déclenché
    * 4. Binder ResponsiveConfig aux dimensions de la fenêtre
    * 5. Initialiser ToastService
    *    a. ToastService.initialize(globalToastManager)
    *    b. ToastService stocke la référence
    *    c. ToastService prêt à être utilisé partout
    * 6. Afficher statut
    *
    * Justification :
    * - Inversion de contrôle (IoC pattern)
    * - Main.qml = responsable de l'assemblage
    * - ToastService = indépendant de l'implémentation
    */
    Component.onCompleted: {
        console.log("=== INITIALISATION APPLICATION ===")
        console.log("🔧 Initialisation ToastService...")

        // ✅ Binder ResponsiveConfig
        console.log("🔧 Binding ResponsiveConfig dimensions...")
        ResponsiveConfig.screenWidth = Qt.binding(() => app.width)
        ResponsiveConfig.screenHeight = Qt.binding(() => app.height)

        console.log("✅ ResponsiveConfig initialized")
        ResponsiveConfig.logDeviceInfo()

        // ✅ Initialiser ToastService
        console.log("🔧 Initialisation ToastService...")
        ToastService.initialize(globalToastManager)  // Enregistrement de l'instance visuelle

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

        // ============================================
        // ITEM 1 : CATALOGUE
        // ============================================

        NavigationItem {
            title: "Catalogue"
            iconType: IconType.film

            NavigationStack {
                // Attendre que le modèle soit prêt avant de créer la page
                // initialPage: Component {
                //     CataloguePage {
                //         /* Plus besoin de passer le modèle, il sera accessible via import car on passe maintenant par le pattern Singleton */
                //     }
                // }


                /* Instance directe pour initialPage:
                * FilmDataSingletonModel est déjà disponible
                * CataloguePage est toujours la première page affichée
                * Pas de bénéfice au lazy loading
                */
                initialPage: CataloguePage {}
            }

            Component.onCompleted: {
                console.log("=== DEBUG App - NavigationItem - Catalogue ===")
                console.log(" ")
            }
        }

        // ============================================
        // ITEM 2 : TESTS
        // ============================================

        NavigationItem {
            title: "Tests"
            iconType: IconType.compass

            NavigationStack {
                initialPage: Component {
                    AppPage {
                        title: "Tests Responsive Features"

                        Column {
                            anchors.fill: parent
                            anchors.margins: dp(16)
                            spacing: dp(12)

                            Text {
                                color: "#111827"
                                font.pixelSize: 14
                                font.bold: true
                                text: "Choisir un test :"
                            }

                            AppButton {
                                text: "Test Spacing"
                                width: parent.width
                                onClicked: navigationStack.push(
                                               testResponsiveSpacingComponent)
                            }

                            AppButton {
                                text: "Test Content Margin Adaptatif"
                                width: parent.width
                                onClicked: navigationStack.push(
                                               testResponsiveContentMarginComponent)
                            }

                            AppButton {
                                text: "Test Item Spacing Adaptatif"
                                width: parent.width
                                onClicked: navigationStack.push(
                                               testResponsiveItemSpacingComponent)
                            }

                            AppButton {
                                text: "Test Calcul Largeur Colonne"
                                width: parent.width
                                onClicked: navigationStack.push(
                                               testResponsiveCalculateColumnWidthComponent)
                            }

                            AppButton {
                                text: "Test DeviceInfo"
                                width: parent.width
                                onClicked: navigationStack.push(
                                               testResponsiveDeviceInfoComponent)
                            }
                        }
                    }
                }
            }
        }

        // ============================================
        // ITEM 3 : RECHERCHE
        // ============================================

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

        // ============================================
        // ITEM 4 : PROFIL
        // ============================================

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

    // ============================================
    // COMPOSANTS DE TEST
    // ============================================

    Component {
        id: testResponsiveSpacingComponent
        TestResponsiveSpacing {}
    }

    Component {
        id: testResponsiveContentMarginComponent
        TestResponsiveContentMargin {}
    }

    Component {
        id: testResponsiveItemSpacingComponent
        TestResponsiveItemSpacing {}
    }

    Component {
        id: testResponsiveCalculateColumnWidthComponent
        TestResponsiveCalculateColumnWidth {}
    }

    Component {
        id: testResponsiveDeviceInfoComponent
        TestResponsiveDeviceInfo {}
    }
}
