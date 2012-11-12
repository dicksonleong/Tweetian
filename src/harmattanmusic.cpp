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

#include "harmattanmusic.h"

#ifdef Q_OS_HARMATTAN
#include <QtDBus/QDBusConnection>
#include <QtDBus/QDBusInterface>
#include <QtDBus/QDBusConnectionInterface>
#include <QtDBus/QDBusReply>
#endif

HarmattanMusic::HarmattanMusic(QObject *parent) :
    QObject(parent)
{
}

void HarmattanMusic::requestCurrentMedia()
{
#ifdef Q_OS_HARMATTAN
    bool isRunning = isMusicSuiteRunning();

    if(!isRunning){
        emit mediaReceived("");
        return;
    }

    QDBusConnection::sessionBus().connect("com.nokia.music-suite", "/", "com.nokia.maemo.meegotouch.MusicSuiteInterface", "mediaChanged", this, SLOT(processMediaChanged(QStringList)));

    QDBusInterface musicInterface("com.nokia.music-suite", "/", "com.nokia.maemo.meegotouch.MusicSuiteInterface");
    musicInterface.call("currentMedia");
#else
    emit mediaReceived("");
#endif
}

void HarmattanMusic::processMediaChanged(const QStringList &media)
{
#ifdef Q_OS_HARMATTAN
    QString mediaName = "";
    if(media.length() >= 3)
        mediaName = media.at(2) + " - " + media.at(1);
    emit mediaReceived(mediaName);
    QDBusConnection::sessionBus().disconnect("com.nokia.music-suite", "/", "com.nokia.maemo.meegotouch.MusicSuiteInterface", "mediaChanged", this, SLOT(processMediaChanged(QStringList)));
#else
    Q_UNUSED(media)
#endif
}

bool HarmattanMusic::isMusicSuiteRunning()
{
#ifdef Q_OS_HARMATTAN
    QDBusConnectionInterface *interface = QDBusConnection::sessionBus().interface();
    QDBusReply<bool> reply = interface->isServiceRegistered("com.nokia.music-suite");
    if (reply.isValid())
        return reply.value();
    else
        return false;
#else
    return false;
#endif
}
