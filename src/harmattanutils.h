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

#ifndef HARMATTANUTILS_H
#define HARMATTANUTILS_H

#include <QtCore/QObject>

class QTimer;

class HarmattanUtils : public QObject
{
    Q_OBJECT
public:
    explicit HarmattanUtils(QObject *parent = 0);

    // Share a link using the integrated ShareUI
    Q_INVOKABLE void shareLink(const QString &url, const QString &title = QString());

    // Create a system notification based on eventType
    Q_INVOKABLE void publishNotification(const QString &eventType, const QString &summary, const QString &body,
                                         const int count);
    // Clear system notifications based on eventType
    Q_INVOKABLE void clearNotification(const QString &eventType);

    // Get now playing media name. The media name will be return through the mediaReceived() signal
    // in the form of "{Artist} - {MediaName}"
    Q_INVOKABLE void getNowPlayingMedia();

signals:
    void mediaReceived(const QString &mediaName);

private slots:
    void processMediaName(const QStringList &media);

private:
    Q_DISABLE_COPY(HarmattanUtils)

    QTimer *mentionColddown;
    QTimer *messageColddown;
};

#endif // HARMATTANUTILS_H
