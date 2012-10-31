#ifndef QMLUPLOADER_H
#define QMLUPLOADER_H

#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>

class QMLUploader : public QObject
{
    Q_OBJECT
    Q_ENUMS(Service)
    Q_PROPERTY(Service service READ getService WRITE setService)
public:
    enum Service { Twitter, TwitPic, MobyPicture, Imgly };

    explicit QMLUploader(QObject *parent = 0);

    Service getService() const { return mService; }
    void setService(const Service service){ mService = service; }

    Q_INVOKABLE void setFile(const QString fileName);
    Q_INVOKABLE void setAuthorizationHeader(const QString authorizationHeader);
    Q_INVOKABLE void setParameter(const QString name, const QString value);
    Q_INVOKABLE void send();

signals:
    void success(const QString &replyData);
    void failure(const int status, const QString &statusText);
    void progressChanged(const int progress);

private slots:
    void replyFinished(QNetworkReply *reply);
    void uploadProgress(qint64 bytesSent, qint64 bytesTotal);

private:
    QString mFileName;
    QByteArray mAuthorizationHeader;
    QNetworkAccessManager *manager;
    Service mService;
    QByteArray bodyData;
    static const QByteArray boundary;
};

#endif // QMLUPLOADER_H
