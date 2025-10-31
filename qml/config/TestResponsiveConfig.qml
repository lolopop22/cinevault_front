import QtQuick
import QtQuick.Window
import QtQuick.Controls
import "config"

/**
 * Test visuel INTERACTIVE de la grille responsive
 * 
 * Ce test vérifie :
 * - Breakpoints chargés correctement
 * - Nombre de colonnes adapté à la largeur
 * - Largeur colonne calculée correctement
 * - GridView se réorganise en temps réel
 * 
 * INSTRUCTIONS :
 * 1. Placer ce fichier à la racine du projet (qml/)
 * 2. Renommer ResponsiveConfig_Step1_1_2.qml → ResponsiveConfig.qml et placer dans qml/config/
 * 3. Ajouter dans qml/qmldir : singleton ResponsiveConfig 1.0 config/ResponsiveConfig.qml
 * 4. Lancer : qml TestStep1_2.qml
 * 5. Redimensionner la fenêtre (voir la grille se réorganiser)
 * 6. Vérifier la console pour les calculs
 */

Window {
    id: mainWindow
    visible: true
    width: 800
    height: 600
    title: "Test Grille Responsive"
    
    // À chaque changement de largeur, afficher les infos
    onWidthChanged: {
        const cols = ResponsiveConfig.getColumnCount(width)
        const colWidth = ResponsiveConfig.calculateColumnWidth(width)
        console.log(`
╔════════════════════════════════════════════╗
║ GRILLE RESPONSIVE - UPDATE                ║
╠════════════════════════════════════════════╣
║ Largeur fenêtre  : ${width.toString().padEnd(3)}px
║ Hauteur fenêtre  : ${height.toString().padEnd(3)}px
║ Colonnes         : ${cols}
║ Largeur/colonne  : ${colWidth.toFixed(0)}px
╚════════════════════════════════════════════╝
        `)
    }
    
    Component.onCompleted: {
        console.log(`
╔════════════════════════════════════════════╗
║ ✅ BREAKPOINTS ET GRILLE CHARGÉS          ║
╠════════════════════════════════════════════╣
║ BREAKPOINTS :
║   mobileSmall     : ${ResponsiveConfig.breakpoints.mobileSmall}px
║   mobileNormal    : ${ResponsiveConfig.breakpoints.mobileNormal}px
║   tabletPortrait  : ${ResponsiveConfig.breakpoints.tabletPortrait}px
║   tabletLandscape : ${ResponsiveConfig.breakpoints.tabletLandscape}px
║   desktop         : ${ResponsiveConfig.breakpoints.desktop}px
║   desktopLarge    : ${ResponsiveConfig.breakpoints.desktopLarge}px
║
║ CONFIGURATION GRILLE :
║   Mobile  : ${ResponsiveConfig.gridConfig.mobileNormalColumns} colonnes
║   Tablet  : ${ResponsiveConfig.gridConfig.tabletPortraitColumns} colonnes
║   Desktop : ${ResponsiveConfig.gridConfig.desktopColumns} colonnes
║
║ 📝 INSTRUCTIONS :
║   • Redimensionnez la fenêtre (tirez les coins)
║   • Observez la grille se réorganiser
║   • Vérifiez la console pour les calculs
║   • Testez ces largeurs : 480, 720, 1024, 1280
╚════════════════════════════════════════════╝
        `)
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#0f1419"  // Gris foncé
        
        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            
            // ═══════════════════════════════════════════════════════════
            // SECTION 1 : EN-TÊTE - INFORMATIONS
            // ═══════════════════════════════════════════════════════════
            
            Rectangle {
                width: parent.width
                height: 100
                color: "#1f2937"
                radius: 8
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8
                    
                    Text {
                        color: "#f3f4f6"
                        font.pixelSize: 18
                        font.bold: true
                        text: "Grille Responsive"
                    }
                    
                    Row {
                        spacing: 20
                        
                        Column {
                            spacing: 2
                            Text {
                                color: "#9ca3af"
                                font.pixelSize: 11
                                text: "Fenêtre"
                            }
                            Text {
                                color: "#60a5fa"
                                font.pixelSize: 14
                                font.bold: true
                                text: `${mainWindow.width}px × ${mainWindow.height}px`
                            }
                        }
                        
                        Column {
                            spacing: 2
                            Text {
                                color: "#9ca3af"
                                font.pixelSize: 11
                                text: "Colonnes"
                            }
                            Text {
                                color: "#60a5fa"
                                font.pixelSize: 14
                                font.bold: true
                                text: ResponsiveConfig.getColumnCount(mainWindow.width)
                            }
                        }
                        
                        Column {
                            spacing: 2
                            Text {
                                color: "#9ca3af"
                                font.pixelSize: 11
                                text: "Largeur/colonne"
                            }
                            Text {
                                color: "#60a5fa"
                                font.pixelSize: 14
                                font.bold: true
                                text: `${ResponsiveConfig.calculateColumnWidth(mainWindow.width).toFixed(0)}px`
                            }
                        }
                    }
                }
            }
            
            // ═══════════════════════════════════════════════════════════
            // SECTION 2 : GUIDE DE TEST
            // ═══════════════════════════════════════════════════════════
            
            Rectangle {
                width: parent.width
                height: 70
                color: "#374151"
                radius: 6
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4
                    
                    Text {
                        color: "#f3f4f6"
                        font.pixelSize: 12
                        font.bold: true
                        text: "🎯 Comment tester :"
                    }
                    
                    Text {
                        color: "#d1d5db"
                        font.pixelSize: 10
                        text: "• Redimensionnez la fenêtre en tirant les bordures"
                        wrapMode: Text.WordWrap
                    }
                    
                    Text {
                        color: "#d1d5db"
                        font.pixelSize: 10
                        text: "• La grille se réorganise automatiquement"
                        wrapMode: Text.WordWrap
                    }
                }
            }
            
            // ═══════════════════════════════════════════════════════════
            // SECTION 3 : GRILLE INTERACTIVE
            // ═══════════════════════════════════════════════════════════
            
            Text {
                color: "#9ca3af"
                font.pixelSize: 12
                text: "Grille de test :"
            }
            
            Rectangle {
                width: parent.width
                height: parent.height - 200
                color: "#111827"
                radius: 8
                border.color: "#4b5563"
                border.width: 1
                clip: true
                
                GridView {
                    id: testGrid
                    anchors.fill: parent
                    anchors.margins: 12
                    
                    // Espacement simulé via cellWidth/cellHeight
                    property real itemSpacing: 12
                    property real contentWidth: width

                    // Largeur colonne calculée (Utiliser calculateColumnWidth() pour adapter la taille) + espacement
                    cellWidth: ResponsiveConfig.calculateColumnWidth(contentWidth) + itemSpacing

                    // Hauteur = ratio 2:3 + espacement
                    cellHeight: (cellWidth - itemSpacing) * (3/2) + itemSpacing
                    
                    model: 12
                    
                    delegate: Rectangle {
                        width: testGrid.cellWidth - 6
                        height: testGrid.cellHeight - 6
                        color: "#6366f1"  // Indigo
                        radius: 8
                        anchors.margins: 3
                        
                        // Effet hover
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.color = "#818cf8"
                            onExited: parent.color = "#6366f1"
                            onClicked: {
                                console.log(`Carte ${index + 1} cliquée`)
                            }
                        }
                        
                        Column {
                            anchors.centerIn: parent
                            spacing: 4
                            
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: "white"
                                font.pixelSize: 20
                                font.bold: true
                                text: (index + 1)
                            }
                            
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: "#a5b4fc"
                                font.pixelSize: 8
                                text: "Cliquez-moi"
                            }
                        }
                    }
                }
            }
        }
    }
}
