import QtQuick 1.1
import "../Utils/Calculations.js" as Calculate

Item{
    id: root
    height: 0
    width: ListView.view.width

    Item{
        id: container
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.top
        anchors.bottomMargin: constant.paddingXXLarge
        height: pullIcon.height
        width: pullIcon.width + textColumn.width + textColumn.anchors.leftMargin
        visible: root.ListView.view.__wasAtYBeginning && root.ListView.view.__initialContentY - root.ListView.view.contentY > 10

        Image{
            id: pullIcon
            anchors.left: parent.left
            source: settings.invertedTheme ? "image://theme/icon-m-toolbar-next" : "image://theme/icon-m-toolbar-next-white-selected"
            sourceSize.width: constant.graphicSizeSmall
            sourceSize.height: constant.graphicSizeSmall
            rotation: visible && root.ListView.view.__initialContentY - root.ListView.view.contentY > 100 ? 270 : 90

            Behavior on rotation { NumberAnimation{ duration: 250 } }
        }

        Column{
            id: textColumn
            width: Math.max(pullText.width, lastUpdateText.width)
            height: childrenRect.height
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: pullIcon.right
            anchors.leftMargin: constant.paddingLarge

            Text{
                id: pullText
                font.pixelSize: constant.fontSizeMedium
                color: constant.colorLight
                text: visible && root.ListView.view.__initialContentY - root.ListView.view.contentY > 100 ?
                          "Release to refresh" : "Pull down to refresh"
            }

            Text{
                id: lastUpdateText
                font.pixelSize: constant.fontSizeSmall
                color: constant.colorMid
                visible: container.visible && root.ListView.view.lastUpdate
                onVisibleChanged: {
                    if(visible) text = "Last update: " + Calculate.timeDiff(root.ListView.view.lastUpdate)
                }
            }
        }
    }
}
