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
import com.nokia.meego 1.0
import "Services/Twitter.js" as Twitter
import "Component"
import "MainPageCom"
import UserStream 1.0
import "MainPageCom/UserStream.js" as StreamScript
import "Utils/Parser.js" as Parser

Page {
    id: mainPage

    property Item timeline: timeline
    property Item mentions: mentions
    property Item directMsg: directMsg

    onStatusChanged: if (status == PageStatus.Activating) loadingRect.visible = false

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back-dimmed"
            enabled: false
        }
        ToolIcon {
            id: newTweetButton
            platformIconId: "toolbar-edit"
            onClicked: pageStack.push(Qt.resolvedUrl("NewTweetPage.qml"), {type: "New"})
        }
        ToolIcon {
            id: messageButton
            platformIconId: "toolbar-search"
            onClicked: pageStack.push(Qt.resolvedUrl("TrendsPage.qml"))
        }
        ToolIcon {
            platformIconId: "toolbar-contact"
            onClicked: pageStack.push(Qt.resolvedUrl("UserPage.qml"), {screenName: settings.userScreenName})
        }
        ToolIcon {
            id: optionsButton
            platformIconId: "toolbar-view-menu"
            onClicked: mainMenu.open()
        }
    }

    Menu {
        id: mainMenu

        MenuLayout {
            MenuItem {
                text: qsTr("Refresh cache")
                enabled: !mainView.currentItem.busy
                onClicked: mainView.currentItem.refresh("all")
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingPage.qml"))
            }
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
        }
    }

    ListView {
        id: mainView
        objectName: "mainView"

        property int __contentXOffset: 0

        function moveToColumn(index) {
            columnMovingAnimation.to = (index * width) + __contentXOffset
            columnMovingAnimation.restart()
        }

        anchors { top: mainPageHeader.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
        highlightRangeMode: ListView.StrictlyEnforceRange
        snapMode: ListView.SnapOneItem
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        model: VisualItemModel {
            TweetListView { id: timeline; type: "Timeline" }
            TweetListView { id: mentions; type: "Mentions" }
            DirectMessage { id: directMsg }
        }
        onWidthChanged: __contentXOffset = contentX - (currentIndex * width)

        NumberAnimation {
            id: columnMovingAnimation
            target: mainView
            property: "contentX"
            duration: 500
            easing.type: Easing.InOutExpo
        }
    }

    Connections {
        target: settings
        onSettingsLoaded: {
            Twitter.init(constant, settings.oauthToken, settings.oauthTokenSecret)
            if (settings.oauthToken === "" || settings.oauthTokenSecret === "") {
                pageStack.push(Qt.resolvedUrl("SignInPage.qml"))
            }
            else {
                timeline.initialize()
                mentions.initialize()
                directMsg.initialize()
                StreamScript.initialize()
                StreamScript.saveUserInfo()
            }
        }
    }

    TabPageHeader {
        id: mainPageHeader
        listView: mainView
        iconArray: [Qt.resolvedUrl("Image/home.svg"), Qt.resolvedUrl("Image/mail.svg"),
            Qt.resolvedUrl("Image/inbox.svg")]
    }

    UserStream {
        id: userStream
        networkAccessManager: QMLUtils.networkAccessManager()
        onDataRecieved: StreamScript.streamRecieved(rawData)
        onDisconnected: StreamScript.reconnectStream(statusCode, errorText)
        // make sure missed tweets is loaded after connected
        onConnectedChanged: if (connected) StreamScript.refreshAll()

        property bool firstStart: true

        Timer {
            id: reconnectTimer
            interval: 30000
            onTriggered: {
                StreamScript.log("Timer triggered, connecting to user stream")
                if (userStream.firstStart) {
                    interval = 5000
                    userStream.firstStart = false
                }
                var obj = Twitter.getUserStreamURLAndHeader()
                userStream.connectToStream(obj.url, obj.header)
            }
        }

        Timer {
            id: timeOutTimer
            interval: 90000 // 90 seconds as describe in <https://dev.twitter.com/docs/streaming-apis/connecting>
            running: userStream.connected
            onTriggered: {
                reconnectTimer.interval = 5000
                StreamScript.log("Timeout error, disconnect and reconnect in "+reconnectTimer.interval/1000+"s")
                userStream.disconnectFromStream()
                reconnectTimer.restart()
            }
        }

        // connect or disconnect stream when streaming settings is changed
        Connections {
            id: streamingSettingsConnection
            target: null
            onEnableStreamingChanged: {
                if (networkMonitor.online) {
                    if (settings.enableStreaming) {
                        reconnectTimer.interval = userStream.firstStart ? 30000 : 5000
                        StreamScript.log("Streaming enabled by user, connect to streaming in "+reconnectTimer.interval/1000+"s")
                        reconnectTimer.restart()
                    }
                    else {
                        StreamScript.log("Streaming disabled by user, disconnect from streaming")
                        reconnectTimer.stop()
                        userStream.disconnectFromStream()
                    }
                }
            }
        }

        // connect or disconnect stream when networkMonitor.online is changed
        Connections {
            id: onlineConnection
            target: null
            onOnlineChanged: {
                if (settings.enableStreaming) {
                    if (networkMonitor.online) {
                        reconnectTimer.interval = userStream.firstStart ? 30000 : 5000
                        StreamScript.log("App going online, connect to streaming in " + reconnectTimer.interval/1000+"s")
                        reconnectTimer.restart()
                    }
                    else {
                        StreamScript.log("App going offline, disconnect from streaming")
                        reconnectTimer.stop()
                        userStream.disconnectFromStream()
                    }
                }
            }
        }
    }
}
