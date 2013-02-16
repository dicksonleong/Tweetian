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
import "../Component"
import "../Delegate"
import "../Dialog"
import "../Services/Twitter.js" as Twitter

Page {
    id: dMThreadPage

    property QtObject userStream: null

    property string screenName: ""

    Component.onCompleted: internal.insertDMs(mainPage.directMsg.fullModel.count)

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back" + (enabled ? "" : "-dimmed")
            enabled: !internal.workerScriptRunning
            onClicked: pageStack.pop()
        }
        ToolIcon {
            platformIconId: "toolbar-edit"
            onClicked: pageStack.push(Qt.resolvedUrl("../NewTweetPage.qml"), {type: "DM", screenName: screenName})
        }
        ToolIcon {
            platformIconId: "toolbar-refresh" + (enabled ? "" : "-dimmed")
            enabled: !userStream.connected
            onClicked: mainPage.directMsg.refresh("newer")
        }
    }

    PullDownListView {
        id: dMConversationView
        anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        model: ListModel {}
        header: PullToRefreshHeader { visible: !userStream.connected }
        delegate: DirectMsgDelegate {}
        onPulledDown: if (!userStream.connected) mainPage.directMsg.refresh("newer")
    }

    ScrollDecorator { flickableItem: dMConversationView }

    PageHeader {
        id: header
        headerText: qsTr("DM: %1").arg("@" + screenName)
        headerIcon: "../Image/inbox.svg"
        busy: internal.workerScriptRunning || mainPage.directMsg.busy
        onClicked: dMConversationView.positionViewAtBeginning()
    }

    WorkerScript {
        id: dmConversationParser
        source: "../WorkerScript/DMConversationParser.js"
        onMessage: internal.workerScriptRunning = false
    }

    Connections {
        target: mainPage.directMsg
        onDmParsed: {
            internal.insertDMs(newDMCount);
            mainPage.directMsg.setDMThreadReaded(screenName);
        }
        onDmRemoved: internal.removeDM(id)
    }

    QtObject {
        id: internal

        property bool workerScriptRunning: false
        property Component __dmDialog: null

        function deleteDMOnSuccess(data) {
            removeDM(data.id_str)
            mainPage.directMsg.removeDM(data.id_str)
            infoBanner.showText(qsTr("Direct message deleted successfully"))
            header.busy = false
        }

        function deleteDMOnFailure(status, statusText) {
            infoBanner.showHttpError(status, statusText)
            header.busy = false
        }

        function createDMDialog(model) {
            var prop = {
                id: model.id,
                screenName: (model.sentMsg ? settings.userScreenName : model.screenName),
                dmText: model.richText
            }
            if (!__dmDialog) __dmDialog = Qt.createComponent("DMDialog.qml")
            __dmDialog.createObject(dMThreadPage, prop)
        }

        function createDeleteDMDialog(id) {
            var message = qsTr("Do you want to delete this direct message?")
            dialog.createQueryDialog(qsTr("Delete Message"), "", message, function() {
                Twitter.postDeleteDirectMsg(id, deleteDMOnSuccess, deleteDMOnFailure)
                header.busy = true
            })
        }

        function insertDMs(count) {
            var msg = {
                type: "insert",
                fullModel: mainPage.directMsg.fullModel,
                model: dMConversationView.model,
                screenName: screenName,
                count: count
            }
            dmConversationParser.sendMessage(msg)
            workerScriptRunning = true;
        }

        function removeDM(id) {
            var msg = { type: "remove", model: dMConversationView.model, id: id }
            dmConversationParser.sendMessage(msg)
            workerScriptRunning = true;
        }
    }
}
