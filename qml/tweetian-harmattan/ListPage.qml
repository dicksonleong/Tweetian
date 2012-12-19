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
import "ListPageCom"

Page {
    id: listPage

    property string listName: ""
    property string listId: ""
    property string listDescription: ""
    property string ownerScreenName: ""
    property int memberCount: 0
    property int subscriberCount: 0
    property bool protectedList: false
    property bool followingList: false
    property url ownerProfileImageUrl: ""

    onOwnerProfileImageUrlChanged: listInfo.initialize()

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolButton {
            text: ownerScreenName === settings.userScreenName ? qsTr("Delete")
                                                              : followingList ? qsTr("Unsubscribe") : qsTr("Subscribe")
            onClicked: ownerScreenName === settings.userScreenName ? internal.createDeleteListDialogDialog()
                                                                   : internal.createSubscribeDialog()
        }
        Item { width: 80; height: 64 }
    }

    ListView {
        id: listPageListView
        anchors { top: pageHeader.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
        highlightRangeMode: ListView.StrictlyEnforceRange
        snapMode: ListView.SnapOneItem
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        model: VisualItemModel {
            ListInfo { id: listInfo }
            ListTimeline { id: listTimeline }
            ListMembers { id: listMembers }
            ListSubscribers { id: listSubscribers }
        }
        onCurrentIndexChanged: if (currentItem.refresh && !currentItem.dataLoaded) currentItem.refresh("all")
        onMovementStarted: paneIndicator.show()
        onMovementEnded: paneIndicator.hide()
    }

    PaneIndicator {
        id: paneIndicator
        listView: listPageListView
    }

    LargePageHeader {
        id: pageHeader
        primaryText: listName
        secondaryText: qsTr("By %1").arg("@" + ownerScreenName)
        imageSource: ownerProfileImageUrl
        showProtectedIcon: protectedList
        onClicked: listPageListView.currentItem.positionAtTop()
    }

    QtObject {
        id: internal

        function subscribeOnSuccess(data) {
            followingList = true
            infoBanner.showText(qsTr("You have subscribed to the list %1 successfully").arg("<b>"+data.name+"</b>"))
            loadingRect.visible = false
        }

        function unsubscribeOnSuccess(data) {
            followingList = false
            infoBanner.showText(qsTr("You have unsubscribed from the list %1 successfully").arg("<b>"+data.name+"</b>"))
            loadingRect.visible = false
        }

        function deleteListOnSuccess(data) {
            infoBanner.showText(qsTr("You have deleted the list %1 successfully").arg("<b>"+data.name+"</b>"))
            loadingRect.visible = false
            pageStack.pop()
        }

        function onFailure(status, statusText) {
            infoBanner.showHttpError(status, statusText)
            loadingRect.visible = false
        }

        function createSubscribeDialog() {
            var title = followingList ? qsTr("Unsubscribe List") : qsTr("Subscribe List")
            var message = followingList ? qsTr("Do you want to unsubscribe from the list %1?").arg("\""+listName+"\"")
                                        : qsTr("Do you want to subscribe to the list %1?").arg("\""+listName+"\"")
            dialog.createQueryDialog(title, "", message, function() {
                if (followingList) Twitter.postUnsubscribeList(listId, unsubscribeOnSuccess, onFailure)
                else Twitter.postSubscribeList(listId, subscribeOnSuccess, onFailure)
                loadingRect.visible = true
            })
        }

        function createDeleteListDialogDialog() {
            var message = qsTr("Do you want to delete the list %1?").arg("\""+listName+"\"")
            dialog.createQueryDialog(qsTr("Delete List"), "", message, function() {
                Twitter.postDeleteList(listId, deleteListOnSuccess, onFailure)
                loadingRect.visible = true
            })
        }
    }
}
