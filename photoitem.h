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

#ifndef PHOTOITEM_H
#define PHOTOITEM_H

#include <QObject>
#include <QString>
#include <QSize>
#include <QJsonObject>

class PhotoItem
{
    Q_GADGET
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString imageUrl READ imageUrl CONSTANT)
    Q_PROPERTY(int userId READ userId CONSTANT)

public:
    PhotoItem(const QJsonObject &jsonData);

    QString name() const;
    QString imageUrl(const QString &size = QString("30")) const;
    int width() const;
    int height() const;
    int userId() const;

    /// Convenience method to retrieve both width and height at once
    QSize size() const;

private:
    QJsonObject m_jsonData;
};

#endif // PHOTOITEM_H
