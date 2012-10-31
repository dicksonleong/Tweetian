#include "qmlimagesaver.h"

#include <QImage>
#include <QStyleOptionGraphicsItem>
#include <QPainter>
#include <QDesktopServices>
#include <QDateTime>

QMLImageSaver::QMLImageSaver(QObject *parent) :
    QObject(parent)
{
}

QString QMLImageSaver::save(QDeclarativeItem *imageObject)
{
    QString fileName = "tweetian_" + QDateTime::currentDateTime().toString("d-M-yy_h-m-s") + ".png";
    QString savingFilePath = QDesktopServices::storageLocation(QDesktopServices::PicturesLocation).append("/").append(fileName);

    QImage img(imageObject->boundingRect().size().toSize(), QImage::Format_ARGB32);
    img.fill(QColor(0,0,0,0).rgba());
    QPainter painter(&img);
    QStyleOptionGraphicsItem styleOption;
    imageObject->paint(&painter, &styleOption, 0);
    bool saved = img.save(savingFilePath, "PNG");

    if(!saved){
        qWarning("QMLImageSaver::save(): Failed to save image to %s", qPrintable(savingFilePath));
        return "";
    }

    return savingFilePath;
}
