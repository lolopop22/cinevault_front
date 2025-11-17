pragma Singleton
import Felgo 4.0
import QtQuick 2.15


/**
 * ResponsiveConfig - Singleton de configuration responsive
 *
 * Responsabilités :
 * - Breakpoints adaptatifs (seuils de largeur d'écran qui
 *   déclenchent un changement de layout)
 * - Calcul du nombre de colonnes par taille d'écran
 * - Espacement standardisé en 7 niveaux
 * - Calcul adaptatif de largeur de colonne
 * - Détection d'appareil (NOUVEAU)
 * - Détection d'orientation (NOUVEAU)
 */
QtObject {
    id: root

    // ============================================
    // SECTION 1: BREAKPOINTS (seuils de largeur)
    // ============================================
    readonly property QtObject breakpoints: QtObject {
        // Mobile petit (iPhone SE, vieux téléphones)
        readonly property real mobileSmall: 320

        // Mobile standard (iPhone 12, Pixel, Galaxy S21)
        readonly property real mobileNormal: 480

        // Tablette en portrait (iPad mini, Galaxy Tab)
        readonly property real tabletPortrait: 720

        // Tablette en landscape (iPad, iPad Pro portrait)
        readonly property real tabletLandscape: 1024

        // Desktop standard (1280x720)
        readonly property real desktop: 1280

        // Desktop large (1920x1080+)
        readonly property real desktopLarge: 1920
    }

    // ============================================
    // SECTION 2: CONFIGURATION GRILLE (nombre de colonnes)
    // ============================================
    readonly property QtObject gridConfig: QtObject {
        // Mobile : priorité à la lisibilité
        readonly property int mobileSmallColumns: 2
        readonly property int mobileNormalColumns: 2

        // Tablet : utilisation efficace de l'espace
        readonly property int tabletPortraitColumns: 3
        readonly property int tabletLandscapeColumns: 4

        // Desktop : utilisation maximale
        readonly property int desktopColumns: 5
        readonly property int desktopLargeColumns: 6
    }

    // ════════════════════════════════════════════════════════
    // SECTION 3: DEVICE INFO (NOUVEAU)
    // ════════════════════════════════════════════════════════

    /**
     * SCREEN DIMENSIONS
     *
     * À binder depuis App.qml :
     * ResponsiveConfig.screenWidth = Qt.binding(() => app.width)
     * ResponsiveConfig.screenHeight = Qt.binding(() => app.height)
     */
    property real screenWidth: 1280
    property real screenHeight: 720

    /**
     * Dimensions actuelles (raccourcis)
     */
    readonly property real currentWidth: screenWidth
    readonly property real currentHeight: screenHeight

    /**
     * DEVICE INFO - Détection automatique d'appareil et orientation
     *
     * Propriétés réactives qui recalculent si dimensions changent
     *
     * Utilisation :
     * - ResponsiveConfig.deviceInfo.isMobile
     * - ResponsiveConfig.deviceInfo.isDesktop
     * - ResponsiveConfig.deviceInfo.isPortrait
     * - etc.
     */
    readonly property QtObject deviceInfo: QtObject {

        // Orientation
        readonly property bool isPortrait: root.screenHeight > root.screenWidth
        readonly property bool isLandscape: root.screenHeight <= root.screenWidth

        // Type d'appareil
        readonly property bool isMobile: root.currentWidth < root.breakpoints.tabletPortrait
        readonly property bool isTablet: root.currentWidth >= root.breakpoints.tabletPortrait &&
                                          root.currentWidth < root.breakpoints.desktop
        readonly property bool isDesktop: root.currentWidth >= root.breakpoints.desktop

        // Labels pour logs/conditions
        readonly property string deviceType:
            root.deviceInfo.isMobile ? "mobile" :
            root.deviceInfo.isTablet ? "tablet" :
            "desktop"

        // readonly property bool isMobileSmall: root.currentWidth < root.breakpoints.mobileNormal
        // readonly property bool isMobileNormal: root.currentWidth >= root.breakpoints.mobileNormal &&
        //                                        root.currentWidth < root.breakpoints.tabletPortrait
        // readonly property bool isTabletPortrait: root.currentWidth >= root.breakpoints.tabletPortrait &&
        //                                          root.currentWidth < root.breakpoints.tabletLandscape
        // readonly property bool isTabletLandscape: root.currentWidth >= root.breakpoints.tabletLandscape &&
        //                                           root.currentWidth < root.breakpoints.desktop
        // readonly property bool isDesktop: root.currentWidth >= root.breakpoints.desktop &&
        //                                   root.currentWidth < root.breakpoints.desktopLarge
        // readonly property bool isDesktopLarge: root.currentWidth >= root.breakpoints.desktopLarge

        // readonly property string deviceType:
        //     root.deviceInfo.isMobileSmall ? "mobileSmall" :
        //     root.deviceInfo.isMobileNormal ? "mobileNormal" :
        //     root.deviceInfo.isTabletPortrait ? "tabletPortrait" :
        //     root.deviceInfo.isTabletLandscape ? "tabletLandscape" :
        //     root.deviceInfo.isDesktop ? "desktop" :
        //     root.deviceInfo.isDesktopLarge ? "desktopLarge" :
        //     "unknown"

        readonly property string orientation: root.deviceInfo.isPortrait ? "portrait" : "landscape"
    }

    // ============================================
    // SECTION 4: FONCTIONS
    // ============================================


    /**
     * Retourne le nombre de colonnes adapté à une largeur d'écran
     *
     * @param width - Largeur en pixels réels
     * @return Nombre de colonnes optimal
     */
    function getColumnCount(width) {
        if (root.deviceInfo.isMobile) {
            return root.gridConfig.mobileNormalColumns  // 2
        } else if (root.deviceInfo.isTablet) {
            if (width < root.breakpoints.tabletLandscape) {
                return root.gridConfig.tabletPortraitColumns  // 3
            } else {
                return root.gridConfig.tabletLandscapeColumns  // 4
            }
        } else {
            if (width < root.breakpoints.desktopLarge) {
                return root.gridConfig.desktopColumns  // 5
            } else {
                return root.gridConfig.desktopLargeColumns  // 6
            }
        }
    }

    // ============================================
    // FONCTION : Largeur d'une colonne
    // ============================================


    /**
     * Calcule la largeur réelle d'une colonne
     *
     * @param containerWidth - Largeur totale disponible (pixels)
     * @param columnCount - Nombre de colonnes
     * @param itemSpacing - Espacement entre items (pixels)
     * @return Largeur d'une colonne (pixels)
     *
     * Formule : (largeur totale - espacements) / nombre de colonnes
     *
     * Exemples :
     * - Desktop (1880px, 5 col, 16px spacing) :
     *   (1880 - (5-1)*16) / 5 = 352px
     *
     * - Tablet (720px, 3 col, 12px spacing) :
     *   (720 - (3-1)*12) / 3 = 232px
     *
     * - Mobile (390px, 2 col, 8px spacing) :
     *   (390 - (2-1)*8) / 2 = 191px
     */
    function calculateColumnWidth(containerWidth, columnCount, itemSpacing) {
        // VALIDATION : Garder-fous pour éviter erreurs
        if (containerWidth <= 0 || columnCount <= 0 || itemSpacing < 0) {
            console.warn("⚠️ calculateColumnWidth: paramètres invalides",
                         "| width:", containerWidth.toFixed(0), "px | cols:",
                         columnCount, "| spacing:",
                         itemSpacing.toFixed(1), "px")
            return 0
        }

        const totalSpacing = Math.max(0, (columnCount - 1) * itemSpacing)
        const availableWidth = containerWidth - totalSpacing
        const columnWidth = availableWidth / columnCount

        // SÉCURITÉ : Largeur minimale de 50px
        const finalWidth = Math.max(columnWidth, 50)

        // DEBUG : Logs pour validation
        if (finalWidth < 100) {
            console.warn("⚠️ calculateColumnWidth: largeur très petite",
                         "width:", finalWidth.toFixed(1), "px",
                         "(minimum recommandé : 100px)")
        }

        return finalWidth
    }

    // ============================================
    // SECTION 5: ESPACEMENT (7 niveaux)
    // ============================================
    readonly property QtObject spacing: QtObject {
        // Micro-espacement (bordures, traits fins)
        readonly property real xs: 4

        // Petit espacement (padding buttons, icônes)
        readonly property real sm: 8

        // Standard (padding conteneurs, Material Design)
        readonly property real md: 12

        // Moyen (marges éléments, spacings)
        readonly property real lg: 16

        // Grand (séparation sections)
        readonly property real xl: 20

        // Très grand (blocs majeurs)
        readonly property real xxl: 24

        // Énorme (respiration desktop large)
        readonly property real xxxl: 32


        /**
        * Marge adaptative du conteneur selon taille écran
        * Utilise deviceInfo et une valeur par défaut pour ne pas casser l'existant
        *
        * Logique :
        * - Mobile  (< 720px)   : sm = 8px
        * - Tablet  (720-1280px): lg = 16px
        * - Desktop (≥ 1280px)  : xl = 20px
        */
        function getContentMargin(availableWidth = -1) {
            const width = availableWidth !== -1 ? availableWidth : root.currentWidth

            if (width < root.breakpoints.tabletPortrait) {
                return root.spacing.sm    // 8px - Mobile
            } else if (width < root.breakpoints.desktop) {
                return root.spacing.lg    // 16px - Tablet
            } else {
                return root.spacing.xl    // 20px - Desktop
            }
        }


        /**
        * Espacement adaptatif entre items (grille, etc..)
        * Utilise deviceInfo et une valeur par défaut pour ne pas casser l'existant
        *
        * Logique :
        * - Mobile  (< 720px)   : sm = 8px
        * - Tablet  (720-1280px): md = 12px
        * - Desktop (≥ 1280px)  : lg = 16px
        */
        function getItemSpacing(availableWidth = -1) {
            const width = availableWidth !== -1 ? availableWidth : root.currentWidth

            if (width < root.breakpoints.tabletPortrait) {
                return root.spacing.sm    // 8px - Mobile
            } else if (width < root.breakpoints.desktop) {
                return root.spacing.md    // 12px - Tablet
            } else {
                return root.spacing.lg    // 16px - Desktop
            }
        }
    }

    // ============================================
    // SECTION 5 : DEBUG & LOGS
    // ============================================

    /**
    * Logs de debug (optionnel, désactivable)
    */
    property bool enableDebugLogs: true

    function logDeviceInfo() {
        if (!root.enableDebugLogs) return

        console.log("\n======================================= ")
        console.log("        RESPONSIVE CONFIG - DEBUG         ")
        console.log("=========================================")
        console.log("📏 Screen: " + root.currentWidth.toFixed(0) + "×" + root.currentHeight.toFixed(0) + " px")
        console.log("📱 Device: " + root.deviceInfo.deviceType + " (" + root.deviceInfo.orientation + ")")
        console.log("🎯 Columns: " + root.getColumnCount(root.currentWidth))
        console.log("📐 Spacing: content=" + root.spacing.getContentMargin() + "px, items=" + root.spacing.getItemSpacing() + "px")
        console.log("============================================\n")
    }

    Component.onCompleted: {
        console.log("[ResponsiveConfig] Initialized - Singleton ready")
    }
}
