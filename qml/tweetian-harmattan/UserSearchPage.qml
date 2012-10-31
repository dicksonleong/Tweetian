import QtQuick 1.1
import com.nokia.meego 1.0
import "twitter.js" as Twitter
import "Component"
import "Delegate"

Page{
    id: userSearchPage

    property string userSearchQuery
    property int page: 1

    function userSearchOnSuccess(data){
        backButton.enabled = false
        userSearchParser.sendMessage({"reloadType": "older", "data": data, "model": userSearchListView.model})
    }

    function userSearchOnFailure(status, statusText){
        if(status == 0) infoBanner.alert("Connection error.")
        else infoBanner.alert("Error:" +status+" "+statusText)
        header.busy = false
    }

    onUserSearchQueryChanged: {
        Twitter.getUserSearch(userSearchQuery, page, userSearchOnSuccess, userSearchOnFailure)
        header.busy = true
    }

    tools: ToolBarLayout{
        ToolIcon{
            id: backButton
            platformIconId: "toolbar-back" + (enabled ? "" : "-dimmed")
            onClicked: pageStack.pop()
        }
    }

    ListView{
        id: userSearchListView
        anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        footer: LoadMoreButton{
            visible: userSearchListView.count > 0 && userSearchListView.count % 20 == 0
            enabled: !header.busy
            onClicked: {
                page++
                Twitter.getUserSearch(userSearchQuery, page, userSearchOnSuccess, userSearchOnFailure)
                header.busy = true
            }
        }

        delegate: UserDelegate{}
        model: ListModel{}
    }

    Text{
        anchors.centerIn: parent
        font.pixelSize: constant.fontSizeXXLarge
        color: constant.colorMid
        text: "No search result"
        visible: userSearchListView.count == 0 && !header.busy
    }

    ScrollDecorator{ flickableItem: userSearchListView }

    PageHeader{
        id: header
        headerIcon: "image://theme/icon-m-toolbar-search-white-selected"
        headerText: "User Search: \"" + userSearchQuery + "\""
        onClicked: userSearchListView.positionViewAtBeginning()
    }

    WorkerScript{
        id: userSearchParser
        source: "WorkerScript/UserParser.js"
        onMessage: {
            backButton.enabled = true
            header.busy = false
        }
    }
}
