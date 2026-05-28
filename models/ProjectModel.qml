import QtQuick
import "../storage/Projects.js" as ProjectsStorage

Item {
    id: root
    property string searchText: ""
    property string sortType: "По умолчанию"

    property var items: []

    function loadData() {
        var raw = ProjectsStorage.getProjects();

        var filtered = raw.filter(function(item) {
            if (root.searchText === "") return true;
            return item.name.toLowerCase().indexOf(root.searchText.toLowerCase()) !== -1;
        });

        if (root.sortType === "По названию") {
            filtered.sort((a, b) => a.name.localeCompare(b.name));
        } else if (root.sortType === "По популярности") {
            filtered.sort((a, b) => b.popularity - a.popularity);
        } else if (root.sortType === "По дате") {
            filtered.sort((a, b) => b.modifiedDate.localeCompare(a.modifiedDate));
        }

        root.items = filtered;
    }

    Component.onCompleted: loadData()

    onSearchTextChanged: loadData()
    onSortTypeChanged: loadData()
}
