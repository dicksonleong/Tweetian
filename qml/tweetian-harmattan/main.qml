import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import QtMobility.feedback 1.1

PageStackWindow {
    id: window
    initialPage: MainPage{ id: mainPage }
    showStatusBar: inPortrait
    showToolBar: true

    Component.onCompleted: settings.loadSettings()

    Settings{ id: settings }
    Cache{ id: cache }
    Constant{ id: constant }

    ThemeEffect{ id: basicHapticEffect; effect: ThemeEffect.Basic }

    InfoBanner{
        id: infoBanner
        topMargin: showStatusBar ? 40 : 8

        function alert(alertText){
            infoBanner.text = alertText
            infoBanner.show()
        }
    }

    Item{
        id: loadingRect
        anchors.fill: parent
        visible: false
        z: 2

        Rectangle{
            anchors.fill: parent
            color: "black"
            opacity: 0.5
        }

        BusyIndicator{
            visible: loadingRect.visible
            running: visible
            anchors.centerIn: parent
            platformStyle: BusyIndicatorStyle{ size: "large" }
        }
    }

    QtObject{
        id: dialog

        property Component __openLinkDialog: null
        property Component __dynamicQueryDialog: null
        property Component __messageDialog: null
        property Component __tweetLongPressMenu: null

        function createOpenLinkDialog(link, pocketCallback, instapaperCallback){
            if(!__openLinkDialog) __openLinkDialog = Qt.createComponent("Dialog/OpenLinkDialog.qml")
            var showAddPageServices = pocketCallback && instapaperCallback ? true : false
            var prop = { link: link, showAddPageServices: showAddPageServices }
            var dialog = __openLinkDialog.createObject(pageStack.currentPage, prop)
            if(showAddPageServices){
                dialog.addToPocketClicked.connect(pocketCallback)
                dialog.addToInstapaperClicked.connect(instapaperCallback)
            }
        }

        function createQueryDialog(titleText, titleIcon, message, acceptCallback){
            if(!__dynamicQueryDialog) __dynamicQueryDialog = Qt.createComponent("Dialog/DynamicQueryDialog.qml")
            var prop = { titleText: titleText, icon: titleIcon, message: message }
            var dialog = __dynamicQueryDialog.createObject(pageStack.currentPage, prop)
            dialog.accepted.connect(acceptCallback)
        }

        function createMessageDialog(titleText, message){
            if(!__messageDialog) __messageDialog = Qt.createComponent("Dialog/MessageDialog.qml")
            __messageDialog.createObject(pageStack.currentPage, { titleText: titleText, message: message })
        }

        function createTweetLongPressMenu(model){
            if(!__tweetLongPressMenu) __tweetLongPressMenu = Qt.createComponent("Dialog/LongPressMenu.qml")
            __tweetLongPressMenu.createObject(pageStack.currentPage, { model: model })
        }
    }
}
