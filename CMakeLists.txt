cmake_minimum_required(VERSION 3.16)
set(CMAKE_PREFIX_PATH "D:/Dependecies/QT/6.10.1/mingw_64")

project(palitr VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(apppalitmvp
    main.cpp
    DataStructs.h
    StorageManager.h
    StorageManager.cpp
    PaletteModel.h
    PaletteModel.cpp

)

qt_add_qml_module(apppalitmvp
    URI palitmvp
    VERSION 1.0
    RESOURCE_PREFIX "/"
    QML_FILES
        Main.qml
        components/navigation/SideMenu.qml
        components/views/SearchView.qml
        components/controls/SearchBar.qml
        components/controls/SortComboBox.qml
        components/cards/ItemCard.qml
        components/cards/PaletteCard.qml
        components/cards/ProjectCard.qml
        components/views/PaletteView.qml
        components/views/AbstractLayers.qml
        pages/SearchPalettePage.qml
        pages/ProjectPage.qml
        pages/FavoritePage.qml

    RESOURCES
        storage/palettes.json
        storage/projects.json
        storage/favourites.json
        QML_FILES
        QML_FILES models/ProjectModel.qml
        QML_FILES models/FavouriteModel.qml
        QML_FILES pages/ProjectDetailPage.qml
        QML_FILES pages/ProjectSearchPage.qml
        SOURCES DataStructs.h
        SOURCES StorageManager.h
        SOURCES StorageManager.cpp
        SOURCES PaletteModel.h
        SOURCES PaletteModel.cpp
        QML_FILES components/dialogs/PaletteDialog.qml
        SOURCES ProjectModel.h
        SOURCES ProjectModel.cpp
        QML_FILES components/dialogs/EditProjectDialog.qml
        SOURCES FavoriteModel.h
        SOURCES FavoriteModel.cpp
        SOURCES ModelRoles.h
        SOURCES SortProxyModel.h
        SOURCES SortModelProxy.cpp
        SOURCES SearchPaletteModel.h
        SOURCES SearchPaletteModel.cpp
        QML_FILES components/cards/PaletteWindow.qml
        QML_FILES components/controls/SpecialButton.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(apppalitmvp PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.apppalitmvp
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(apppalitmvp
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS apppalitmvp
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
