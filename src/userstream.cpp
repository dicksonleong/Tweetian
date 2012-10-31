#include "userstream.h"

#include <QNetworkRequest>
#include <QNetworkReply>
#include <QApplication>

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
    request.setRawHeader("Content-Type", "application/x-www-form-urlencoded");

    QString userAgent;
#if defined(Q_OS_HARMATTAN)
    userAgent = "Tweetian/" + QApplication::applicationVersion() + " (Nokia; Qt; MeeGo Harmattan)";
#elif defined(Q_OS_SYMBIAN)
    userAgent = "Tweetian/" + QApplication::applicationVersion() + " (Nokia; Qt; Symbian)";
#else
    userAgent = "Tweetian/" + QApplication::applicationVersion() + " (Nokia; Qt; QtSimulator)";
#endif
    request.setRawHeader("User-Agent", userAgent.toAscii());

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
