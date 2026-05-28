#include "PaletteModel.h"
#include "ModelRoles.h"
#include "StorageManager.h"
#include <QUuid>
#include <QDateTime>

PaletteModel::PaletteModel(QObject *parent) : QAbstractListModel(parent), m_projectIndex(-1) {}

void PaletteModel::setProjectId(const QString &projectId) {
    beginResetModel();
    m_projectIndex = -1;
    auto& projects = StorageManager::instance().projects;
    for(int i = 0; i < projects.size(); ++i) {
        if(projects[i].id == projectId) {
            m_projectIndex = i;
            break;
        }
    }
    endResetModel();
}

int PaletteModel::rowCount(const QModelIndex &parent) const {
    if (parent.isValid() || m_projectIndex < 0) return 0;
    return StorageManager::instance().projects[m_projectIndex].palettes.size();
}

QVariant PaletteModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid()) return QVariant();
    const auto &p = StorageManager::instance().projects[m_projectIndex].palettes[index.row()];

    switch (role) {
    case SharedRoles::NameRole:         return p.name;
    case ColorsRole:                   return QVariant::fromValue(p.colors);
    case EditableRole:                 return p.editable;
    case IdRole:                       return p.id;
    case ModifiedDateRole:             return p.modifiedDate;
    default: return QVariant();
    }
}

QHash<int, QByteArray> PaletteModel::roleNames() const {
    return {
        {IdRole, "id"},
        {SharedRoles::NameRole, "name"},
        {ColorsRole, "colorsArray"},
        {EditableRole, "editable"},
        {ModifiedDateRole, "modifiedDate"}
    };
}

void PaletteModel::addPalette(const QString &name, const QVariantList &colors) {
    if (m_projectIndex < 0) return;
    beginInsertRows(QModelIndex(), rowCount(), rowCount());

    PaletteData p;
    p.id = QUuid::createUuid().toString();
    p.name = name;
    p.modifiedDate = QDateTime::currentDateTime().toString(Qt::ISODate);
    for(const auto& c : colors) p.colors.append(c.toString());

    StorageManager::instance().projects[m_projectIndex].palettes.append(p);
    StorageManager::instance().saveProjects();
    endInsertRows();
}

void PaletteModel::removePaletteById(const QString &id) {
    if (m_projectIndex < 0) return;
    auto &palettes = StorageManager::instance().projects[m_projectIndex].palettes;

    for (int i = 0; i < palettes.size(); ++i) {
        if (palettes[i].id == id) {
            // 1. Сначала сохраняем копию для удаления из избранного
            PaletteData dataToDelete = palettes[i];

            beginRemoveRows(QModelIndex(), i, i);

            // 2. Удаляем из списка проектов
            palettes.removeAt(i);

            // 3. Сохраняем проекты
            StorageManager::instance().saveProjects();

            // 4. Удаляем из избранного (используем копию dataToDelete)
            StorageManager::instance().updateFavoritePalette(dataToDelete, true);

            endRemoveRows();
            return;
        }
    }
}

void PaletteModel::updatePaletteById(const QString &id, const QString &name, const QVariantList &colors) {
    // Используем твой текущий m_projectIndex
    if (m_projectIndex < 0) return;

    auto &palettes = StorageManager::instance().projects[m_projectIndex].palettes;

    for (int i = 0; i < palettes.size(); ++i) {
        if (palettes[i].id == id) {
            palettes[i].name = name;
            palettes[i].modifiedDate = QDateTime::currentDateTime().toString(Qt::ISODate);

            palettes[i].colors.clear();
            for(const auto& c : colors) palettes[i].colors.append(c.toString());

            StorageManager::instance().saveProjects();

            // ВАЖНО: Тот самый вызов для синхронизации с избранным
            StorageManager::instance().updateFavoritePalette(palettes[i]);

            emit dataChanged(index(i), index(i));
            return;
        }
    }
}
