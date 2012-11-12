import QtQuick 1.1
import com.nokia.meego 1.0
import "../Delegate"
import "../Services/Twitter.js" as Twitter

AbstractListPageItem{
    id: listSubscribers

    property string nextCursor: "-1"

    width: listPageListView.width
    height: listPageListView.height
    workerScriptSource: "../WorkerScript/UserParser.js"
    headerText: qsTr("Subscribers (%1)").arg(subscriberCount)
    emptyText: qsTr("No subscriber")
    showLoadMoreButton: nextCursor != "0"
    refreshTimeStamp: false
    delegate: UserDelegate{}
    onRefresh: {
        if(type === "newer" || type === "all") {
            reloadType = "all"
            model.clear()
            Twitter.getListSubscribers(listId, -1, successCallback, failureCallback)
        }
        else {
            reloadType = "older"
            Twitter.getListSubscribers(listId, nextCursor, successCallback, failureCallback)
        }
    }
    onDataRecieved: {
        nextCursor = data.next_cursor_str
        sendToWorkerScript(data.users)
    }
}
