import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "pages"
import "components/navigation"
ApplicationWindow {
    visible: true
    width: 1000; height: 700
    title: "Palitrum"

    RowLayout{
        anchors.fill: parent
        SideMenu {
            Layout.preferredWidth: 200
            Layout.fillHeight: true

            // ПРИВЯЗКА: когда в меню меняется выбор, меняем индекс стека
            onPageSelectionChanged: (index) => {
                navStack.currentIndex = index
            }
        }

        StackLayout {
            id: navStack // ID для управления
            Layout.fillHeight: true
            Layout.fillWidth: true

            // Индекс 0
            SearchPalettePage {}
            // Индекс 1
            ProjectPage { }
            // Индекс 2
            FavoritePage { }
        }
    }
    background: Rectangle{
        anchors.fill: parent
        color: "#2D4263"
        z: -1
    }
}
