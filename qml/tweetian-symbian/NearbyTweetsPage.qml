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
import QtMobility.location 1.2
import "Services/Twitter.js" as Twitter
import "Utils/Calculations.js" as Calculate
import "Component"
import "Delegate"

Page {
    id: nearbyTweetsPage

    property double latitude
    property double longitude

    Component.onCompleted: positionSource.start()

    tools: ToolBarLayout {
        ToolButtonWithTip {
            id: backButton
            iconSource: "toolbar-back"
            opacity: enabled ? 1 : 0.25
            toolTipText: qsTr("Back")
            onClicked: pageStack.pop()
        }
        ToolButtonWithTip {
            iconSource: "toolbar-menu"
            toolTipText: qsTr("Menu")
            onClicked: menu.open()
        }
    }

    Menu {
        id: menu
        platformInverted: settings.invertedTheme

        MenuLayout {
            MenuItem {
                text: qsTr("Refresh Cache & Location")
                platformInverted: menu.platformInverted
                enabled: !header.busy
                onClicked: positionSource.start()
            }
        }
    }

    PullDownListView {
        id: searchListView
        property bool stayAtCurrentPosition: internal.reloadType === "newer"
        anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        enabled: !header.busy || count > 0
        footer: LoadMoreButton {
            visible: searchListView.count > 0
            enabled: !header.busy
            onClicked: internal.refresh("older")
        }
        delegate: TweetDelegate {}
        model: ListModel {}
        onPulledDown: internal.refresh("newer")
        onAtYBeginningChanged: if (atYBeginning) header.countBubbleValue = 0
        onContentYChanged: refreshUnreadCountTimer.running = true

        Timer {
            id: refreshUnreadCountTimer
            interval: 250
            repeat: false
            onTriggered: header.countBubbleValue = Math.min(searchListView.indexAt(0, searchListView.contentY + 5) + 1,
                                                            header.countBubbleValue)
        }
    }

    Text {
        anchors.centerIn: parent
        font.pixelSize: constant.fontSizeXXLarge
        color: constant.colorMid
        text: qsTr("No tweet")
        visible: searchListView.count == 0 && !header.busy
    }

    ScrollDecorator { flickableItem: searchListView }

    PageHeader {
        id: header
        headerIcon: "Image/location_mark.svg"
        headerText: positionSource.active ? qsTr("Getting location...") : qsTr("Nearby Tweets")
        onClicked: searchListView.positionViewAtBeginning()
    }

    WorkerScript {
        id: searchParser
        source: "WorkerScript/SearchParser.js"
        onMessage: {
            backButton.enabled = true
            if (internal.reloadType === "newer") {
                header.countBubbleVisible = true
                header.countBubbleValue = messageObject.count
            }
            else {
                header.countBubbleVisible = false
                header.countBubbleValue = 0
            }
            header.busy = false
        }
    }

    PositionSource {
        id: positionSource
        updateInterval: 1000
        onActiveChanged: if (active) header.busy = true

        onPositionChanged: {
            nearbyTweetsPage.latitude = position.coordinate.latitude
            nearbyTweetsPage.longitude = position.coordinate.longitude
            stop()
            internal.refresh("all")
        }

        Component.onDestruction: stop()
    }

    QtObject {
        id: internal

        property string reloadType: "all"

        function refresh(type) {
            if (searchListView.count <= 0)
                type = "all";
            var sinceId = "", maxId = "";
            switch (type) {
            case "newer": sinceId = searchListView.model.get(0).id; break;
            case "older": maxId =  searchListView.model.get(searchListView.count - 1).id; break;
            case "all": searchListView.model.clear(); break;
            default: throw new Error("Invalid type");
            }
            internal.reloadType = type
            Twitter.getNearbyTweets(latitude, longitude, sinceId, Calculate.minusOne(maxId), onSuccess, onFailure)
            header.busy = true
        }

        function onSuccess(data) {
            if (reloadType != "older") searchListView.lastUpdate = new Date().toString()
            backButton.enabled = false
            searchParser.sendMessage({ type: reloadType, model: searchListView.model, data: data})
        }

        function onFailure(status, statusText) {
            infoBanner.showHttpError(status, statusText)
            header.busy = false
        }
    }
}
