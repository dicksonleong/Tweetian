HEADERS += \
    src/qmlclipboard.h \
    src/qmlimagesaver.h \
    src/qmluploader.h \
    src/thumbnailcacher.h \
    src/userstream.h \
    src/networkmonitor.h

SOURCES += main.cpp \
    src/qmlimagesaver.cpp \
    src/qmluploader.cpp \
    src/thumbnailcacher.cpp \
    src/userstream.cpp \
    src/networkmonitor.cpp

simulator{
    qml_harmattan.source = qml/tweetian-harmattan
    qml_harmattan.target = qml
    qml_symbian.source = qml/tweetian-symbian
    qml_symbian.target = qml
    DEPLOYMENTFOLDERS = qml_harmattan qml_symbian

    RESOURCES += qmlsymbian.qrc qmlharmattan.qrc
}

simulator|contains(MEEGO_EDITION,harmattan){
    include(notifications/notifications.pri)

    splash.files = splash/tweetian-splash-portrait.jpg splash/tweetian-splash-landscape.jpg
    splash.path = /opt/tweetian/splash

    icon64.files = tweetian64.png
    icon64.path = /usr/share/icons/hicolor/64x64/apps

    INSTALLS += splash icon64

    HEADERS += \
        src/harmattanmusic.h \
        src/harmattannotification.h \
        src/harmattanshareui.h

    SOURCES += \
        src/harmattanmusic.cpp \
        src/harmattannotification.cpp \
        src/harmattanshareui.cpp
}

contains(MEEGO_EDITION,harmattan){
    QT *= dbus
    CONFIG *= shareuiinterface-maemo-meegotouch share-ui-plugin share-ui-common mdatauri qdeclarative-boostable
    DEFINES += Q_OS_HARMATTAN
    RESOURCES += qmlharmattan.qrc

    SOURCES += src/tweetianif.cpp
    HEADERS += src/tweetianif.h
}

symbian{
    TARGET.UID3 = 0x2005e90a
    TARGET.CAPABILITY += NetworkServices Location LocalServices ReadUserData WriteUserData
    TARGET.EPOCHEAPSIZE = 0x40000 0x2000000 # 256KB 32MB

    CONFIG += qt-components
    vendorinfo += "%{\"Dickson\"}" ":\"Dickson\""
    my_deployment.pkg_prerules = vendorinfo
    DEPLOYMENT += my_deployment
    DEPLOYMENT.display_name = Tweetian
    ICON = Tweetian.svg
    RESOURCES += qmlsymbian.qrc

    VERSION = 1.6.1
}

QT *= network

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

# Smart Installer package's UID
# This UID is from the protected range and therefore the package will
# fail to install if self-signed. By default qmake uses the unprotected
# range value if unprotected UID is defined for the application and
# 0x2002CCCF value if protected UID is given to the application
#symbian:DEPLOYMENT.installer_header = 0x2002CCCF

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
CONFIG += mobility
MOBILITY += feedback location gallery

TRANSLATIONS += i18n/tweetian_en.ts \
                i18n/tweetian_zh.ts

OTHER_FILES += qtc_packaging/debian_harmattan/* \
    i18n/tweetian_*.ts \
    tweetian_harmattan.desktop \
    README.md

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()
