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
    id: suggestedUserPage

    property string slug: ""

    Component.onCompleted: script.refresh()

    tools: ToolBarLayout {
        ToolIcon {
            id: backButton
            platformIconId: "toolbar-back" + (enabled ? "" : "-dimmed")
            onClicked: pageStack.pop()
        }
    }

    ListView {
        id: suggestedUserView
        anchors { top: header.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
        delegate: UserDelegate {}
        model: ListModel {}
    }

    ScrollDecorator { flickableItem: suggestedUserView }

    PageHeader {
        id: header
        headerIcon: "image://theme/icon-m-toolbar-people-white-selected"
        headerText: qsTr("Suggested Users")
        countBubbleValue: suggestedUserView.count
        countBubbleVisible: countBubbleValue != 0
        onClicked: suggestedUserView.positionViewAtBeginning()
    }

    WorkerScript {
        id: userParser
        source: "WorkerScript/UserParser.js"
        onMessage: {
            backButton.enabled = true
            header.busy = false
        }
    }

    QtObject {
        id: script

        function refresh() {
            Twitter.getSuggestedUser(slug, onSuccess, onFailure)
            header.busy = true
        }

        function onSuccess(data) {
            backButton.enabled = false
            header.headerText += ": " + data.name
            var msg = {
                type: "all",
                data: data.users,
                model: suggestedUserView.model
            }
            userParser.sendMessage(msg)
        }

        function onFailure(status, statusText) {
            infoBanner.showHttpError(status, statusText)
            header.busy = false
        }
    }
}
