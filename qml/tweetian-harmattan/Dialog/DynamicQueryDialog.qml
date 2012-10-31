import QtQuick 1.1
import com.nokia.meego 1.0

QueryDialog{
    id: root

    property bool __isClosing: false

    acceptButtonText: "Yes"
    rejectButtonText: "No"

    Component.onCompleted: open()

    onStatusChanged: {
        if(status === DialogStatus.Closing) __isClosing = true
        else if(status === DialogStatus.Closed && __isClosing) root.destroy(250)
    }
}
