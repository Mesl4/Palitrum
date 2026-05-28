#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <qsortfilterproxymodel.h>
#include "StorageManager.h"
#include "PaletteModel.h"
#include "ProjectModel.h"
#include "FavoriteModel.h"
#include "ModelRoles.h"
#include "SortProxyModel.h"
#include "SearchPaletteModel.h"

#include <QDirIterator>
#include <QDebug>
int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // ВСТАВЬ ЭТОТ БЛОК:
    qDebug() << "--- Проверка доступных ресурсов ---";
    QDirIterator it(":", QDirIterator::Subdirectories);
    while (it.hasNext()) {
        qDebug() << "Ресурс найден:" << it.next();
    }
    qDebug() << "-----------------------------------";

    // Загрузка данных
    StorageManager::instance().loadProjects();
    StorageManager::instance().loadFavorites();

    // Регистрация типов
    qmlRegisterType<ProjectModel>("palitmvp", 1, 0, "ProjectModel");
    qmlRegisterType<PaletteModel>("palitmvp", 1, 0, "PaletteModel");
    qmlRegisterType<SortProxyModel>("palitmvp", 1, 0, "SortProxyModel");
    qmlRegisterType<SearchPaletteModel>("palitmvp", 1, 0, "SearchPaletteModel");
    // Исходные модели
    ProjectModel myProjectModel;
    PaletteModel myPaletteModel;
    FavoriteModel myFavoriteModel;


    // Прокси-модели
    auto createProxy = [](QAbstractListModel* source, int filterRole) {
        auto *proxy = new SortProxyModel();
        proxy->setSourceModel(source);
        proxy->setFilterRole(filterRole);
        proxy->setFilterCaseSensitivity(Qt::CaseInsensitive);
        proxy->setSortRole(ModifiedDateRole); // Сортируем по дате по умолчанию
        proxy->sort(0, Qt::DescendingOrder);
        return proxy;
    };

    auto *projectProxy = createProxy(&myProjectModel, NameRole);
    auto *paletteProxy = createProxy(&myPaletteModel, NameRole);
    auto *favoriteProxy = createProxy(&myFavoriteModel, NameRole);

    QQmlApplicationEngine engine;
    // Добавь эту строку ниже:
    engine.rootContext()->setContextProperty("paletteModel", &myPaletteModel);
    // Пробрасываем роли в QML как свойства контекста, чтобы не использовать цифры
    engine.rootContext()->setContextProperty("NameRole", NameRole);
    engine.rootContext()->setContextProperty("ModifiedDateRole", ModifiedDateRole);

    engine.rootContext()->setContextProperty("projectFilterModel", projectProxy);
    engine.rootContext()->setContextProperty("paletteFilterModel", paletteProxy);
    engine.rootContext()->setContextProperty("favoriteFilterModel", favoriteProxy);
    engine.rootContext()->setContextProperty("IdRole", IdRole); // Добавь это!
    SearchPaletteModel mySearchModel;
    auto *searchProxy = createProxy(&mySearchModel, NameRole);

    // Регистрация свойства контекста для использования на SearchPalettePage
    engine.rootContext()->setContextProperty("searchFilterModel", searchProxy);
    // Или для прямой работы с методами без сортировки:
    engine.rootContext()->setContextProperty("searchPaletteModel", &mySearchModel);
    const QUrl url(u"qrc:/palitmvp/Main.qml"_qs);
    engine.load(url);

    return app.exec();

}
