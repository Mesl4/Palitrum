import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components/cards"
import "../components/controls"
import "../components/dialogs" // Добавили, чтобы иметь доступ к ProjectDialog

Item {
    id: searchPage
    signal requestOpenProject(string name, string id)

    // Добавляем диалог для редактирования проектов
    EditProjectDialog { id: projectDialog }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 10
            spacing: 10
            SpecialButton{buttonText: "Добавить в проект"}
            SearchBar {
                id: searchBar
                Layout.fillWidth: true
                placeholder: "Поиск проекта..."
                onTextChanged: (text) => projectFilterModel.setFilterFixedString(text)
            }

            SortComboBox {
                targetModel: projectFilterModel
            }
        }

        GridView {
            id: gridView
            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: 250
            cellHeight: 300
            model: projectFilterModel

            delegate: ProjectCard {
                width: 230
                height: 280
                cardName: model.name

                onCardOpened: (name) => requestOpenProject(name, model.id)

                // ВАЖНО: Добавляем обработку настроек для проектов
                onSettingTriggered: (action) => {
                    if (action === "edit") {
                        projectDialog.openForEdit(model.id, model.name);
                    } else if (action === "delete") {
                        // Предполагаем, что у тебя есть метод в ProjectModel
                        // Замени projectModel на имя, которое ты пробросил в Main.qml
                        projectFilterModel.sourceModel.removeProjectById(model.id);
                    }
                }
            }
        }
    }
}
