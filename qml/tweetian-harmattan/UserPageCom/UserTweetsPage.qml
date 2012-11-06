import QtQuick 1.1
import com.nokia.meego 1.0
import "../Delegate"
import "../twitter.js" as Twitter

AbstractUserPage{
    id: userTweetsPage

    headerText: qsTr("Tweets")
    headerNumber: userInfoData.statusesCount
    emptyText: qsTr("No tweet")
    loadMoreButtonVisible: listView.count > 0 && listView.count % 50 === 0
    delegate: TweetDelegate{}

    onReload: {
        var maxId = ""
        if(reloadType === "all") listView.model.clear()
        else maxId = listView.model.get(listView.count - 1).tweetId

        Twitter.getUserTweets(userInfoData.screenName, maxId,
        function(data){
            backButtonEnabled = false
            userTweetsParser.sendMessage({'model': listView.model, 'data': data, 'reloadType': reloadType})
        },
        function(status, statusText){
            infoBanner.showHttpError(status, statusText)
            loadingRect.visible = false
        })
        loadingRect.visible = true
    }

    WorkerScript{
        id: userTweetsParser
        source: "../WorkerScript/TimelineParser.js"
        onMessage: {
            backButtonEnabled = true
            loadingRect.visible = false
        }
    }
}
