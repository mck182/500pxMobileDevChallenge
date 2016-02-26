/*
 * Copyright 2016 (c) Martin Klapetek <mklapetek@kde.org>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include "photosmodel.h"
#include "restwrapper.h"

#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>

PhotosModel::PhotosModel(QObject *parent)
    : QAbstractListModel(parent),
      m_restWrapper(new RestWrapper(this))
{
    connect(m_restWrapper, &RestWrapper::photosRetrieved, this, &PhotosModel::onPhotosRetrieved);
    m_restWrapper->requestPhotos();
}

QVariant PhotosModel::data(const QModelIndex &index, int role) const
{
    // Return empty for invalid index
    if (!index.isValid()) {
        return QVariant();
    }

    const PhotoItem &photo = m_photos.at(index.row());

    switch (role) {
        case Qt::DisplayRole:
            return photo.title();
        case Qt::DecorationRole:
            return photo.photoUrl();
    }

    return QVariant();
}

int PhotosModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_photos.size();
}

void PhotosModel::onPhotosRetrieved(const QJsonDocument &jsonData)
{
    QJsonObject topLevelObject = jsonData.object();
    QJsonArray photosArray = topLevelObject.value("photos").toArray();

    beginInsertRows(QModelIndex(), m_photos.size(), m_photos.size() + photosArray.size());
    Q_FOREACH (const QJsonValue &photo, photosArray) {
        m_photos << PhotoItem(photo.toObject());
    }
    endInsertRows();
}
