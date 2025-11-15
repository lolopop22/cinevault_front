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
                initialPage: CataloguePage { }
            }

            Component.onCompleted: {
                console.log("=== DEBUG App - NavigationItem - Catalogue ===")
                console.log(" ")
            }
        }

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
                                onClicked: navigationStack.push(testResponsiveSpacingComponent)
                            }

                            AppButton {
                                text: "Test Content Margin Adaptatif"
                                width: parent.width
                                onClicked: navigationStack.push(testResponsiveContentMarginComponent)
                            }

                            AppButton {
                                text: "Test Item Spacing Adaptatif"
                                width: parent.width
                                onClicked: navigationStack.push(testResponsiveItemSpacingComponent)
                            }
                        }
                    }
                }
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
}


// import QtQuick
// import QtQuick.Window
// import QtQuick.Controls
// import "config"

// /**
//  * TestStep1_3_1.qml - Étape 1.3.1 TEST : ESPACEMENT STATIQUE
//  *
//  * ✅ Objectifs :
//  * 1. Vérifier que les 7 niveaux de spacing sont définis
//  * 2. Afficher les 7 valeurs dans la console
//  * 3. Afficher visuellement les espacements
//  * 4. Comprendre chaque niveau et son utilité
//  *
//  * ✅ TESTABLE :
//  * • Console logs affichant les 7 valeurs
//  * • Visuel montrant les espacements progressifs
//  * • Pas d'erreur de compilation
//  */

// Window {
//     id: mainWindow
//     visible: true
//     width: 800
//     height: 600
//     title: "Test Étape 1.3.1 - Espacement Statique ✅"

//     // ═══════════════════════════════════════════════════════════
//     // LOGS DE DEBUG - Vérifier les valeurs
//     // ═══════════════════════════════════════════════════════════

//     Component.onCompleted: {
//         console.log(`
// ╔═══════════════════════════════════════════════════════════════╗
// ║ ✅ ÉTAPE 1.3.1 : ESPACEMENT STATIQUE - 7 NIVEAUX           ║
// ╠═══════════════════════════════════════════════════════════════╣
// ║ Les 7 niveaux d'espacement disponibles :
// ║
// ║ Niveau │ Valeur │ Utilisation
// ║────────┼────────┼──────────────────────────────────────────
// ║ xs     │ ${ResponsiveConfig.spacing.xs}px    │ Micro-spacing (bordures)
// ║ sm     │ ${ResponsiveConfig.spacing.sm}px    │ Petit padding
// ║ md     │ ${ResponsiveConfig.spacing.md}px   │ Padding standard
// ║ lg     │ ${ResponsiveConfig.spacing.lg}px   │ Marge moyen
// ║ xl     │ ${ResponsiveConfig.spacing.xl}px   │ Marge grand
// ║ xxl    │ ${ResponsiveConfig.spacing.xxl}px   │ Marge très grand
// ║ xxxl   │ ${ResponsiveConfig.spacing.xxxl}px   │ Marge énorme
// ║
// ║ 📊 Progression : 4 → 8 → 12 → 16 → 20 → 24 → 32
// ║
// ║ ✅ Si tu vois ces 7 valeurs → Étape 1.3.1 réussie !
// ╚═══════════════════════════════════════════════════════════════╝
//         `)
//     }

//     Rectangle {
//         anchors.fill: parent
//         color: "#0f1419"

//         Column {
//             anchors.fill: parent
//             anchors.margins: 16
//             spacing: 12

//             // ═══════════════════════════════════════════════════════════
//             // SECTION 1 : TITRE
//             // ═══════════════════════════════════════════════════════════

//             Text {
//                 color: "#f3f4f6"
//                 font.pixelSize: 22
//                 font.bold: true
//                 text: "Étape 1.3.1 : Espacement Statique ✅"
//             }

//             Text {
//                 color: "#9ca3af"
//                 font.pixelSize: 12
//                 text: "Les 7 niveaux d'espacement définis dans ResponsiveConfig.spacing"
//             }

//             // ═══════════════════════════════════════════════════════════
//             // SECTION 2 : TABLEAU DES VALEURS
//             // ═══════════════════════════════════════════════════════════

//             Rectangle {
//                 width: parent.width
//                 height: 250
//                 color: "#1f2937"
//                 radius: 8

