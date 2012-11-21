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

#include "harmattannotification.h"

#ifdef Q_OS_HARMATTAN
#include <MNotification>
#include <MRemoteAction>
#endif

#define COLDDOWN_TIMER_INVERVAL 5000

HarmattanNotification::HarmattanNotification(QObject *parent) :
    QObject(parent), colddown(new QTimer(this))
{
    colddown->setInterval(COLDDOWN_TIMER_INVERVAL);
    colddown->setSingleShot(true);
}

void HarmattanNotification::publish(const QString &eventType, const QString &summary, const QString &body, const int count)
{
    if(colddown->isActive())
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

    colddown->start();
}

void HarmattanNotification::clear(const QString &eventType)
{
#ifdef Q_OS_HARMATTAN
    QList<MNotification*> activeNotifications = MNotification::notifications();
    for(int i=0; i<activeNotifications.length(); i++){
        if(activeNotifications.at(i)->eventType() == eventType){
            activeNotifications.at(i)->remove();
        }
    }
#else
    Q_UNUSED(eventType)
#endif
}
