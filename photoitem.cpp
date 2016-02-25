#include "photoitem.h"

PhotoItem::PhotoItem(const QString &title, const QString &photoUrl)
    : m_title(title),
      m_photoUrl(photoUrl)
{

}

QString PhotoItem::title() const
{
    return m_title;
}

QString PhotoItem::photoUrl() const
{
    return m_photoUrl;
}
