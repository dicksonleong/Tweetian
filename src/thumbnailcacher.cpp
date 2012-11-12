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

#include <QCryptographicHash>
#include <QFile>
#include <QImage>
#include <QPainter>
#include <QStyleOptionGraphicsItem>
#include <QDesktopServices>
#include <QDir>

ThumbnailCacher::ThumbnailCacher(QObject *parent) :
    QObject(parent)
{
#if defined (Q_OS_SYMBIAN) // On Symbian, cachePath should be !:/Private/{UID}/.thumbnails
    QDir cacheDir(QDesktopServices::storageLocation(QDesktopServices::DataLocation));
    if(!cacheDir.exists(".thumbnails")) cacheDir.mkdir(".thumbnails");
    cacheDir.cd(".thumbnails");

    cachePath = cacheDir.absolutePath();
#elif defined (Q_OS_LINUX) // On Linux, cachePath should be /home/user/.thumbnails/tweetian
    QDir cacheDir = QDir::homePath();
    if(!cacheDir.exists(".thumbnails")) cacheDir.mkdir(".thumbnails");
    cacheDir.cd(".thumbnails");

    if(!cacheDir.exists("tweetian")) cacheDir.mkdir("tweetian");
    cacheDir.cd("tweetian");

    cachePath = cacheDir.absolutePath();
#elif defined (Q_WS_SIMULATOR)
    QDir cacheDir = QDir::currentPath();
    if(!cacheDir.exists(".thumbnails")) cacheDir.mkdir(".thumbnails");
    cacheDir.cd(".thumbnails");

    cachePath = cacheDir.absolutePath();
#else
#error "Unrecognized target. Please set your own cachePath for thumbnails."
#endif

    QStringList thumbFiles = QDir(cachePath).entryList();
    if(thumbFiles.length() > 1000)
        clearAll();
}

QString ThumbnailCacher::get(const QString thumbUrl)
{
    QString thumbFile = cachePath + "/" + QCryptographicHash::hash(thumbUrl.toUtf8(), QCryptographicHash::Md5).toHex() + ".png";

    if(QFile::exists(thumbFile))
        return thumbFile.prepend("file:///");
    else
        return "";
}

void ThumbnailCacher::cache(const QString thumbUrl, QDeclarativeItem *imageObj)
{
    QString thumbFile = cachePath + "/" + QCryptographicHash::hash(thumbUrl.toUtf8(), QCryptographicHash::Md5).toHex() + ".png";

    if(QFile::exists(thumbFile)){
        return;
    }

    QImage thumb(imageObj->boundingRect().size().toSize(), QImage::Format_ARGB32);
    thumb.fill(QColor(0,0,0,0).rgba());
    QPainter painter(&thumb);
    QStyleOptionGraphicsItem style;
    imageObj->paint(&painter, &style, 0);
    bool saved = thumb.save(thumbFile, "PNG");

    if(!saved)
        qWarning("ThumbnailCacher::cache: Failed to save thumbnails to %s", qPrintable(thumbFile));
}

int ThumbnailCacher::clearAll()
{
    int deleteCount = 0;

    QStringList thumbFiles = QDir(cachePath).entryList();
    for(int i=0; i<thumbFiles.length(); i++){
        bool removed = QFile::remove(cachePath + "/" + thumbFiles.at(i));
        if(removed) deleteCount++;
    }

    return deleteCount;
}
