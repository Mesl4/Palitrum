import QtQuick
import QtQuick.Controls

Window {
    id: paletteWindow
    width: 400
    height: 500
    title: "Просмотр палитры"
    modality: Qt.NonModal // Окно не блокирует основное приложение

    // Сюда будем передавать цвета из карточки
    property var colors: []

    Rectangle {
        anchors.fill: parent
        color: "#1e293b"

        GridView {
            anchors.fill: parent
            anchors.margins: 20
            model: colors
            cellWidth: 80; cellHeight: 80

            delegate: Rectangle {
                id: colorCard
                width: 70; height: 70
                radius: 8

                // Сохраняем оригинальный цвет
                property color originalColor: modelData
                color: originalColor

                // Текст-подсказка, появляющийся при копировании
                Text {
                    id: copiedText
                    text: "✓"
                    color: "white"
                    font.bold: true
                    font.pixelSize: 18
                    anchors.centerIn: parent
                    opacity: 0 // По умолчанию невидим

                    // Белая обводка для читаемости на светлых цветах
                    style: Text.Outline
                    styleColor: "#1e293b"
                }

                // Таймер для автоматического возврата цвета в исходное состояние
                Timer {
                    id: resetTimer
                    interval: 300 // Время удержания эффекта в миллисекундах
                    onTriggered: colorCard.state = ""
                }

                // Описываем состояние "copied" (скопировано)
                states: [
                    State {
                        name: "copied"
                        PropertyChanges { target: colorCard; color: "#2ecc71" } // Меняем цвет на зеленый (или любой другой, например "#ffffff")
                        PropertyChanges { target: copiedText; opacity: 1 }     // Показываем галочку
                    }
                ]

                // Плавный переход цвета обратно к оригиналу при сбросе состояния
                transitions: [
                    Transition {
                        from: "copied"; to: ""
                        ColorAnimation { duration: 250 } // Плавное затухание за 250мс
                        NumberAnimation { target: copiedText; property: "opacity"; duration: 200 }
                    }
                ]

                // Добавляем MouseArea для отслеживания клика
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor // Курсор-пальчик при наведении

                    onClicked: {
                        // Запускаем состояние анимации
                        colorCard.state = "copied"
                        resetTimer.restart()

                        // Копируем в буфер
                        colorCard.copyColorToClipboard(modelData)
                    }
                }

                function copyColorToClipboard(colorValue) {
                    // Создаем временный элемент для доступа к буферу обмена
                    // Используем paletteWindow как родителя
                    let dynamicBuffer = Qt.createQmlObject(
                        'import QtQuick; TextEdit { visible: false }',
                        paletteWindow
                    );

                    if (dynamicBuffer) {
                        dynamicBuffer.text = colorValue;
                        dynamicBuffer.selectAll();
                        dynamicBuffer.copy(); // Копируем в буфер обмена системы
                        dynamicBuffer.destroy();

                        console.log("Цвет " + colorValue + " скопирован в буфер!");
                    }
                }
            }
        }
    }
}
