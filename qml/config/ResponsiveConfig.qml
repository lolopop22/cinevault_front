pragma Singleton
import QtQuick

/**
 * ResponsiveConfig
 *
 * Breakpoints = seuils de largeur d'écran qui déclenchent un changement de layout
 *
 * Responsabilité :
 * - Définir les 6 breakpoints basés sur appareils réels
 * - Décider nombre de colonnes par breakpoint
 * - Calculer la largeur réelle d'une colonne
 */

QtObject {
    id: root
    
    // ============================================
    // 1 : BREAKPOINTS
    // ============================================

    // 6 seuils de largeur d'écran basés sur résolutions réelles
    readonly property QtObject breakpoints: QtObject {
        // 320px : Petit téléphone (iPhone SE, vieux Android)
        readonly property real mobileSmall: 320
        
        // 480px : Téléphone standard (iPhone 12, Pixel 5, Galaxy S21)
        readonly property real mobileNormal: 480
        
        // 720px : Tablette portrait (iPad mini, Galaxy Tab)
        readonly property real tabletPortrait: 720
        
        // 1024px : Tablette paysage (iPad, iPad Pro portrait)
        readonly property real tabletLandscape: 1024
        
        // 1280px : Desktop standard (1280x720)
        readonly property real desktop: 1280
        
        // 1920px : Desktop large (1920x1080, 4K)
        readonly property real desktopLarge: 1920
    }
    
    // ============================================
    // 2: GRID CONFIGURATION - COLONNES
    // ============================================

    // Nombre de colonnes adapté à chaque breakpoint
    readonly property QtObject gridConfig: QtObject {
        // Mobile small & normal : 2 colonnes (priorité lisibilité)
        readonly property int mobileSmallColumns: 2
        readonly property int mobileNormalColumns: 2
        
        // Tablet portrait : 3 colonnes (utilisation espace)
        readonly property int tabletPortraitColumns: 3
        
        // Tablet landscape : 4 colonnes (espace horizontal)
        readonly property int tabletLandscapeColumns: 4
        
        // Desktop : 5 colonnes
        readonly property int desktopColumns: 5
        
        // Desktop large : 6 colonnes
        readonly property int desktopLargeColumns: 6
    }
    
    // ============================================
    // 3 : FONCTION - DÉTERMINER NBRE DE COLONNES
    // ============================================
    /**
     * Retourne le nombre de colonnes optimal basé sur une largeur
     * 
     * @param {real} width - Largeur disponible en pixels
     * @return {int} Nombre de colonnes à utiliser
     * 
     * LOGIQUE :
     * width < 720   → 2 colonnes
     * width < 1024  → 3 colonnes
     * width < 1280  → 4 colonnes
     * width < 1920  → 5 colonnes
     * width >= 1920 → 6 colonnes
     * 
     * EXPLICATION :
     * Chaque condition teste si width est dans une plage.
     * Par exemple :
     * - Si width = 500 et breakpoint.tabletPortrait = 720
     * - 500 < 720 ? Oui → retourner 2 colonnes
     */
    function getColumnCount(width) {
        // Premier breakpoint où on passe à 3 colonnes
        if (width < root.breakpoints.tabletPortrait) {
            return root.gridConfig.mobileNormalColumns  // 2
        }
        
        // Breakpoint où on passe à 4 colonnes
        else if (width < root.breakpoints.tabletLandscape) {
            return root.gridConfig.tabletPortraitColumns  // 3
        }
        
        // Breakpoint où on passe à 5 colonnes
        else if (width < root.breakpoints.desktop) {
            return root.gridConfig.tabletLandscapeColumns  // 4
        }
        
        // Breakpoint où on passe à 6 colonnes
        else if (width < root.breakpoints.desktopLarge) {
            return root.gridConfig.desktopColumns  // 5
        }
        
        // Si écran large, on retourne 6 colonnes (maximum)
        else {
            return root.gridConfig.desktopLargeColumns  // 6
        }
    }
    
    // ============================================
    // 4 : FONCTION - CALCULER LARGEUR COLONNE
    // ============================================
    /**
     * Calcule la largeur réelle d'UNE colonne dans une grille
     * 
     * @param {real} containerWidth - Largeur totale du conteneur
     * @param {int} columnCount - Nombre de colonnes (optionnel, auto-détecté)
     * @return {real} Largeur disponible pour UNE colonne (sans espacement)
     * 
     * FORMULE :
     * (containerWidth - espacements totaux) / nombre de colonnes
     * 
     * EXEMPLE 1 : Tablet portrait (720px, 3 colonnes)
     * - Largeur conteneur : 720px
     * - Nombre colonnes : 3
     * - Espacements inter-colonnes : 2 × 12 = 24px (2 espacements)
     * - Calcul : (720 - 24) / 3 = 232px par colonne
     * 
     * EXEMPLE 2 : Mobile (480px, 2 colonnes)
     * - Largeur conteneur : 480px
     * - Nombre colonnes : 2
     * - Espacements inter-colonnes : 1 × 12 = 12px (1 espacement)
     * - Calcul : (480 - 12) / 2 = 234px par colonne
     *
     * Pour le moment, on hardcode 12px d'espacement.
     * Mais ce sera centralisé dans la section dédiée au spacing.
     */
    function calculateColumnWidth(containerWidth, columnCount) {
        // Espacement entre colonnes (TODO : à centraliser plus tard)
        const itemSpacing = 12
        
        // Déterminer le nombre de colonnes (auto-détection si pas fourni)
        const cols = columnCount || root.getColumnCount(containerWidth)
        
        // Entre N colonnes, il y a N-1 espacements d'où (cols - 1) espacement
        // Exemple : 3 colonnes = 2 espacements (col1 | space | col2 | space | col3)
        // on calcule l'espace pris par les espacements
        const totalSpacing = Math.max(0, (cols - 1) * itemSpacing)
        
        // On divise par cols car on veut répartir équitablement l'espace restant entre les colonnes
        return (containerWidth - totalSpacing) / cols
    }
}
