import Felgo 4.0
import QtQuick 2.15
import "logic"
import "model"
import "pages"

App {
    id: app

    // You get free licenseKeys from https://felgo.com/licenseKey
    // With a licenseKey you can:
    //  * Publish your games & apps for the app stores
    //  * Remove the Felgo Splash Screen or set a custom one (available with the Pro Licenses)
    //  * Add plugins to monetize, analyze & improve your apps (available with the Pro Licenses)
    //licenseKey: "<generate one from https://felgo.com/licenseKey>"

    // Modèle de données initialisé EN PREMIER
    FilmDataModel {
        id: filmDataModel
        Component.onCompleted: {
            console.log("=== DEBUG App - FilmDataModel ===")
            console.log("FilmDataModel initialisé avec", films.length, "films")
            console.log(" ")
        }
    }

    // Navigation principale avec Bottom Navigation
    Navigation {
        navigationMode: navigationModeDefault

        NavigationItem {
            title: "Catalogue"
            iconType: IconType.film

            NavigationStack {
                // Attendre que le modèle soit prêt avant de créer la page
                initialPage: Component {
                    CataloguePage {
                        filmDataModel: filmDataModel
                        // data: "Bonjour"
                    }
                }
            }

            Component.onCompleted: {
                console.log("=== DEBUG App - NavigationItem - Catalogue ===")
                console.log(" ")
            }
        }

        NavigationItem {
            title: "Recherche"
            iconType: IconType.search

            NavigationStack {
                AppPage {
                    title: "Recherche"
                    AppText {
                        anchors.centerIn: parent
                        text: "Page Recherche - À implémenter"
                    }
                }
            }

            Component.onCompleted: {
                console.log("=== DEBUG App - NavigationItem - Recherche ===")
                console.log(" ")
            }
        }

        NavigationItem {
            title: "Profil"
            iconType: IconType.user

            NavigationStack {
                AppPage {
                    title: "Profil"
                    AppText {
                        anchors.centerIn: parent
                        text: "Page Profil - À implémenter"
                    }
                }
            }

            Component.onCompleted: {
                console.log("=== DEBUG App - NavigationItem - Profil ===")
                console.log(" ")
            }
        }
    }

    // Initialisation de l'application
    Component.onCompleted: {
        console.log("App initialisée")
        // Le modèle est maintenant sûrement prêt
        console.log("Films disponibles:", filmDataModel.films.length)
        console.log(" ")

        // Chargement initial des données (sera implémenté plus tard)
    }

}
