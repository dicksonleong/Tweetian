import QtQuick 1.1
import com.nokia.symbian 1.1
import "twitter.js" as Twitter
import "Component"
import "ListPageCom"

Page{
    id: listPage

    property string listName: ""
    property string listId: ""
    property string listDescription: ""
    property string ownerScreenName: ""
    property int memberCount: 0
    property int subscriberCount: 0
    property bool protectedList: false
    property bool followingList: false
    property url ownerProfileImageUrl: ""

    onOwnerProfileImageUrlChanged: listInfo.initialize()

    tools: ToolBarLayout{
        ToolButtonWithTip{
            iconSource: "toolbar-back"
            toolTipText: "Back"
            onClicked: pageStack.pop()
        }
        ToolButton{
            text: ownerScreenName == settings.userScreenName ? "Delete"
                                                             : followingList ? "Unsubscribe" : "Subscribe"
            platformInverted: settings.invertedTheme
            onClicked: ownerScreenName == settings.userScreenName ? internal.createDeleteListDialogDialog()
                                                                  : internal.createSubscribeDialog()
        }
    }

    ListView{
        id: listPageListView
        anchors { top: pageHeader.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
        highlightRangeMode: ListView.StrictlyEnforceRange
        snapMode: ListView.SnapOneItem
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        model: VisualItemModel{
            ListInfo{ id: listInfo }
            ListTimeline{ id: listTimeline }
            ListMembers{ id: listMembers }
            ListSubscribers{ id: listSubscribers }
        }
        onCurrentIndexChanged: if(currentItem.refresh && !currentItem.dataLoaded) currentItem.refresh("all")
        onMovementStarted: paneIndicator.show()
        onMovementEnded: paneIndicator.hide()
    }

    PaneIndicator{
        id: paneIndicator
        listView: listPageListView
    }

    LargePageHeader{
        id: pageHeader
        primaryText: listName
        secondaryText: "By @" + ownerScreenName
        imageSource: ownerProfileImageUrl
        showProtectedIcon: protectedList
        onClicked: listPageListView.currentItem.positionAtTop()
    }

    QtObject{
        id: internal

        function subscribeOnSuccess(data){
            followingList = true
            infoBanner.alert("You have subscribed to the list <b>" + data.name + "</b> successfully.")
            loadingRect.visible = false
        }

        function unsubscribeOnSuccess(data){
            followingList = false
            infoBanner.alert("You have unsubscribed from the list <b>" + data.name + "</b> successfully.")
            loadingRect.visible = false
        }

        function deleteListOnSuccess(data){
            infoBanner.alert("You have deleted the list <b>" + data.name + "</b> successfully.")
            loadingRect.visible = false
            pageStack.pop()
        }

        function onFailure(status, statusText){
            if(status === 0) infoBanner.alert("Connection error.")
            else infoBanner.alert("Error: " + status + " " + statusText)
            loadingRect.visible = false
        }

        function createSubscribeDialog(){
            var title = followingList ? "Unsubscribe List" : "Subscribe List"
            var message = followingList ? "Do you want to unsubscribe from the list \"" + listName + "\"?"
                                        : "Do you want to subscribe to the list \"" + listName + "\"?"
            dialog.createQueryDialog(title, "", message, function(){
                if(followingList) Twitter.postUnsubscribeList(listId, unsubscribeOnSuccess, onFailure)
                else Twitter.postSubscribeList(listId, subscribeOnSuccess, onFailure)
                loadingRect.visible = true
            })
        }

        function createDeleteListDialogDialog(){
            var icon = settings.invertedTheme ? "image://theme/toolbar-delete_inverse"
                                              : "image://theme/toolbar-delete"
            var message = "Do you want to delete the list \"" + listName + "\"?"
            dialog.createQueryDialog("Delete List", icon, message, function(){
                Twitter.postDeleteList(listId, deleteListOnSuccess, onFailure)
                loadingRect.visible = true
            })
        }
    }
}
