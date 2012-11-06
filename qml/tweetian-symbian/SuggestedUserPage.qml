import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "Delegate"
import "twitter.js" as Twitter

Page{
    id: suggestedUserPage

    property string slug: ""

    onSlugChanged: script.refresh()

    tools: ToolBarLayout{
        ToolButtonWithTip{
            id: backButton
            iconSource: "toolbar-back"
            toolTipText: qsTr("Back")
            onClicked: pageStack.pop()
        }
    }

    ListView{
        id: suggestedUserView
        anchors{ top: header.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
        delegate: UserDelegate{}
        model: ListModel{}
    }

    ScrollDecorator{ platformInverted: settings.invertedTheme; flickableItem: suggestedUserView }

    PageHeader{
        id: header
        headerIcon: "Image/people.svg"
        headerText: qsTr("Suggested Users")
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
            infoBanner.showHttpError(status, statusText)
            header.busy = false
        }
    }
}
