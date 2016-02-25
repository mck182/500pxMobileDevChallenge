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

#include "restwrapper.h"

#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrlQuery>

RestWrapper::RestWrapper(QObject *parent)
    : QObject(parent),
      m_consumerKey("ujftkFBVkHDFUugAogXhfwb74aIUmDzSIKp0egtQ"),
      m_baseUrl("https://api.500px.com/v1"),
      m_networkManager(new QNetworkAccessManager(this))
{

}

void RestWrapper::requestPhotos(const QString &feature, int page, int imageSize)
{
    QUrl requestUrl(m_baseUrl + "/photos");
    QUrlQuery requestDetails;

    // Set the request details
    requestDetails.addQueryItem("consumer_key", m_consumerKey);
    requestDetails.addQueryItem("feature", feature);
    requestDetails.addQueryItem("image_size", QString::number(imageSize));

    // No need to set the page param if it's 0
    if (page > 0) {
        requestDetails.addQueryItem("page", QString::number(page));
    }

    requestUrl.setQuery(requestDetails);

    QNetworkRequest photoRequest;
    photoRequest.setUrl(requestUrl);

    // Send the request
    QNetworkReply *reply = m_networkManager->get(photoRequest);
    connect(reply, &QNetworkReply::finished, this, [=] {
        if (reply->error() == QNetworkReply::NoError) {
            // Parse the reply into JSON document and notify the model
            QJsonDocument jsonReply = QJsonDocument::fromJson(reply->readAll());
            Q_EMIT photosRetrieved(jsonReply);
        } else {
            // Print the error to console and emit the error type
            qWarning() << reply->errorString();
            Q_EMIT requestError(reply->error());
        }
    });
}
