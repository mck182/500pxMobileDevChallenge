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

#ifndef RESTWRAPPER_H
#define RESTWRAPPER_H

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonDocument>

class RestWrapper : public QObject
{
    Q_OBJECT

public:
    explicit RestWrapper(QObject *parent = 0);

    /**
     * @brief Method that retrieves the photos from specified page
     *
     * @param page Which page to retrieve photos from, default is first page
     * @param imageSize Which image sizes to retrieve, default is 3 (280px x 280px)
     * @param feature Which category ('feature') to retrieve, default is "fresh_today"
     */
    void requestPhotos(uint page = 1, uint imageSize = 3, const QString &feature = QString("fresh_today"));

signals:
    /**
     * @brief Emitted when a non-error server response is retrieved
     *
     * @param jsonData The data the server sent
     */
    void photosRetrieved(const QJsonDocument &jsonData);

    /**
     * @brief Emitted when there is an error while processing the request
     */
    void requestError(QNetworkReply::NetworkError error);

public slots:
private:
    QString m_consumerKey;
    QString m_baseUrl;
    QNetworkAccessManager *m_networkManager;
};

#endif // RESTWRAPPER_H
