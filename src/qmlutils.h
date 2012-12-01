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

#ifndef QMLUTILS_H
#define QMLUTILS_H

#include <QClipboard>
#include <QDeclarativeItem>

class QMLUtils : public QObject
{
    Q_OBJECT
public:
    explicit QMLUtils(QObject *parent = 0);

    // Copy text to system clipboard
    Q_INVOKABLE void copyToClipboard(const QString &text);

    // Save image from QML Image element as local file
    // Return the image path if save successfully or empty string if failed
    Q_INVOKABLE QString saveImage(QDeclarativeItem *imageObject);

    // Return the user agent that use for set as User-Agent header when making network request
    Q_INVOKABLE static QString userAgent();

private:
    QClipboard *clipboard;
    static const QString imageSavingPath;
};

#endif // QMLUTILS_H
