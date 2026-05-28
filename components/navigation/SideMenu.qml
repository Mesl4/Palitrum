import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root
    width: 240
    Layout.fillHeight: true
    color: "#0f172a" // Глубокий тёмный бэкэнд-фон меню
    border.color: "#1e293b"
    border.width: 1

    signal pageSelectionChanged(int index)

    component NavButton : ToolButton {
        id: btn
        Layout.fillWidth: true
        Layout.preferredHeight: 46
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        checkable: true

        contentItem: Item {
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                spacing: 12

                Text {
                    text: btn.text
                    font.pixelSize: 14
                    font.bold: btn.checked
                    color: btn.checked ? "#60a5fa" : "#94a3b8" // Яркий акцент у выбранного элемента
                    Layout.fillWidth: true
                }
            }
        }

        background: Rectangle {
            radius: 8
            // Слабое синее свечение при выборе или серый ховер
            color: btn.checked ? "#1e3a8a" : (btn.hovered ? "#1e293b" : "transparent")

            Rectangle {
                width: 4
                height: 20
                radius: 2
                color: "#60a5fa"
                visible: btn.checked
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 2
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 32
        spacing: 8

        ButtonGroup { id: navGroup }

        NavButton {
            text: "🎨  Палитры"
            checked: true
            ButtonGroup.group: navGroup
            onClicked: root.pageSelectionChanged(0)
        }

        NavButton {
            text: "📁  Проекты"
            ButtonGroup.group: navGroup
            onClicked: root.pageSelectionChanged(1)
        }

        NavButton {
            text: "⭐  Избранное"
            ButtonGroup.group: navGroup
            onClicked: root.pageSelectionChanged(2)
        }

        Item { Layout.fillHeight: true }
    }
}
