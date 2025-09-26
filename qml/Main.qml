import Felgo 4.0
import QtQuick 2.15
import "logic"
import "model"
import "pages"

App {
    // You get free licenseKeys from https://felgo.com/licenseKey
    // With a licenseKey you can:
    //  * Publish your games & apps for the app stores
    //  * Remove the Felgo Splash Screen or set a custom one (available with the Pro Licenses)
    //  * Add plugins to monetize, analyze & improve your apps (available with the Pro Licenses)
    //licenseKey: "<generate one from https://felgo.com/licenseKey>"

    // Modèle de données global
    FilmDataModel {
        id: filmDataModel
    }

    // Navigation principale avec Bottom Navigation
    Navigation {
        navigationMode: navigationModeDefault

        NavigationItem {
            title: "Catalogue"
            iconType: IconType.film

            NavigationStack {
                initialPage: CataloguePage {
                    // Passage des références globales
                    filmDataModel: filmDataModel
                }
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
        }
    }

    // Initialisation de l'application
    Component.onCompleted: {
        console.log("Film Catalogue App initialisée")
        // Chargement initial des données (sera implémenté plus tard)
    }
}
