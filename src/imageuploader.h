#ifndef IMAGEUPLOADER_H
#define IMAGEUPLOADER_H

#include <QtCore/QObject>

class QNetworkAccessManager;
class QNetworkReply;

class ImageUploader : public QObject
{
    Q_OBJECT
    Q_ENUMS(Service)

    Q_PROPERTY(qreal progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(QObject* networkAccessManager READ networkAccessManager WRITE setNetworkAccessManager)
    Q_PROPERTY(Service service READ getService WRITE setService)
public:
    explicit ImageUploader(QObject *parent = 0);
    ~ImageUploader();

    enum Service { Twitter, TwitPic, MobyPicture, Imgly };

    Q_INVOKABLE void setFile(const QString &fileName);
    Q_INVOKABLE void setAuthorizationHeader(const QString &authorizationHeader);
    Q_INVOKABLE void setParameter(const QString &name, const QString &value);
    Q_INVOKABLE void send();

    qreal progress() const;

    QObject *networkAccessManager() const;
    void setNetworkAccessManager(QObject *manager);

    Service getService() const;
    void setService(const Service service);

signals:
    void success(const QString &replyData);
    void failure(const int status, const QString &statusText);
    void progressChanged();

private slots:
    void uploadProgress(qint64 bytesSent, qint64 bytesTotal);
    void replyFinished();

private:
    qreal m_progress;
    QNetworkAccessManager *m_networkAccessManager;
    Service m_service;

    QString m_fileName;
    QByteArray m_authorizationHeader;
    QByteArray bodyData;
    QNetworkReply *m_reply;
};

#endif // IMAGEUPLOADER_H
