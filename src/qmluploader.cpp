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

#include "qmluploader.h"

#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QtCore/QFile>
#include <QtCore/QFileInfo>
#include "qmlutils.h"

namespace {
    const QByteArray BOUNDARY = "-----------485984513665493";

    const QUrl TWITTER_UPLOAD_URL("https://upload.twitter.com/1/statuses/update_with_media.json");
    const QUrl TWITPIC_UPLOAD_URL("http://api.twitpic.com/2/upload.json");
    const QUrl MOBYPICTURE_UPLOAD_URL("https://api.mobypicture.com/2.0/upload.json");
    const QUrl IMGLY_UPLOAD_URL("http://img.ly/api/2/upload.json");
}

QMLUploader::QMLUploader(QObject *parent) :
    QObject(parent), m_progress(0)
{
}

void QMLUploader::setFile(const QString &fileName)
{
    m_fileName = fileName;
}

void QMLUploader::setAuthorizationHeader(const QString &authorizationHeader)
{
    m_authorizationHeader = authorizationHeader.toUtf8();
}

void QMLUploader::setParameter(const QString &name, const QString &value)
{
    bodyData.append("--" + BOUNDARY + "\r\n");
    bodyData.append("Content-Disposition: form-data; name=\"");
    bodyData.append(name.toUtf8());
    bodyData.append("\"\r\n\r\n");
    bodyData.append(value.toUtf8());
    bodyData.append("\r\n");
}

void QMLUploader::send()
{
    QFileInfo fileInfo(m_fileName);

    if(!fileInfo.exists()){
        emit failure(-1, tr("The file %1 does not exists").arg(m_fileName));
        bodyData.clear();
        return;
    }

    bodyData.append("--" + BOUNDARY + "\r\n");
    bodyData.append("Content-Disposition: form-data; name=\"");
    if(m_service == QMLUploader::Twitter) bodyData.append("media[]");
    else bodyData.append("media");
    bodyData.append("\"; filename=\"");
    bodyData.append(fileInfo.fileName());
    bodyData.append("\"\r\n");
    bodyData.append("Content-Type: image/" + fileInfo.suffix().toLower() + "\"\r\n\r\n");

    QFile file(fileInfo.absoluteFilePath());
    bool opened = file.open(QIODevice::ReadOnly);

    if(!opened){
        emit failure(-1, tr("Unable to open the file %1").arg(file.fileName()));
        bodyData.clear();
        return;
    }

    bodyData.append(file.readAll());
    bodyData.append("\r\n");
    bodyData.append("--" + BOUNDARY + "--\r\n\r\n");

    QNetworkRequest request;

    if(m_service == QMLUploader::Twitter){
        request.setUrl(TWITTER_UPLOAD_URL);
        request.setRawHeader("Authorization", m_authorizationHeader);
    }
    else{
        if(m_service == QMLUploader::TwitPic)
            request.setUrl(TWITPIC_UPLOAD_URL);
        else if(m_service == QMLUploader::MobyPicture)
            request.setUrl(MOBYPICTURE_UPLOAD_URL);
        else if(m_service == QMLUploader::Imgly)
            request.setUrl(IMGLY_UPLOAD_URL);

        request.setRawHeader("X-Verify-Credentials-Authorization", m_authorizationHeader);
        request.setRawHeader("X-Auth-Service-Provider", "https://api.twitter.com/1/account/verify_credentials.json");
    }

    request.setRawHeader("Content-Type", "multipart/form-data; boundary=" + BOUNDARY);
    request.setRawHeader("User-Agent", QMLUtils::userAgent().toAscii());

    if(!manager) manager = new QNetworkAccessManager(this);

    QNetworkReply *reply = manager->post(request, bodyData);

    connect(reply, SIGNAL(uploadProgress(qint64,qint64)), this, SLOT(uploadProgress(qint64,qint64)));
    connect(manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(replyFinished(QNetworkReply*)));
}

void QMLUploader::replyFinished(QNetworkReply *reply)
{
    QByteArray replyData = reply->readAll();
    int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    QString statusText = reply->attribute(QNetworkRequest::HttpReasonPhraseAttribute).toString();

    if(status == 200) emit success(replyData);
    else emit failure(status, statusText);

    reply->deleteLater();
    bodyData.clear();
}

void QMLUploader::uploadProgress(qint64 bytesSent, qint64 bytesTotal)
{
    qreal progress = qreal(bytesSent) / qreal(bytesTotal);

    if(m_progress != progress){
        m_progress = progress;
        emit progressChanged();
    }
}
