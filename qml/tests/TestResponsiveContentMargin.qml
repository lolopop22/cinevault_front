import Felgo 4.0
import QtQuick 2.15
import QtQuick.Layouts

import "../config"


/**
 * TestResponsiveContentMargin - Test getContentMargin() adaptatif
 *
 * Affiche comment les marges du conteneur s'adaptent selon la largeur d'écran
 * Mobile : 8px | Tablet : 16px | Desktop : 20px
 */
AppPage {
    id: testPage
    title: "Test - Content Margin Adaptatif"

    // Scrollable (Flickable) pour afficher tout le contenu
    Flickable {
        anchors.fill: parent
        contentHeight: column.height
        contentWidth: width
        anchors.margins: dp(ResponsiveConfig.spacing.getContentMargin(
                                testPage.width))

        Column {
            id: column
            width: parent.width
            anchors.margins: dp(ResponsiveConfig.spacing.getContentMargin(
                                    testPage.width))
            spacing: dp(12)

            // ════════════════════════════════════════════════════════
            // EN-TÊTE
            // ════════════════════════════════════════════════════════
            Text {
                color: "#111827"
                width: parent.width
                font.pixelSize: sp(18)
                font.bold: true
                text: "getContentMargin() - Marges Adaptatives"
                wrapMode: Text.WordWrap
            }

            Text {
                color: "#4b5563"
                font.pixelSize: sp(13)
                width: parent.width
                text: "Les marges du conteneur changent automatiquement selon la taille de l'écran. Redimensionne la fenêtre pour voir les changements en direct."
                wrapMode: Text.WordWrap
            }

            // ════════════════════════════════════════════════════════
            // INFORMATIONS ACTUELLES
            // ════════════════════════════════════════════════════════
            Text {
                color: "#1f2937"
                font.pixelSize: sp(13)
                font.bold: true
                text: "Valeurs actuelles"
            }

            Rectangle {
                width: parent.width
                height: dp(80)
                color: "#f3f4f6"
                radius: dp(8)
                border.color: "#d1d5db"
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: dp(12)
                    spacing: dp(8)

                    Row {
                        spacing: dp(10)

                        Text {
                            color: "#4b5563"
                            font.pixelSize: sp(11)
                            width: dp(120)
                            text: "Largeur écran :"
                        }

                        Text {
                            color: "#1f2937"
                            font.pixelSize: sp(11)
                            font.bold: true
                            text: testPage.width.toFixed(0) + " px"
                        }
                    }

                    Row {
                        spacing: dp(10)

                        Text {
                            color: "#4b5563"
                            font.pixelSize: sp(11)
                            width: dp(120)
                            text: "Marge appliquée :"
                        }

                        Text {
                            color: "#1f2937"
                            font.pixelSize: sp(11)
                            font.bold: true
                            text: ResponsiveConfig.spacing.getContentMargin(
                                      testPage.width).toFixed(1) + " px"
                        }
                    }

                    Row {
                        spacing: dp(10)

                        Text {
                            color: "#4b5563"
                            font.pixelSize: sp(11)
                            width: dp(120)
                            text: "Type d'écran :"
                        }

                        Text {
                            color: "#1f2937"
                            font.pixelSize: sp(11)
                            font.bold: true
                            text: getDeviceType()
                        }
                    }
                }
            }

            // ════════════════════════════════════════════════════════
            // EXPLICATION
            // ════════════════════════════════════════════════════════
            Rectangle {
                width: parent.width
                height: dp(90)
                color: "#eff6ff"
                radius: dp(6)
                border.color: "#93c5fd"
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: dp(10)
                    spacing: dp(6)

                    Text {
                        color: "#1e40af"
                        font.pixelSize: sp(12)
                        font.bold: true
                        text: "💡 Qu'est-ce que getContentMargin() ?"
                    }

                    Text {
                        color: "#1e3a8a"
                        font.pixelSize: sp(10)
                        text: "Les marges du conteneur s'adaptent à la taille d'écran. Sur mobile, les marges sont plus petites (8px) pour utiliser l'espace. Sur desktop, elles sont plus grandes (20px) pour du confort. Cela crée une meilleure expérience utilisateur sur tous les appareils."
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }

            // ════════════════════════════════════════════════════════
            // TABLEAU DE CORRESPONDANCE
            // ════════════════════════════════════════════════════════
            Text {
                color: "#1f2937"
                font.pixelSize: sp(13)
                font.bold: true
                text: "Correspondance par taille d'écran"
            }

            Column {
                width: parent.width
                spacing: dp(8)

                // Mobile
                Rectangle {
                    width: parent.width
                    height: dp(70)
                    color: "#f3f4f6"
                    radius: dp(6)
                    border.color: "#d1d5db"
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: dp(10)
                        spacing: dp(4)

                        Text {
                            color: "#1f2937"
                            font.pixelSize: sp(12)
                            font.bold: true
                            text: "📱 Mobile (< 720px)"
                        }

                        Text {
                            color: "#4b5563"
                            font.pixelSize: sp(10)
                            text: "Marge appliquée : sm = 8px"
                        }

                        Text {
                            color: "#6b7280"
                            font.pixelSize: sp(9)
                            text: "Utilisation efficace de l'espace limité"
                        }
                    }
                }

                // Tablet
                Rectangle {
                    width: parent.width
                    height: dp(70)
                    color: "#f3f4f6"
                    radius: dp(6)
                    border.color: "#d1d5db"
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: dp(10)
                        spacing: dp(4)

                        Text {
                            color: "#1f2937"
                            font.pixelSize: sp(12)
                            font.bold: true
                            text: "📊 Tablet (720px - 1280px)"
                        }

                        Text {
                            color: "#4b5563"
                            font.pixelSize: sp(10)
                            text: "Marge appliquée : lg = 16px"
                        }

                        Text {
                            color: "#6b7280"
                            font.pixelSize: sp(9)
                            text: "Équilibre entre espace et lisibilité"
                        }
                    }
                }

                // Desktop
                Rectangle {
                    width: parent.width
                    height: dp(70)
                    color: "#f3f4f6"
                    radius: dp(6)
                    border.color: "#d1d5db"
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: dp(10)
                        spacing: dp(4)

                        Text {
                            color: "#1f2937"
                            font.pixelSize: sp(12)
                            font.bold: true
                            text: "🖥️ Desktop (> 1280px)"
                        }

                        Text {
                            color: "#4b5563"
                            font.pixelSize: sp(10)
                            text: "Marge appliquée : xl = 20px"
                        }

                        Text {
                            color: "#6b7280"
                            font.pixelSize: sp(9)
                            text: "Respiration visuelle et confort de lecture"
                        }
                    }
                }
            }

            Item {
                width: 1
                height: dp(12)
            }

            // ════════════════════════════════════════════════════════
            // CONSEIL
            // ════════════════════════════════════════════════════════
            Rectangle {
                width: parent.width
                height: dp(60)
                color: "#1f2937"
                radius: dp(6)
                border.color: "#4b5563"
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: dp(10)
                    spacing: dp(4)

                    Text {
                        color: "#60a5fa"
                        font.pixelSize: sp(11)
                        font.bold: true
                        text: "💡 Essaie ceci"
                    }

                    Text {
                        color: "#e5e7eb"
                        font.pixelSize: sp(10)
                        text: "Redimensionne la fenêtre et regarde la largeur et la marge changer en direct. Les valeurs se mettent à jour automatiquement."
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }

            Item {
                width: 1
                height: dp(20)
            }
        }
    }

    // ════════════════════════════════════════════════════════
    // FONCTION UTILITAIRE
    // ════════════════════════════════════════════════════════


    /**
     * Retourne le type d'écran selon la largeur
     */
    function getDeviceType() {
        if (testPage.width < ResponsiveConfig.breakpoints.tabletPortrait) {
            return "Mobile"
        } else if (testPage.width < ResponsiveConfig.breakpoints.desktop) {
            return "Tablet"
        } else {
            return "Desktop"
        }
    }

    // ════════════════════════════════════════════════════════
    // LOGS DE VALIDATION
    // ════════════════════════════════════════════════════════
    Component.onCompleted: {
        console.log("✅ Test - Content Margin Adaptatif")
        console.log("Largeur écran :", testPage.width.toFixed(0), "px")
        console.log("Marge appliquée (mais on utilise le dp en plus):",
                    ResponsiveConfig.spacing.getContentMargin(
                        testPage.width).toFixed(1), "px")
        console.log("Type écran :", getDeviceType())
    }
}
