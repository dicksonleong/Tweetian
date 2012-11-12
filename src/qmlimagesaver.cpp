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
