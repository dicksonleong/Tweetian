import QtQuick 1.1
import com.nokia.meego 1.0
import "../Utils/Calculations.js" as Calculate
import "../storage.js" as Database
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
    property bool active: platformWindow.active && mainPage.status === PageStatus.Active &&
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

    onUnreadCountChanged: if(unreadCount === 0 && type === "Mentions") notification.clear("tweetian.mention")

    AbstractListView{
        id: tweetView

        property bool stayAtCurrentPosition: (userStream.status === 2 && !active) ||
                                             (userStream.status !== 2 && reloadType === "newer")

        anchors.fill: parent
        model: ListModel{}
        section.property: "timeDiff" // for FastScroll
        delegate: TweetDelegate{}
        header: settings.enableStreaming ? streamingHeader : pullToRefreshHeader
        footer: LoadMoreButton{
            visible: tweetView.count > 0
            enabled: !busy
            onClicked: refresh("older")
        }
        onPullDownRefresh: if(userStream.status === 0) refresh("newer")
        onAtYBeginningChanged: if(atYBeginning) unreadCount = 0
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

    FastScroll{ listView: tweetView }

    QtObject{
        id: internal

        function successCallback(data){
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
        running: platformWindow.active
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
                    if(type === "Mentions" && settings.mentionNotification){
                        var body = qsTr("%n new mention(s)", "", unreadCount)
                        if(!platformWindow.active){
                            notification.clear("tweetian.mention")
                            notification.publish("tweetian.mention", "Tweetian", body, unreadCount)
                        }
                        else if(mainPage.status !== PageStatus.Active){
                            infoBanner.alert(body)
                        }
                    }
                }
                if(messageObject.screenNames.length > 0) cache.screenNames = Database.storeScreenNames(messageObject.screenNames)
                busy = false
            }
            else if(messageObject.type === "all" || messageObject.type === "older") {
                if(messageObject.screenNames.length > 0)cache.screenNames = Database.storeScreenNames(messageObject.screenNames)
                busy = false
            }
            else if(messageObject.type === "database") {
                if(tweetView.count > 0) {
                    tweetView.lastUpdate = type == "Timeline" ? settings.timelineLastUpdate : settings.mentionsLastUpdate
                    refresh("newer")
                }
                else refresh("all")
            }
            cache.pushToHashtags(messageObject.hashtags)
        }
    }

    Component.onDestruction: {
        Database.setSetting([[type == "Timeline" ? "timelineIndex" : "mentionsIndex", tweetView.indexAt(tweetView.contentX, tweetView.contentY)],
                             [type == "Timeline" ? "timelineLastUpdate" : "mentionsLastUpdate", tweetView.lastUpdate]])
        var tweets = []
        for(var i=0; i<Math.min(100, tweetView.count); i++){
            tweets[i] = {
                "tweetId": tweetView.model.get(i).tweetId,
                "retweetId": tweetView.model.get(i).retweetId,
                "displayScreenName": tweetView.model.get(i).displayScreenName,
                "screenName": tweetView.model.get(i).screenName,
                "userName": tweetView.model.get(i).userName,
                "tweetText": tweetView.model.get(i).tweetText,
                "displayTweetText": tweetView.model.get(i).displayTweetText,
                "profileImageUrl": tweetView.model.get(i).profileImageUrl,
                "source": tweetView.model.get(i).source,
                "createdAt": tweetView.model.get(i).createdAt,
                "favourited": tweetView.model.get(i).favourited ? 1 : 0,
                "inReplyToScreenName": tweetView.model.get(i).inReplyToScreenName,
                "inReplyToStatusId": tweetView.model.get(i).inReplyToStatusId,
                "mediaExpandedUrl": tweetView.model.get(i).mediaExpandedUrl,
                "mediaViewUrl": tweetView.model.get(i).mediaViewUrl,
                "mediaThumbnail": tweetView.model.get(i).mediaThumbnail,
                "latitude": tweetView.model.get(i).latitude,
                "longitude": tweetView.model.get(i).longitude
            }
        }
        Database.storeTweets(type,tweets)
    }
}
