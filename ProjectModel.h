#pragma once
#include <QAbstractListModel>
#include "StorageManager.h"
#include <QUuid>

class ProjectModel : public QAbstractListModel {
    Q_OBJECT
public:

    explicit ProjectModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // Методы для QML
    Q_INVOKABLE void addProject(const QString &name, const QString &desc);
    Q_INVOKABLE void removeProject(int index);
    Q_INVOKABLE void updateProject(int index, const QString &name, const QString &desc);
    Q_INVOKABLE QVariantMap get(int i) const;

    Q_INVOKABLE void removeProjectById(const QString &id);
    Q_INVOKABLE void updateProjectById(const QString &id, const QString &name, const QString &desc);
private:
    QHash<int, QByteArray> m_roleNames;
};
