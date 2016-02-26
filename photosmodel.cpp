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
      m_restWrapper(new RestWrapper(this)),
      m_currentPage(1),
      m_availablePages(0)
{
    connect(m_restWrapper, &RestWrapper::photosRetrieved, this, &PhotosModel::onPhotosRetrieved);
    connect(m_restWrapper, &RestWrapper::requestActive, this, &PhotosModel::activeRequestChanged);
    connect(m_restWrapper, &RestWrapper::requestError, this, &PhotosModel::connectionErrorChanged);

    m_restWrapper->requestPhotos();
}

QHash<int, QByteArray> PhotosModel::roleNames() const
{
    QHash<int, QByteArray> roles = QAbstractItemModel::roleNames();

    roles.insert(NameRole, "name");
    roles.insert(ImageUrlRole, "imageUrl");
    roles.insert(SizeRole, "size");
    roles.insert(UserFullnameRole, "userFullname");
    roles.insert(UserpicUrlRole, "userpicUrl");

    return roles;
}

QVariant PhotosModel::data(const QModelIndex &index, int role) const
{
    // Return empty for invalid index
    if (!index.isValid()) {
        return QVariant();
    }

    const PhotoItem &photo = m_photos.at(index.row());

    switch (role) {
        case PhotosModel::NameRole:
            return photo.name();
        case PhotosModel::ImageUrlRole:
            return photo.imageUrl();
        case PhotosModel::SizeRole:
            return photo.size();

        case PhotosModel::UserFullnameRole:
        case PhotosModel::UserpicUrlRole:
            const UserItem &userItem = m_users.value(photo.userId());

            if (role == PhotosModel::UserFullnameRole) {
                return userItem.fullname();
            } else if (role == PhotosModel::UserpicUrlRole) {
                return userItem.userpicUrl();
            }
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

    // Extract the paging info
    m_currentPage = topLevelObject.value("current_page").toInt();
    m_availablePages = topLevelObject.value("total_pages").toInt();

    // Extract the photos array from the server data
    QJsonArray photosArray = topLevelObject.value("photos").toArray();

    // Add photos to the model and check for duplicates
    QList<PhotoItem> photosToAdd;
    Q_FOREACH (const QJsonValue &photo, photosArray) {
        const QJsonObject photoObject = photo.toObject();
        const int photoId = photoObject.value("id").toInt();

        // Check if this photo is already loaded and don't add it twice
        if (m_photoIds.contains(photoId)) {
            continue;
        }

        m_photoIds << photoId;
        photosToAdd << PhotoItem(photo.toObject());

        const QJsonObject userInfo = photo.toObject().value("user").toObject();

        m_users.insert(userInfo.value("id").toInt(), UserItem(userInfo));
    }

    // Now append the newly retrieved deduplicated photos to the existing collection
    beginInsertRows(QModelIndex(), m_photos.size(), m_photos.size() + photosToAdd.size());
    m_photos << photosToAdd;
    endInsertRows();
}

bool PhotosModel::canFetchMore(const QModelIndex &parent) const
{
    Q_UNUSED(parent);

    // If we have pages left to browse, return true
    if (m_currentPage < m_availablePages) {
        return true;
    }

    return false;
}

void PhotosModel::fetchMore(const QModelIndex &parent)
{
    Q_UNUSED(parent);
    // Request photos from the current+1 page
    m_restWrapper->requestPhotos(++m_currentPage);
}

QSize PhotosModel::sizeForIndex(int index) const
{
    if (index >= m_photos.size()) {
        return QSize();
    }

    return m_photos.at(index).size();
}

bool PhotosModel::hasActiveRequest() const
{
    return m_restWrapper->hasActiveRequest();
}

QString PhotosModel::connectionError() const
{
    return m_restWrapper->lastConnectionError();
}

void PhotosModel::retryFetch() const
{
    m_restWrapper->requestPhotos(m_currentPage);
}
