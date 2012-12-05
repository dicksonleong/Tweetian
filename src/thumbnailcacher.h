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

#ifndef THUMBNAILCACHER_H
#define THUMBNAILCACHER_H

#include <QtCore/QObject>

class QDeclarativeItem;

class ThumbnailCacher : public QObject
{
    Q_OBJECT
public:
    explicit ThumbnailCacher(QObject *parent = 0);

    // Get a thumbnail url from local thumbnails cache based on id
    // Return thumbnail local file path and prepended with "file:" scheme if exists
    // Return empty string if not exists
    Q_INVOKABLE QString get(const QString &id);

    // Store a image from imageObj to the thumbnails cache based on id
    Q_INVOKABLE void store(const QString &id, QDeclarativeItem *imageObj);

    // Clear all thumbnails from the thuubmails cache
    Q_INVOKABLE int clearAll();

private:
    Q_DISABLE_COPY(ThumbnailCacher)

    QString cachePath;
    inline QString getThumbFilePath(const QString &id);
};

#endif // THUMBNAILCACHER_H
