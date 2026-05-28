#pragma once
#include <QObject>
#include <QList>
#include "DataStructs.h"

class StorageManager : public QObject {
    Q_OBJECT
public:
    static StorageManager& instance();

    // Теперь работаем с проектами


    // В памяти теперь дерево: список проектов, внутри каждого - список палитр
    QList<ProjectData> projects;
    void loadProjects();
    void saveProjects(bool emitSignal = true);

    QList<FavoriteData> favorites; // Новый список
    void loadFavorites();
    void saveFavorites();
    void updateFavoritePalette(const PaletteData& updatedPalette, bool del = false);
    void removeFavoritesByProjectId(const QString &projectId);
signals:
    void dataChanged();


private:
    explicit StorageManager(QObject *parent = nullptr);
    QString getStoragePath(const QString& fileName) const;
    void ensureDataDirectoryExists() const;
};
