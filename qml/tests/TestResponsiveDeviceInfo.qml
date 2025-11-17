// import QtQuick
// import Felgo

// Item {

//     id: item

// }

import QtQuick
import QtQuick.Controls
import "../config" as Config

Rectangle {
    id: testContainer

    width: 800
    height: 600
    color: "#f5f5f5"

    Component.onCompleted: {
        // ✅ Bind les dimensions
        Config.ResponsiveConfig.screenWidth = Qt.binding(() => testContainer.width)
        Config.ResponsiveConfig.screenHeight = Qt.binding(() => testContainer.height)

        // ✅ Logs de test
        console.log("\n")
        console.log("======================================================")
        console.log("        TEST DEVICE INFO - INITIAL STATE              ")
        console.log("======================================================")
        logDeviceInfo()

        // ✅ Tester les changements de dimension
        testDimensionChanges()
    }

    function logDeviceInfo() {
        console.log("📏 Dimensions:")
        console.log("   Width:", Config.ResponsiveConfig.currentWidth, "px")
        console.log("   Height:", Config.ResponsiveConfig.currentHeight, "px")
        console.log("")
        console.log("📱 Appareil:")
        console.log("   Type:", Config.ResponsiveConfig.deviceInfo.deviceType)
        console.log("   isMobile:", Config.ResponsiveConfig.deviceInfo.isMobile)
        console.log("   isTablet:", Config.ResponsiveConfig.deviceInfo.isTablet)
        console.log("   isDesktop:", Config.ResponsiveConfig.deviceInfo.isDesktop)
        console.log("")
        console.log("🔄 Orientation:")
        console.log("   Orientation:", Config.ResponsiveConfig.deviceInfo.orientation)
        console.log("   isPortrait:", Config.ResponsiveConfig.deviceInfo.isPortrait)
        console.log("   isLandscape:", Config.ResponsiveConfig.deviceInfo.isLandscape)
        console.log("")
    }

    function testDimensionChanges() {
        // Test 1 : Mobile
        console.log("=======================================")
        console.log("              TEST 1 : MOBILE (390×844)")
        console.log("=======================================")
        testContainer.width = 390
        testContainer.height = 844
        Qt.callLater(logDeviceInfo)

        // Test 2 : Tablet (après 1s)
        Qt.callLater(() => {
                         console.log("=======================================")
                         console.log("            TEST 2 : TABLET (768×1024) ")
                         console.log("=======================================")
                         testContainer.width = 768
                         testContainer.height = 1024
                         Qt.callLater(logDeviceInfo)
                     }, 1000)

        // Test 3 : Desktop (après 2s)
        Qt.callLater(() => {
                         console.log("=======================================")
                         console.log("           TEST 3 : DESKTOP (1920×1080)")
                         console.log("=======================================")
                         testContainer.width = 1920
                         testContainer.height = 1080
                         Qt.callLater(logDeviceInfo)
                     }, 2000)

        // Test 4 : Landscape (après 3s)
        Qt.callLater(() => {
                         console.log("=======================================")
                         console.log("         TEST 4 : LANDSCAPE (1280×720) ")
                         console.log("=======================================")
                         testContainer.width = 1280
                         testContainer.height = 720
                         Qt.callLater(logDeviceInfo)
                     }, 3000)
    }

    // =======================================
    // UI DE TEST
    // =======================================

    Column {
        anchors.fill: parent
        anchors.margins: dp(20)
        anchors.topMargin: dp(40)
        spacing: dp(20)

        Text {
            text: "🧪 Test Device Info"
            font.pixelSize: sp(24)
            font.bold: true
            color: "#333"
        }

        Rectangle {
            width: parent.width
            height: dp(1)
            color: "#ddd"
        }

        Grid {
            width: parent.width
            columns: 2
            spacing: sp(20)

            // Dimension
            Column {
                spacing:dp(10)
                Text {
                    text: "📏 Dimensions"
                    font.bold: true
                    font.pixelSize: sp(14)
                }

                Text {
                    text: "Width: " + Config.ResponsiveConfig.currentWidth + "px"
                    font.pixelSize: sp(12)
                }

                Text {
                    text: "Height: " + Config.ResponsiveConfig.currentHeight + "px"
                    font.pixelSize: sp(12)
                }
            }

            // Appareil
            Column {
                spacing:dp(10)
                Text {
                    text: "📱 Appareil"
                    font.bold: true
                    font.pixelSize: sp(14)
                }

                Text {
                    text: "Type: " + Config.ResponsiveConfig.deviceInfo.deviceType
                    font.pixelSize: sp(12)
                }

                Text {
                    text: "isMobile: " + Config.ResponsiveConfig.deviceInfo.isMobile
                    font.pixelSize: sp(12)
                }

                Text {
                    text: "isTablet: " + Config.ResponsiveConfig.deviceInfo.isTablet
                    font.pixelSize: sp(12)
                }

                Text {
                    text: "isDesktop: " + Config.ResponsiveConfig.deviceInfo.isDesktop
                    font.pixelSize: sp(12)
                }
            }

            // Orientation
            Column {
                spacing: dp(10)
                Text {
                    text: "🔄 Orientation"
                    font.bold: true
                    font.pixelSize: sp(14)
                }

                Text {
                    text: "Orientation: " + Config.ResponsiveConfig.deviceInfo.orientation
                    font.pixelSize: sp(12)
                }

                Text {
                    text: "isPortrait: " + Config.ResponsiveConfig.deviceInfo.isPortrait
                    font.pixelSize: sp(12)
                }

                Text {
                    text: "isLandscape: " + Config.ResponsiveConfig.deviceInfo.isLandscape
                    font.pixelSize: sp(12)
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: "#ddd"
        }

        Text {
            text: "✅ Vérifiez les logs pour les changements automatiques"
            font.pixelSize: sp(12)
            color: "#666"
        }
    }
}

