import QtQuick
import QtQuick.Controls
import "../views"

ItemCard {
    id: root
    property var colors: []
    property int maxPerRow: 5
    property string mode: "" // "search", "favorite", ""

    PaletteView {
        anchors.fill: parent
        colors: root.colors
        maxPerRow: root.maxPerRow
    }

    // Вместо статического массива используем функцию для создания меню
    function getContextMenuItems() {
        var items = [];

        // 1. Всегда можно добавить в проект
        items.push(Qt.createQmlObject('import QtQuick.Controls;import QtQuick; MenuItem {text: "Копировать"; onTriggered: root.copyPaletteToClipboard();contentItem: Text { text: parent.text; color: "#ffffff"; leftPadding: 16; verticalAlignment: Text.AlignVCenter }}', root));
        // Внутри getContextMenuItems в PaletteCard.qml
        // 2. "В избранное" только если не в режиме избранного
        if (root.mode === "") {
            items.push(Qt.createQmlObject('import QtQuick.Controls;import QtQuick; MenuItem { text: "В избранное"; onTriggered: root.settingTriggered("favorite", root.cardName);contentItem: Text { text: parent.text; color: "#ffffff"; leftPadding: 16; verticalAlignment: Text.AlignVCenter } }', root));
        }

        // 3. "Редактировать" только если стандартный режим
        if (root.mode === "") {
            items.push(Qt.createQmlObject('import QtQuick.Controls;import QtQuick; MenuItem { text: "Редактировать"; onTriggered: root.settingTriggered("edit", root.cardName);contentItem: Text { text: parent.text; color: "#ffffff"; leftPadding: 16; verticalAlignment: Text.AlignVCenter } }', root));
        }

        // 4. "Удалить" если не в режиме поиска
        if (root.mode !== "search") {
            items.push(Qt.createQmlObject('import QtQuick.Controls;import QtQuick; MenuItem { text: "Удалить"; onTriggered: root.settingTriggered("delete", root.cardName);contentItem: Text { text: parent.text; color: "#ffffff"; leftPadding: 16; verticalAlignment: Text.AlignVCenter } }', root));
        }

        return items;
    }
    function copyPaletteToClipboard() {
        // Формируем структуру данных на основе свойств этой карточки
        let paletteJson = {
            "title": root.cardName,
            "colors": root.colors,
            "exportedAt": new Date().toISOString()
        };
        let jsonString = JSON.stringify(paletteJson, null, 2);

        // Создаем невидимый текстовый буфер "на лету"
        let dynamicBuffer = Qt.createQmlObject(
            'import QtQuick; TextEdit { visible: false; activeFocusOnTab: false }',
            root
        );

        if (dynamicBuffer) {
            dynamicBuffer.text = jsonString;
            dynamicBuffer.selectAll();
            dynamicBuffer.copy(); // Копируем в систему
            dynamicBuffer.destroy(); // Сразу удаляем из памяти
        }
    }
    // Внутри PaletteCard.qml

        // Создаем компонент окна один раз
        property Component windowComponent: Qt.createComponent("PaletteWindow.qml")

        onCardOpened: {
            if (windowComponent.status === Component.Ready) {
                // Создаем окно
                var newWindow = windowComponent.createObject(root, {
                    "colors": root.colors,
                    "title": root.cardName
                });
                newWindow.show(); // Показываем его
            } else {
                console.log("Ошибка загрузки окна:", windowComponent.errorString());
            }
        }
    // Присваиваем меню результат функции
    menuItems: getContextMenuItems()
}
