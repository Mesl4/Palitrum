import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components/cards"
import "../components/dialogs"
import "../components/controls"

Item {

    id: detailPage

    property string projectName: ""
    property string projectId: ""

    signal goBack()

    onProjectIdChanged: {
        if (projectId !== "") {
            paletteModel.setProjectId(projectId);
        }
    }

    PaletteDialog { id: paletteDialog }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 20
            spacing: 10

            SpecialButton {
                buttonText: "Назад"
                onClicked: goBack()
            }
            Rectangle{
                height: 20
                width: 2
                color: "#64748b"
            }
            SpecialButton {
                buttonText: "Добавить палитру"
                onClicked: paletteDialog.openForCreate()
            }
            SearchBar {
                id: searchBar
                Layout.fillWidth: true
                placeholder: "Поиск палитры..."
                onTextChanged: (text) => paletteFilterModel.setFilterFixedString(text)
            }

            // ПРИВЯЗКА: передаем нашу прокси-модель
            SortComboBox {
                targetModel: paletteFilterModel
            }
        }

        GridView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            anchors.margins: 20
            cellWidth: 280
            cellHeight: 180

            model: paletteFilterModel

            delegate: PaletteCard {
                width: 260
                height: 160
                cardName: model.name
                colors: model.colorsArray

                onSettingTriggered: (action) => {
                    if (action === "delete") {
                        paletteModel.removePaletteById(model.id);
                    } else if (action === "favorite") {
                        favoriteFilterModel.sourceModel.addFavorite(model.id, detailPage.projectId, model.name, model.colorsArray);
                    } else if (action === "edit") {
                        paletteDialog.openForEdit(model.id, model.name, model.colorsArray);
                    }
                }
            }
        }
    }
}
