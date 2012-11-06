#include <QtGui/QApplication>
#include <QDeclarativeContext>
#include <QDeclarativeView>
#include "qmlapplicationviewer.h"

#include "src/qmlclipboard.h"
#include "src/qmlimagesaver.h"
#include "src/qmluploader.h"
#include "src/thumbnailcacher.h"
#include "src/userstream.h"
#include "src/networkmonitor.h"

#if defined(Q_OS_HARMATTAN) || defined(Q_WS_SIMULATOR)
#include "src/harmattanmusic.h"
#include "src/harmattannotification.h"
#include "src/harmattanshareui.h"
#endif

#if defined(Q_OS_SYMBIAN) || defined(Q_WS_SIMULATOR)
#include <QSplashScreen>
#include <QPixmap>
#endif

#ifdef Q_OS_HARMATTAN
#include <QDBusConnection>
#include "src/tweetianif.h"
#endif

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));

    app->setApplicationName("Tweetian");
    app->setOrganizationName("Tweetian");
    app->setApplicationVersion("1.6.1");

#if defined(Q_OS_SYMBIAN) || defined(Q_WS_SIMULATOR)
    QSplashScreen *splash = new QSplashScreen(QPixmap(":/splash/tweetian-splash-symbian.jpg"));
    splash->show();
    splash->showMessage(QSplashScreen::tr("Loading..."), Qt::AlignHCenter | Qt::AlignBottom, Qt::white);
#endif

    QDeclarativeView view;

#ifdef Q_OS_HARMATTAN
    new TweetianIf(app.data(), &view);
    QDBusConnection bus = QDBusConnection::sessionBus();
    bus.registerService("com.tweetian");
    bus.registerObject("/com/tweetian", app.data());
#endif

    QMLClipboard clipboard;
    view.rootContext()->setContextProperty("clipboard", &clipboard);
    QMLImageSaver imageSaver;
    view.rootContext()->setContextProperty("imageSaver", &imageSaver);
    ThumbnailCacher thumbnailCacher;
    view.rootContext()->setContextProperty("thumbnailCacher", &thumbnailCacher);
    NetworkMonitor networkMonitor;
    view.rootContext()->setContextProperty("networkMonitor", &networkMonitor);
    view.rootContext()->setContextProperty("appVersion", app->applicationVersion());

#if defined(Q_OS_HARMATTAN) || defined(Q_WS_SIMULATOR)
    HarmattanNotification notification;
    view.rootContext()->setContextProperty("notification", &notification);
    HarmattanShareUI shareUI;
    view.rootContext()->setContextProperty("shareUI", &shareUI);
    qmlRegisterType<HarmattanMusic>("Harmattan", 1, 0, "HarmattanMusic");
#endif

    qmlRegisterType<QMLUploader>("Uploader", 1, 0, "ImageUploader");
    qmlRegisterType<UserStream>("UserStream", 1, 0, "UserStream");

#if defined(Q_OS_HARMATTAN)
    view.setSource(QUrl("qrc:/qml/tweetian-harmattan/main.qml"));
#elif defined(Q_OS_SYMBIAN)
    view.rootContext()->setContextProperty("appQmlView", &view);
    view.setSource(QUrl("qrc:/qml/tweetian-symbian/main.qml"));
#else
    view.setSource(QUrl("qrc:/qml/tweetian-harmattan/main.qml"));
#endif

    view.showFullScreen();

#if defined(Q_OS_SYMBIAN) || defined(Q_WS_SIMULATOR)
    splash->finish(&view);
    splash->deleteLater();
#endif

    return app->exec();
}
