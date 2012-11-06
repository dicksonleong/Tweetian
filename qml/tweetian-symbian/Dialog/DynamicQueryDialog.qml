import QtQuick 1.1
import com.nokia.symbian 1.1

QueryDialog{
    id: root

    property bool __isClosing: false

    platformInverted: settings.invertedTheme
    acceptButtonText: qsTr("Yes")
    rejectButtonText: qsTr("No")

    Component.onCompleted: open()

    onStatusChanged: {
        if(status === DialogStatus.Closing) __isClosing = true
        else if(status === DialogStatus.Closed && __isClosing) root.destroy()
    }
}
