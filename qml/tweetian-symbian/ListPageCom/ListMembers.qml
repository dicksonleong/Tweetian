import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Delegate"
import "../twitter.js" as Twitter

AbstractListPageItem{
    id: listMembers

    property string nextCursor: "-1"

    width: listPageListView.width
    height: listPageListView.height
    workerScriptSource: "../WorkerScript/UserParser.js"
    headerText: "Members (" + memberCount + ")"
    emptyText: "No member"
    showLoadMoreButton: nextCursor != "0"
    refreshTimeStamp: false
    delegate: UserDelegate{}
    onRefresh: {
        if(type === "newer" || type === "all") {
            reloadType = "all"
            model.clear()
            Twitter.getListMembers(listId, -1, successCallback, failureCallback)
        }
        else {
            reloadType = "older"
            Twitter.getListMembers(listId, nextCursor, successCallback, failureCallback)
        }
    }
    onDataRecieved: {
        nextCursor = data.next_cursor_str
        sendToWorkerScript(data.users)
    }
}
