import Felgo 4.0
import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import "../config" as Config
import "../logic" as Logic
import "../model" as Model
import "../components" as Components
import "../services" as Services


/**
 * CataloguePage - Grille responsive de films
 */
AppPage {
    id: cataloguePage
    title: "Mon Catalogue"

    // ════════════════════════════════════════════════════════
    // SECTION 1 : CONSTANTES
    // ════════════════════════════════════════════════════════


    /**
     * POSTER_ASPECT_RATIO
     *
     * Ratio cinématographique standard : 2:3
     * Utilisé pour calculer la hauteur du poster selon sa largeur
     *
     * Valeur : 3/2 = 1.5
     * Signification : hauteur = largeur × 1.5
     *
     * Exemple :
     * - Largeur : 100px
     * - Hauteur : 100 × 1.5 = 150px
     */
    readonly property real poster_aspect_ratio: 3 / 2

    // ════════════════════════════════════════════════════════
    // SECTION 2 : PROPRIÉTÉS RESPONSIVES (ResponsiveConfig)
    // ════════════════════════════════════════════════════════


    /**
     * COLONNES ADAPTATIF
     * Détermine le nombre de colonnes selon la largeur disponible
     *
     * Breakpoints :
     * - < 720px : 2 colonnes (mobile)
     * - 720-1024px : 3 colonnes (tablet portrait)
     * - 1024-1280px : 4 colonnes (tablet landscape)
     * - ≥ 1280px : 5-6 colonnes (desktop)
     *
     * @return {int} Nombre de colonnes : 2-6
     */
    readonly property int columnCount: Config.ResponsiveConfig.getColumnCount(
                                           width)


    /**
     * ESPACEMENT ENTRE ITEMS
     *
     * Espacement horizontal et vertical entre les cartes
     *
     * Adaptation :
     * - Mobile (< 720px) : 8px
     * - Tablet (720-1280px) : 12px
     * - Desktop (≥ 1280px) : 16px
     *
     * @return {real} Espacement en pixels
     */
    readonly property real itemSpacing: Config.ResponsiveConfig.spacing.getItemSpacing(
                                            width)


    /**
     * MARGE DU CONTENEUR
     *
     * Espace entre la grille et les bords de la page
     *
     * Adaptation :
     * - Mobile (< 720px) : 8px
     * - Tablet (720-1280px) : 16px
     * - Desktop (≥ 1280px) : 20px
     *
     * @return {real} Marge en pixels
     */
    readonly property real contentMargin: Config.ResponsiveConfig.spacing.getContentMargin(
                                              width)


    /**
     * LARGEUR D'UNE COLONNE
     *
     * Calcule la largeur réelle d'une colonne
     *
     * Formule : (largeur disponible - espacements) / colonnes
     *
     * Exemple (Desktop 1280px, 5 colonnes, 16px spacing) :
     * - Largeur disponible : 1280 - 40 = 1240px
     * - Total espacement : (5-1) × 16 = 64px
     * - Largeur colonne : (1240 - 64) / 5 = 235.2px
     *
     * @return {real} Largeur d'une colonne en pixels
     */
    readonly property real columnWidth: Config.ResponsiveConfig.calculateColumnWidth(
                                            width - (2 * contentMargin),
                                            columnCount, itemSpacing)


    /**
     * HAUTEUR D'UNE CELLULE
     *
     * Hauteur totale (poster + titre)
     *
     * Calcul :
     * - Hauteur poster : largeur × POSTER_ASPECT_RATIO
     * - Hauteur titre : espacement pour 2 lignes
     * - Total : poster_height + 40px
     *
     * @return {real} Hauteur cellule en pixels
     */
    readonly property real cellHeight: (columnWidth * poster_aspect_ratio) + dp(
                                           40)


    /**
     * GRID TOTAL WIDTH
     *
     * Calcule la largeur TOTALE que prend la grille
     * (colonnes + espacements entre colonnes)
     *
     * Formule :
     * - Colonnes : columnWidth × columnCount
     * - Spacing entre colonnes : (columnCount - 1) × itemSpacing
     * - Total = colonnes + spacing
     *
     * Exemple (3 colonnes, 240px, 12px spacing) :
     * - Colonnes : 240 × 3 = 720px
     * - Spacing : 2 × 12 = 24px
     * - Total : 720 + 24 = 744px  Pas fullwidth !
     */
    readonly property real gridTotalWidth: (columnWidth * columnCount) + (columnCount * itemSpacing)


    /**
     * VISIBILITÉ THRESHOLD (Lazy loading)
     *
     * Buffer de pixels avant/après la zone visible
     * pour charger les images anticipativement
     * (permet de déterminer l'espace tampon avant/après
     * la zone visible du viewport de la GridView afin de charger
     * l'image)
     *
     * Impact :
     * - Petit (0px) : images chargées au dernier moment
     * - Moyen (50px) : préchargement modéré
     * - Grand (100px) : préchargement agressif
     *
     * Recommandation : 50px (équilibre perf/UX)
     */
    property real visibilityThreshold: dp(50)


    /**
     * ENABLE LAZY LOADING GLOBAL
     *
     * Active/désactive le chargement lazy des images
     * pour optimiser la performance sur gros catalogues
     */
    property bool enableLazyLoadingGlobal: true

    // ════════════════════════════════════════════════════════
    // SECTION 3 : SERVICES (LOGIQUE MÉTIER)
    // ════════════════════════════════════════════════════════


    /**
     * CATALOGUE LOGIC
     *
     * Gère :
     * - Chargement des films
     * - Gestion d'erreurs
     * - État (loading, hasData, errorMessage)
     */
    Logic.CatalogueLogic {
        id: logic
    }

    // ════════════════════════════════════════════════════════
    // SECTION 4 : HEADER FIXE
    // ════════════════════════════════════════════════════════


    /**
     * HEADER FIXE
     *
     * Affiche le titre et le nombre de films
     * Reste visible en haut pendant le scroll
     *
     * Responsabilités :
     * - Affichage du titre
     * - Comptage des films
     * - Messages d'erreur
     * - Ombre de profondeur
     */
    Rectangle {
        id: fixedHeader

        // Ancrages pour positionner et centrer
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: dp(contentMargin)
        anchors.topMargin: dp(Config.ResponsiveConfig.spacing.md)

        height: dp(60)
        radius: dp(8)
        color: Theme.colors.backgroundColor
        z: 100 // Z-index élevé pour rester au-dessus

        // Effet d'ombre pour détacher visuellement
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: dp(4)
            radius: dp(4)
            samples: 9
            color: Qt.rgba(0, 0, 0, 0.1)
        }

        // Texte qui affiche le nombre de films ou l’erreur
        AppText {
            anchors.centerIn: parent
            text: logic.errorMessage ? "Mon Catalogue – Erreur" : logic.hasData ? "Mon Catalogue – " + logic.filmCount + " films" : "Mon Catalogue – Aucun film"
            font.pixelSize: sp(16)
            font.bold: true
            color: Theme.colors.textColor
        }
    }

    // ════════════════════════════════════════════════════════
    // SECTION 5 : INDICATEUR DE CHARGEMENT
    // ════════════════════════════════════════════════════════


    /**
     * LOADING INDICATOR
     *
     * Affiche pendant le chargement du catalogue
     * Visible seulement si logic.loading = true
     */
    Column {
        anchors.centerIn: parent
        spacing: dp(10)
        visible: logic.loading // ← Visible seulement pendant le chargement

        BusyIndicator {
            anchors.horizontalCenter: parent.horizontalCenter
            running: logic.loading
            width: dp(60)
            height: dp(60)
        }

        AppText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Chargement du catalogue..."
            font.pixelSize: sp(14)
            color: Theme.colors.secondaryTextColor
        }
    }

    // ════════════════════════════════════════════════════════
    // SECTION 6 : GRILLE DE FILMS (RESPONSIVE)
    // ════════════════════════════════════════════════════════


    /**
     * GRIDVIEW RESPONSIVE DANS UN CONTENEUR
     *
     * Adaptation dynamique :
     * - Colonnes : 2-6 selon largeur
     * - Espacement : 8-16px selon largeur
     * - Largeur colonne : calculée auto
     *
     * Optimisations :
     * - Lazy loading des images
     * - Visibility tracking pour économiser CPU
     * - Smooth transitions
     */
    Item {
        id: gridContainer

        anchors.top: fixedHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: dp(contentMargin)

        clip: true

        // Pour le debug du centrage
        // Rectangle {
        //     anchors.fill: parent
        //     color: "transparent"
        //     border.color: "red"
        //     border.width: 2
        // }

        // ════════════════════════════════════════════════════════
        // GRIDVIEW CENTRÉE À L'INTÉRIEUR DU CONTENEUR
        // ════════════════════════════════════════════════════════
        GridView {
            id: filmGridView

            anchors.top: parent.top
            anchors.bottom: parent.bottom

            width: gridTotalWidth

            // ════════════════════════════════════════════════════════
            // DIMENSIONS RESPONSIVE
            // ════════════════════════════════════════════════════════

            // clip: true  // Cache tout ce qui sort des limites


            /**
                * CELL WIDTH - Largeur colonne adaptée
                *
                * Calcul responsif :
                * - Largeur disponible : width - 2×contentMargin
                * - Divisée par nombre de colonnes
                * - Moins les espacements entre colonnes
                *
                * Formule dans ResponsiveConfig :
                * (width - totalSpacing) / columnCount
                */
            cellWidth: columnWidth + itemSpacing


            /**
                * CELL HEIGHT - Hauteur de cellule
                *
                * Adaptée à la largeur (respecte aspect ratio)
                *
                * Calcul :
                * - Hauteur poster : largeur × 1.5
                * - Espace titre : 40px
                * - Total : columnWidth × 1.5 + 40
                */
            cellHeight: cataloguePage.cellHeight

            model: Model.FilmDataSingletonModel
                   && Model.FilmDataSingletonModel.films ? Model.FilmDataSingletonModel.films : []

            // Visibilité conditionnelle : visible seulement si pas en chargement ET qu'il y a des films
            visible: !logic.loading
                     && Model.FilmDataSingletonModel.films.length > 0

            // ════════════════════════════════════════════════════════
            // PROPRIÉTÉS LAZY LOADING
            // ════════════════════════════════════════════════════════
            property real itemHeight: cellHeight
            property real viewportTop: contentY
            property real viewportBottom: contentY + height


            /**
                * CACHE BUFFER
                *
                * À décommenter pour gros catalogues (1000+ films)
                * Optimise la performance en cachant/réutilisant les items
                */
            // cacheBuffer: cellHeight * 2
            // reuseItems: true

            // Opacité réduite pendant le chargement, mais visible
            // opacity: logic.loading ? 0.5 : 1.0


            /**
                * TIMER OPTIMISATION DES CALCULS DE VISIBILITÉ
                *
                * Évite les recalculs constants (et excessifs) lors du scroll
                * Throttle : 100ms entre recalculs
                */
            Timer {
                id: visibilityUpdateTimer
                interval: 100
                repeat: false
                onTriggered: {
                    // Force la mise à jour des bindings de visibilité
                    filmGridView.viewportTop = filmGridView.contentY
                    filmGridView.viewportBottom = filmGridView.contentY + filmGridView.height
                }
            }


            /**
                * DELEGATE - Carte film
                *
                * Rendu pour chaque film du modèle
                *
                * Responsabilités :
                * - Affichage poster (lazy loading)
                * - Affichage titre
                * - Navigation
                * - Feedback visuel (hover, press)
                */
            delegate: Rectangle {
                id: filmCard

                width: columnWidth
                height: cataloguePage.cellHeight - dp(4)

                // ════════════════════════════════════════════════════════
                // STYLE AMÉLIORÉ
                // ════════════════════════════════════════════════════════

                // radius: dp(8)
                // color: Theme.colors.backgroundColor
                // border.color: Theme.colors.dividerColor
                // border.width: dp(0.5)


                /**
                     * RADIUS - Coins arrondis
                     *
                     * ✅ AUGMENTÉ : 8 → 12px
                     * Donne un aspect plus moderne et doux
                     */
                radius: dp(12)

                color: Theme.colors.backgroundColor


                /**
                     * BORDER - Bordure visible et élégante
                     *
                     * AMÉLIORÉ :
                     * - width : 0.5 → 1.0px (plus visible)
                     * - color : couleur cohérente
                     */
                border.width: dp(1)
                border.color: "#e5e7eb" // Gris clair pour délimitation douce


                /**
                     * SHADOW - Ombre profonde et prononcée
                     *
                     * - Verticale : 4 → 6px (plus de profondeur)
                     * - Radius : 4 → 12px (blur plus important)
                     * - Samples : augmenté pour qualité
                     * - Opacité : 0.1 → 0.15 (plus visible)
                     *
                     * Donne de la profondeur et de la dimension
                     */
                layer.enabled: true
                layer.effect: DropShadow {
                    horizontalOffset: 0
                    verticalOffset: dp(6)
                    radius: dp(12)
                    samples: 17
                    color: Qt.rgba(0, 0, 0, 0.15)
                    spread: dp(0)
                }

                // ════════════════════════════════════════════════════════
                // VISIBILITY TRACKING (Lazy loading)
                // ════════════════════════════════════════════════════════
                property real itemTop: y
                property real itemBottom: y + height
                property real threshold: cataloguePage.visibilityThreshold


                /**
                     * ITEM VISIBLE
                     *
                     * Détermine si l'item est dans la zone visible
                     * avec buffer de visibilityThreshold pixels
                     *
                     * Calcul :
                     * - Item visible si :
                     *   (itemBottom >= vpTop - threshold) AND
                     *   (itemTop <= vpBottom + threshold)
                     */
                property bool itemVisible: {
                    var top = y
                    var bottom = y + height
                    var vpTop = filmGridView.viewportTop
                    var vpBottom = filmGridView.viewportBottom

                    return (bottom >= vpTop - threshold)
                            && (top <= vpBottom + threshold)
                }

                property real padding: dp(6)

                // ════════════════════════════════════════════════════════
                // FEEDBACK VISUEL (Press effect)


                /**
                     *Effet visuel au clic
                     * Feedback visuel lors du press :
                     * - Opacité réduite à 70% (convention mobile)
                     * - Scale réduit à 97% (effet de "press" subtil)
                     * - Animation 100ms (instantané pour l'utilisateur)
                     * - Easing OutQuad (décélération naturelle)
                     */
                // ════════════════════════════════════════════════════════
                property bool isPressed: false

                scale: isPressed ? 0.95 : 1.0
                opacity: isPressed ? 0.7 : 1.0

                // ============================================
                // TRANSITIONS POUR LE FEEDBACK VISUEL
                // ============================================


                /**
                     * TRANSITION OPACITY
                     *
                     * Animation fluide de l'opacité
                     *
                     * Paramètres :
                     * - duration: 100ms (imperceptible, perçu comme instantané)
                     * - easing: InOutQuad (accélération/décélération douce)
                     */
                Behavior on opacity {
                    NumberAnimation {
                        duration: 100
                        easing.type: Easing.InOutQuad
                    }
                }


                /**
                     * TRANSITION SCALE
                     *
                     * Animation fluide de l'échelle
                     *
                     * Paramètres :
                     * - duration: 100ms (synchronisé avec opacity)
                     * - easing: OutQuad (décélération naturelle)
                     */
                Behavior on scale {
                    NumberAnimation {
                        duration: 100
                        easing.type: Easing.OutQuad
                    }
                }

                // ════════════════════════════════════════════════════════
                // ZONE INTERACTIVE (MouseArea)
                // ════════════════════════════════════════════════════════


                /**
                     * MOUSE AREA
                     *
                     * Rend la carte cliquable
                     * Gère la navigation vers FilmDetailPage
                     */
                MouseArea {
                    id: filmCardMouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        console.log("=== NAVIGATION VERS DÉTAILS ===")
                        console.log("🖱️  Clic sur film:",
                                    modelData ? modelData.title : "Inconnu")
                        console.log("🆔 ID du film:",
                                    modelData ? modelData.id : -1)

                        if (!modelData || !modelData.id || modelData.id <= 0) {
                            console.error(
                                        "❌ Données film invalides - navigation annulée")
                            Services.ToastService.showError("Film invalide")
                            return
                        }

                        console.log("🚀 Push vers FilmDetailPage avec filmId:",
                                    modelData.id)

                        navigationStack.push(filmDetailPageComponent, {
                                                 "filmId": modelData.id
                                             })

                        console.log("✅ Navigation déclenchée\n")
                    }

                    onPressed: {
                        filmCard.isPressed = true
                    }

                    onReleased: {
                        filmCard.isPressed = false
                    }

                    onCanceled: {
                        filmCard.isPressed = false
                    }
                }

                // ════════════════════════════════════════════════════════
                // CONTENU : POSTER + TITRE
                // ════════════════════════════════════════════════════════
                Column {
                    id: cardContainer
                    anchors.fill: parent
                    anchors.margins: filmCard.padding
                    spacing: dp(10)


                    /**
                          * POSTER IMAGE
                          *
                          * Affichage du poster avec :
                          * - Ratio cinéma 2:3
                          * - Lazy loading optionnel
                          * - Visibility tracking
                          */
                    Components.PosterImage {
                        width: parent.width

                        // Respect du ratio cinéma et utilisation de la largeur fixe
                        height: width * poster_aspect_ratio

                        source: modelData ? modelData.poster_url : ""

                        // Configuration lazy loading (activé pour test)
                        enableLazyLoading: cataloguePage.enableLazyLoadingGlobal
                        isVisible: filmCard.itemVisible // Référence au delegate
                        visibilityThreshold: cataloguePage.visibilityThreshold

                        onIsVisibleChanged: {
                            console.log("📱 Film", index, "visible:",
                                        isVisible, "- Poster:",
                                        source.split('/').pop())
                        }
                    }


                    /**
                          * TITRE FILM
                          *
                          * Affichage du titre
                          *
                          * Caractéristiques :
                          * - Ellipsis après 2 lignes
                          * - Texte centré
                          * - Alignement vertical
                          */
                    AppText {
                        width: parent.width

                        text: modelData ? modelData.title : "?"
                        font.pixelSize: sp(10)
                        font.bold: true
                        color: Theme.colors.textColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }
                }
            }

            // ════════════════════════════════════════════════════════
            // SIGNAUX & OPTIMISATIONS
            // Mettre à jour viewportTop et viewportBottom sur scroll
            // Mise à jour de la visibilité lors du scroll
            // Optimisation du scroll
            // ════════════════════════════════════════════════════════
            onContentYChanged: {
                visibilityUpdateTimer.restart()
            }
            onHeightChanged: {
                visibilityUpdateTimer.restart()
            }
        }
    }

    // ════════════════════════════════════════════════════════
    // SECTION 7 : COMPOSANT LAZY - FILM DETAIL PAGE
    // ════════════════════════════════════════════════════════


    /**
     * FILM DETAIL PAGE COMPONENT
     *
     * Pattern de lazy instantiation (lazy loading)
     * La page est créée seulement au moment du push
     * Économise mémoire et temps de chargement
     */
    Component {
        id: filmDetailPageComponent
        FilmDetailPage {// La page sera créée dynamiquement avec les propriétés passées lors du push (filmId)
        }
    }

    // ════════════════════════════════════════════════════════
    // SECTION 8 : GESTION DES SIGNAUX
    // ════════════════════════════════════════════════════════


    /**
     * ERROR HANDLER
     *
     * Gère les erreurs du logic
     */
    Connections {
        target: logic
        function onErrorOccurred(message) {
            console.log("⚠️ Erreur reçue dans CataloguePage:", message)
            Services.ToastService.showError(message)
        }
    }

    // ════════════════════════════════════════════════════════
    // SECTION 9 : DEBUG & LOGS
    // ════════════════════════════════════════════════════════


    /**
     * LOGS DE DÉMARRAGE
     *
     * Affiche les paramètres responsive calculés
     * Utile pour debug sur différentes résolutions
     */
    Component.onCompleted: {
        console.log("\n=== DEBUG CataloguePage [INITIAL] ===")
        console.log("⚠️ Note: width peut être 0 au démarrage (normal)")
        console.log("   Les bindings réactifs se mettront à jour après layout")
        console.log("")
        console.log("📏 Dimensions initiales:")
        console.log("   Largeur page:", width, "px")
        console.log("   (Width sera calculé après layout)")
        console.log("")

        // Démarrer timer pour logger après layout
        logTimer.start()
    }


    /**
     * TIMER POUR LOGS POST-LAYOUT
     *
     * Attend 100ms pour logger APRÈS que width soit calculé
     */
    Timer {
        id: logTimer
        interval: 100
        running: false
        repeat: false
        onTriggered: {
            console.log("\n=== DEBUG CataloguePage [APRÈS LAYOUT] ===")
            console.log("📏 Dimensions:")
            console.log("   Largeur page:",
                        cataloguePage.width.toFixed(0), "px")
            console.log("   Marge contenu:", contentMargin, "px")
            console.log("")
            console.log("🎯 Responsive Config:")
            console.log("   Colonnes:", columnCount)
            console.log("   Espacement items:", itemSpacing, "px")
            console.log("   Largeur colonne:", columnWidth.toFixed(1), "px")
            console.log("   Hauteur cellule:", cellHeight.toFixed(1), "px")
            console.log("   gridTotalWidth:", gridTotalWidth.toFixed(1), "px")
            console.log("")
            console.log("📊 Données:")
            console.log("   Films model:",
                        Model.FilmDataSingletonModel ? "✅ Chargé" : "❌ Non chargé")
            if (Model.FilmDataSingletonModel
                    && Model.FilmDataSingletonModel.films) {
                console.log("   Nombre films:",
                            Model.FilmDataSingletonModel.films.length)
            }
            console.log("==========================================\n")
        }
    }
}
