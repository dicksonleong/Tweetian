import QtQuick 1.1
import com.nokia.meego 1.0

SelectionDialog{
    id: root

    property bool __isClosing: false

    titleText: "Trends Location"
    model: trendsLocationModel
    onSelectedIndexChanged: settings.trendsLocationWoeid = trendsLocationModel.get(selectedIndex).woeid

    Component.onCompleted:open()

    onStatusChanged: {
        if(status === DialogStatus.Closing) __isClosing = true
        else if(status === DialogStatus.Closed && __isClosing) root.destroy(250)
    }
}
