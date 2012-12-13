/*
    Copyright (C) 2012 Dickson Leong
    This file is part of Tweetian.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

#include "thumbnailcacher.h"

#include <QtCore/QCryptographicHash>
#include <QtCore/QFile>
#include <QtCore/QDir>
#include <QtDeclarative/QDeclarativeItem>
#include <QtGui/QImage>
#include <QtGui/QPainter>
#include <QtGui/QStyleOptionGraphicsItem>
#include <QtGui/QDesktopServices>

ThumbnailCacher::ThumbnailCacher(QObject *parent) :
    QObject(parent)
{
#if defined (Q_OS_SYMBIAN) // On Symbian, cachePath should be !:/Private/{UID}/.thumbnails
    QDir cacheDir(QDesktopServices::storageLocation(QDesktopServices::DataLocation));
    if (!cacheDir.exists(".thumbnails")) cacheDir.mkdir(".thumbnails");
    cacheDir.cd(".thumbnails");

    cachePath = cacheDir.absolutePath();
#elif defined (Q_OS_LINUX) // On Linux, cachePath should be /home/user/.thumbnails/tweetian
    QDir cacheDir = QDir::homePath();
    if (!cacheDir.exists(".thumbnails/tweetian")) cacheDir.mkpath(".thumbnails/tweetian");
    cacheDir.cd(".thumbnails/tweetian");

    cachePath = cacheDir.absolutePath();
#elif defined (Q_WS_SIMULATOR)
    QDir cacheDir = QDir::currentPath();
    if (!cacheDir.exists(".thumbnails")) cacheDir.mkdir(".thumbnails");
    cacheDir.cd(".thumbnails");

    cachePath = cacheDir.absolutePath();
#else
#error "Unrecognized target. Please set your own cachePath for thumbnails."
#endif

    QStringList thumbFiles = QDir(cachePath).entryList();
    if (thumbFiles.length() > 1000)
        clearAll();
}

QString ThumbnailCacher::get(const QString &id)
{
    QString thumbFile = getThumbFilePath(id);

    if (QFile::exists(thumbFile)) {
        QUrl thumbUrl = QUrl::fromLocalFile(thumbFile);
        thumbUrl.setScheme("file");
        return thumbUrl.toString();
    }
    else
        return "";
}

void ThumbnailCacher::store(const QString &id, QDeclarativeItem *imageObj)
{
    QString thumbFile = getThumbFilePath(id);

    if (QFile::exists(thumbFile))
        return;

    QImage thumb(imageObj->boundingRect().size().toSize(), QImage::Format_ARGB32);
    thumb.fill(QColor(0,0,0,0).rgba());
    QPainter painter(&thumb);
    QStyleOptionGraphicsItem style;
    imageObj->paint(&painter, &style, 0);
    bool saved = thumb.save(thumbFile, "PNG");

    if (!saved)
        qWarning("ThumbnailCacher::cache: Failed to save thumbnails to %s", qPrintable(thumbFile));
}

int ThumbnailCacher::clearAll()
{
    int deleteCount = 0;

    QStringList thumbFiles = QDir(cachePath).entryList();
    foreach (const QString &thumb, thumbFiles) {
        bool removed = QFile::remove(cachePath + "/" + thumb);
        if (removed) deleteCount++;
    }

    return deleteCount;
}

inline QString ThumbnailCacher::getThumbFilePath(const QString &id)
{
    return cachePath + "/" + QCryptographicHash::hash(id.toUtf8(), QCryptographicHash::Md5).toHex() + ".png";
}
