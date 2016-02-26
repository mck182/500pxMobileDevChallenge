#include "photoitem.h"

PhotoItem::PhotoItem(const QJsonObject &jsonData)
{
    m_jsonData = jsonData;
}

QString PhotoItem::title() const
{
    return m_jsonData.value("name").toString();
}

QString PhotoItem::photoUrl() const
{
    return m_jsonData.value("image_url").toString();
}
