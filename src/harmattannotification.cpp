#include "harmattannotification.h"

#ifdef Q_OS_HARMATTAN
#include <MNotification>
#include <MRemoteAction>
#endif

HarmattanNotification::HarmattanNotification(QObject *parent) :
    QObject(parent), colddown(new QTimer(this))
{
    colddown->setInterval(5000);
    colddown->setSingleShot(true);
}

void HarmattanNotification::publish(const QString &eventType, const QString &summary, const QString &body, const int count)
{
    if(colddown->isActive())
        return;

#ifdef Q_OS_HARMATTAN
    QString identifier = QString(eventType).remove(0,9);

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
