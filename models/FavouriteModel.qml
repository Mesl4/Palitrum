import QtQuick
import "../storage/Favourites.js" as FavouritesStorage
import "../storage/Palettes.js" as PalettesStorage

Item {
    id: root
    property string searchText: ""
    property string sortType: "По умолчанию"

    property var items: []

    function loadAndSyncData() {
        var favs = FavouritesStorage.getFavourites();
        var pails = PalettesStorage.getPalettes();
        var synced = [];

        for (var i = 0; i < favs.length; i++) {
            var fav = favs[i];
            // Поиск оригинальной палитры
            var original = pails.find(p => p.id === fav.paletteId);

            if (!original) {
                // Если палитра отсутствует в системе
                fav.missingSource = true;
                fav.sourceProjectName = "Исходный проект удален";
            } else if (original.modifiedDate !== fav.modifiedDate) {
                // Если даты модификации разнятся — обновляем слепок данных в избранном
                fav.colors = original.colors;
                fav.modifiedDate = original.modifiedDate;
            }

            // Фильтрация по поисковому запросу
            if (root.searchText !== "") {
                if (fav.paletteName.toLowerCase().indexOf(root.searchText.toLowerCase()) === -1) {
                    continue;
                }
            }
            synced.push(fav);
        }

        if (root.sortType === "По названию") {
            synced.sort((a, b) => a.paletteName.localeCompare(b.paletteName));
        } else if (root.sortType === "По дате") {
            synced.sort((a, b) => b.modifiedDate.localeCompare(a.modifiedDate));
        }

        root.items = synced;
    }

    Component.onCompleted: loadAndSyncData()

    onSearchTextChanged: loadAndSyncData()
    onSortTypeChanged: loadAndSyncData()
}
