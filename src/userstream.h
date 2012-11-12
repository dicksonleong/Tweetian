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

#ifndef USERSTREAM_H
#define USERSTREAM_H

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QDeclarativeListProperty>

class UserStream : public QObject
{
    Q_OBJECT
    Q_ENUMS(Status)
    Q_PROPERTY(Status status READ getStatus NOTIFY statusChanged)
    Q_PROPERTY(QDeclarativeListProperty<QObject> resources READ resources DESIGNABLE false)
    Q_CLASSINFO("DefaultProperty", "resources")
public:
    explicit UserStream(QObject *parent = 0);

    enum Status { Disconnected, Connecting, Connected };

    UserStream::Status getStatus() const;
    void setStatus(UserStream::Status status);
    QDeclarativeListProperty<QObject> resources();

signals:
    void dataRecieved(const QString &rawData);
    void statusChanged();
    void disconnected(const int statusCode, const QString &errorText);

public slots:
    void connectToStream(const QString url, const QString authHeader);
    void disconnectFromStream();

private slots:
    void replyRecieved();
    void replyFinished();

private:
    Status mStatus;
    QNetworkAccessManager *manager;
    QNetworkReply *mReply;
    QByteArray mCachedResponse;
    QList<QObject*> mResources;
};

#endif // USERSTREAM_H
