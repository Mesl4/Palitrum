#include "FavoriteModel.h"
#include "ModelRoles.h"
FavoriteModel::FavoriteModel(QObject *parent)
    : QAbstractListModel(parent), m_favorites(StorageManager::instance().favorites)
{
    // Подписываемся на обновление данных из StorageManager
    connect(&StorageManager::instance(), &StorageManager::dataChanged, this, [this](){
        beginResetModel();
        endResetModel();
    });
}
int FavoriteModel::rowCount(const QModelIndex &parent) const {
    return m_favorites.size();
}

QVariant FavoriteModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid()) return QVariant();
    const auto &fav = m_favorites[index.row()];
    switch (role) {
    case IdRole: return fav.id;
    case NameRole: return fav.palette.name; // Берем из объекта palette
    case ColorsRole: return QVariant::fromValue(fav.palette.colors); // Преобразуем QStringList в QVariant
    case ProjectIdRole: return fav.projectId;
    case ModifiedDateRole: return fav.palette.modifiedDate;
    default: return QVariant();
    }
}

QHash<int, QByteArray> FavoriteModel::roleNames() const {
    return {
        {IdRole, "id"},
        {NameRole, "name"},
        {ColorsRole, "colorsArray"},
        {ProjectIdRole, "projectId"},
        {ModifiedDateRole, "modifiedDate"} // ОБЯЗАТЕЛЬНО ДОБАВИТЬ ЭТО
    };
}
void FavoriteModel::addFavorite(const QString &id, const QString &projectId, const QString &name, const QVariantList &colors) {
    // 1. Проверка на дубликаты
    for(const auto &f : m_favorites) if(f.id == id) return;

    // 2. Преобразуем QVariantList в QStringList
    QStringList stringColors;
    for(const auto &c : colors) stringColors.append(c.toString());

    // 3. Создаем объект PaletteData
    PaletteData p;
    p.id = id;
    p.name = name;
    p.colors = stringColors;
    p.updateTimestamp();
    // (можно добавить текущую дату в createdDate/modifiedDate, если нужно)

    // 4. Добавляем в модель
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    m_favorites.append({id, projectId, p});
    endInsertRows();

    // 5. Сохраняем через StorageManager
    StorageManager::instance().saveFavorites();
}

void FavoriteModel::removeFavoriteById(const QString &id) {
    for (int i = 0; i < m_favorites.size(); ++i) {
        if (m_favorites[i].id == id) {
            beginRemoveRows(QModelIndex(), i, i);
            m_favorites.removeAt(i);
            endRemoveRows();

            // Сохраняем изменения в глобальное хранилище
            StorageManager::instance().saveFavorites();
            return;
        }
    }
}

// В FavoriteModel
void FavoriteModel::refresh() {
    beginResetModel(); // Сбрасываем модель, чтобы она заново прочитала данные
    // m_favorites теперь актуален, так как это ссылка на StorageManager
    endResetModel();
}
