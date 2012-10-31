import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"

ContextMenu{
    id: root

    property string screenName: ""
    property string tweetId
    property variant linksArray: []

    property bool __isClosing: false

    platformInverted: settings.invertedTheme

    MenuLayout{
        id: menuLayout
        MenuItemWithIcon{
            iconSource: platformInverted ? "image://theme/toolbar-delete_inverse" : "image://theme/toolbar-delete"
            text: "Delete"
            onClicked: internal.createDeleteDMDialog(tweetId)
        }
        MenuItemWithIcon{
            iconSource: platformInverted ? "../Image/contacts_inverse.svg" : "../Image/contacts.svg"
            text: "<font color=\"LightSeaGreen\">@" + screenName + "</font> Profile"
            visible: screenName != ""
            onClicked: pageStack.push(Qt.resolvedUrl("../UserPage.qml"), {screenName: screenName})
        }
        Repeater{
            model: root.linksArray

            MenuItemWithIcon{
                width: menuLayout.width
                iconSource: platformInverted ? "../Image/internet_inverse.svg" : "../Image/internet.svg"
                text: modelData.substring(modelData.indexOf('://') + 3)
                onClicked: dialog.createOpenLinkDialog(modelData)
            }
        }
    }

    Component.onCompleted: open()

    onStatusChanged: {
        if(status === DialogStatus.Closing) __isClosing = true
        else if(status === DialogStatus.Closed && __isClosing) root.destroy()
    }
}

