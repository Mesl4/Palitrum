#pragma once
#include <QAbstractListModel>
#include "StorageManager.h"
#include <QUuid>
#include <QVariant>

class PaletteModel : public QAbstractListModel {
    Q_OBJECT
public:
    explicit PaletteModel(QObject *parent = nullptr);

    // Основной метод для переключения проекта по ID
    Q_INVOKABLE void setProjectId(const QString &projectId);

    // Стандартные методы модели
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // Методы для управления палитрами через ID
    Q_INVOKABLE void addPalette(const QString &name, const QVariantList &colors);
    Q_INVOKABLE void removePaletteById(const QString &id);
    Q_INVOKABLE void updatePaletteById(const QString &id, const QString &name, const QVariantList &colors);

private:
    int m_projectIndex = -1; // Индекс текущего проекта в StorageManager
};
