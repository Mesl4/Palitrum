#include "StorageManager.h"
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QJsonDocument>

StorageManager& StorageManager::instance() {
    static StorageManager _instance;
    return _instance;
}

StorageManager::StorageManager(QObject *parent) : QObject(parent) {
    ensureDataDirectoryExists();
}

void StorageManager::ensureDataDirectoryExists() const {
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(path);
    if (!dir.exists()) {
        dir.mkpath(".");
    }
}

QString StorageManager::getStoragePath(const QString& fileName) const {
    QString dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    return QDir(dir).filePath(fileName);
}

void StorageManager::saveProjects(bool emitSignal) {
    QJsonArray projectsArray;
    for (const auto& project : projects) {
        projectsArray.append(project.toJson()); // Используем метод из DataStructs.h
    }

    QJsonDocument doc(projectsArray);
    QFile file(getStoragePath("data.json"));
    if (file.open(QIODevice::WriteOnly)) {
        file.write(doc.toJson());
        file.close();
    }
    if (emitSignal) {
        emit dataChanged();
    }
}

void StorageManager::loadProjects() {
    QFile file(getStoragePath("data.json"));
    if (!file.exists() || !file.open(QIODevice::ReadOnly)) return;

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    QJsonArray projectsArray = doc.array();

    projects.clear();
    for (const QJsonValue& val : projectsArray) {
        projects.append(ProjectData::fromJson(val.toObject()));
    }
}


void StorageManager::loadFavorites() {
    QFile file(getStoragePath("favorites.json"));
    if (!file.open(QIODevice::ReadOnly)) return;

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    QJsonArray arr = doc.array();

    favorites.clear();
    for (const auto& val : arr) {
        favorites.append(FavoriteData::fromJson(val.toObject()));
    }
}

void StorageManager::saveFavorites() {
    ensureDataDirectoryExists(); // Проверяем, есть ли папка

    QJsonArray arr;
    for (const auto& fav : favorites) {
        arr.append(fav.toJson());
    }

    QFile file(getStoragePath("favorites.json"));
    if (file.open(QIODevice::WriteOnly)) {
        file.write(QJsonDocument(arr).toJson());
        file.close();
    }
    emit dataChanged();
}


// В StorageManager.cpp
void StorageManager::updateFavoritePalette(const PaletteData& updatedPalette, bool del) {
    bool changed = false;

    if (del) {
        // Логика удаления
        for (int i = 0; i < favorites.size(); ++i) {
            if (favorites[i].id == updatedPalette.id) {
                favorites.removeAt(i);
                changed = true;
                break; // Выходим после удаления
            }
        }
    } else {
        // Логика обновления
        for (auto& fav : favorites) {
            if (fav.id == updatedPalette.id) {
                fav.palette = updatedPalette;
                changed = true;
            }
        }
    }

    if (changed) {
        saveFavorites(); // Сохраняем изменения на диск
        emit dataChanged(); // Все модели (через connect) обновятся автоматически
    }
}

void StorageManager::removeFavoritesByProjectId(const QString &projectId) {
    bool changed = false;
    // Идем с конца списка, чтобы безопаснее удалять элементы при итерации
    for (int i = favorites.size() - 1; i >= 0; --i) {
        if (favorites[i].projectId == projectId) {
            favorites.removeAt(i);
            changed = true;
        }
    }

    if (changed) {
        saveFavorites(); // Сохраняем чистый список
    }
}
