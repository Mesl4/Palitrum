// components/views/SearchView.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    spacing: 10

    // Свойства для управления
    property alias placeholder: searchField.placeholderText
    property string filterText: searchField.text.toLowerCase()

    // Сюда мы будем "складывать" сам контент (GridView или Flow)
    default property alias content: contentArea.children

    TextField {
        id: searchField
        Layout.fillWidth: true
        placeholderText: "Поиск..."
    }

    Item {
        id: contentArea
        Layout.fillWidth: true
        Layout.fillHeight: true
    }
}
