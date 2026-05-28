#pragma once
#include <QAbstractListModel>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTimer>
#include <QUuid>
#include <QDateTime>
#include "DataStructs.h"

class SearchPaletteModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)

public:
    explicit SearchPaletteModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void fetchPalettes(const QString &url, bool isNextPage = false);

    // Этот метод QML будет использовать, чтобы узнать, какую страницу запрашивать следующей
    Q_INVOKABLE int nextPage() const { return m_currentPage + 1; }

    // Метод для сброса страницы (например, при смене сортировки)
    Q_INVOKABLE void resetPage() { m_currentPage = 1; }

    bool isLoading() const { return m_isLoading; }

signals:
    void isLoadingChanged();
    void pageLoaded();

private:
    void parseLospecJson(const QByteArray &data, bool isNextPage = false);
    void loadLocalJson(const QString &filePath);
    void createDefaultPalettes();
    void setIsLoading(bool loading);

    QList<PaletteData> m_palettes;
    QNetworkAccessManager *manager;
    bool m_isLoading = false;
    int m_currentPage = 1; // Храним текущую УСПЕШНО загруженную страницу на стороне C++
};
