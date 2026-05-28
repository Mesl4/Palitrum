import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    height: 44

    property alias placeholder: searchField.placeholderText
    signal textChanged(string text)

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        radius: 22
        color: "#1e293b" // Тёмная подложка
        border.color: searchField.activeFocus ? "#60a5fa" : "#334155"
        Behavior on border.color { ColorAnimation { duration: 150 } }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 10

            Label {
                text: "🔍"
                font.pixelSize: 15
                color: searchField.activeFocus ? "#60a5fa" : "#64748b"
            }

            TextField {
                id: searchField
                Layout.fillWidth: true
                Layout.fillHeight: true
                placeholderText: "Поиск..."
                placeholderTextColor: "#64748b" // Приглушённый цвет плейсхолдера
                color: "#f8fafc"
                background: Item {}
                verticalAlignment: TextInput.AlignVCenter
                onTextChanged: root.textChanged(text)
            }

            ToolButton {
                visible: searchField.text.length > 0
                text: "✕"
                font.pixelSize: 12

                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: parent.hovered ? "#f8fafc" : "#64748b"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                background: Rectangle {
                    radius: 12
                    color: parent.hovered ? "#475569" : "transparent"
                }
                onClicked: searchField.text = ""
            }
        }
    }
}
