import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog{
    id: root

    property string message: ""
    property bool __isClosing: false

    platformInverted: settings.invertedTheme
    buttonTexts: ["Close"]
    content: Item{
        anchors { left: parent.left; right: parent.right; top: parent.top }
        height: messageText.paintedHeight + messageText.anchors.margins * 2

        Text{
            id: messageText
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: constant.paddingMedium }
            color: constant.colorLight
            font.pixelSize: constant.fontSizeMedium
            text: root.message
            wrapMode: Text.Wrap
            onLinkActivated: Qt.openUrlExternally(link)
        }
    }

    Component.onCompleted: open()

    onStatusChanged: {
        if(status === DialogStatus.Closing) __isClosing = true
        else if(status === DialogStatus.Closed && __isClosing) root.destroy()
    }
}
