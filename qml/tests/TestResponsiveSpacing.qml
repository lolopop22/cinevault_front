import Felgo 4.0
import QtQuick 2.15

import "../config"

/**
 * TestResponsiveSpacing - Test des 7 niveaux d'espacement
 *
 * Affiche visuellement les 7 niveaux d'espacement avec des barres de taille proportionnelle
 * Permet de valider que les espacements responsive sont corrects sur tous les appareils
 */

AppPage {
    id: testPage
    title: "Test - Spacing"

    // Scrollable (Flickable) pour afficher tout le contenu
    Flickable {
        anchors.fill: parent
        contentHeight: column.height
        contentWidth: width
        anchors.margins: dp(10)

        Column {
            id: column
            width: parent.width
            anchors.margins: dp(16)
            spacing: dp(12)

            // ════════════════════════════════════════════════════════
            // EN-TÊTE
            // ════════════════════════════════════════════════════════

            Text {
                color: "#111827"
                font.pixelSize: sp(18)
                font.bold: true
                text: "7 Niveaux d'Espacement"
            }

            Text {
                color: "#4b5563"
                font.pixelSize: sp(13)
                text: "Chaque niveau avec sa barre visuelle (affichage en dp)"
                wrapMode: Text.WordWrap
                width: parent.width
            }

            // ════════════════════════════════════════════════════════
            // LES 7 NIVEAUX D'ESPACEMENT
            // ════════════════════════════════════════════════════════

            // XS (extra small)
            Column {
                width: parent.width
                spacing: dp(6)

                Text {
                    color: "#1f2937"
                    font.pixelSize: sp(12)
                    font.bold: true
                    text: "xs - Micro-espacement"
                }

                Row {
                    width: parent.width
                    spacing: dp(10)

                    // Label
                    Text {
                        color: "#4b5563"
                        font.pixelSize: sp(10)
                        width: dp(60)
                        text: "xs (" + ResponsiveConfig.spacing.xs.toFixed(1) + "px)"
                    }

                    Rectangle {
                        width: dp(ResponsiveConfig.spacing.xs)
                        height: dp(20)
                        color: "#6366f1"
                        radius: dp(3)
                    }

                    // Description
                    Text {
                        color: "#1f2937"
                        font.pixelSize: sp(10)
                        text: "Bordures, traits fins"
                    }
                }
            }

            // SM (small)
            Column {
                width: parent.width
                spacing: dp(6)

                Text {
                    color: "#1f2937"
                    font.pixelSize: sp(12)
                    font.bold: true
                    text: "sm - Petit espacement"
                }

                Row {
                    width: parent.width
                    spacing: dp(10)

                    Text {
                        color: "#4b5563"
                        font.pixelSize: sp(10)
                        width: dp(60)
                        text: "sm (" + ResponsiveConfig.spacing.sm.toFixed(1) + "px)"
                    }

                    Rectangle {
                        width: dp(ResponsiveConfig.spacing.sm)
                        height: dp(20)
                        color: "#6366f1"
                        radius: dp(3)
                    }

                    Text {
                        color: "#1f2937"
                        font.pixelSize: sp(10)
                        text: "Padding buttons, icônes"
                    }
                }
            }

            // MD (medium)
            Column {
                width: parent.width
                spacing: dp(6)

                Text {
                    color: "#1f2937"
                    font.pixelSize: sp(12)
                    font.bold: true
                    text: "md - Espacement standard"
                }

                Row {
                    width: parent.width
                    spacing: dp(10)

                    Text {
                        color: "#4b5563"
                        font.pixelSize: sp(10)
                        width: dp(60)
                        text: "md (" + ResponsiveConfig.spacing.md.toFixed(1) + "px)"
                    }

                    Rectangle {
                        width: dp(ResponsiveConfig.spacing.md)
                        height: dp(20)
                        color: "#6366f1"
                        radius: dp(3)
                    }

                    Text {
                        color: "#1f2937"
                        font.pixelSize: sp(10)
                        text: "Padding conteneurs (Material Design)"
                    }
                }
            }

            // LG (large)
            Column {
                width: parent.width
                spacing: dp(6)

                Text {
                    color: "#1f2937"
                    font.pixelSize: sp(12)
                    font.bold: true
                    text: "lg - Espacement moyen"
                }

                Row {
                    width: parent.width
                    spacing: dp(10)

                    Text {
                        color: "#4b5563"
                        font.pixelSize: sp(10)
                        width: dp(60)
                        text: "lg (" + ResponsiveConfig.spacing.lg.toFixed(1) + "px)"
                    }

                    Rectangle {
                        width: dp(ResponsiveConfig.spacing.lg)
                        height: dp(20)
                        color: "#6366f1"
                        radius: dp(3)
                    }

                    Text {
                        color: "#1f2937"
                        font.pixelSize: sp(10)
                        text: "Marges entre éléments"
                    }
                }
            }

            // XL (extra large)
            Column {
                width: parent.width
                spacing: dp(6)

                Text {
                    color: "#1f2937"
                    font.pixelSize: sp(12)
                    font.bold: true
                    text: "xl - Grand espacement"
                }

                Row {
                    width: parent.width
                    spacing: dp(10)

                    Text {
                        color: "#4b5563"
                        font.pixelSize: sp(10)
                        width: dp(60)
                        text: "xl (" + ResponsiveConfig.spacing.xl.toFixed(1) + "px)"
                    }

                    Rectangle {
                        width: dp(ResponsiveConfig.spacing.xl)
                        height: dp(20)
                        color: "#6366f1"
                        radius: dp(3)
                    }

                    Text {
                        color: "#1f2937"
                        font.pixelSize: sp(10)
                        text: "Séparation sections"
                    }
                }
            }

            // XXL (extra extra large)
            Column {
                width: parent.width
                spacing: dp(6)

                Text {
                    color: "#1f2937"
                    font.pixelSize: sp(12)
                    font.bold: true
                    text: "xxl - Très grand espacement"
                }

                Row {
                    width: parent.width
                    spacing: dp(10)

                    Text {
                        color: "#4b5563"
                        font.pixelSize: sp(10)
                        width: dp(60)
                        text: "xxl (" + ResponsiveConfig.spacing.xxl.toFixed(1) + "px)"
                    }

                    Rectangle {
                        width: dp(ResponsiveConfig.spacing.xxl)
                        height: dp(20)
                        color: "#6366f1"
                        radius: dp(3)
                    }

                    Text {
                        color: "#1f2937"
                        font.pixelSize: sp(10)
                        text: "Blocs majeurs, hiérarchie"
                    }
                }
            }

            // XXXL (extra extra extra large)
            Column {
                width: parent.width
                spacing: dp(6)

                Text {
                    color: "#1f2937"
                    font.pixelSize: sp(12)
                    font.bold: true
                    text: "xxxl - Énorme espacement"
                }

                Row {
                    width: parent.width
                    spacing: dp(10)

                    Text {
                        color: "#4b5563"
                        font.pixelSize: sp(10)
                        width: dp(60)
                        text: "xxxl (" + ResponsiveConfig.spacing.xxxl.toFixed(1) + "px)"
                    }

                    Rectangle {
                        width: dp(ResponsiveConfig.spacing.xxxl)
                        height: dp(20)
                        color: "#6366f1"
                        radius: dp(3)
                    }

                    Text {
                        color: "#1f2937"
                        font.pixelSize: sp(10)
                        text: "Respiration desktop large"
                    }
                }
            }

            Item { width: 1; height: dp(20) }
        }
    }

    // ════════════════════════════════════════════════════════
    // LOGS DE VALIDATION
    // ════════════════════════════════════════════════════════

    Component.onCompleted: {
        console.log("Test - 7 Niveaux d'Espacement")
        console.log("xs:", ResponsiveConfig.spacing.xs.toFixed(2), "px")
        console.log("sm:", ResponsiveConfig.spacing.sm.toFixed(2), "px")
        console.log("md:", ResponsiveConfig.spacing.md.toFixed(2), "px")
        console.log("lg:", ResponsiveConfig.spacing.lg.toFixed(2), "px")
        console.log("xl:", ResponsiveConfig.spacing.xl.toFixed(2), "px")
        console.log("xxl:", ResponsiveConfig.spacing.xxl.toFixed(2), "px")
        console.log("xxxl:", ResponsiveConfig.spacing.xxxl.toFixed(2), "px")
    }
}
