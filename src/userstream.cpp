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

#include "userstream.h"

#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include "qmlutils.h"

UserStream::UserStream(QObject *parent) :
    QObject(parent), m_connected(false), m_networkAccessManager(0), m_reply(0)
{
}

UserStream::~UserStream()
{
    if (m_reply != 0) {
        m_reply->disconnect();
        m_reply->deleteLater();
        m_reply = 0;
    }
}

void UserStream::connectToStream(const QString &url, const QString &authHeader)
{
    if (!m_networkAccessManager) {
        qWarning("UserStream::connectToStream(): networkAccessManager not set");
        return;
    }

    disconnectFromStream();

    QNetworkRequest request;
    request.setUrl(QUrl(url));
    request.setRawHeader("User-Agent", QMLUtils::userAgent().toAscii());
    request.setRawHeader("Content-Type", "application/x-www-form-urlencoded");
    request.setRawHeader("Authorization", authHeader.toUtf8());
    request.setRawHeader("Connection", "close");

    m_reply = m_networkAccessManager->get(request);
    connect(m_reply, SIGNAL(readyRead()), this, SLOT(replyRecieved()));
    connect(m_reply, SIGNAL(finished()), this, SLOT(replyFinished()));
}

void UserStream::disconnectFromStream()
{
    if (m_reply != 0) {
        m_reply->disconnect();
        m_reply->deleteLater();
        m_reply = 0;
    }
    setConnected(false);
}

bool UserStream::isConnected() const
{
    return m_connected;
}

void UserStream::setConnected(bool connected)
{
    if (m_connected != connected) {
        m_connected = connected;
        emit connectedChanged();
    }
}

QObject *UserStream::networkAccessManager() const
{
    return m_networkAccessManager;
}

void UserStream::setNetworkAccessManager(QObject *manager)
{
    if (m_networkAccessManager != 0) {
        qWarning("UserStream::setNetworkAccessManager(): networkAccessManager can only set once");
        return;
    }

    m_networkAccessManager = qobject_cast<QNetworkAccessManager*>(manager);
}

QDeclarativeListProperty<QObject> UserStream::resources()
{
    return QDeclarativeListProperty<QObject>(this, m_resources);
}

void UserStream::replyRecieved()
{
    setConnected(true);
    QByteArray replyData = m_reply->readAll();

    if (replyData == "\r\n") { // Keep alive newline
        emit dataRecieved("");
        return;
    }

    if (!m_cachedResponse.isEmpty()) {
        replyData.prepend(m_cachedResponse);
        m_cachedResponse.clear();
    }

    int length = replyData.left(replyData.indexOf("\r\n")).toInt();

    QByteArray jsonRawData = replyData.mid(replyData.indexOf("{"));

    if (jsonRawData.length() == length) // complete JSON
        emit dataRecieved(jsonRawData);
    else if (jsonRawData.length() < length) // incomplete JSON
        m_cachedResponse = replyData;
}

void UserStream::replyFinished()
{   
    int statusCode = m_reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    QString statusText = m_reply->errorString();

    emit disconnected(statusCode, statusText);

    m_reply->deleteLater();
    m_reply = 0;

    setConnected(false);
}
