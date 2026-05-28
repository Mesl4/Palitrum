import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    // Свойства из спецификации
    property var colors: []
    property int maxPerRow: 5

    spacing: 2 // Зазор между строками

    Repeater {
        // Считаем количество строк
        model: Math.ceil(root.colors.length / root.maxPerRow)

        delegate: RowLayout {
            id: rowLayout
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 2 // Зазор между цветами в строке

            readonly property int rowIndex: index

            Repeater {
                // Считаем, сколько цветов должно быть в этой строке
                model: {
                    let remaining = root.colors.length - (rowLayout.rowIndex * root.maxPerRow)
                    return Math.min(root.maxPerRow, remaining)
                }

                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 4 // Легкое скругление для красоты

                    // Достаем нужный цвет из массива по индексу
                    color: root.colors[(rowLayout.rowIndex * root.maxPerRow) + index]
                }
            }
        }
    }
}
