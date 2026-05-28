import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    width: 260
    height: 180
    // Тёмный фон карточки
    color: "#1e293b"
    // Тёмная рамка
    border.color: "#334155"
    border.width: 1
    radius: 8
    clip: true

    property string cardName: ""
    property bool editable: true

    property alias menuItems: settingsMenu.contentData
    default property alias cardContent: contentArea.data

    signal cardOpened(string cardName)
    signal settingTriggered(string action, string cardName)

    MouseArea {
        anchors.fill: parent
        onDoubleClicked: root.cardOpened(root.cardName)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            id: contentArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 8
            clip: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#334155"
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.leftMargin: 12
            Layout.rightMargin: 8

            Label {
                text: root.cardName
                font.bold: true
                font.pixelSize: 14
                color: "#f8fafc" // Светлый текст
                Layout.fillWidth: true
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            ToolButton {

                            // 1. Убираем стандартный фон, чтобы кнопка стала прозрачной
                            background: Rectangle {
                                color: "transparent"
                            }

                            // 2. Настраиваем цвет иконки (текста)
                            contentItem: Text {
                                text: "⚙"
                                font.pixelSize: 18
                                color: "#94a3b8" // Приятный серо-голубой цвет
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: settingsMenu.open()

                            Menu {
                                id: settingsMenu
                                width: 170
                                background: Rectangle {
                                   anchors.fill:parent
                                   color: "#334155"
                                   radius: 16
                                }
                            }
                        }
        }
    }
}
