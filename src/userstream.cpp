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

#include <QNetworkRequest>
#include <QNetworkReply>
#include "qmlutils.h"

UserStream::UserStream(QObject *parent) :
    QObject(parent), mStatus(UserStream::Disconnected), mReply(0)
{
}

UserStream::Status UserStream::getStatus() const
{
    return mStatus;
}

void UserStream::setStatus(UserStream::Status status)
{
    if(mStatus != status){
        mStatus = status;
        emit statusChanged();
    }
}

QDeclarativeListProperty<QObject> UserStream::resources()
{
    return QDeclarativeListProperty<QObject>(this, mResources);
}

void UserStream::connectToStream(const QString url, const QString authHeader)
{
    if(mReply != 0){
        mReply->disconnect();
        mReply->abort();
        mReply->deleteLater();
        mReply = 0;
    }

    if(!manager) manager = new QNetworkAccessManager(this);

    QNetworkRequest request;
    request.setUrl(QUrl(url));
    request.setRawHeader("User-Agent", QMLUtils::userAgent().toAscii());
    request.setRawHeader("Content-Type", "application/x-www-form-urlencoded");
    request.setRawHeader("Authorization", authHeader.toUtf8());
    request.setRawHeader("Connection", "close");

    mReply = manager->get(request);
    connect(mReply, SIGNAL(readyRead()), this, SLOT(replyRecieved()));
    connect(mReply, SIGNAL(finished()), this, SLOT(replyFinished()));

    setStatus(UserStream::Connecting);
}

void UserStream::disconnectFromStream()
{
    if(mReply != 0){
        mReply->disconnect();
        mReply->abort();
        mReply->deleteLater();
        mReply = 0;
        setStatus(UserStream::Disconnected);
    }
}

void UserStream::replyRecieved()
{
    setStatus(UserStream::Connected);
    QByteArray replyData = mReply->readAll();

    if(replyData == "\r\n"){ // Keep alive newline
        emit dataRecieved("");
        return;
    }

    if(!mCachedResponse.isEmpty()){
        replyData.prepend(mCachedResponse);
        mCachedResponse.clear();
    }

    int length = replyData.left(replyData.indexOf("\r\n")).toInt();

    QByteArray jsonRawData = replyData.mid(replyData.indexOf("{"));
    if(jsonRawData.length() == length){ // complete JSON
        emit dataRecieved(jsonRawData);
    }
    else if(jsonRawData.length() < length){ // incomplete JSON
        mCachedResponse = replyData;
    }
}

void UserStream::replyFinished()
{   
    int statusCode = mReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    QString statusText;

    if(!mReply->error())
        statusText = mReply->attribute(QNetworkRequest::HttpReasonPhraseAttribute).toString();
    else
        statusText = mReply->errorString();

    emit disconnected(statusCode, statusText);

    mReply->deleteLater();
    mReply = 0;

    setStatus(UserStream::Disconnected);
}
