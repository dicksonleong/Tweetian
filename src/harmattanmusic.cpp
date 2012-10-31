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
