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
 */
QtObject {
    id: root

    // ============================================
    // BREAKPOINTS (seuils de largeur)
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
    // CONFIGURATION GRILLE (nombre de colonnes)
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

    // ============================================
    // FONCTION : Nombre de colonnes optimal
    // ============================================


    /**
     * Retourne le nombre de colonnes adapté à une largeur d'écran
     *
     * @param width - Largeur en pixels réels
     * @return Nombre de colonnes optimal
     */
    function getColumnCount(width) {
        if (width < root.breakpoints.tabletPortrait) {
            return root.gridConfig.mobileNormalColumns
        } else if (width < root.breakpoints.tabletLandscape) {
            return root.gridConfig.tabletPortraitColumns
        } else if (width < root.breakpoints.desktop) {
            return root.gridConfig.tabletLandscapeColumns
        } else if (width < root.breakpoints.desktopLarge) {
            return root.gridConfig.desktopColumns
        } else {
            return root.gridConfig.desktopLargeColumns
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
    // ESPACEMENT (7 niveaux)
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
        *
         * Logique :
         * - Mobile  (< 720px)   : sm = 8px
         * - Tablet  (720-1280px): lg = 16px
         * - Desktop (≥ 1280px)  : xl = 20px
        */
        function getContentMargin(availableWidth) {

            if (availableWidth < root.breakpoints.tabletPortrait) {
                return sm // Mobile
            } else if (availableWidth < root.breakpoints.desktop) {
                return lg // Tablet
            } else {
                return xl // Desktop
            }
        }


        /**
         * Espacement adaptatif entre items grille
         *
         * Logique :
         * - Mobile  (< 720px)   : sm = 8px
         * - Tablet  (720-1280px): md = 12px
         * - Desktop (≥ 1280px)  : lg = 16px
        */
        function getItemSpacing(availableWidth) {
            if (availableWidth < root.breakpoints.tabletPortrait) {
                return sm // Mobile
            } else if (availableWidth < root.breakpoints.desktop) {
                return md // Tablet
            } else {
                return lg // Desktop
            }
        }
    }
}
