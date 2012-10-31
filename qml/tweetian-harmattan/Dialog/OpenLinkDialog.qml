import QtQuick 1.1
import com.nokia.meego 1.0
import "../Component"

ContextMenu{
    id: root

    property string link
    property bool showAddPageServices: false

    signal addToPocketClicked(string link)
    signal addToInstapaperClicked(string link)

    property bool __isClosing: false

    platformTitle: Text{
        id: linkText
        anchors{ left: parent.left; right: parent.right }
        horizontalAlignment: Text.AlignHCenter
        text: link
        font.italic: true
        font.pixelSize: constant.fontSizeMedium
        color: "LightSeaGreen"
        elide: Text.ElideRight
        maximumLineCount: 3
        wrapMode: Text.WrapAnywhere
    }

    MenuLayout{
        MenuItem{
            text: "Open link in web browser"
            onClicked: {
                Qt.openUrlExternally(link)
                infoBanner.alert("Launching web browser...")
            }
        }
        MenuItem{
            text: "Share link"
            onClicked: shareUI.shareLink(link)
        }

        MenuItem{
            text: "Copy link"
            onClicked: {
                clipboard.setText(link)
                infoBanner.alert("Link copied to clipboard.")
            }
            platformStyle: MenuItemStyle{ position: sendToPocketButton.visible ? "vertical-center" : "vertical-bottom" }
        }
        MenuItem{
            id: sendToPocketButton
            visible: showAddPageServices
            text: "Send to Pocket"
            onClicked: addToPocketClicked(link)
        }
        MenuItem{
            id: sendToInstapaperButton
            visible: showAddPageServices
            text: "Send to Instapaper"
            onClicked: addToInstapaperClicked(link)
        }
    }

    Component.onCompleted: open()

    onStatusChanged: {
        if(status === DialogStatus.Closing) __isClosing = true
        else if(status === DialogStatus.Closed && __isClosing) root.destroy(250)
    }
}
