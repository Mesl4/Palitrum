import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Dialog {
    id: root
    title: isEditMode ? "Редактировать палитру" : "Новая палитра"
    standardButtons: Dialog.Save | Dialog.Cancel
    modal: true
    width: 400
    anchors.centerIn: Overlay.overlay

    property bool isEditMode: false
    property string currentPaletteId: ""
    property var currentColors: []
    property int selectedColorIndex: -1

    ColorDialog {
        id: qtColorPicker
        onAccepted: {
            let temp = Array.from(currentColors)
            temp[selectedColorIndex] = selectedColor.toString()
            currentColors = []
            currentColors = temp
        }
    }

    // Внутренняя функция для чтения буфера обмена и импорта JSON
    function pastePaletteFromClipboard() {
        // Создаем невидимый текстовый элемент на лету
        let dynamicBuffer = Qt.createQmlObject(
            'import QtQuick; TextEdit { visible: false; activeFocusOnTab: false }',
            root
        );

        if (dynamicBuffer) {
            dynamicBuffer.selectAll();
            dynamicBuffer.paste(); // Вызываем системную вставку текста в TextEdit

            let rawText = dynamicBuffer.text.trim();
            dynamicBuffer.destroy(); // Сразу удаляем объект из памяти

            if (rawText.length === 0) return;

            try {
                // Пытаемся распарсить JSON, который скопировали ранее
                let parsedJson = JSON.parse(rawText);

                // Проверяем валидность структуры (поддерживаем и "title", и "name")
                let newName = parsedJson.title || parsedJson.name || "";
                let newColors = parsedJson.colors || [];

                if (Array.isArray(newColors)) {
                    nameField.text = newName;
                    currentColors = Array.from(newColors);
                }
            } catch (e) {
                console.log("Ошибка парсинга JSON из буфера обмена:", e);
            }
        }
    }

    ColumnLayout {
        width: parent.width - 20
        spacing: 15

        // Строка с текстовым полем и кнопкой вставки в один ряд
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            TextField {
                id: nameField
                placeholderText: "Название палитры"
                Layout.fillWidth: true
            }

            Button {
                text: "📋 Вставить"
                ToolTip.visible: hovered
                ToolTip.text: "Импортировать палитру из буфера обмена"
                onClicked: root.pastePaletteFromClipboard()
            }
        }

        Flow {
            Layout.fillWidth: true
            spacing: 10

            Repeater {
                model: root.currentColors
                delegate: Rectangle {
                    width: 40; height: 40
                    radius: 8
                    color: modelData
                    border.color: "#333"

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: (mouse) => {
                            if (mouse.button === Qt.RightButton) {
                                removeColor(index)
                            } else {
                                selectedColorIndex = index
                                qtColorPicker.open()
                            }
                        }
                    }
                }
            }

            Button {
                text: "+"
                onClicked: {
                    let temp = Array.from(currentColors)
                    temp.push("#cccccc")
                    currentColors = []
                    currentColors = temp
                }
            }
        }
    }

    onAccepted: {
        if (isEditMode) {
            paletteFilterModel.sourceModel.updatePaletteById(currentPaletteId, nameField.text, currentColors);
        } else {
            paletteFilterModel.sourceModel.addPalette(nameField.text, currentColors);
        }
    }

    function openForEdit(id, name, colors) {
        isEditMode = true;
        currentPaletteId = id;
        nameField.text = name;
        currentColors = Array.from(colors);
        open();
    }

    function openForCreate() {
        isEditMode = false;
        currentPaletteId = "";
        nameField.text = "";
        currentColors = [];
        open();
    }

    function removeColor(index) {
        let temp = Array.from(currentColors)
        temp.splice(index, 1)
        currentColors = []
        currentColors = temp
    }
}
