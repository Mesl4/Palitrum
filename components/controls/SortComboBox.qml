import QtQuick
import QtQuick.Controls 2.15

ComboBox {
    id: root
    property var targetModel
    property var customAction

    model: ["По дате", "По имени"]

    background: Rectangle {
        implicitWidth: 150
        implicitHeight: 44
        radius: 22
        color: root.down ? "#334155" : "#1e293b" // Согласовано с SearchBar
        border.color: root.visualFocus ? "#60a5fa" : "#334155"
        Behavior on border.color { ColorAnimation { duration: 150 } }
    }

    contentItem: Text {
            leftPadding: 18
            text: root.displayText
            font.pixelSize: 14

            // ПРАВИЛЬНО: Задаем среднюю жирность через перечисление Font.Medium
            font.weight: Font.Medium

            color: "#f8fafc"
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

    // Стилизация самого выпадающего списка элементов
    popup: Popup {
        y: root.height + 4
        width: root.width
        implicitHeight: contentItem.implicitHeight
        padding: 1

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: root.popup.visible ? root.delegateModel : null
            currentIndex: root.highlightedIndex
        }

        background: Rectangle {
            color: "#1e293b"
            border.color: "#334155"
            radius: 12
        }
    }

    delegate: ItemDelegate {
        width: root.width
        text: modelData
        contentItem: Text {
            text: parent.text
            color: parent.highlighted ? "#60a5fa" : "#f8fafc"
            font.pixelSize: 14
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            color: highlighted ? "#334155" : "transparent"
        }
    }

    onActivated: function(index) {
        if (!targetModel) return;

        if (index === 0) {
            targetModel.sortRole = ModifiedDateRole;
            targetModel.sort(0, Qt.DescendingOrder);
        } else {
            targetModel.sortRole = NameRole;
            targetModel.sort(0, Qt.AscendingOrder);
        }

        if (customAction) {
            customAction(index);
            return;
        }
    }
}
