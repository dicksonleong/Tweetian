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

#include "harmattanutils.h"

#include <QtCore/QTimer>

#ifdef Q_OS_HARMATTAN
#include <MDataUri>
#include <maemo-meegotouch-interfaces/shareuiinterface.h>
#include <MNotification>
#include <MRemoteAction>
#include <QtDBus/QDBusConnection>
#include <QtDBus/QDBusInterface>
#include <QtDBus/QDBusConnectionInterface>
#include <QtDBus/QDBusReply>
#endif

namespace {
#ifdef Q_OS_HARMATTAN
    const QString SHARE_UI_SERVICE = "com.nokia.ShareUi";
    const QString MUSIC_SUITE_SERVICE = "com.nokia.music-suite";
    const QString MUSIC_SUITE_INTERFACE = "com.nokia.maemo.meegotouch.MusicSuiteInterface";
#endif

    const int NOTIFICATION_COLDDOWN_INVERVAL = 5000;
}

HarmattanUtils::HarmattanUtils(QObject *parent) :
    QObject(parent), mentionColddown(new QTimer(this)), messageColddown(new QTimer(this))
{
    mentionColddown->setInterval(NOTIFICATION_COLDDOWN_INVERVAL);
    mentionColddown->setSingleShot(true);
    messageColddown->setInterval(NOTIFICATION_COLDDOWN_INVERVAL);
    messageColddown->setSingleShot(true);
}

void HarmattanUtils::shareLink(const QString &url, const QString &title)
{
#ifdef Q_OS_HARMATTAN
    MDataUri uri;
    uri.setMimeType("text/x-url");
    uri.setTextData(url);

    if (!title.isEmpty())
        uri.setAttribute("title", title);

    if (!uri.isValid()) {
        qWarning("HarmattanUtils::shareLink: Invalid URI");
        return;
    }

    ShareUiInterface shareIf(SHARE_UI_SERVICE);

    if (!shareIf.isValid()) {
        qCritical("HarmattanUtils::shareLink: Invalid Share UI interface");
        return;
    }

    shareIf.share(QStringList(uri.toString()));
#else
    Q_UNUSED(url)
    Q_UNUSED(title)
#endif
}

void HarmattanUtils::publishNotification(const QString &eventType, const QString &summary, const QString &body,
                                         const int count)
{
    if (eventType == "tweetian.mention" ? mentionColddown->isActive() : messageColddown->isActive())
        return;

#ifdef Q_OS_HARMATTAN
    QString identifier = eventType.mid(9);

    MNotification notification(eventType, summary, body);
    notification.setCount(count);
    notification.setIdentifier(identifier);
    MRemoteAction action("com.tweetian", "/com/tweetian", "com.tweetian", identifier);
    notification.setAction(action);
    notification.publish();
#else
    Q_UNUSED(eventType)
    Q_UNUSED(summary)
    Q_UNUSED(body)
    Q_UNUSED(count)
#endif

    if (eventType == "tweetian.mention") mentionColddown->start();
    else messageColddown->start();
}

void HarmattanUtils::clearNotification(const QString &eventType)
{
#ifdef Q_OS_HARMATTAN
    QList<MNotification*> activeNotifications = MNotification::notifications();
    QMutableListIterator<MNotification*> i(activeNotifications);
    while (i.hasNext()) {
        MNotification *notification = i.next();
        if (notification->eventType() == eventType)
            notification->remove();
    }
#else
    Q_UNUSED(eventType)
#endif
}

void HarmattanUtils::getNowPlayingMedia()
{
#ifdef Q_OS_HARMATTAN
    QDBusConnectionInterface *interface = QDBusConnection::sessionBus().interface();
    QDBusReply<bool> reply = interface->isServiceRegistered(MUSIC_SUITE_SERVICE);
    if (!reply.isValid() || reply.value() == false) {
        emit mediaReceived("");
        return;
    }

    QDBusConnection::sessionBus().connect(MUSIC_SUITE_SERVICE, "/", MUSIC_SUITE_INTERFACE, "mediaChanged",
                                          this, SLOT(processMediaName(QStringList)));

    QDBusInterface musicInterface(MUSIC_SUITE_SERVICE, "/", MUSIC_SUITE_INTERFACE);
    musicInterface.call("currentMedia");
#else
    emit mediaReceived("");
#endif
}

void HarmattanUtils::processMediaName(const QStringList &media)
{
#ifdef Q_OS_HARMATTAN
    QString mediaName = "";
    if (media.length() >= 3)
        mediaName = media.at(2) + " - " + media.at(1);
    emit mediaReceived(mediaName);

    QDBusConnection::sessionBus().disconnect(MUSIC_SUITE_SERVICE, "/", MUSIC_SUITE_INTERFACE, "mediaChanged",
                                             this, SLOT(processMediaName(QStringList)));
#else
    Q_UNUSED(media)
#endif
}
