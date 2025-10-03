import Felgo 4.0
import QtQuick 2.15
import "logic"
import "model"
import "pages"

App {
    id: app

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
                        /* Plus besoin de passer le modèle, il sera accessible via import car on passe maintenant par le pattern Singleton */
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
        console.log("Films disponibles:", FilmDataSingletonModel.films.length)
        console.log(" ")

        // Chargement initial des données (sera implémenté plus tard)
    }
}
