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

import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import QtMobility.feedback 1.1

PageStackWindow {
    id: window
    initialPage: MainPage { id: mainPage }
    showStatusBar: !inputContext.visible
    platformSoftwareInputPanelEnabled: true
    platformInverted: settings.invertedTheme

    Component.onCompleted: settings.loadSettings()

    Settings { id: settings }
    Cache { id: cache }
    Constant { id: constant }

    ThemeEffect { id: listItemHapticEffect; effect: ThemeEffect.BasicItem }
    ThemeEffect { id: basicHapticEffect; effect: ThemeEffect.Basic }

    Text {
        anchors { top: parent.top; left: parent.left }
        visible: showStatusBar
        color: "white"
        font.pixelSize: constant.fontSizeMedium
        text: "Tweetian"
    }

    ToolTip {
        id: toolTip
        visible: false
        platformInverted: settings.invertedTheme
    }

    InfoBanner {
        id: infoBanner
        platformInverted: settings.invertedTheme

        function showText(text) {
            infoBanner.text = text
            infoBanner.open()
            infoBannerHapticEffect.play()
        }

        function showHttpError(errorCode, errorMessage) {
            if (errorCode === 0) showText(qsTr("Server or connection error"))
            else if (errorCode === 429) showText(qsTr("Rate limit reached, please try again later"))
            else showText(qsTr("Error: %1").arg(errorMessage + " (" + errorCode + ")"))
        }

        ThemeEffect { id: infoBannerHapticEffect; effect: ThemeEffect.NeutralTacticon }
    }

    Item {
        id: loadingRect
        anchors.fill: parent
        visible: false
        z: 2

        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.5
        }

        BusyIndicator {
            anchors.centerIn: parent
            height: constant.graphicSizeLarge; width: constant.graphicSizeLarge
            visible: loadingRect.visible
            running: visible
            platformInverted: !settings.invertedTheme
        }
    }

    QtObject {
        id: dialog

        property Component __openLinkDialog: null
        property Component __dynamicQueryDialog: null
        property Component __messageDialog: null
        property Component __tweetLongPressMenu: null

        function createOpenLinkDialog(link, pocketCallback, instapaperCallback) {
            if (!__openLinkDialog) __openLinkDialog = Qt.createComponent("Dialog/OpenLinkDialog.qml")
            var showAddPageServices = pocketCallback && instapaperCallback ? true : false
            var prop = { link: link, showAddPageServices: showAddPageServices }
            var dialog = __openLinkDialog.createObject(pageStack.currentPage, prop)
            if (showAddPageServices) {
                dialog.addToPocketClicked.connect(pocketCallback)
                dialog.addToInstapaperClicked.connect(instapaperCallback)
            }
        }

        function createQueryDialog (titleText, titleIcon, message, acceptCallback) {
            if (!__dynamicQueryDialog) __dynamicQueryDialog = Qt.createComponent("Dialog/DynamicQueryDialog.qml")
            // Add another newline at the end of message is to fix the bug in QueryDialog (QQC's ver <= 1.1.0)
            var prop = { titleText: titleText, titleIcon: titleIcon, message: message.concat("\n") }
            var dialog = __dynamicQueryDialog.createObject(pageStack.currentPage, prop)
            dialog.accepted.connect(acceptCallback)
        }

        function createMessageDialog(titleText, message) {
            if (!__messageDialog) __messageDialog = Qt.createComponent("Dialog/MessageDialog.qml")
            __messageDialog.createObject(pageStack.currentPage, { titleText: titleText, message: message })
        }

        function createTweetLongPressMenu(model ) {
            if (!__tweetLongPressMenu) __tweetLongPressMenu = Qt.createComponent("Dialog/LongPressMenu.qml")
            __tweetLongPressMenu.createObject(pageStack.currentPage, { model: model })
        }
    }
}
