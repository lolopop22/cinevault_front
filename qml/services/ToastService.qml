pragma Singleton
import QtQuick 2.15

/**
 * ToastService - Singleton QML pour accès global au ToastManager
 *
 * Pattern : Service Locator (recommandé Qt)
 *
 * Architecture :
 * ┌─────────────────────────────────────────┐
 * │ ToastService (Singleton logique)        │
 * │ - Accessible partout                    │
 * │ - Pas de parent visuel                  │
 * │ - API publique                          │
 * └──────────────┬──────────────────────────┘
 *                │ référence (_manager)
 *                ↓
 * ┌─────────────────────────────────────────┐
 * │ ToastManager (Instance visuelle)        │
 * │ - Parent : Overlay.overlay              │
 * │ - Rendu à l'écran                       │
 * │ - Implémentation concrète               │
 * └─────────────────────────────────────────┘
 *
 * Avantages :
 * 1. ✅ Singleton QML (protection duplication Qt)
 * 2. ✅ Pas de dépendance sur "app"
 * 3. ✅ Testable (peut être mocké)
 * 4. ✅ Performance (accès direct)
 * 5. ✅ Cohérent avec FilmDataSingletonModel
 *
 * Usage :
 * import "../services" as Services
 *
 * Services.ToastService.showError("Erreur")
 * Services.ToastService.showSuccess("Succès")
 *
 * Références :
 * - Qt Singleton docs : https://doc.qt.io/qt-6/qml-singleton.html
 * - Service Locator pattern : https://martinfowler.com/articles/injection.html
 */
QtObject {
    id: toastService

    // ============================================
    // RÉFÉRENCE À L'IMPLÉMENTATION
    // ============================================

    /**
     * Référence vers l'instance visuelle de ToastManager
     *
     * Initialement : null
     * Définie par : Main.qml via initialize()
     *
     * Justification :
     * - Singleton ne peut pas créer ToastManager lui-même (visuel)
     * - Main.qml crée ToastManager (avec parent visuel)
     * - Main.qml enregistre l'instance ici
     * - Service délègue tous les appels à cette instance
     */
    property var _manager: null

    // ============================================
    // INITIALISATION
    // ============================================

    /**
     * Initialise le service avec l'instance visuelle
     *
     * Appelé depuis Main.qml au démarrage de l'app
     *
     * @param {ToastManager} managerInstance - Instance de ToastManager
     *
     * Flow :
     * 1. Main.qml crée ToastManager (avec parent visuel)
     * 2. Main.qml appelle ToastService.initialize(toastManager)
     * 3. ToastService stocke la référence dans _manager
     * 4. ToastService est prêt à être utilisé
     *
     * Justification :
     * - Inversion de contrôle (IoC)
     * - Main.qml = point d'entrée (responsable initialisation)
     * - ToastService = pure logique (pas de création d'UI)
     */
    function initialize(managerInstance) {
        console.log("🔧 ToastService.initialize()")

        // Validation de l'instance
        if (!managerInstance) {
            console.error("❌ ToastService.initialize() : managerInstance est null")
            return
        }

        // Enregistrement de l'instance
        _manager = managerInstance

        console.log("✅ ToastService initialisé avec ToastManager")
        console.log("📍 Manager parent:", _manager.parent)
    }

    // ============================================
    // API PUBLIQUE - Délégation au ToastManager
    // ============================================

    /**
     * Affiche un toast avec type personnalisé
     *
     * @param {string} text - Message à afficher
     * @param {string} type - Type (success, error, warning, info)
     * @param {int} duration - Durée en ms (optionnel, défaut 3000)
     *
     * Délègue l'appel au ToastManager sous-jacent
     *
     * Justification :
     * - Service = façade (design pattern Facade - https://refactoring.guru/fr/design-patterns/facade)
     * - Délégation pure (pas de logique métier ici)
     * - Validation de l'initialisation (fail-safe)
     */
    function show(text, type, duration) {
        // Vérification que le service est initialisé
        if (!_manager) {
            console.error("❌ ToastService.show() : Service non initialisé")
            console.error("   → Appelez ToastService.initialize() depuis Main.qml")
            console.error("   → Message non affiché :", text)
            return
        }

        // Délégation au manager
        _manager.show(text, type, duration)
    }

    /**
     * Raccourcis pour types courants
     *
     * Justification :
     * - API simple pour cas fréquents
     * - Évite erreurs de typage
     * - Auto-complétion IDE
     */
    function showSuccess(text, duration) {
        if (!_manager) {
            console.error("❌ ToastService.showSuccess() : Service non initialisé")
            return
        }
        _manager.showSuccess(text, duration)
    }

    function showError(text, duration) {
        if (!_manager) {
            console.error("❌ ToastService.showError() : Service non initialisé")
            return
        }
        _manager.showError(text, duration)
    }

    function showWarning(text, duration) {
        if (!_manager) {
            console.error("❌ ToastService.showWarning() : Service non initialisé")
            return
        }
        _manager.showWarning(text, duration)
    }

    function showInfo(text, duration) {
        if (!_manager) {
            console.error("❌ ToastService.showInfo() : Service non initialisé")
            return
        }
        _manager.showInfo(text, duration)
    }

    // ============================================
    // UTILITAIRES
    // ============================================

    /**
     * Vérifie si le service est initialisé
     *
     * Utile pour debugging ou validation dans les tests
     */
    function isInitialized() {
        return _manager !== null
    }
}
