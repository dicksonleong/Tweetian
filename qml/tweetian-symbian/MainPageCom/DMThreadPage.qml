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
import "../Component"
import "../Delegate"
import "../Dialog"
import "../Services/Twitter.js" as Twitter

Page{
    id: dMThreadPage

    property QtObject userStream: null

    property string screenName: ""
    property WorkerScript parser: dMConversationParser

    onScreenNameChanged: if(parser) parser.insert(mainPage.directMsg.fullModel.count) // Qt 4.7.4 compatibility
    Component.onCompleted: if(screenName) parser.insert(mainPage.directMsg.fullModel.count)

    tools: ToolBarLayout{
        ToolButtonWithTip{
            id: backButton
            iconSource: "toolbar-back"
            toolTipText: qsTr("Back")
            onClicked: pageStack.pop()
        }
        ToolButtonWithTip{
            iconSource: platformInverted ? "../Image/edit_inverse.svg" : "../Image/edit.svg"
            toolTipText: qsTr("New DM")
            onClicked: pageStack.push(Qt.resolvedUrl("../NewTweetPage.qml"),
                                      {type: "DM", screenName: screenName})
        }
        ToolButtonWithTip{
            iconSource: "toolbar-refresh"
            toolTipText: qsTr("Refresh")
            opacity: enabled ? 1 : 0.25
            enabled: userStream.status === 0
            onClicked: mainPage.directMsg.refresh("newer")
        }
    }

    AbstractListView{
        id: dMConversationView
        anchors{ top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        model: ListModel{}
        header: PullToRefreshHeader{ visible: userStream.status === 0 }
        delegate: DirectMsgDelegate{}
        onPullDownRefresh: if(userStream.status === 0) mainPage.directMsg.refresh("newer")
    }

    ScrollDecorator { platformInverted: settings.invertedTheme; flickableItem: dMConversationView }

    PageHeader{
        id: header
        headerText: qsTr("DM: %1").arg("@" + screenName)
        headerIcon: "../Image/inbox.svg"
        busy: mainPage.directMsg.busy
        onClicked: dMConversationView.positionViewAtBeginning()
    }

    WorkerScript{
        id: dMConversationParser
        source: "../WorkerScript/DMConversationParser.js"
        onMessage: backButton.enabled = true

        function insert(count){
            if(count > 0){
                backButton.enabled = false
                var msg = {
                    type: "insert",
                    fullModel: mainPage.directMsg.fullModel,
                    model: dMConversationView.model,
                    screenName: screenName,
                    count: count
                }
                sendMessage(msg)
            }
        }

        function remove(tweetId){
            var msg = {
                type: "remove",
                model: dMConversationView.model,
                tweetId: tweetId
            }
            sendMessage(msg)
        }
    }

    Connections{
        target: mainPage.directMsg
        onDataParsed: if(type === "insert") parser.insert(count)
    }

    QtObject{
        id: internal

        property Component __dmDialog: null

        function deleteDMOnSuccess(data){
            mainPage.directMsg.parser.remove(data.id_str)
            parser.remove(data.id_str)
            infoBanner.alert(qsTr("Direct message deleted successfully"))
            header.busy = false
        }

        function deleteDMOnFailure(status, statusText){
            infoBanner.showHttpError(status, statusText)
            header.busy = false
        }

        function createDMDialog(model){
            var prop = {
                tweetId: model.tweetId,
                screenName: (model.sentMsg ? settings.userScreenName : model.screenName),
                dmText: model.tweetText
            }
            if(!__dmDialog) __dmDialog = Qt.createComponent("DMDialog.qml")
            __dmDialog.createObject(dMThreadPage, prop)
        }

        function createDeleteDMDialog(tweetId){
            var icon = platformInverted ? "image://theme/toolbar-delete_inverse" : "image://theme/toolbar-delete"
            var message = qsTr("Do you want to delete this direct message?")
            dialog.createQueryDialog(qsTr("Delete Message"), icon, message, function(){
                Twitter.postDeleteDirectMsg(tweetId, deleteDMOnSuccess, deleteDMOnFailure)
                header.busy = true
            })
        }
    }
}
