import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root
    title: isEditMode ? "Редактирование проекта" : "Создание проекта"
    standardButtons: Dialog.Save | Dialog.Cancel
    modal: true
    focus: true
    anchors.centerIn: Overlay.overlay
    width: 350

    property bool isEditMode: true // Флаг режима
    property string currentProjectId: ""
    property alias nameText: nameField.text

    ColumnLayout {
        width: parent.width
        spacing: 15

        Label {
            text: "Название проекта:"
            font.pixelSize: 12
            color: "#666"
        }

        TextField {
            id: nameField
            placeholderText: "Введите имя..."
            maximumLength: 30
            Layout.fillWidth: true
            font.pixelSize: 16
        }
    }

    onAccepted: {
        if (isEditMode) {
            // Обновление существующего
            projectFilterModel.sourceModel.updateProjectById(root.currentProjectId, nameField.text, "Описание")
        } else {
            // Создание нового
            projectFilterModel.sourceModel.addProject(nameField.text, "Описание")
        }
    }

    // Метод для редактирования
    function openForEdit(id, name) {
        isEditMode = true
        root.currentProjectId = id
        root.nameText = name
        root.open()
    }

    // Метод для создания
    function openForCreate() {
        isEditMode = false
        root.currentProjectId = ""
        root.nameText = ""
        root.open()
    }
}
