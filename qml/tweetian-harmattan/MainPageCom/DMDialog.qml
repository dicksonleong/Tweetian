import QtQuick 1.1
import com.nokia.meego 1.0

ContextMenu{
    id: root

    property string screenName: ""
    property string tweetId
    property variant linksArray: []

    property bool __isClosing: false

    MenuLayout{
        id: menuLayout
        MenuItem{
            text: qsTr("Delete")
            onClicked: internal.createDeleteDMDialog(tweetId)
        }
        MenuItem{
            text: qsTr("%1 Profile").arg("<font color=\"LightSeaGreen\">@" + screenName + "</font>")
            visible: screenName != ""
            onClicked: pageStack.push(Qt.resolvedUrl("../UserPage.qml"), {screenName: screenName})
            platformStyle: MenuItemStyle{ position: linksRepeater.count > 0 ? "vertical-center" : "vertical-bottom" }
        }
        Repeater{
            id: linksRepeater
            model: root.linksArray

            MenuItem{
                width: menuLayout.width
                parent: menuLayout
                text: modelData.substring(modelData.indexOf('://') + 3)
                onClicked: dialog.createOpenLinkDialog(modelData)
            }
        }
    }

    Component.onCompleted: open()

    onStatusChanged: {
        if(status === DialogStatus.Closing) __isClosing = true
        else if(status === DialogStatus.Closed && __isClosing) root.destroy(250)
    }
}
