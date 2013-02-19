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
import "Component"
import "Delegate"
import "Services/Twitter.js" as Twitter

Page {
    id: browseUsersPage

    property variant userIdsArray

    property alias headerText: header.headerText
    property alias headerCount: header.countBubbleValue
    property alias headerIcon: header.headerIcon

    Component.onCompleted: {
        if (userIdsArray.length === 0) {
            noUserText.visible = true;
            return;
        }

        Twitter.getUserLookup(userIdsArray.join(","), function(data) {
            var obj = { type: "all", data: data, model: usersListView.model }
            usersParser.sendMessage(obj)
        }, function(status, statusText) {
            infoBanner.showHttpError(status, statusText)
            header.busy = false
        })
        header.busy = true
    }

    tools: ToolBarLayout {
        ToolIcon {
            id: backButton
            platformIconId: "toolbar-back" + (enabled ? "" : "-dimmed")
            onClicked: pageStack.pop()
        }
    }

    ListView {
        id: usersListView
        anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        delegate: UserDelegate {}
        model: ListModel {}
    }

    Text {
        id: noUserText
        anchors.centerIn: parent
        visible: false
        font.pixelSize: constant.fontSizeXXLarge
        color: constant.colorMid
        text: qsTr("No user")
    }

    ScrollDecorator { flickableItem: usersListView }

    PageHeader {
        id: header
        countBubbleVisible: true
        onClicked: usersListView.positionViewAtBeginning()
    }

    WorkerScript {
        id: usersParser
        source: "WorkerScript/UserParser.js"
        onMessage: {
            backButton.enabled = true
            header.busy = false
        }
    }
}
