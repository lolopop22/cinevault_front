import Felgo 4.0
import QtQuick 2.15

App {
    NavigationStack {
        Page {
            title: "Catalogue"

            Rectangle {
                width: parent.width
                height: parent.height

                Text {
                    anchors.centerIn: parent
                    text: "Bienvenue au Catalogue"
                }
            }
        }
    }
}
