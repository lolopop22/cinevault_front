import Felgo 4.0
import QtQuick 2.15

import "../config"

/**
 * TestResponsiveItemSpacing - Test getItemSpacing() adaptatif
 *
 * Affiche une GridView avec espacement adaptatif selon la taille d'écran
 * Mobile : 8px | Tablet : 12px | Desktop : 16px
 */

AppPage {
    id: testPage
    title: "Test - Item Spacing Adaptatif"

    // Scrollable (Flickable) pour afficher tout le contenu
    Flickable {
        anchors.fill: parent
        contentHeight: column.height
        contentWidth: width
        anchors.margins: dp(ResponsiveConfig.spacing.getContentMargin(testPage.width))

        Column {
            id: column
            width: parent.width
            anchors.margins: dp(ResponsiveConfig.spacing.getContentMargin(testPage.width))
            spacing: dp(12)

            // ════════════════════════════════════════════════════════
            // EN-TÊTE
            // ════════════════════════════════════════════════════════

            Text {
                color: "#111827"
                font.pixelSize: sp(18)
                font.bold: true
                text: "getItemSpacing() - Grille Adaptative"
            }

            Text {
                color: "#4b5563"
                font.pixelSize: sp(13)
                text: "L'espacement entre les cartes change automatiquement selon la taille d'écran. Les cartes se réorganisent en fonction du nombre de colonnes optimal."
                wrapMode: Text.WordWrap
                width: parent.width
            }

            Item { width: 1; height: dp(8) }

            // ════════════════════════════════════════════════════════
            // INFORMATIONS ACTUELLES
            // ════════════════════════════════════════════════════════

            Text {
                color: "#1f2937"
                font.pixelSize: sp(13)
                font.bold: true
                text: "Paramètres actuels"
            }

            Rectangle {
                width: parent.width
                height: dp(110)
                color: "#f3f4f6"
                radius: dp(8)
                border.color: "#d1d5db"
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: dp(12)
                    spacing: dp(8)

                    // Largeur et type écran
                    Row {
                        width: parent.width
                        spacing: dp(20)

                        Column {
                            spacing: dp(3)

                            Text {
                                color: "#4b5563"
                                font.pixelSize: sp(10)
                                text: "Largeur écran"
                            }

                            Text {
                                color: "#1f2937"
                                font.pixelSize: sp(12)
                                font.bold: true
                                text: testPage.width.toFixed(0) + " px"
                            }
                        }

                        Column {
                            spacing: dp(3)

                            Text {
                                color: "#4b5563"
                                font.pixelSize: sp(10)
                                text: "Type d'écran"
                            }

                            Text {
                                color: "#1f2937"
                                font.pixelSize: sp(12)
                                font.bold: true
                                text: getDeviceType(testPage.width)
                            }
                        }
                    }

                    // Colonnes et espacement
                    Row {
                        width: parent.width
                        spacing: dp(20)

                        Column {
                            spacing: dp(3)

                            Text {
                                color: "#4b5563"
                                font.pixelSize: sp(10)
                                text: "Nombre colonnes"
                            }

                            Text {
                                color: "#1f2937"
                                font.pixelSize: sp(12)
                                font.bold: true
                                text: ResponsiveConfig.getColumnCount(testGrid.width) + " col"
                            }
                        }

                        Column {
                            spacing: dp(3)

                            Text {
                                color: "#4b5563"
                                font.pixelSize: sp(10)
                                text: "Item Spacing"
                            }

                            Text {
                                color: "#1f2937"
                                font.pixelSize: sp(12)
                                font.bold: true
                                text: ResponsiveConfig.spacing.getItemSpacing(testPage.width).toFixed(1) + " px"
                            }
                        }
                    }
                }
            }

            Item { width: 1; height: dp(12) }

            // ════════════════════════════════════════════════════════
            // EXPLICATION
            // ════════════════════════════════════════════════════════

            Rectangle {
                width: parent.width
                height: dp(85)
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
                        text: "💡 Qu'est-ce que getItemSpacing() ?"
                    }

                    Text {
                        color: "#1e3a8a"
                        font.pixelSize: sp(10)
                        text: "L'espacement entre les cartes s'adapte à la largeur d'écran. Sur mobile, les espaces sont réduits (8px). Sur tablet, ils augmentent (12px). Sur desktop, ils sont plus grands (16px) pour une meilleure respiration visuelle."
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }

            Item { width: 1; height: dp(12) }

            // ════════════════════════════════════════════════════════
            // TABLEAU DE CORRESPONDANCE
            // ════════════════════════════════════════════════════════

            Text {
                color: "#1f2937"
                font.pixelSize: sp(13)
                font.bold: true
                text: "Correspondance par écran"
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
                            text: "Espacement : 8px  |  Colonnes : 2"
                        }

                        Text {
                            color: "#6b7280"
                            font.pixelSize: sp(9)
                            text: "Priorité : espace utilisable limité"
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
                            text: "Espacement : 12px  |  Colonnes : 3-4"
                        }

                        Text {
                            color: "#6b7280"
                            font.pixelSize: sp(9)
                            text: "Priorité : équilibre espace/lisibilité"
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
                            text: "Espacement : 16px  |  Colonnes : 5-6"
                        }

                        Text {
                            color: "#6b7280"
                            font.pixelSize: sp(9)
                            text: "Priorité : respiration visuelle"
                        }
                    }
                }
            }

            Item { width: 1; height: dp(12) }


            // ════════════════════════════════════════════════════════
            // CONSEIL
            // ════════════════════════════════════════════════════════

            Rectangle {
                width: parent.width
                height: dp(65)
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
                        text: "Redimensionne la fenêtre ou change d'appareil. La grille se réorganise automatiquement : le nombre de colonnes change, l'espacement s'adapte, les cartes se repositionnent."
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }

            Item { width: 1; height: dp(20) }

            // ════════════════════════════════════════════════════════
            // GRILLE AVEC ESPACEMENT ADAPTATIF
            // ════════════════════════════════════════════════════════

            Text {
                color: "#1f2937"
                font.pixelSize: sp(13)
                font.bold: true
                text: "Grille de démonstration"
            }

            Rectangle {
                width: parent.width
                height: Math.max(testGrid.contentHeight + dp(24), dp(400))
                color: "#f3f4f6"
                radius: dp(6)
                border.color: "#d1d5db"
                border.width: 1
                clip: true

                GridView {
                    id: testGrid
                    anchors.fill: parent
                    anchors.margins: dp(12)

                    // anchors.horizontalCenter: parent.horizontalCenter

                    interactive: false

                    property real itemSpacing: ResponsiveConfig.spacing.getItemSpacing(testGrid.width)
                    property int columnCount: ResponsiveConfig.getColumnCount(testGrid.width)

                    // cellWidth: ResponsiveConfig.calculateColumnWidth(testGrid.width, columnCount) + itemSpacing
                    // cellHeight: cellWidth * (4/3)

                    cellWidth: {
                        if (width <= 0 || columnCount <= 0) return 100
                        const spacing = (columnCount - 1) * itemSpacing
                        const calc = (width - spacing) / columnCount
                        return Math.max(calc, 50)
                    }

                    cellHeight: {
                        if (cellWidth <= 0) return 67
                        return Math.max(cellWidth * (4/3), 67)
                    }

                    model: 12

                    Component.onCompleted: {
                        console.log("=== GRIDVIEW DEBUG ===")
                        console.log("GridView width:", width)
                        console.log("itemSpacing:", itemSpacing, "px")
                        console.log("columnCount:", columnCount)
                        console.log("cellWidth:", cellWidth)
                        console.log("cellHeight:", cellHeight)
                        console.log("Calcul colonnes possibles:", Math.floor(width / cellWidth))
                    }

                    delegate: Rectangle {
                        width: testGrid.cellWidth - testGrid.itemSpacing * 0.5
                        height: testGrid.cellHeight - testGrid.itemSpacing * 0.5 // O.5 pour espacement des 2 côtés

                        color: "#6366f1"
                        radius: dp(6)

                        // anchors.centerIn: parent  // c'est à cause de lui que je ne voyais qu'une seule carte...

                        Component.onCompleted: {
                            console.log("=== GRIDVIEW DEBUG ===")
                            console.log("Carte", index + 1,
                                        "- width:", width,
                                        "- height:", height,
                                        "- x:", x,
                                        "- y:", y)
                        }

                        // Hover effect
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.color = "#818cf8"
                            onExited: parent.color = "#6366f1"
                        }

                        // Contenu de la carte
                        Column {
                            anchors.centerIn: parent
                            spacing: dp(4)

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: "white"
                                font.pixelSize: sp(16)
                                font.bold: true
                                text: (index + 1)
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: "#a5b4fc"
                                font.pixelSize: sp(9)
                                text: "Carte"
                            }
                        }
                    }
                }
            }

            Item { width: 1; height: dp(12) }
        }
    }

    // ════════════════════════════════════════════════════════
    // FONCTION UTILITAIRE
    // ════════════════════════════════════════════════════════

    /**
     * Retourne le type d'écran selon la largeur
     *
     * @param screenWidth - Largeur en pixels
     * @return Type d'écran ("Mobile", "Tablet" ou "Desktop")
     */
    function getDeviceType(screenWidth) {
        if (screenWidth < ResponsiveConfig.breakpoints.tabletPortrait) {
            return "Mobile"
        } else if (screenWidth < ResponsiveConfig.breakpoints.desktop) {
            return "Tablet"
        } else {
            return "Desktop"
        }
    }

    // ════════════════════════════════════════════════════════
    // LOGS DE VALIDATION
    // ════════════════════════════════════════════════════════

    Component.onCompleted: {
        console.log("✅ Test - Item Spacing Adaptatif")
        console.log("Largeur écran :", testPage.width.toFixed(0), "px")
        console.log("Type écran :", getDeviceType(testPage.width))
        console.log("Colonnes :", ResponsiveConfig.getColumnCount(testGrid.width))
        console.log("Item Spacing :", ResponsiveConfig.spacing.getItemSpacing(testPage.width).toFixed(1), "px")
    }
}
