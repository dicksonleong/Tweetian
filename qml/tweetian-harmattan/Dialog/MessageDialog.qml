import QtQuick 1.1
import com.nokia.meego 1.0

CommonDialog{
    id: root

    property string message: ""
    property bool __isClosing: false

    buttonTexts: [qsTr("Close")]
    content: Item{
        anchors {
            left: parent.left
            leftMargin: constant.paddingMedium
            right: parent.right
            rightMargin: constant.paddingMedium
            top: parent.top
            topMargin: root.platformStyle.contentMargin
        }
        height: messageText.paintedHeight + anchors.topMargin * 2

        Text{
            id: messageText
            anchors { left: parent.left; right: parent.right }
            color: "white"
            font.pixelSize: constant.fontSizeMedium
            text: root.message
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            onLinkActivated: Qt.openUrlExternally(link)
        }
    }

    Component.onCompleted: open()

    onStatusChanged: {
        if(status === DialogStatus.Closing) __isClosing = true
        else if(status === DialogStatus.Closed && __isClosing) root.destroy(250)
    }
}
