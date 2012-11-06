import QtQuick 1.1
import com.nokia.symbian 1.1
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
        infoBanner.showHttpError(status, statusText)
        header.busy = false
    }

    onUserSearchQueryChanged: {
        Twitter.getUserSearch(userSearchQuery, page, userSearchOnSuccess, userSearchOnFailure)
        header.busy = true
    }

    tools: ToolBarLayout{
        ToolButtonWithTip{
            id: backButton
            iconSource: "toolbar-back"
            toolTipText: qsTr("Back")
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
        text: qsTr("No search result")
        visible: userSearchListView.count == 0 && !header.busy
    }

    ScrollDecorator{ platformInverted: settings.invertedTheme; flickableItem: userSearchListView }

    PageHeader{
        id: header
        headerIcon: "image://theme/toolbar-search"
        headerText: qsTr("User Search: %1").arg("\"" + userSearchQuery + "\"")
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
