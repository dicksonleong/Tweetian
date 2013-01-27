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

    Q_PROPERTY(bool connected READ isConnected NOTIFY connectedChanged)
    Q_PROPERTY(QObject* networkAccessManager READ networkAccessManager WRITE setNetworkAccessManager)
    Q_PROPERTY(QDeclarativeListProperty<QObject> resources READ resources DESIGNABLE false)
    Q_CLASSINFO("DefaultProperty", "resources")
public:
    explicit UserStream(QObject *parent = 0);
    ~UserStream();

    Q_INVOKABLE void connectToStream(const QString &url, const QString &authHeader);
    Q_INVOKABLE void disconnectFromStream();

    bool isConnected() const;
    void setConnected(bool connected);

    QObject *networkAccessManager() const;
    void setNetworkAccessManager(QObject *manager);

    QDeclarativeListProperty<QObject> resources();

signals:
    void connectedChanged();
    void dataRecieved(const QString &rawData);
    void disconnected(const int statusCode, const QString &errorText);

private slots:
    void replyRecieved();
    void replyFinished();

private:
    bool m_connected;
    QNetworkAccessManager *m_networkAccessManager;
    QList<QObject*> m_resources;

    QNetworkReply *m_reply;
    QByteArray m_cachedResponse;
};

#endif // USERSTREAM_H
