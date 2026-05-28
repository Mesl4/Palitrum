#pragma once
#include <QString>
#include <QStringList>
#include <QJsonObject>
#include <QJsonArray>
#include <QDateTime>

struct PaletteData {
    QString id;
    QString name;
    QString createdDate;
    QString modifiedDate;
    int popularity = 0;
    bool editable = true;
    QStringList colors;

    static PaletteData fromJson(const QJsonObject& json) {
        PaletteData data;
        data.id = json["id"].toString();
        data.name = json["name"].toString();
        data.createdDate = json["createdDate"].toString();
        data.modifiedDate = json["modifiedDate"].toString();
        data.popularity = json["popularity"].toInt();
        data.editable = json["editable"].toBool(true);
        QJsonArray colorsArray = json["colors"].toArray();
        for (const auto& val : colorsArray) data.colors.append(val.toString());
        return data;
    }

    QJsonObject toJson() const {
        QJsonObject json;
        json["id"] = id;
        json["name"] = name;
        json["createdDate"] = createdDate;
        json["modifiedDate"] = modifiedDate;
        json["popularity"] = popularity;
        json["editable"] = editable;
        QJsonArray arr;
        for (const auto& c : colors) arr.append(c);
        json["colors"] = arr;
        return json;
    }
    void updateTimestamp() { modifiedDate = QDateTime::currentDateTime().toString(Qt::ISODate); }
};

struct ProjectData {
    QString id;
    QString name;
    QString description;
    QString modifiedDate; // Добавили поле

    QJsonObject toJson() const {
        QJsonObject json;
        json["id"] = id;
        json["name"] = name;
        json["description"] = description;
        json["modifiedDate"] = modifiedDate; // Сохраняем
        QJsonArray arr;
        for (const auto& p : palettes) arr.append(p.toJson());
        json["palettes"] = arr;
        return json;
    }

    static ProjectData fromJson(const QJsonObject& json) {
        ProjectData data;
        data.id = json["id"].toString();
        data.name = json["name"].toString();
        data.description = json["description"].toString();
        data.modifiedDate = json["modifiedDate"].toString(); // Читаем
        QJsonArray arr = json["palettes"].toArray();
        for (const auto& val : arr) data.palettes.append(PaletteData::fromJson(val.toObject()));
        return data;
    }
    void updateTimestamp() { modifiedDate = QDateTime::currentDateTime().toString(Qt::ISODate); }
    QList<PaletteData> palettes;
};

struct FavoriteData {
    QString id;
    QString projectId;
    PaletteData palette;
    QString modifiedDate; // Добавили поле

    QJsonObject toJson() const {
        QJsonObject json;
        json["id"] = id;
        json["projectId"] = projectId;
        json["modifiedDate"] = modifiedDate; // Сохраняем
        json["palette"] = palette.toJson();
        return json;
    }

    static FavoriteData fromJson(const QJsonObject& json) {
        FavoriteData data;
        data.id = json["id"].toString();
        data.projectId = json["projectId"].toString();
        data.modifiedDate = json["modifiedDate"].toString(); // Читаем
        data.palette = PaletteData::fromJson(json["palette"].toObject());
        return data;
    }
    void updateTimestamp() { modifiedDate = QDateTime::currentDateTime().toString(Qt::ISODate); }
};
