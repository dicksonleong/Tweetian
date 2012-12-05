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

#ifndef QMLUPLOADER_H
#define QMLUPLOADER_H

#include <QtCore/QObject>

class QNetworkAccessManager;
class QNetworkReply;

class QMLUploader : public QObject
{
    Q_OBJECT
    Q_ENUMS(Service)
    Q_PROPERTY(Service service READ getService WRITE setService)
    Q_PROPERTY(qreal progress READ getProgress NOTIFY progressChanged)
public:
    enum Service { Twitter, TwitPic, MobyPicture, Imgly };

    explicit QMLUploader(QObject *parent = 0);

    Q_INVOKABLE void setFile(const QString &fileName);
    Q_INVOKABLE void setAuthorizationHeader(const QString &authorizationHeader);
    Q_INVOKABLE void setParameter(const QString &name, const QString &value);
    Q_INVOKABLE void send();

    Service getService() const { return m_service; }
    void setService(const Service service) { m_service = service; }

    qreal getProgress() const { return m_progress; }

signals:
    void success(const QString &replyData);
    void failure(const int status, const QString &statusText);
    void progressChanged();

private slots:
    void replyFinished(QNetworkReply *reply);
    void uploadProgress(qint64 bytesSent, qint64 bytesTotal);

private:
    Service m_service;
    qreal m_progress;
    QString m_fileName;
    QByteArray m_authorizationHeader;
    QNetworkAccessManager *manager;
    QByteArray bodyData;
};

#endif // QMLUPLOADER_H
