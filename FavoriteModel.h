#pragma once
#include <QAbstractListModel>
#include "DataStructs.h" // Твой файл со структурами
#include "StorageManager.h"


class FavoriteModel : public QAbstractListModel {
    Q_OBJECT
public:
    explicit FavoriteModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void addFavorite(const QString &id, const QString &projectId, const QString &name, const QVariantList &colors);
    Q_INVOKABLE void removeFavoriteById(const QString &id);
    Q_INVOKABLE void refresh();

private:
    // Ссылка на общий список в StorageManager
    // Мы не храним QList внутри модели, мы берем его из менеджера
    QList<FavoriteData>& m_favorites;
};
