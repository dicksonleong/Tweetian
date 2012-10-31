import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"
import "../Delegate"
import "../Dialog"
import "../twitter.js" as Twitter

Page{
    id: dMThreadPage

    property QtObject userStream: null

    property string screenName: ""
    property WorkerScript parser: dMConversationParser

    onScreenNameChanged: if(parser) parser.insert(mainPage.directMsg.fullModel.count) // Qt 4.7.4 compatibility
    Component.onCompleted: if(screenName) parser.insert(mainPage.directMsg.fullModel.count)

    tools: ToolBarLayout{
        ToolButtonWithTip{
            id: backButton
            iconSource: "toolbar-back"
            toolTipText: "Back"
            onClicked: pageStack.pop()
        }
        ToolButtonWithTip{
            iconSource: platformInverted ? "../Image/edit_inverse.svg" : "../Image/edit.svg"
            toolTipText: "New DM"
            onClicked: pageStack.push(Qt.resolvedUrl("../NewTweetPage.qml"),
                                      {type: "DM", screenName: screenName})
        }
        ToolButtonWithTip{
            iconSource: "toolbar-refresh"
            toolTipText: "Refresh"
            opacity: enabled ? 1 : 0.25
            enabled: userStream.status === 0
            onClicked: mainPage.directMsg.refresh("newer")
        }
    }

    AbstractListView{
        id: dMConversationView
        anchors{ top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        model: ListModel{}
        header: PullToRefreshHeader{ visible: userStream.status === 0 }
        delegate: DirectMsgDelegate{}
        onPullDownRefresh: if(userStream.status === 0) mainPage.directMsg.refresh("newer")
    }

    ScrollDecorator { platformInverted: settings.invertedTheme; flickableItem: dMConversationView }

    PageHeader{
        id: header
        headerText: "DM > @" + screenName
        headerIcon: "../Image/inbox.svg"
        busy: mainPage.directMsg.busy
        onClicked: dMConversationView.positionViewAtBeginning()
    }

    WorkerScript{
        id: dMConversationParser
        source: "../WorkerScript/DMConversationParser.js"
        onMessage: backButton.enabled = true

        function insert(count){
            if(count > 0){
                backButton.enabled = false
                var msg = {
                    type: "insert",
                    fullModel: mainPage.directMsg.fullModel,
                    model: dMConversationView.model,
                    screenName: screenName,
                    count: count
                }
                sendMessage(msg)
            }
        }

        function remove(tweetId){
            var msg = {
                type: "remove",
                model: dMConversationView.model,
                tweetId: tweetId
            }
            sendMessage(msg)
        }
    }

    Connections{
        target: mainPage.directMsg
        onDataParsed: if(type === "insert") parser.insert(count)
    }

    QtObject{
        id: internal

        property Component __dmDialog: null

        function deleteDMOnSuccess(data){
            mainPage.directMsg.parser.remove(data.id_str)
            parser.remove(data.id_str)
            infoBanner.alert("Direct message deleted.")
            header.busy = false
        }

        function deleteDMOnFailure(status, statusText){
            if(status === 0) infoBanner.alert("Connection error.")
            else infoBanner.alert("Error: " + status + " " + statusText)
            header.busy = false
        }

        function getAllLinks(text){
            var linksArray = text.match(/href="http[^"]*"/g)
            if(linksArray != null){
                for(var i=0; i < linksArray.length; i++){
                    linksArray[i] = linksArray[i].substring(6, linksArray[i].length - 1)
                }
                return linksArray
            }
            else return []
        }

        function createDMDialog(model){
            var prop = {
                tweetId: model.tweetId,
                screenName: (model.sentMsg ? settings.userScreenName : model.screenName),
                linksArray: getAllLinks(model.tweetText)
            }
            if(!__dmDialog) __dmDialog = Qt.createComponent("DMDialog.qml")
            __dmDialog.createObject(dMThreadPage, prop)
        }

        function createDeleteDMDialog(tweetId){
            var icon = platformInverted ? "image://theme/toolbar-delete_inverse" : "image://theme/toolbar-delete"
            var message = "Do you want to delete this direct message?"
            dialog.createQueryDialog("Delete Message", icon, message, function(){
                Twitter.postDeleteDirectMsg(tweetId, deleteDMOnSuccess, deleteDMOnFailure)
                header.busy = true
            })
        }
    }
}
