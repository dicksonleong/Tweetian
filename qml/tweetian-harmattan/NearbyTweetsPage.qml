import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.location 1.2
import "twitter.js" as Twitter
import "Utils/Calculations.js" as Calculate
import "Component"
import "Delegate"

Page{
    id: nearbyTweetsPage

    property double latitude
    property double longitude

    Component.onCompleted: positionSource.start()

    tools: ToolBarLayout{
        ToolIcon{
            id: backButton
            platformIconId: "toolbar-back" + (enabled ? "" : "-dimmed")
            onClicked: pageStack.pop()
        }
        ToolIcon{
            platformIconId: "toolbar-view-menu"
            onClicked: menu.open()
        }
    }

    Menu{
        id: menu

        MenuLayout{
            MenuItem{
                text: "Refresh Cache & Location"
                enabled: !header.busy
                onClicked: positionSource.start()
            }
        }
    }

    AbstractListView{
        id: searchListView
        property bool stayAtCurrentPosition: internal.reloadType === "newer"
        anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        footer: LoadMoreButton{
            visible: searchListView.count > 0
            enabled: !header.busy
            onClicked: internal.refresh("older")
        }
        delegate: TweetDelegate{}
        model: ListModel{}
        onPullDownRefresh: internal.refresh("newer")
        onAtYBeginningChanged: if(atYBeginning) header.countBubbleValue = 0
        onContentYChanged: refreshUnreadCountTimer.running = true

        Timer{
            id: refreshUnreadCountTimer
            interval: 250
            repeat: false
            onTriggered: header.countBubbleValue = Math.min(searchListView.indexAt(0, searchListView.contentY + 5) + 1,
                                                            header.countBubbleValue)
        }
    }

    Text{
        anchors.centerIn: parent
        font.pixelSize: constant.fontSizeXXLarge
        color: constant.colorMid
        text: "No tweet"
        visible: searchListView.count == 0 && !header.busy
    }

    ScrollDecorator{ flickableItem: searchListView }

    PageHeader{
        id: header
        headerIcon: "image://theme/icon-m-common-location-inverse"
        headerText: positionSource.active ? "Getting location..." : "Nearby Tweets"
        countBubbleVisible: true
        onClicked: searchListView.positionViewAtBeginning()
    }

    WorkerScript{
        id: searchParser
        source: "WorkerScript/SearchParser.js"
        onMessage: {
            if(internal.reloadType === "newer") header.countBubbleValue = messageObject.count
            backButton.enabled = true
            header.busy = false
        }
    }

    PositionSource{
        id: positionSource
        updateInterval: 1000
        onActiveChanged: if(active) header.busy = true

        onPositionChanged: {
            nearbyTweetsPage.latitude = position.coordinate.latitude
            nearbyTweetsPage.longitude = position.coordinate.longitude
            stop()
            internal.refresh("all")
        }

        Component.onDestruction: stop()
    }

    QtObject{
        id: internal

        property string reloadType: "all"

        function refresh(type){
            var sinceId = "", maxId = ""
            if(searchListView.count > 0){
                if(type === "newer") sinceId = searchListView.model.get(0).tweetId
                else if(type === "older") maxId =  searchListView.model.get(searchListView.count - 1).tweetId
                else if(type === "all") searchListView.model.clear()
            }
            else type = "all"
            internal.reloadType = type
            Twitter.getNearbyTweets(latitude, longitude, sinceId, Calculate.minusOne(maxId), onSuccess, onFailure)
            header.busy = true
        }

        function onSuccess(data){
            if(reloadType != "older") searchListView.lastUpdate = new Date().toString()
            backButton.enabled = false
            searchParser.sendMessage({'model': searchListView.model, 'data': data, 'reloadType': reloadType})
        }

        function onFailure(status, statusText){
            if(status === 0) infoBanner.alert("Connection error.")
            else infoBanner.alert("Error:" + status + " " + statusText)
            header.busy = false
        }
    }
}
