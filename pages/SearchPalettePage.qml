import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components/cards"
import "../components/controls"

Item {
    id: favoriteRoot

    // Теперь храним только сортировку. Страницами управляет C++
    property string currentSorting: "default"

    Connections {
        target: searchPaletteModel

        // Исправлен синтаксис согласно предупреждению Qt: function onFoo()
        function onPageLoaded() {
            console.log("Страница успешно добавлена в модель.")
        }
    }

    // Вспомогательная функция для отправки запроса
    function loadPage(page, sorting, isNextPage = false) {
        let url = `https://lospec.com/palette-list/load?colorNumberFilterType=any&colorNumber=8&page=${page}&tag=&sortingType=${sorting}`;
        console.log("Запрос страницы:", page, "URL:", url);
        searchPaletteModel.fetchPalettes(url, isNextPage);
    }

    Component.onCompleted: {
        searchPaletteModel.resetPage();
        // Загружаем первую страницу (1)
        favoriteRoot.loadPage(1, favoriteRoot.currentSorting, false);
    }

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
                placeholder: "Поиск палитр..."
                onTextChanged: (text) => {
                    searchFilterModel.setFilterFixedString(text)
                }
            }

            SortComboBox {
                targetModel: searchFilterModel
                customAction: (index) => {
                    searchFilterModel.sortRole = -1;

                    // Сбрасываем страницу в C++ модели
                    searchPaletteModel.resetPage();
                    favoriteRoot.currentSorting = (index === 0) ? "default" : "alphabetical";

                    // Грузим заново первую страницу с новой сортировкой
                    favoriteRoot.loadPage(1, favoriteRoot.currentSorting, false);
                }
            }
        }

        TextEdit {
            id: clipboardBuffer
            visible: false
        }

        GridView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            Layout.margins: 20
            cellWidth: 280
            cellHeight: 180

            model: searchFilterModel

            delegate: PaletteCard {
                mode: "search"
                width: 260
                height: 160
                cardName: model.name
                colors: model.colorsArray
                onSettingTriggered: (action) => {}
                onCardOpened: {}
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 20
            Layout.alignment: Qt.AlignHCenter

            Button {
                id: loadMoreButton
                enabled: !searchPaletteModel.isLoading
                text: searchPaletteModel.isLoading ? "Загрузка..." : "Загрузить следующую страницу"
                hoverEnabled: false

                contentItem: Text {
                    text: loadMoreButton.text
                    font.pixelSize: 14
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    implicitWidth: 250
                    implicitHeight: 40
                    color: !loadMoreButton.enabled ? "#B0BEC5" : (loadMoreButton.down ? "#1565C0" : "#2196F3")
                    radius: 4
                }

                onClicked: {
                    // Спрашиваем у C++ модели, какой номер страницы должен быть СЛЕДУЮЩИМ.
                    // Если прошлый раз упал в таймаут, метод вернет то же число, что и раньше,
                    // предотвращая холостое накручивание счетчика!
                    let targetPage = searchPaletteModel.nextPage();

                    favoriteRoot.loadPage(targetPage, favoriteRoot.currentSorting, true);
                }
            }
        }
    }
}
