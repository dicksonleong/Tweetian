import QtQuick 1.1
import com.nokia.meego 1.0
import "../Component"
import "../Delegate"
import "../Dialog"
import "../twitter.js" as Twitter

Page{
    id: dMThreadPage

    property QtObject userStream: null

    property string screenName: ""
    property WorkerScript parser: dMConversationParser

    Component.onCompleted: parser.insert(mainPage.directMsg.fullModel.count)

    tools: ToolBarLayout{
        ToolIcon{
            id: backButton
            platformIconId: "toolbar-back" + (enabled ? "" : "-dimmed")
            onClicked: pageStack.pop()
        }
        ToolIcon{
            platformIconId: "toolbar-edit"
            onClicked: pageStack.push(Qt.resolvedUrl("../NewTweetPage.qml"), {type: "DM", screenName: screenName})
        }
        ToolIcon{
            platformIconId: "toolbar-refresh" + (enabled ? "" : "-dimmed")
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

    ScrollDecorator{ flickableItem: dMConversationView }

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
            if(status == 0) infoBanner.alert("Connection error.")
            else infoBanner.alert("Error: " + status + " " + statusText)
            header.busy = false
        }

        function getAllLinks(text){
            var linksArray = text.match(/href="http[^"]+"/g)
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
            var message = "Do you want to delete this direct message?"
            dialog.createQueryDialog("Delete Message", "", message, function(){
                Twitter.postDeleteDirectMsg(tweetId, deleteDMOnSuccess, deleteDMOnFailure)
                header.busy = true
            })
        }
    }
}
