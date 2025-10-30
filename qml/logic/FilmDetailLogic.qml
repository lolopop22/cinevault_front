import QtQuick 2.15
import Felgo 4.0
import "../model" as Model

/**
 * FilmDetailLogic - Controller MVC pour la page de détails d'un film
 *
 * Responsabilités :
 * - Charger les données d'un film depuis le modèle global (par ID)
 * - Gérer les erreurs de chargement (film introuvable, ID invalide)
 * - Préparer les données pour l'affichage dans la Vue (FilmDetailPage)
 * - Respecter le pattern MVC avec séparation strict View/Logic
 *
 * Pattern :
 * - Hérite de QtObject (pas d'éléments visuels)
 * - Propriétés readonly pour exposition publique
 * - Propriétés privées (_) pour état interne
 * - Signaux pour communication avec la Vue
 * - Méthodes publiques pour API logique
 * - Méthodes privées (_) pour orchestration interne
 */
QtObject {
    id: filmDetailLogic

    // ============================================
    // PROPRIÉTÉS PUBLIQUES - Interface pour la Vue
    // ============================================

    /**
     * Film actuellement chargé
     * Readonly : exposé pour bindings dans la Vue
     * Mis à jour via signal filmLoaded ou interne _currentFilm
     */
    readonly property var currentFilm: _currentFilm

    /**
     * Indicateur de chargement
     * True pendant la recherche du film
     * Readonly : pour UI réactive (BusyIndicator, etc.)
     */
    readonly property bool loading: _loading

    /**
     * Message d'erreur en cas de problème
     * Readonly : exposé pour affichage ou logs
     * Vide si pas d'erreur
     */
    readonly property string errorMessage: _errorMessage

    // ============================================
    // SIGNAUX - Communication avec la Vue
    // ============================================

    /**
     * Signal émis quand le film est chargé avec succès
     * Utilisé par FilmDetailPage pour affichage (toast succès)
     *
     * Paramètre : film (object) - Les données complètes du film
     */
    signal filmLoaded(var film)

    /**
     * Signal émis en cas d'erreur de chargement
     * Utilisé par FilmDetailPage pour affichage (toast erreur)
     *
     * Paramètre : message (string) - Description de l'erreur
     */
    signal loadError(string message)

    // ============================================
    // PROPRIÉTÉS PRIVÉES - État interne
    // ============================================

    /**
     * Film en cours de traitement (interne)
     * Convention _ = private, non accessible de l'extérieur
     */
    property var _currentFilm: null

    /**
     * État de chargement (interne)
     * Convention _ = private
     */
    property bool _loading: false

    /**
     * Message d'erreur (interne)
     * Convention _ = private
     */
    property string _errorMessage: ""

    // ============================================
    // MÉTHODES PUBLIQUES - API de la Logic
    // ============================================

    /**
     * Charge les données d'un film depuis le modèle global
     *
     * Algorithme :
     * 1. Validation de l'ID (doit être > 0)
     * 2. Accès au FilmDataSingletonModel
     * 3. Recherche linéaire du film par ID (O(n), acceptable pour <1000 films)
     * 4. Mise à jour de l'état ou gestion d'erreur
     * 5. Émission du signal approprié
     *
     * @param {int} filmId - ID du film à charger
     *
     * Comportement :
     * - Si succès : émet filmLoaded(film)
     * - Si erreur : émet loadError(message) + mise à jour errorMessage
     */
    function loadFilm(filmId) {
        console.log("=== DEBUG FilmDetailLogic.loadFilm ===")
        console.log("🔍 Chargement du film ID:", filmId)

        // PHASE 1 : VALIDATION DE L'ID
        if (filmId <= 0) {
            var invalidIdMsg = "ID de film invalide\n\nL'ID du film doit être un nombre positif."
            console.error("❌ ID invalide:", filmId)

            _handleError(invalidIdMsg)
            return
        }

        // PHASE 2 : ACCÈS AU MODÈLE GLOBAL
        _loading = true
        _errorMessage = ""

        var films = Model.FilmDataSingletonModel.films

        // Vérification : catalogue vide
        if (!films || films.length === 0) {
            var emptyCatalogMsg = "Catalogue vide\n\nAucun film n'est disponible dans le catalogue."
            console.warn("⚠️ Catalogue vide lors du chargement du film ID:", filmId)

            _handleError(emptyCatalogMsg)
            return
        }

        console.log("📊 Catalogue disponible:", films.length, "films")

        // PHASE 3 : RECHERCHE DU FILM PAR ID
        var film = _findFilmById(filmId, films)

        if (film) {
            // ✅ FILM TROUVÉ
            _currentFilm = film
            _errorMessage = ""
            _loading = false

            console.log("✅ Film trouvé:")
            console.log("   - Titre:", _currentFilm.title)
            console.log("   - ID:", _currentFilm.id)
            console.log("   - Poster:", _currentFilm.poster_url ? "disponible" : "manquant")

            filmLoaded(_currentFilm)
        } else {
            // ❌ PHASE 4 : FILM NON TROUVÉ
            var notFoundMsg = "Film introuvable\n\nLe film avec l'ID " + filmId + " n'existe pas dans le catalogue."
            console.error("❌ Film non trouvé avec ID:", filmId)

            var availableIds = films.map(function(f) { return f.id }).join(", ")
            console.error("   IDs disponibles:", availableIds)

            _handleError(notFoundMsg)
        }
    }

    /**
     * Réinitialise l'état de la Logic
     *
     * Appelé avant destruction de la page ou pour nettoyer après une erreur
     * Utilisé dans FilmDetailPage.leftBarItem.onClicked
     */
    function reset() {
        console.log("🔄 Reset FilmDetailLogic")
        _currentFilm = null
        _errorMessage = ""
        _loading = false
    }

    // ============================================
    // MÉTHODES PRIVÉES - Orchestration interne
    // ============================================

    /**
     * Recherche un film par ID dans la liste
     *
     * Algorithme : Recherche linéaire (O(n))
     * - Acceptable pour < 1000 films
     * - Si perf problème : penser à implémenter Map/Index dans Model
     *
     * @param {int} filmId - ID à rechercher
     * @param {array} films - Liste de films
     * @return {object} Film trouvé ou null
     */
    function _findFilmById(filmId, films) {
        for (var i = 0; i < films.length; i++) {
            if (films[i].id === filmId) {
                return films[i]
            }
        }
        return null
    }

    /**
     * Gestion centralisée des erreurs
     *
     * Responsabilités :
     * - Mise à jour de l'état interne
     * - Logging structured
     * - Émission du signal
     *
     * @param {string} message - Message d'erreur
     */
    function _handleError(message) {
        _currentFilm = null
        _errorMessage = message
        _loading = false
        loadError(message)
    }
}
