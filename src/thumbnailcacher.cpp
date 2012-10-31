#include "thumbnailcacher.h"

#include <QCryptographicHash>
#include <QFile>
#include <QImage>
#include <QPainter>
#include <QStyleOptionGraphicsItem>
#include <QDesktopServices>
#include <QDir>

ThumbnailCacher::ThumbnailCacher(QObject *parent) :
    QObject(parent)
{
#if defined (Q_OS_SYMBIAN) // On Symbian, cachePath should be !:/Private/{UID}/.thumbnails
    QDir cacheDir(QDesktopServices::storageLocation(QDesktopServices::DataLocation));
    if(!cacheDir.exists(".thumbnails")) cacheDir.mkdir(".thumbnails");
    cacheDir.cd(".thumbnails");

    cachePath = cacheDir.absolutePath();
#elif defined (Q_OS_LINUX) // On Linux, cachePath should be /home/user/.thumbnails/tweetian
    QDir cacheDir = QDir::homePath();
    if(!cacheDir.exists(".thumbnails")) cacheDir.mkdir(".thumbnails");
    cacheDir.cd(".thumbnails");

    if(!cacheDir.exists("tweetian")) cacheDir.mkdir("tweetian");
    cacheDir.cd("tweetian");

    cachePath = cacheDir.absolutePath();
#elif defined (Q_WS_SIMULATOR)
    QDir cacheDir = QDir::currentPath();
    if(!cacheDir.exists(".thumbnails")) cacheDir.mkdir(".thumbnails");
    cacheDir.cd(".thumbnails");

    cachePath = cacheDir.absolutePath();
#else
#error "Unrecognized target. Please set your own cachePath for thumbnails."
#endif

    QStringList thumbFiles = QDir(cachePath).entryList();
    if(thumbFiles.length() > 1000)
        clearAll();
}

QString ThumbnailCacher::get(const QString thumbUrl)
{
    QString thumbFile = cachePath + "/" + QCryptographicHash::hash(thumbUrl.toUtf8(), QCryptographicHash::Md5).toHex() + ".png";

    if(QFile::exists(thumbFile))
        return thumbFile.prepend("file:///");
    else
        return "";
}

void ThumbnailCacher::cache(const QString thumbUrl, QDeclarativeItem *imageObj)
{
    QString thumbFile = cachePath + "/" + QCryptographicHash::hash(thumbUrl.toUtf8(), QCryptographicHash::Md5).toHex() + ".png";

    if(QFile::exists(thumbFile)){
        return;
    }

    QImage thumb(imageObj->boundingRect().size().toSize(), QImage::Format_ARGB32);
    thumb.fill(QColor(0,0,0,0).rgba());
    QPainter painter(&thumb);
    QStyleOptionGraphicsItem style;
    imageObj->paint(&painter, &style, 0);
    bool saved = thumb.save(thumbFile, "PNG");

    if(!saved)
        qWarning("ThumbnailCacher::cache: Failed to save thumbnails to %s", qPrintable(thumbFile));
}

int ThumbnailCacher::clearAll()
{
    int deleteCount = 0;

    QStringList thumbFiles = QDir(cachePath).entryList();
    for(int i=0; i<thumbFiles.length(); i++){
        bool removed = QFile::remove(cachePath + "/" + thumbFiles.at(i));
        if(removed) deleteCount++;
    }

    return deleteCount;
}
