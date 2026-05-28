#include "ProjectModel.h"
#include "ModelRoles.h"
#include "StorageManager.h"
#include <QUuid>
#include <QDateTime>

ProjectModel::ProjectModel(QObject *parent) : QAbstractListModel(parent) {
    // 1. Инициализация ролей
    m_roleNames[NameRole] = "name";
    m_roleNames[IdRole] = "id";
    m_roleNames[ModifiedDateRole] = "modifiedDate";
    m_roleNames[PaletteCountRole] = "paletteCount";
    m_roleNames[DescRole] = "desc";

    // 2. Глобальная подписка на изменения.
    // Срабатывает каждый раз, когда кто-то вызывает StorageManager::instance().saveProjects()
    connect(&StorageManager::instance(), &StorageManager::dataChanged, this, [this](){
        beginResetModel();
        endResetModel();
    });
}

int ProjectModel::rowCount(const QModelIndex &parent) const {
    if (parent.isValid()) return 0;
    return StorageManager::instance().projects.size();
}

QVariant ProjectModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid()) return QVariant();

    const auto &project = StorageManager::instance().projects[index.row()];
    switch (role) {
    case NameRole: return project.name;
    case DescRole: return project.description;
    case PaletteCountRole: return project.palettes.size();
    case IdRole: return project.id;
    case ModifiedDateRole: return project.modifiedDate;
    default: return QVariant();
    }
}

QHash<int, QByteArray> ProjectModel::roleNames() const {
    return m_roleNames;
}

void ProjectModel::addProject(const QString &name, const QString &desc) {
    ProjectData newProject;
    newProject.id = QUuid::createUuid().toString();
    newProject.name = name;
    newProject.description = desc;
    newProject.modifiedDate = QDateTime::currentDateTime().toString(Qt::ISODate);

    // Добавляем в хранилище
    StorageManager::instance().projects.append(newProject);

    // Сохраняем. Это автоматически триггерит сигнал dataChanged в StorageManager,
    // который вызовет сброс модели через connect в конструкторе.
    StorageManager::instance().saveProjects();
}

void ProjectModel::removeProject(int index) {
    if (index < 0 || index >= rowCount()) return;

    // Удаляем из хранилища
    StorageManager::instance().projects.removeAt(index);

    // Сохраняем и доверяем обновление глобальному сигналу
    StorageManager::instance().saveProjects();
}

void ProjectModel::updateProject(int index, const QString &name, const QString &desc) {
    if (index < 0 || index >= rowCount()) return;

    auto &p = StorageManager::instance().projects[index];
    p.name = name;
    p.description = desc;

    // Обязательно обновляем дату для корректной сортировки
    p.modifiedDate = QDateTime::currentDateTime().toString(Qt::ISODate);

    // Сохраняем и обновляем UI одним махом
    StorageManager::instance().saveProjects();
}

QVariantMap ProjectModel::get(int i) const {
    if (i < 0 || i >= rowCount()) return QVariantMap();
    const auto &project = StorageManager::instance().projects[i];

    QVariantMap map;
    map["id"] = project.id;
    map["name"] = project.name;
    map["desc"] = project.description; // Добавил описание, чтобы всё было под рукой

    return map;
}

void ProjectModel::removeProjectById(const QString &id) {
    StorageManager::instance().removeFavoritesByProjectId(id);
    for (int i = 0; i < StorageManager::instance().projects.size(); ++i) {
        if (StorageManager::instance().projects[i].id == id) {
            removeProject(i);
            return;
        }
    }
}

void ProjectModel::updateProjectById(const QString &id, const QString &name, const QString &desc) {
    for (int i = 0; i < StorageManager::instance().projects.size(); ++i) {
        if (StorageManager::instance().projects[i].id == id) {
            updateProject(i, name, desc);
            return;
        }
    }
}
