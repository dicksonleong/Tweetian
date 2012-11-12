import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Delegate"
import "../Services/Twitter.js" as Twitter

AbstractUserPage{
    id: userFavouritesPage

    headerText: qsTr("Favourites")
    headerNumber: userInfoData.favouritesCount
    emptyText: qsTr("No favourite")
    loadMoreButtonVisible: listView.count > 0 && listView.count % 50 === 0
    delegate: TweetDelegate{}

    onReload: {
        var maxId = ""
        if(reloadType === "all") listView.model.clear()
        else maxId = listView.model.get(listView.count - 1).tweetId

        Twitter.getUserFavourites(userInfoData.screenName, maxId,
        function(data){
            backButtonEnabled = false
            userFavouritesParser.sendMessage({'model': listView.model, 'data': data, 'reloadType': reloadType})
        },
        function(status, statusText){
            infoBanner.showHttpError(status, statusText)
            loadingRect.visible = false
        })
        loadingRect.visible = true
    }

    WorkerScript{
        id: userFavouritesParser
        source: "../WorkerScript/TimelineParser.js"
        onMessage: {
            backButtonEnabled = true
            loadingRect.visible = false
        }
    }
}
