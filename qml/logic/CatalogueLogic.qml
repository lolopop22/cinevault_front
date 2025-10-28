import QtQuick 2.15
import Felgo 4.0
import "../model" as Model
import "../services" as Services

/**
 * CatalogueLogic - Controller MVC pour la page du catalogue
 *
 * Responsabilités :
 * - Orchestrer le chargement du catalogue (API ou test data)
 * - Transformer les données de l'API pour la Vue
 * - Exposer l'état du catalogue (loading, hasData, filmCount, errorMessage)
 * - Propager les erreurs vers la Vue via ToastService
 * - Respecter le pattern MVC avec propriétés readonly pour exposition
 *
 * Pattern :
 * - Hérite de QtObject (pas d'éléments visuels)
 * - Propriétés readonly pour exposition publique
 * - Propriétés privées (_) pour état interne
 * - Signaux pour événements spéciaux
 * - Méthodes publiques pour API logique
 * - Pas d'accès direct aux Services (utilise signaux)
 */
Item {
    id: catalogueLogic

    // ============================================
    // PROPRIÉTÉS PUBLIQUES - Interface pour la Vue
    // ============================================

    /**
     * Indicateur de chargement en cours
     * Readonly : binding automatique vers FilmDataSingletonModel
     * Utilisé par CataloguePage pour afficher BusyIndicator
     */
    readonly property bool loading: Model.FilmDataSingletonModel.isLoading

    /**
     * Indicateur de présence de données
     * Readonly : dérivé du compte de films
     * Utilisé pour affichage conditionnel (liste vide vs contenu)
     */
    readonly property bool hasData: filmCount > 0

    /**
     * Nombre de films disponibles
     * Readonly : binding automatique vers FilmDataSingletonModel.films.length
     * Utilisé pour affichage du titre ("X films" dans header)
     */
    readonly property int filmCount: Model.FilmDataSingletonModel.films.length

    /**
     * Message d'erreur en cas de problème
     * Readonly : binding automatique vers FilmDataSingletonModel.lastError
     * Utilisé pour logging ou debugging
     */
    readonly property string errorMessage: Model.FilmDataSingletonModel.lastError

    // ============================================
    // SIGNAUX - Communication avec la Vue
    // ============================================

    /**
     * Signal pour propager les erreurs à la Vue
     * Utilisé par CataloguePage.Connections pour afficher toast d'erreur
     *
     * @param {string} message - Description de l'erreur
     */
    signal errorOccurred(string message)

    // ============================================
    // INSTANCE DU SERVICE HTTP
    // ============================================

    /**
     * Service HTTP pour appels API
     * Émet des signaux : filmsFetched, fetchError
     * Écouté via Connections ci-dessous
     */
    Services.FilmService {
        id: filmService
        apiUrl: "https://localhost:8000/api"
    }

    // ============================================
    // CONNECTIONS AUX SIGNAUX DU SERVICE
    // ============================================

    /**
     * Écoute les signaux du FilmService
     * Communication : Service → Logic
     *
     * Flux :
     * 1. filmService.fetchAllFilms() déclenché
     * 2. Service reçoit réponse HTTP
     * 3. Service émet filmsFetched ou fetchError
     * 4. Les handlers ci-dessous réagissent
     */
    Connections {
        target: filmService

        /**
         * Traitement du résultat positif
         *
         * Responsabilités :
         * - Transformer les films reçus
         * - Mettre à jour le Model
         * - Pas d'affichage d'erreur (succès)
         *
         * Transformation :
         * - Extrait uniquement les champs nécessaires
         * - Élimine les données inutiles
         * - Prépare pour l'affichage dans GridView
         */
        function onFilmsFetched(films) {
            console.log("📥 Réception de", films.length, "films depuis API")

            Model.FilmDataSingletonModel.updateFromAPI(
                films.map(function(f) {
                    return {
                        id: f.id,
                        title: f.title,
                        poster_url: f.poster_url
                    }
                })
            )

            console.log("✅ Catalogue mis à jour")
        }

        /**
         * Gestion des erreurs réseau/API
         *
         * Responsabilités :
         * - Enregistrer l'erreur dans le Model
         * - Propager le signal vers la Vue
         * - Vue affichera toast d'erreur
         */
        function onFetchError(errorMessage) {
            console.error("❌ Erreur API:", errorMessage)

            // 1. Enregistrer dans le Model (état global)
            Model.FilmDataSingletonModel.setError(errorMessage)

            // 2. Propager vers la Vue
            errorOccurred(errorMessage)
        }
    }

    // Timer {
    //     id: refreshTimer
    //     interval: 30000   // Délai en ms (ici 0,8 seconde)
    //     repeat: false
    //     onTriggered: {
    //         Model.FilmDataSingletonModel.startLoading();
    //         filmService.fetchAllFilms();
    //     }
    // }

    // ============================================
    // MÉTHODES PUBLIQUES - API de la Logic
    // ============================================

    /**
     * Lance le chargement des films depuis l'API
     *
     * Flow :
     * 1. Signal startLoading() au Model (isLoading = true)
     * 2. Appel filmService.fetchAllFilms()
     * 3. Service effectue HTTP GET /movies/
     * 4. Signal filmsFetched ou fetchError reçu
     * 5. Handlers Connections réagissent
     *
     * Utilisé par : Vue quand utilisateur clique "Rafraîchir"
     * Ou : CatalogueLogic.useTestData() pour test
     */
    function refreshCatalogue() {
        console.log("🔄 Rafraîchissement du catalogue depuis API")
        Model.FilmDataSingletonModel.startLoading()
        filmService.fetchAllFilms()
        // refreshTimer.start();
    }

    /**
     * Charge les données de test (développement)
     *
     * Justification :
     * - Développement sans backend opérationnel
     * - Tests UI/UX rapides
     * - Données fixes et prévisibles
     *
     * Utilisé par : Component.onCompleted (voir ci-dessous)
     * Remplace : refreshCatalogue() en développement
     */
    function useTestData() {
        console.log("📋 Chargement des données de test")
        Model.FilmDataSingletonModel.useTestData()
    }

    // ============================================
    // INITIALISATION
    // ============================================

    /**
     * Chargement automatique au démarrage
     *
     * Choix actuellement : données de test
     * Future : décommenter refreshCatalogue() pour API réelle
     *
     * Justification de Qt.callLater :
     * - Évite la création du Component de sa propre destruction
     * - Repousse l'exécution au prochain tick événement
     * - Meilleure séparation des cycles de vie
     */
    Component.onCompleted: {
        console.log("🚀 Initialisation CatalogueLogic")

        // Développement : utiliser données de test
        Qt.callLater(useTestData)

        // Production : décommenter pour API réelle
        // Qt.callLater(refreshCatalogue)
    }

}
