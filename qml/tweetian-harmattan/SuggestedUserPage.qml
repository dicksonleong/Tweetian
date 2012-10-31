import QtQuick 1.1
import com.nokia.meego 1.0
import "Component"
import "Delegate"
import "twitter.js" as Twitter

Page{
    id: suggestedUserPage

    property string slug: ""

    Component.onCompleted: script.refresh()

    tools: ToolBarLayout{
        ToolIcon{
            id: backButton
            platformIconId: "toolbar-back" + (enabled ? "" : "-dimmed")
            onClicked: pageStack.pop()
        }
    }

    ListView{
        id: suggestedUserView
        anchors{ top: header.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
        delegate: UserDelegate{}
        model: ListModel{}
    }

    ScrollDecorator{ flickableItem: suggestedUserView }

    PageHeader{
        id: header
        headerIcon: "image://theme/icon-m-toolbar-people-white-selected"
        headerText: "Suggested Users"
        countBubbleValue: suggestedUserView.count
        countBubbleVisible: countBubbleValue != 0
        onClicked: suggestedUserView.positionViewAtBeginning()
    }

    WorkerScript{
        id: userParser
        source: "WorkerScript/UserParser.js"
        onMessage: {
            backButton.enabled = true
            header.busy = false
        }
    }

    QtObject{
        id: script

        function refresh(){
            Twitter.getSuggestedUser(slug, onSuccess, onFailure)
            header.busy = true
        }

        function onSuccess(data){
            backButton.enabled = false
            header.headerText += " - " + data.name
            var msg = {
                data: data.users,
                reloadType: "all",
                model: suggestedUserView.model
            }
            userParser.sendMessage(msg)
        }

        function onFailure(status, statusText){
            if(status === 0) infoBanner.alert("Connection error.")
            else infoBanner.alert("Error: " + status + " " + statusText)
            header.busy = false
        }
    }
}
