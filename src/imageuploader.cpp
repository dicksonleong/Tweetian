#include "imageuploader.h"

#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QtCore/QFile>
#include <QtCore/QFileInfo>
#include "qmlutils.h"

static const QByteArray BOUNDARY = "-----------485984513665493";

static const QUrl TWITTER_UPLOAD_URL("https://api.twitter.com/1.1/statuses/update_with_media.json");
static const QUrl TWITPIC_UPLOAD_URL("http://api.twitpic.com/2/upload.json");
static const QUrl MOBYPICTURE_UPLOAD_URL("https://api.mobypicture.com/2.0/upload.json");
static const QUrl IMGLY_UPLOAD_URL("http://img.ly/api/2/upload.json");

ImageUploader::ImageUploader(QObject *parent) :
    QObject(parent), m_progress(0), m_networkAccessManager(0), m_reply(0)
{
}

ImageUploader::~ImageUploader()
{
    if (m_reply != 0) {
        m_reply->disconnect();
        m_reply->deleteLater();
        m_reply = 0;
    }
}

void ImageUploader::setFile(const QString &fileName)
{
    m_fileName = fileName;
}

void ImageUploader::setAuthorizationHeader(const QString &authorizationHeader)
{
    m_authorizationHeader = authorizationHeader.toUtf8();
}

void ImageUploader::setParameter(const QString &name, const QString &value)
{
    bodyData.append("--" + BOUNDARY + "\r\n");
    bodyData.append("Content-Disposition: form-data; name=\"");
    bodyData.append(name.toUtf8());
    bodyData.append("\"\r\n\r\n");
    bodyData.append(value.toUtf8());
    bodyData.append("\r\n");
}

void ImageUploader::send()
{
    if (!m_networkAccessManager) {
        qWarning("ImageUploader::send(): networkAccessManager not set");
        return;
    }

    if (m_reply != 0) {
        m_reply->disconnect();
        m_reply->deleteLater();
        m_reply = 0;
    }

    QFileInfo fileInfo(m_fileName);

    if (!fileInfo.exists()) {
        emit failure(-1, tr("The file %1 does not exists").arg(m_fileName));
        bodyData.clear();
        return;
    }

    bodyData.append("--" + BOUNDARY + "\r\n");
    bodyData.append("Content-Disposition: form-data; name=\"");
    if (m_service == Twitter) bodyData.append("media[]");
    else bodyData.append("media");
    bodyData.append("\"; filename=\"");
    bodyData.append(fileInfo.fileName());
    bodyData.append("\"\r\n");
    bodyData.append("Content-Type: image/" + fileInfo.suffix().toLower() + "\"\r\n\r\n");

    QFile file(fileInfo.absoluteFilePath());
    bool opened = file.open(QIODevice::ReadOnly);

    if (!opened) {
        emit failure(-1, tr("Unable to open the file %1").arg(file.fileName()));
        bodyData.clear();
        return;
    }

    bodyData.append(file.readAll());
    bodyData.append("\r\n");
    bodyData.append("--" + BOUNDARY + "--\r\n\r\n");

    QNetworkRequest request;

    if (m_service == Twitter) {
        request.setUrl(TWITTER_UPLOAD_URL);
        request.setRawHeader("Authorization", m_authorizationHeader);
    }
    else {
        if (m_service == TwitPic)
            request.setUrl(TWITPIC_UPLOAD_URL);
        else if (m_service == MobyPicture)
            request.setUrl(MOBYPICTURE_UPLOAD_URL);
        else if (m_service == Imgly)
            request.setUrl(IMGLY_UPLOAD_URL);

        request.setRawHeader("X-Verify-Credentials-Authorization", m_authorizationHeader);
        request.setRawHeader("X-Auth-Service-Provider", "https://api.twitter.com/1.1/account/verify_credentials.json");
    }

    request.setRawHeader("Content-Type", "multipart/form-data; boundary=" + BOUNDARY);
    request.setRawHeader("User-Agent", QMLUtils::userAgent().toAscii());

    m_reply = m_networkAccessManager->post(request, bodyData);

    connect(m_reply, SIGNAL(uploadProgress(qint64,qint64)), this, SLOT(uploadProgress(qint64,qint64)));
    connect(m_reply, SIGNAL(finished()), this, SLOT(replyFinished()));
}

qreal ImageUploader::progress() const
{
    return m_progress;
}

QObject *ImageUploader::networkAccessManager() const
{
    return m_networkAccessManager;
}

void ImageUploader::setNetworkAccessManager(QObject *manager)
{
    if (m_networkAccessManager != 0) {
        qWarning("ImageUploader::setNetworkAccessManager(): networkAccessManager can only set once");
        return;
    }

    m_networkAccessManager = qobject_cast<QNetworkAccessManager*>(manager);
}

ImageUploader::Service ImageUploader::getService() const
{
    return m_service;
}

void ImageUploader::setService(const Service service)
{
    m_service = service;
}

void ImageUploader::uploadProgress(qint64 bytesSent, qint64 bytesTotal)
{
    qreal progress = qreal(bytesSent) / qreal(bytesTotal);

    if (m_progress != progress) {
        m_progress = progress;
        emit progressChanged();
    }
}

void ImageUploader::replyFinished()
{
    if (!m_reply->error()) {
        QByteArray replyData = m_reply->readAll();
        emit success(replyData);
    }
    else {
        int status = m_reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        QString statusText = m_reply->errorString();
        emit failure(status, statusText);
    }

    m_reply->deleteLater();
    m_reply = 0;
    bodyData.clear();
}
