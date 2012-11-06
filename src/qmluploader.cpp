#include "qmluploader.h"

#include <QFile>
#include <QFileInfo>
#include <QApplication>

const QByteArray QMLUploader::boundary = "-----------485984513665493";

QMLUploader::QMLUploader(QObject *parent) :
    QObject(parent)
{
}

void QMLUploader::setFile(const QString fileName)
{
    mFileName = fileName;
}

void QMLUploader::setAuthorizationHeader(const QString authorizationHeader)
{
    mAuthorizationHeader = authorizationHeader.toUtf8();
}

void QMLUploader::setParameter(const QString name, const QString value)
{
    bodyData.append("--" + boundary + "\r\n");
    bodyData.append("Content-Disposition: form-data; name=\"");
    bodyData.append(name.toUtf8());
    bodyData.append("\"\r\n\r\n");
    bodyData.append(value.toUtf8());
    bodyData.append("\r\n");
}

void QMLUploader::send()
{
    QFileInfo fileInfo(mFileName);

    if(!fileInfo.exists()){
        emit failure(-1, tr("The file %1 does not exists").arg(mFileName));
        bodyData.clear();
        return;
    }

    bodyData.append("--" + boundary + "\r\n");
    bodyData.append("Content-Disposition: form-data; name=\"");
    if(mService == QMLUploader::Twitter) bodyData.append("media[]");
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
    bodyData.append("--" + boundary + "--\r\n\r\n");

    QNetworkRequest request;

    if(mService == QMLUploader::Twitter){
        request.setUrl(QUrl("https://upload.twitter.com/1/statuses/update_with_media.json"));
        request.setRawHeader("Authorization", mAuthorizationHeader);
    }
    else{
        if(mService == QMLUploader::TwitPic)
            request.setUrl(QUrl("http://api.twitpic.com/2/upload.json"));
        else if(mService == QMLUploader::MobyPicture)
            request.setUrl(QUrl("https://api.mobypicture.com/2.0/upload.json"));
        else if(mService == QMLUploader::Imgly)
            request.setUrl(QUrl("http://img.ly/api/2/upload.json"));
        request.setRawHeader("X-Verify-Credentials-Authorization", mAuthorizationHeader);
        request.setRawHeader("X-Auth-Service-Provider", "https://api.twitter.com/1/account/verify_credentials.json");
    }

    request.setRawHeader("Content-Type", "multipart/form-data; boundary=" + boundary);

    QString userAgent;
#if defined(Q_OS_HARMATTAN)
    userAgent = "Tweetian/" + QApplication::applicationVersion() + " (Nokia; Qt; MeeGo Harmattan)";
#elif defined(Q_OS_SYMBIAN)
    userAgent = "Tweetian/" + QApplication::applicationVersion() + " (Nokia; Qt; Symbian)";
#else
    userAgent = "Tweetian/" + QApplication::applicationVersion() + " (Nokia; Qt; QtSimulator)";
#endif
    request.setRawHeader("User-Agent", userAgent.toAscii());

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
    int progress = qRound( (qreal)bytesSent / (qreal)bytesTotal*100 );
    emit progressChanged(progress);
}
