import QtQuick 2.15
import Felgo 4.0
import "../model" as Model

/**
 * FilmDetailLogic - Logique métier pour la page de détails d'un film
 *
 * Responsabilités :
 * - Charger les données d'un film depuis le modèle global (par ID)
 * - Gérer les erreurs de chargement (film introuvable, ID invalide)
 * - Préparer les données pour l'affichage dans la Vue

 * Respect du pattern MVC
 * - Controller/Logic : Orchestre entre Model (FilmDataSingletonModel) et View (FilmDetailPage)
 * - Émet des signaux pour communication avec la Vue
 */
QtObject {
    id: filmDetailLogic

    // ============================================
    // PROPRIÉTÉS PUBLIQUES - Interface pour la Vue
    // ============================================

    // Film actuellement chargé
    property var currentFilm: null

    // Indicateur de chargement
    property bool loading: false

    // Message d'erreur
    property string errorMessage: ""

    // ============================================
    // SIGNAUX - Communication avec la Vue
    // ============================================

    // ignal émis quand le film est chargé avec succès
    signal filmLoaded(var film)

    // Signal émis en cas d'erreur de chargement
    signal loadError(string message)

    // ============================================
    // MÉTHODES PUBLIQUES - API de la Logic
    // ============================================

    /**
     * Charge les données d'un film depuis le modèle global
     *
     * Algorithme :
     * 1. Validation de l'ID (doit être > 0)
     * 2. Vérification du catalogue (pas vide)
     * 3. Recherche linéaire du film par ID (O(n), acceptable pour <1000 films)
     * 4. Mise à jour de currentFilm ou errorMessage
     * 5. Émission du signal approprié (filmLoaded ou loadError)
     *
     * Paramètres :
     * - filmId (int) : ID du film à charger
     *
     * Retour : void (résultat via propriétés et signaux)
     */
    function loadFilm(filmId) {
        console.log("=== DEBUG FilmDetailLogic.loadFilm ===")
        console.log("🔍 Chargement du film ID:", filmId)

        // PHASE 1 : VALIDATION DE L'ID
        if (filmId <= 0) {
            var invalidIdMsg = "ID de film invalide\n\nL'ID du film doit être un nombre positif."
            console.error("❌ ID invalide:", filmId)

            // Mise à jour de l'état
            currentFilm = null
            errorMessage = invalidIdMsg
            loading = false

            // Émission du signal d'erreur
            loadError(invalidIdMsg)
            return
        }

        // PHASE 2 : ACCÈS AU MODÈLE GLOBAL
        loading = true
        errorMessage = ""

        var films = Model.FilmDataSingletonModel.films

        // Vérification : catalogue vide
        if (!films || films.length === 0) {
            var emptyCatalogMsg = "Catalogue vide\n\nAucun film n'est disponible dans le catalogue."
            console.warn("⚠️ Catalogue vide lors du chargement du film ID:", filmId)

            // Mise à jour de l'état
            currentFilm = null
            errorMessage = emptyCatalogMsg
            loading = false

            // Émission du signal d'erreur
            loadError(emptyCatalogMsg)
            return
        }

        console.log("📊 Catalogue disponible:", films.length, "films")

        // PHASE 3 : RECHERCHE DU FILM PAR ID
        for (var i = 0; i < films.length; i++) {
            if (films[i].id === filmId) {
                // ✅ FILM TROUVÉ
                currentFilm = films[i]
                errorMessage = ""
                loading = false

                console.log("✅ Film trouvé:")
                console.log("   - Titre:", currentFilm.title)
                console.log("   - ID:", currentFilm.id)
                console.log("   - Poster:", currentFilm.poster_url ? "disponible" : "manquant")

                // Émission du signal de succès
                filmLoaded(currentFilm)
                return
            }
        }

        // PHASE 4 : FILM NON TROUVÉ
        var notFoundMsg = "Film introuvable\n\nLe film avec l'ID " + filmId + " n'existe pas dans le catalogue."
        console.error("❌ Film non trouvé avec ID:", filmId)

        // Log des IDs disponibles pour debugging
        var availableIds = films.map(function(f) { return f.id }).join(", ")
        console.error("   IDs disponibles:", availableIds)

        // Mise à jour de l'état
        currentFilm = null
        errorMessage = notFoundMsg
        loading = false

        // Émission du signal d'erreur
        loadError(notFoundMsg)
    }

    /**
     * Réinitialise l'état de la Logic
     *
     * Usage : Appelé quand on quitte la page de détails pour nettoyer l'état
     */
    function reset() {
        console.log("🔄 Reset FilmDetailLogic")
        currentFilm = null
        errorMessage = ""
        loading = false
    }
}
