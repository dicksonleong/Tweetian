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
    implicitHeight: mainView.height; implicitWidth: mainView.width

    property string reloadType: "all"
    property ListModel fullModel: ListModel {}

    property bool busy: true
    property int unreadCount: 0

    // For DMThreadPage
    signal dmParsed(int newDMCount)
    signal dmRemoved(string id)

    function initialize() {
        var msg = {
            type: "database",
            model: fullModel,
            threadModel: directMsgView.model,
            data: Database.getDMs()
        }
        dmParser.sendMessage(msg)
        busy = true
        directMsgView.lastUpdate = Database.getSetting("directMsgLastUpdate")
    }

    function insertNewDMs(receivedDM, sentDM) {
        var msg = {
            type: "newer",
            model: fullModel,
            threadModel: directMsgView.model,
            receivedDM: receivedDM,
            sentDM: sentDM
        }
        dmParser.sendMessage(msg)
        directMsgView.lastUpdate = new Date().toString()
    }

    function setDMThreadReaded(indexOrScreenName) {
        unreadCount = 0;
        var msg = { type: "setReaded", threadModel: directMsgView.model, index: -1 }
        switch (typeof indexOrScreenName) {
        case "number": msg.index = indexOrScreenName; break;
        case "string": msg.screenName = indexOrScreenName; break;
        default: throw new TypeError();
        }
        dmParser.sendMessage(msg)
    }

    function removeDM(id) {
        dmParser.sendMessage({type: "delete", model: fullModel, id: id})
        dmRemoved(id)
    }

    function removeAllDM() {
        var msg = {
            type: "all",
            model: fullModel,
            threadModel: directMsgView.model,
            receivedDM: [], sentDM: []
        }
        dmParser.sendMessage(msg)
    }

    function positionAtTop() {
        directMsgView.positionViewAtBeginning()
    }

    function refresh(type) {
        if (directMsgView.count <= 0)
            type = "all";
        var sinceId = "";
        switch (type) {
        case "newer": sinceId = fullModel.get(0).id; break;
        case "all": directMsgView.model.clear(); break;
        default: throw new Error("Invalid type");
        }
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
        onPulledDown: if (!userStream.connected) refresh("newer")

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
        interval: settings.autoRefreshInterval * 60000
        repeat: true
        running: networkMonitor.online && !settings.enableStreaming
        onTriggered: refresh("newer")
    }

    WorkerScript {
        id: dmParser
        source: "../WorkerScript/DMParser.js"
        onMessage: internal.onParseComplete(messageObject);
    }

    QtObject {
        id: internal

        function refreshDMTime() {
            dmParser.sendMessage({type: "time", threadModel: directMsgView.model})
        }

        function successCallback(dmRecieve, dmSent) {
            var msg = {
                type: reloadType,
                model: fullModel,
                threadModel: directMsgView.model,
                receivedDM: dmRecieve,
                sentDM: dmSent
            }
            dmParser.sendMessage(msg)
            if (reloadType == "newer" || reloadType == "all") {
                directMsgView.lastUpdate = new Date().toString()
                if (autoRefreshTimer.running) autoRefreshTimer.restart()
            }
        }

        function failureCallback(status, statusText) {
            infoBanner.showHttpError(status, statusText)
            busy = false
        }

        function onParseComplete(msg) {
            switch (msg.type) {
            case "newer":
                if (msg.showNotification) __createNotification(msg.newDMCount);
                dmParsed(msg.newDMCount)
                // fallthrough
            case "all":
                busy = false;
                break;
            case "database":
                refresh("newer");
                break;
            }
        }

        function __createNotification(newDMCount) {
            if (newDMCount <= 0) return;
            unreadCount += newDMCount;

            var message = qsTr("%n new message(s)", "", unreadCount);
            if (symbian.foreground) {
                if (mainPage.status !== PageStatus.Active)
                    infoBanner.showText(body);
            }
            else {
                if (settings.enableNotification)
                    symbianUtils.showNotification("Tweetian", message);
            }
        }
    }

    Component.onDestruction: {
        Database.setSetting({"directMsgLastUpdate": directMsgView.lastUpdate})
        Database.storeDMs(fullModel)
    }
}
