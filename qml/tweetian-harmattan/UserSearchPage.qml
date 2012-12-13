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
import "Delegate"

Page {
    id: userSearchPage

    property string userSearchQuery
    property int page: 1

    function userSearchOnSuccess(data) {
        backButton.enabled = false
        userSearchParser.sendMessage({"reloadType": "older", "data": data, "model": userSearchListView.model})
    }

    function userSearchOnFailure(status, statusText) {
        infoBanner.showHttpError(status, statusText)
        header.busy = false
    }

    onUserSearchQueryChanged: {
        Twitter.getUserSearch(userSearchQuery, page, userSearchOnSuccess, userSearchOnFailure)
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
        id: userSearchListView
        anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        footer: LoadMoreButton {
            visible: userSearchListView.count > 0 && userSearchListView.count % 20 == 0
            enabled: !header.busy
            onClicked: {
                page++
                Twitter.getUserSearch(userSearchQuery, page, userSearchOnSuccess, userSearchOnFailure)
                header.busy = true
            }
        }

        delegate: UserDelegate {}
        model: ListModel {}
    }

    Text {
        anchors.centerIn: parent
        visible: userSearchListView.count == 0 && !header.busy
        font.pixelSize: constant.fontSizeXXLarge
        color: constant.colorMid
        text: qsTr("No search result")
    }

    ScrollDecorator { flickableItem: userSearchListView }

    PageHeader {
        id: header
        headerIcon: "image://theme/icon-m-toolbar-search-white-selected"
        headerText: qsTr("User Search: %1").arg("\"" + userSearchQuery + "\"")
        onClicked: userSearchListView.positionViewAtBeginning()
    }

    WorkerScript {
        id: userSearchParser
        source: "WorkerScript/UserParser.js"
        onMessage: {
            backButton.enabled = true
            header.busy = false
        }
    }
}
