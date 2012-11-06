import QtQuick 1.1
import com.nokia.symbian 1.1

Item{
    id: root
    height: 0
    width: ListView.view.width

    Row{
        id: headerRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.top
        anchors.bottomMargin: constant.paddingXXLarge
        width: childrenRect.width
        visible: root.ListView.view.__wasAtYBeginning && root.ListView.view.__initialContentY - root.ListView.view.contentY > 10
        spacing: constant.paddingLarge

        Loader{
            id: iconLoader
            sourceComponent: userStream.status === 2 ? streamingIcon : pullIcon
        }

        Text{
            font.pixelSize: constant.fontSizeMedium
            color: constant.colorLight
            text: networkMonitor.online ? (userStream.status === 2 ? qsTr("Streaming...") : qsTr("Connecting to streaming"))
                                        : qsTr("Offline")
        }
    }

    Component{
        id: streamingIcon

        Image{
            source: settings.invertedTheme ? "image://theme/toolbar-refresh_inverse"
                                           : "image://theme/toolbar-refresh"
            sourceSize.width: constant.graphicSizeSmall
            sourceSize.height: constant.graphicSizeSmall
            smooth: true

            RotationAnimation on rotation {
                from: 360; to: 0
                duration: 2000
                loops: Animation.Infinite
                running: headerRow.visible
            }
        }
    }

    Component{
        id: pullIcon

        Image{
            source: settings.invertedTheme ? "image://theme/toolbar-next_inverse"
                                           : "image://theme/toolbar-next"
            sourceSize.width: constant.graphicSizeSmall
            sourceSize.height: constant.graphicSizeSmall
            rotation: visible && root.ListView.view.__initialContentY - root.ListView.view.contentY > 100 ? 270 : 90

            Behavior on rotation { NumberAnimation{ duration: 250 } }
        }
    }
}
