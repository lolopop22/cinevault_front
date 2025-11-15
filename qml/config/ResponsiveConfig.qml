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
 */

QtObject {
    id: root
    
    // Facteur de densité : convertit pixels en device-independent pixels
    // Permet que les tailles soient adaptées au DPI de l'écran
    // readonly property real dp: Screen.pixelDensity / 160

    // /**
    //  * Convertit des pixels réels en dp (device-independent pixels)
    //  *
    //  * @param pixels - Valeur en pixels réels
    //  * @return Valeur équivalente en dp
    //  *
    //  * Exemple : 390px sur iPhone (DPI 326)
    //  * → 390 * 0.02 = 7.8 dp
    //  */
    // function pixelsToDp(pixels) {
    //     return pixels * root.dp
    // }

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
     *
     */
    function getColumnCount(width) {
        if (width < root.breakpoints.tabletPortrait) {
            return root.gridConfig.mobileNormalColumns
        }
        else if (width < root.breakpoints.tabletLandscape) {
            return root.gridConfig.tabletPortraitColumns
        }
        else if (width < root.breakpoints.desktop) {
            return root.gridConfig.tabletLandscapeColumns
        }
        else if (width < root.breakpoints.desktopLarge) {
            return root.gridConfig.desktopColumns
        }
        else {
            return root.gridConfig.desktopLargeColumns
        }
    }

    
    // ============================================
    // FONCTION : Largeur d'une colonne
    // ============================================

    /**
     * Calcule la largeur réelle d'une colonne
     *
     * Formule : (largeur totale - espacements) / nombre de colonnes
     *
     * Exemple : Tablet portrait (720px, 3 colonnes, 12px espacement)
     * (720 - 24) / 3 = 232px par colonne
     */
    function calculateColumnWidth(containerWidth, columnCount) {
        const itemSpacing = 12
        const cols = columnCount || root.getColumnCount(containerWidth)
        const totalSpacing = Math.max(0, (cols - 1) * itemSpacing)
        return (containerWidth - totalSpacing) / cols
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
                return sm  // Mobile
            }
            else if (availableWidth < root.breakpoints.desktop) {
                return lg  // Tablet
            }
            else {
                return xl  // Desktop
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
                return sm  // Mobile
            }
            else if (availableWidth < root.breakpoints.desktop) {
                return md  // Tablet
            }
            else {
                return lg  // Desktop
            }
        }
    }
}
