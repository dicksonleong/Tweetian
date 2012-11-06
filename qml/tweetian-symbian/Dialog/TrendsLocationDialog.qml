import QtQuick 1.1
import com.nokia.symbian 1.1

SelectionDialog{
    id: root

    property bool __isClosing: false

    platformInverted: settings.invertedTheme
    titleText: qsTr("Trends Location")
    delegate: MenuItem{
        platformInverted: root.platformInverted
        text: model.name
        onClicked: {
            selectedIndex = index
            accept()
        }

        Image {
            anchors{
                right: parent.right
                rightMargin: constant.paddingMedium
                verticalCenter: parent.verticalCenter
            }
            source: settings.trendsLocationWoeid === model.woeid.toString() ?
                        (platformInverted ? "../Image/selection_indicator_inverse.svg"
                                          : "../Image/selection_indicator.svg") : ""
            sourceSize.height: constant.graphicSizeSmall
            sourceSize.width: constant.graphicSizeSmall
        }
    }

    Component.onCompleted: open()

    onStatusChanged: {
        if(status === DialogStatus.Closing) __isClosing = true
        else if(status === DialogStatus.Closed && __isClosing) root.destroy()
    }
}
