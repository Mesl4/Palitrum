import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components/cards"
import "../components/controls"

Item {
    id: favoriteRoot

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 20
            spacing: 10

            SearchBar {
                id: searchBar
                Layout.fillWidth: true
                placeholder: "Поиск в избранном..."
                onTextChanged: (text) => {
                    favoriteFilterModel.setFilterFixedString(text)
                }
            }
            // Пример изменения сортировки в QML:
            SortComboBox{
                targetModel: favoriteFilterModel
            }
        }

        GridView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            anchors.margins: 20
            cellWidth: 280
            cellHeight: 180

            // Используем модель избранного
            model: favoriteFilterModel

            delegate: PaletteCard {
                mode: "favorite"
                width: 260
                height: 160
                cardName: model.name
                colors: model.colorsArray

                // Здесь логика действий для избранного
                onSettingTriggered: (action) => {
                    if (action === "delete") {
                        console.log("sdfsdffsdfdsf")
                        // Удаляем из избранного по ID палитры
                        favoriteFilterModel.sourceModel.removeFavoriteById(model.id);
                    }
                }

                // Можно добавить логику "Открыть палитру"
                onCardOpened: {
                    // Например, переход к проекту, где лежит эта палитра
                }
            }
        }
    }
}
