import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../views"

ItemCard {
    id: root
    cardName: model.name
    clip: true

    cardContent: ColumnLayout {
        anchors.fill: parent
        spacing: 0 // Убираем отступы, чтобы графика была до краев

        // Создаем контейнер, в котором графика и кружок будут лежать друг на друге
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // 1. Твой генеративный дизайн на фоне
            AbstractLayers {
                anchors.fill: parent
                seed: model.id
            }

            // 2. Кружок с числом палитр посередине
            Rectangle {
                anchors.centerIn: parent
                width: 54
                height: 54
                radius: 27
                color: "#ffffff"
                opacity: 0.9 // Матовый эффект

                // Тонкая обводка, чтобы кружок не сливался с фоном
                border.color: "#22000000"
                border.width: 1

                Label {
                    anchors.centerIn: parent
                    text: model.paletteCount
                    font.pixelSize: 22
                    font.bold: true
                    color: "#222"
                }
            }
        }
    }

    menuItems: [
        MenuItem {
            text: "Редактировать";
            onTriggered: root.settingTriggered("edit", root.cardName);
            // Обязательно добавь эти строки, чтобы текст был виден на черном
            contentItem: Text { text: parent.text; color: "#ffffff"; leftPadding: 16; verticalAlignment: Text.AlignVCenter }
        },
        MenuItem {
            text: "Удалить";
            onTriggered: root.settingTriggered("delete", root.cardName);
            contentItem: Text { text: parent.text; color: "#ffffff"; leftPadding: 16; verticalAlignment: Text.AlignVCenter }
        }
    ]
}