//                 Column {
//                     anchors.fill: parent
//                     anchors.margins: 12
//                     spacing: 8

//                     Text {
//                         color: "#f3f4f6"
//                         font.pixelSize: 14
//                         font.bold: true
//                         text: "📊 Les 7 niveaux avec leurs valeurs :"
//                     }

//                     // Grille des espacements
//                     Column {
//                         width: parent.width
//                         spacing: 6

//                         // xs
//                         Row {
//                             width: parent.width
//                             spacing: 12

//                             Text {
//                                 width: 50
//                                 color: "#60a5fa"
//                                 font.pixelSize: 12
//                                 font.bold: true
//                                 text: "xs"
//                             }

//                             Rectangle {
//                                 width: ResponsiveConfig.spacing.xs
//                                 height: 20
//                                 color: "#6366f1"
//                                 radius: 2
//                             }

//                             Text {
//                                 color: "#d1d5db"
//                                 font.pixelSize: 11
//                                 text: `${ResponsiveConfig.spacing.xs}px - Micro-spacing`
//                             }
//                         }

//                         // sm
//                         Row {
//                             width: parent.width
//                             spacing: 12

//                             Text {
//                                 width: 50
//                                 color: "#60a5fa"
//                                 font.pixelSize: 12
//                                 font.bold: true
//                                 text: "sm"
//                             }

//                             Rectangle {
//                                 width: ResponsiveConfig.spacing.sm
//                                 height: 20
//                                 color: "#6366f1"
//                                 radius: 2
//                             }

//                             Text {
//                                 color: "#d1d5db"
//                                 font.pixelSize: 11
//                                 text: `${ResponsiveConfig.spacing.sm}px - Petit padding`
//                             }
//                         }

//                         // md
//                         Row {
//                             width: parent.width
//                             spacing: 12

//                             Text {
//                                 width: 50
//                                 color: "#60a5fa"
//                                 font.pixelSize: 12
//                                 font.bold: true
//                                 text: "md"
//                             }

//                             Rectangle {
//                                 width: ResponsiveConfig.spacing.md
//                                 height: 20
//                                 color: "#6366f1"
//                                 radius: 2
//                             }

//                             Text {
//                                 color: "#d1d5db"
//                                 font.pixelSize: 11
//                                 text: `${ResponsiveConfig.spacing.md}px - Padding standard`
//                             }
//                         }

//                         // lg
//                         Row {
//                             width: parent.width
//                             spacing: 12

//                             Text {
//                                 width: 50
//                                 color: "#60a5fa"
//                                 font.pixelSize: 12
//                                 font.bold: true
//                                 text: "lg"
//                             }

//                             Rectangle {
//                                 width: ResponsiveConfig.spacing.lg
//                                 height: 20
//                                 color: "#6366f1"
//                                 radius: 2
//                             }

//                             Text {
//                                 color: "#d1d5db"
//                                 font.pixelSize: 11
//                                 text: `${ResponsiveConfig.spacing.lg}px - Marge moyen`
//                             }
//                         }

//                         // xl
//                         Row {
//                             width: parent.width
//                             spacing: 12

//                             Text {
//                                 width: 50
//                                 color: "#60a5fa"
//                                 font.pixelSize: 12
//                                 font.bold: true
//                                 text: "xl"
//                             }

//                             Rectangle {
//                                 width: ResponsiveConfig.spacing.xl
//                                 height: 20
//                                 color: "#6366f1"
//                                 radius: 2
//                             }

//                             Text {
//                                 color: "#d1d5db"
//                                 font.pixelSize: 11
//                                 text: `${ResponsiveConfig.spacing.xl}px - Marge grand`
//                             }
//                         }

//                         // xxl
//                         Row {
//                             width: parent.width
//                             spacing: 12

//                             Text {
//                                 width: 50
//                                 color: "#60a5fa"
//                                 font.pixelSize: 12
//                                 font.bold: true
//                                 text: "xxl"
//                             }

//                             Rectangle {
//                                 width: ResponsiveConfig.spacing.xxl
//                                 height: 20
//                                 color: "#6366f1"
//                                 radius: 2
//                             }

//                             Text {
//                                 color: "#d1d5db"
//                                 font.pixelSize: 11
//                                 text: `${ResponsiveConfig.spacing.xxl}px - Marge très grand`
//                             }
//                         }

