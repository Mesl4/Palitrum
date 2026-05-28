import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    StackLayout {
        id: stack
        anchors.fill: parent
        currentIndex: 0 // 0 - Поиск, 1 - Детали

        // Экран 0: Список всех проектов
        ProjectSearchPage {
            onRequestOpenProject: (name, id) => {
                detailPage.projectId = id; // Передаем ID в DetailPage
                stack.currentIndex = 1;    // Переключаем экран
            }
        }

        // Экран 1: Детали конкретного проекта (фильтрованная PaletteModel)
        ProjectDetailPage {
            id: detailPage
            onGoBack: stack.currentIndex = 0 // Возврат к поиску
        }
    }
}
