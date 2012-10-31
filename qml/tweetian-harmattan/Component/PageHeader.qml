import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1

Item{
    id: root

    property url headerIcon: ""
    property string headerText: ""

    property bool busy: false
    property bool countBubbleVisible: false
    property int countBubbleValue: 0

    signal clicked

    implicitHeight: constant.headerHeight
    anchors { top: parent.top; left: parent.left; right: parent.right }

    Image {
        id: background
        anchors.fill: parent
        source: "image://theme/color6-meegotouch-view-header-fixed" + (mouseArea.pressed ? "-pressed" : "")
    }

    Image{
        id: icon
        source: headerIcon
        anchors { verticalCenter: parent.verticalCenter; left: parent.left; margins: constant.paddingLarge }
        sourceSize { height: constant.graphicSizeSmall; width: constant.graphicSizeSmall }
    }

    Text{
        id: mainText
        anchors{
            verticalCenter: parent.verticalCenter
            left: icon.right
            right: busyIndicatorLoader.status === Loader.Ready ? busyIndicatorLoader.left : parent.right
            margins: constant.paddingMedium
        }
        elide: Text.ElideRight
        font.pixelSize: constant.fontSizeLarge
        color: "white"
        text: headerText
    }

    Loader{
        id: busyIndicatorLoader
        anchors{ right: parent.right; rightMargin: constant.paddingXLarge; verticalCenter: parent.verticalCenter }
        sourceComponent: busy ? busyIndicatorComponent : (countBubbleVisible ? countBubbleComponent : undefined)
    }

    Component{
        id: busyIndicatorComponent

        BusyIndicator{
            running: true
        }
    }

    Component{
        id: countBubbleComponent

        CountBubble{
            value: root.countBubbleValue
            largeSized: true
        }
    }

    MouseArea{
        id: mouseArea
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
