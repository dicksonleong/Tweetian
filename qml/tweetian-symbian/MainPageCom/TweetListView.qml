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
import "../Utils/Calculations.js" as Calculate
import "../database.js" as Database
import "../Component"
import "../Delegate"
import "../Services/Twitter.js" as Twitter

Item{
    id: root
    implicitHeight: mainView.height
    implicitWidth: mainView.width

    property string type //"Timeline" or "Mentions"

    property ListModel model: tweetView.model // strictly read-only

    property bool busy: true
    property int unreadCount: 0

    property string reloadType: "all" //"older", "newer" or "all"
    property bool active: symbian.foreground && mainPage.status === PageStatus.Active &&
                          mainView.currentIndex === (type === "Timeline" ? 0 : 1)

    function initialize(){
        reloadType = "database"
        var tweets = Database.getTweets(type)
        parseData(reloadType, tweets)
        busy = true
    }

    function refresh(type){
        var sinceId = "", maxId = ""
        if(tweetView.count > 0){
            if(type === "newer") sinceId = tweetView.model.get(0).tweetId
            else if(type === "older") maxId = tweetView.model.get(tweetView.count - 1).tweetId
            else if(type === "all") tweetView.model.clear()
        }
        else type = "all"
        reloadType = type
        if(root.type == "Timeline") Twitter.getHomeTimeline(sinceId, Calculate.minusOne(maxId), internal.successCallback, internal.failureCallback)
        else Twitter.getMentions(sinceId, Calculate.minusOne(maxId), internal.successCallback, internal.failureCallback)
        busy = true
    }

    function positionAtTop(){
        tweetView.positionViewAtBeginning()
    }

    function parseData(method, data, updateLastRefreshTime){
        var msg = {
            model: tweetView.model,
            data: data,
            reloadType: method,
            muteString: (type === "Timeline" ? settings.muteString : "")
        }
        tweetParser.sendMessage(msg)
        if(updateLastRefreshTime) tweetView.lastUpdate = new Date().toString()
    }

    AbstractListView{
        id: tweetView

        property bool stayAtCurrentPosition: (userStream.status === 2 && !active) ||
                                             (userStream.status !== 2 && reloadType === "newer")

        anchors.fill: parent
        model: ListModel{}
        delegate: TweetDelegate{}
        header: settings.enableStreaming ? streamingHeader : pullToRefreshHeader
        footer: LoadMoreButton{
            visible: tweetView.count > 0
            enabled: !busy
            onClicked: refresh("older")
        }
        onPullDownRefresh: if(userStream.status === 0) refresh("newer")
        onAtYBeginningChanged: if(atYBeginning) root.unreadCount = 0
        onContentYChanged: refreshUnreadCountTimer.running = true

        Timer{
            id: refreshUnreadCountTimer
            interval: 250
            repeat: false
            onTriggered: root.unreadCount = Math.min(tweetView.indexAt(0, tweetView.contentY + 5) + 1, root.unreadCount)
        }

        Component{ id: pullToRefreshHeader; PullToRefreshHeader{} }
        Component{ id: streamingHeader; StreamingHeader{} }
    }

    ScrollDecorator { platformInverted: settings.invertedTheme; flickableItem: tweetView }

    QtObject{
        id: internal

        function successCallback(data){
            networkMonitor.setToOnline()
            if(reloadType == "newer" || reloadType == "all") {
                parseData(reloadType, data, true)
                if(autoRefreshTimer.running) autoRefreshTimer.restart()
            }
            else parseData(reloadType, data)
        }

        function failureCallback(status, statusText){
            infoBanner.showHttpError(status, statusText)
            busy = false
        }
    }

    // Timer used for refresh the timestamp of every tweet every minute. triggeredOnStart is set to true
    // so that the timestamp is refreshed when the app is switch from background to foreground.
    Timer{
        interval: 60000 // 1 minute
        repeat: true
        running: symbian.foreground
        triggeredOnStart: true
        onTriggered: if(tweetView.count > 0) parseData("time")
    }

    Timer{
        id: autoRefreshTimer
        interval: type == "Timeline" ? settings.timelineRefreshFreq * 60 * 1000
                                     : settings.mentionsRefreshFreq * 60 * 1000
        running: networkMonitor.online && !settings.enableStreaming
        repeat: true
        onTriggered: refresh("newer")
    }

    WorkerScript{
        id: tweetParser
        source: "../WorkerScript/TimelineParser.js"
        onMessage: {
            if(messageObject.type === "newer") {
                if(messageObject.count > 0) {
                    if(tweetView.stayAtCurrentPosition || tweetView.indexAt(0, tweetView.contentY) > 0)
                        unreadCount += messageObject.count
                    if(type === "Mentions" && symbian.foreground && mainPage.status !== PageStatus.Active)
                        infoBanner.alert(qsTr("%n new mention(s)", "", unreadCount))
                }
                if(messageObject.screenNames.length > 0) cache.screenNames = Database.storeScreenNames(messageObject.screenNames)
                busy = false
            }
            else if(messageObject.type === "all" || messageObject.type === "older") {
                if(messageObject.screenNames.length > 0) cache.screenNames = Database.storeScreenNames(messageObject.screenNames)
                busy = false
            }
            else if(messageObject.type === "database") {
                if(tweetView.count > 0) {
                    if(type === "Timeline") tweetView.lastUpdate = Database.getSetting("timelineLastUpdate")
                    else tweetView.lastUpdate = Database.getSetting("mentionsLastUpdate")
                    refresh("newer")
                }
                else refresh("all")
            }
            cache.pushToHashtags(messageObject.hashtags)
        }
    }

    Component.onDestruction: {
        if(type === "Timeline") Database.setSetting({"timelineLastUpdate": tweetView.lastUpdate})
        else Database.setSetting({"mentionsLastUpdate": tweetView.lastUpdate})
        Database.storeTweets(type, tweetView.model)
    }
}
