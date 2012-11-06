import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Delegate"
import "../twitter.js" as Twitter
import "../Utils/Calculations.js" as Calculate

AbstractListPageItem{
    id: listTimeline
    width: listPageListView.width
    height: listPageListView.height
    workerScriptSource: "../WorkerScript/TimelineParser.js"
    headerText: qsTr("List Timeline")
    emptyText: qsTr("No tweet")
    delegate: TweetDelegate{}
    onRefresh: {
        var sinceId = "", maxId = "", mType = type
        if(model.count > 0){
            if(mType === "newer") sinceId = model.get(0).tweetId
            else if(mType === "older") maxId = model.get(model.count - 1).tweetId
            else if(mType === "all") model.clear()
        }
        else mType = "all"
        reloadType = mType
        Twitter.getListTimeline(listId, sinceId, Calculate.minusOne(maxId), successCallback, failureCallback)
    }
    onDataRecieved: sendToWorkerScript(data)
}
