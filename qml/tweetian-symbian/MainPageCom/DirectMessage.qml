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
import "../Utils/Database.js" as Database
import "../Services/Twitter.js" as Twitter

Item {
    id: root
    implicitHeight: mainView.height; implicitWidth: mainView.width

    property string reloadType: "all"
    property ListModel fullModel: ListModel {}

    property bool busy: true
    property int unreadCount: 0

    signal dmParsed(int newDMCount)

    function initialize() {
        var msg = {
            type: "database",
            model: fullModel,
            threadModel: directMsgView.model,
            data: Database.getDMs()
        }
        dmParser.sendMessage(msg)
        busy = true
    }

    function insertDM(receivedDM, sentDM) {
        var msg = {
            type: reloadType,
            model: fullModel,
            threadModel: directMsgView.model,
            receivedDM: receivedDM,
            sentDM: sentDM
        }
        dmParser.sendMessage(msg)
        directMsgView.lastUpdate = new Date().toString()
    }

    function removeDM(id) {
        dmParser.sendMessage({type: "delete", model: fullModel, id: id})
    }

    function removeAllDM() {
        reloadType = "all";
        insertDM([], []);
    }

    function positionAtTop() {
        directMsgView.positionViewAtBeginning()
    }

    function refresh(type) {
        var sinceId = ""
        if (directMsgView.count > 0) {
            if (type === "newer") sinceId = fullModel.get(0).id
            else if (type === "all") directMsgView.model.clear()
        }
        else type = "all"
        reloadType = type
        Twitter.getDirectMsg(sinceId, "", internal.successCallback, internal.failureCallback)
        busy = true
    }

    PullDownListView {
        id: directMsgView
        anchors.fill: parent
        header: settings.enableStreaming ? streamingHeader : pullToRefreshHeader
        delegate: DMThreadDelegate {}
        model: ListModel {}
        onPulledDown: if (userStream.status === 0) refresh("newer")

        Component { id: pullToRefreshHeader; PullToRefreshHeader {} }
        Component { id: streamingHeader; StreamingHeader {} }
    }

    Text {
        anchors.centerIn: parent
        visible: directMsgView.count == 0 && !busy
        font.pixelSize: constant.fontSizeXXLarge
        color: constant.colorMid
        text: qsTr("No message")
    }

    ScrollDecorator { platformInverted: settings.invertedTheme; flickableItem: directMsgView }

    Timer {
        id: refreshTimeStampTimer
        interval: 60000
        repeat: true
        running: symbian.foreground
        triggeredOnStart: true
        onTriggered: if (directMsgView.count > 0) internal.refreshDMTime()
    }

    Timer {
        id: autoRefreshTimer
        interval: settings.directMsgRefreshFreq * 60000
        repeat: true
        running: networkMonitor.online && !settings.enableStreaming
        onTriggered: refresh("newer")
    }

    WorkerScript {
        id: dmParser
        source: "../WorkerScript/DMParser.js"
        onMessage: internal.onParseComplete(messageObject.type, messageObject.newDMCount,
                                            messageObject.showNotification)
    }

    QtObject {
        id: internal

        function setDMThreadReaded(index) {
            dmParser.sendMessage({type: "setReaded", index: index, threadModel: directMsgView.model})
        }

        function refreshDMTime() {
            dmParser.sendMessage({type: "time", threadModel: directMsgView.model})
        }

        function successCallback(dmRecieve, dmSent) {
            insertDM(dmRecieve, dmSent)
            if (autoRefreshTimer.running) autoRefreshTimer.restart()
        }

        function failureCallback(status, statusText) {
            infoBanner.showHttpError(status, statusText)
            busy = false
        }

        function onParseComplete(type, newDMCount, showNotification) {
            if (type === "newer") {
                if (showNotification) {
                    unreadCount += count
                    if (symbian.foreground && mainPage.status !== PageStatus.Active)
                        infoBanner.showText(qsTr("%n new message(s)", "", unreadCount))
                }
                busy = false
            }
            else if (type === "all") {
                busy = false
            }
            else if (type == "database") {
                if (fullModel.count > 0) {
                    directMsgView.lastUpdate = Database.getSetting("directMsgLastUpdate")
                    refresh("newer")
                }
                else {
                    refresh("all")
                }
            }
        }
    }

    Component.onDestruction: {
        Database.setSetting({"directMsgLastUpdate": directMsgView.lastUpdate})
        Database.storeDMs(fullModel)
    }
}
