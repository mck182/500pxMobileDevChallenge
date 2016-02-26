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

#ifndef PHOTOSMODEL_H
#define PHOTOSMODEL_H

#include <QAbstractListModel>
#include <QJsonDocument>

#include "photoitem.h"
#include "useritem.h"

class RestWrapper;

class PhotosModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(bool hasActiveRequest READ hasActiveRequest NOTIFY activeRequestChanged)
    Q_PROPERTY(QString connectionError READ connectionError NOTIFY connectionErrorChanged)

public:
    enum ModelRoles {
        NameRole = Qt::UserRole,
        ImageUrlRole,
        SizeRole,
        UserFullnameRole,
        UserpicUrlRole
    };
    Q_ENUM(ModelRoles)

    explicit PhotosModel(QObject *parent = 0);

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const Q_DECL_OVERRIDE;
    int rowCount(const QModelIndex &parent) const Q_DECL_OVERRIDE;
    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;
    Q_INVOKABLE bool canFetchMore(const QModelIndex &parent = QModelIndex()) const Q_DECL_OVERRIDE;
    Q_INVOKABLE void fetchMore(const QModelIndex &parent = QModelIndex()) Q_DECL_OVERRIDE;

    /**
     * @brief This method returns the size of the photo at @param index
     *
     * @param index Index of the photo
     */
    Q_INVOKABLE QSize sizeForIndex(int index) const;

    /**
     * @brief Indicates if there are any currently ongoing network requests
     *
     * @return true if any active requests is currently ongoing, false otherwise
     */
    bool hasActiveRequest() const;

    /**
     * @brief Returns the connection error if there is any
     *
     * @return The error for displaying
     */
    QString connectionError() const;

    /**
     * @brief Method to allow manual retrying when network error occurs
     */
    Q_INVOKABLE void retryFetch() const;

Q_SIGNALS:
    void activeRequestChanged(bool isActive);

    void connectionErrorChanged();

private Q_SLOTS:
    void onPhotosRetrieved(const QJsonDocument &jsonData);

private:
    RestWrapper *m_restWrapper;
    QList<PhotoItem> m_photos;
    QList<int> m_photoIds;
    QHash<int, UserItem> m_users;
    uint m_availablePages;
    uint m_currentPage;
};

#endif // PHOTOSMODEL_H
