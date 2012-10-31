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