//                         // xxxl
//                         Row {
//                             width: parent.width
//                             spacing: 12

//                             Text {
//                                 width: 50
//                                 color: "#60a5fa"
//                                 font.pixelSize: 12
//                                 font.bold: true
//                                 text: "xxxl"
//                             }

//                             Rectangle {
//                                 width: ResponsiveConfig.spacing.xxxl
//                                 height: 20
//                                 color: "#6366f1"
//                                 radius: 2
//                             }

//                             Text {
//                                 color: "#d1d5db"
//                                 font.pixelSize: 11
//                                 text: `${ResponsiveConfig.spacing.xxxl}px - Marge énorme`
//                             }
//                         }
//                     }
//                 }
//             }

//             // ═══════════════════════════════════════════════════════════
//             // SECTION 3 : PROGRESSION VISUELLE
//             // ═══════════════════════════════════════════════════════════

//             Text {
//                 color: "#f3f4f6"
//                 font.pixelSize: 14
//                 font.bold: true
//                 text: "📈 Progression visuelle (du plus petit au plus grand) :"
//             }

//             Rectangle {
//                 width: parent.width
//                 height: 200
//                 color: "#1f2937"
//                 radius: 8

//                 Column {
//                     anchors.fill: parent
//                     anchors.margins: 12
//                     anchors.left: parent.left
//                     anchors.leftMargin: 12
//                     spacing: 8

//                     // Chaque carré représente un niveau
//                     Row {
//                         spacing: 0

//                         Rectangle {
//                             width: 20 + ResponsiveConfig.spacing.xs * 4
//                             height: 40
//                             color: "#6366f1"
//                             radius: 4

//                             Text {
//                                 anchors.centerIn: parent
//                                 color: "white"
//                                 font.pixelSize: 10
//                                 text: "xs"
//                             }
//                         }

//                         Rectangle {
//                             width: 20 + ResponsiveConfig.spacing.sm * 4
//                             height: 40
//                             color: "#8b5cf6"
//                             radius: 4

//                             Text {
//                                 anchors.centerIn: parent
//                                 color: "white"
//                                 font.pixelSize: 10
//                                 text: "sm"
//                             }
//                         }

//                         Rectangle {
//                             width: 20 + ResponsiveConfig.spacing.md * 4
//                             height: 40
//                             color: "#a78bfa"
//                             radius: 4

//                             Text {
//                                 anchors.centerIn: parent
//                                 color: "white"
//                                 font.pixelSize: 10
//                                 text: "md"
//                             }
//                         }

//                         Rectangle {
//                             width: 20 + ResponsiveConfig.spacing.lg * 4
//                             height: 40
//                             color: "#c4b5fd"
//                             radius: 4

//                             Text {
//                                 anchors.centerIn: parent
//                                 color: "white"
//                                 font.pixelSize: 10
//                                 text: "lg"
//                             }
//                         }

//                         Rectangle {
//                             width: 20 + ResponsiveConfig.spacing.xl * 4
//                             height: 40
//                             color: "#ddd6fe"
//                             radius: 4

//                             Text {
//                                 anchors.centerIn: parent
//                                 color: "#1f2937"
//                                 font.pixelSize: 10
//                                 text: "xl"
//                             }
//                         }
//                     }
//                 }
//             }

//             // ═══════════════════════════════════════════════════════════
//             // SECTION 4 : MESSAGES DE VALIDATION
//             // ═══════════════════════════════════════════════════════════

//             Rectangle {
//                 width: parent.width
//                 height: 60
//                 color: "#047857"
//                 radius: 6

//                 Column {
//                     anchors.fill: parent
//                     anchors.margins: 10
//                     spacing: 4

//                     Text {
//                         color: "#ecfdf5"
//                         font.pixelSize: 12
//                         font.bold: true
//                         text: "✅ ÉTAPE 1.3.1 RÉUSSIE !"
//                     }

//                     Text {
//                         color: "#d1fae5"
//                         font.pixelSize: 10
//                         text: "Les 7 niveaux d'espacement sont définis et affichés ✓"
//                     }

//                     Text {
//                         color: "#d1fae5"
//                         font.pixelSize: 10
//                         text: "Vérifiez la console pour les valeurs complètes"
//                     }
//                 }
//             }
//         }
//     }
// }

