#include "SearchPaletteModel.h"
#include "ModelRoles.h"
#include <QFile>
#include <QDebug>

SearchPaletteModel::SearchPaletteModel(QObject *parent) : QAbstractListModel(parent) {
    manager = new QNetworkAccessManager(this);
}

int SearchPaletteModel::rowCount(const QModelIndex &parent) const {
    if (parent.isValid()) return 0;
    return m_palettes.size();
}

QVariant SearchPaletteModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_palettes.size()) return QVariant();
    const auto &p = m_palettes[index.row()];

    switch (role) {
    case SharedRoles::IdRole:           return p.id;
    case SharedRoles::NameRole:         return p.name;
    case SharedRoles::ColorsRole:       return QVariant::fromValue(p.colors);
    case SharedRoles::EditableRole:     return p.editable;
    case SharedRoles::ModifiedDateRole: return p.modifiedDate;
    default: return QVariant();
    }
}

QHash<int, QByteArray> SearchPaletteModel::roleNames() const {
    return {
        {SharedRoles::IdRole, "id"},
        {SharedRoles::NameRole, "name"},
        {SharedRoles::ColorsRole, "colorsArray"},
        {SharedRoles::EditableRole, "editable"},
        {SharedRoles::ModifiedDateRole, "modifiedDate"}
    };
}

void SearchPaletteModel::setIsLoading(bool loading) {
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged();
    }
}

void SearchPaletteModel::fetchPalettes(const QString &url, bool isNextPage) {
    if (m_isLoading) return;

    setIsLoading(true);
    QNetworkReply *reply = manager->get(QNetworkRequest(QUrl(url)));

    QTimer *timeoutTimer = new QTimer(reply);
    timeoutTimer->setSingleShot(true);

    connect(timeoutTimer, &QTimer::timeout, reply, [reply]() {
        if (reply->isRunning()) {
            qWarning() << "SearchPaletteModel: Превышено время ожидания. Прерывание запроса...";
            reply->abort();
        }
    });

    connect(reply, &QNetworkReply::finished, this, [this, reply, timeoutTimer, isNextPage]() {
        timeoutTimer->stop();

        if (reply->error() == QNetworkReply::NoError) {
            parseLospecJson(reply->readAll(), isNextPage);

            // Если догружали следующую страницу и сеть ответила успехом — увеличиваем счетчик
            if (isNextPage) {
                m_currentPage++;
            } else {
                m_currentPage = 1;
            }

            setIsLoading(false);
            emit pageLoaded();
        } else {
            qWarning() << "SearchPaletteModel: Сетевая ошибка, загрузка fallback-файла:" << reply->errorString();

            // В случае ошибки подгружаем локальный файл.
            // Счетчик m_currentPage НЕ увеличивается, оставаясь прежним!
            loadLocalJson(":/palitmvp/storage/palettes.json");
            setIsLoading(false);
        }
        reply->deleteLater();
    });

    timeoutTimer->start(5000);
}

void SearchPaletteModel::parseLospecJson(const QByteArray &data, bool isNextPage) {
    QJsonDocument doc = QJsonDocument::fromJson(data);
    QJsonArray palettesArray;
    if (doc.isArray()) {
        palettesArray = doc.array();
    } else if (doc.isObject()) {
        palettesArray = doc.object()["palettes"].toArray();
    }

    if (!isNextPage) {
        beginResetModel();
        m_palettes.clear();
        if (palettesArray.isEmpty()) {
            endResetModel();
            return;
        }
    } else {
        if (palettesArray.isEmpty()) return;

        int startIdx = m_palettes.size();
        int endIdx = startIdx + palettesArray.size() - 1;
        beginInsertRows(QModelIndex(), startIdx, endIdx);
    }

    for (const auto &v : palettesArray) {
        auto obj = v.toObject();
        PaletteData p;
        p.id = obj["_id"].toString();
        p.name = obj["title"].toString();
        p.editable = false;
        p.modifiedDate = obj["publishedAt"].toString();

        QJsonArray colorsJArray = obj["colors"].toArray();
        for (auto c : colorsJArray) {
            p.colors << "#" + c.toString();
        }
        m_palettes.append(p);
    }

    if (!isNextPage) {
        endResetModel();
    } else {
        endInsertRows();
    }
}

void SearchPaletteModel::loadLocalJson(const QString &filePath) {
    QFile file(filePath);
    if (file.open(QIODevice::ReadOnly)) {
        parseLospecJson(file.readAll(), false);
        file.close();
    } else {
        qWarning() << "SearchPaletteModel: Не удалось открыть fallback файл ресурсов!";
        createDefaultPalettes();
    }
}

void SearchPaletteModel::createDefaultPalettes() {
    beginResetModel();
    m_palettes.clear();

    PaletteData p;
    p.id = QUuid::createUuid().toString();
    p.name = "Запасная палитра (Ошибка соединения)";
    p.colors = QStringList{"#ff0000", "#00ff00", "#0000ff"};
    p.editable = false;
    p.modifiedDate = QDateTime::currentDateTime().toString(Qt::ISODate);

    m_palettes.append(p);
    endResetModel();
}
