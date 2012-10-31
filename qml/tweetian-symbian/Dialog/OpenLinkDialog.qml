import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"

ContextMenu{
    id: root

    property string link
    property bool showAddPageServices: false

    signal addToPocketClicked(string link)
    signal addToInstapaperClicked(string link)

    property bool __isClosing: false

    platformInverted: settings.invertedTheme

    MenuLayout{
        Text{
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: link
            font.italic: true
            font.pixelSize: constant.fontSizeMedium
            color: "LightSeaGreen"
            elide: Text.ElideRight
            maximumLineCount: 2
            wrapMode: Text.WrapAnywhere
        }
        MenuItemWithIcon{
            iconSource: platformInverted ? "../Image/internet_inverse.svg" : "../Image/internet.svg"
            text: "Open link in web browser"
            platformInverted: root.platformInverted
            onClicked: {
                Qt.openUrlExternally(link)
                infoBanner.alert("Launching web browser...")
            }
        }
        MenuItemWithIcon{
            iconSource: "image://theme/qtg_toolbar_copy" + (platformInverted ? "_inverse" : "" )
            text: "Copy link"
            platformInverted: root.platformInverted
            onClicked: {
                clipboard.setText(link)
                infoBanner.alert("Link copied to clipboard.")
            }
        }
        MenuItemWithIcon{
            visible: showAddPageServices
            iconSource: platformInverted ? "../Image/web_page_inverse.svg" : "../Image/web_page.svg"
            text: "Send to Pocket"
            onClicked: addToPocketClicked(link)
        }
        MenuItemWithIcon{
            visible: showAddPageServices
            iconSource: platformInverted ? "../Image/web_page_inverse.svg" : "../Image/web_page.svg"
            text: "Send to Instapaper"
            onClicked: addToInstapaperClicked(link)
        }
    }

    Component.onCompleted: open()

    onStatusChanged: {
        if(status === DialogStatus.Closing) __isClosing = true
        else if(status === DialogStatus.Closed && __isClosing) root.destroy()
    }
}
