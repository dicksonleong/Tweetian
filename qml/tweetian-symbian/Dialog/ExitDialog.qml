import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog{
    id: root

    property bool __isClosing: false

    platformInverted: settings.invertedTheme
    titleText: qsTr("Exit Tweetian")
    buttonTexts: [qsTr("Exit"), qsTr("Hide"), qsTr("Cancel")]
    content: Text {
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: constant.paddingMedium }
        text: qsTr("Do you want to hide or exit Tweetian?")
        font.pixelSize: constant.fontSizeMedium
        color: constant.colorLight
        wrapMode: Text.Wrap
    }

    onButtonClicked: {
        if(index === 0) Qt.quit()
        else if(index === 1) appQmlView.lower()
    }

    Component.onCompleted: open()

    onStatusChanged: {
        if(status === DialogStatus.Closing) __isClosing = true
        else if(status === DialogStatus.Closed && __isClosing) root.destroy()
    }
}
