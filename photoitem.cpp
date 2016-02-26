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

#include "photoitem.h"

PhotoItem::PhotoItem(const QJsonObject &jsonData)
{
    m_jsonData = jsonData;
}

QString PhotoItem::name() const
{
    return m_jsonData.value("name").toString();
}

QString PhotoItem::imageUrl() const
{
    return m_jsonData.value("image_url").toString();
}

int PhotoItem::width() const
{
    return m_jsonData.value("width").toInt();
}

int PhotoItem::height() const
{
    return m_jsonData.value("height").toInt();
}

QSize PhotoItem::size() const
{
    return QSize(width(), height());
}
