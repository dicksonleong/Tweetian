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

#include <QtCore/QObject>
#include <QtDeclarative/QDeclarativeListProperty>

class QNetworkAccessManager;
class QNetworkReply;

class UserStream : public QObject
{
    Q_OBJECT
    Q_ENUMS(Status)
    Q_PROPERTY(Status status READ getStatus NOTIFY statusChanged)
    Q_PROPERTY(QDeclarativeListProperty<QObject> resources READ resources DESIGNABLE false)
    Q_CLASSINFO("DefaultProperty", "resources")
public:
    enum Status { Disconnected, Connecting, Connected };

    explicit UserStream(QObject *parent = 0);

    Q_INVOKABLE void connectToStream(const QString &url, const QString &authHeader);
    Q_INVOKABLE void disconnectFromStream();

    Status getStatus() const;
    void setStatus(Status status);
    QDeclarativeListProperty<QObject> resources();

signals:
    void dataRecieved(const QString &rawData);
    void statusChanged();
    void disconnected(const int statusCode, const QString &errorText);

private slots:
    void replyRecieved();
    void replyFinished();

private:
    Status m_status;
    QNetworkAccessManager *manager;
    QNetworkReply *m_reply;
    QByteArray m_cachedResponse;
    QList<QObject*> m_resources;
};

#endif // USERSTREAM_H
