#ifndef THUMBNAILCACHER_H
#define THUMBNAILCACHER_H

#include <QDeclarativeItem>

class ThumbnailCacher : public QObject
{
    Q_OBJECT
public:
    explicit ThumbnailCacher(QObject *parent = 0);

    Q_INVOKABLE QString get(const QString thumbUrl);
    Q_INVOKABLE void cache(const QString thumbUrl, QDeclarativeItem *imageObj);
    Q_INVOKABLE int clearAll();

private:
    QString cachePath;
};

#endif // THUMBNAILCACHER_H
