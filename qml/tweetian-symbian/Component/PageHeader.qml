import QtQuick 1.1
import com.nokia.symbian 1.1

Item{
    id: root

    property url headerIcon: ""
    property string headerText: ""

    property bool busy: false
    property int countBubbleValue: 0
    property bool countBubbleVisible: false

    signal clicked

    implicitHeight: constant.headerHeight
    anchors { top: parent.top; left: parent.left; right: parent.right }

    Image {
        id: background
        anchors.fill: parent
        source: mouseArea.pressed ? "../Image/header-pressed.png" : "../Image/header.png"
    }

    Image{
        anchors { top: parent.top; left: parent.left }
        source: "../Image/meegoTLCorner.png"
    }

    Image{
        anchors { top: parent.top; right: parent.right }
        source: "../Image/meegoTRCorner.png"
    }

    Image{
        id: icon
        source: headerIcon
        anchors { verticalCenter: parent.verticalCenter; left: parent.left; margins: constant.paddingMedium }
        sourceSize { height: constant.graphicSizeSmall; width: constant.graphicSizeSmall }
    }

    Text{
        anchors{
            left: icon.right
            right: busyIndicatorLoader.status == Loader.Ready ? busyIndicatorLoader.left : parent.right
            verticalCenter: parent.verticalCenter
            margins: constant.paddingMedium
        }
        elide: Text.ElideRight
        font.pixelSize: constant.fontSizeLarge
        color: "white"
        text: headerText
    }

    Loader{
        id: busyIndicatorLoader
        anchors { right: parent.right; rightMargin: constant.paddingMedium; verticalCenter: parent.verticalCenter }
        sourceComponent: busy ? busyIndicatorComponent : (countBubbleVisible ? countBubbleComponent : undefined)
    }

    Component{
        id: busyIndicatorComponent

        BusyIndicator{
            anchors.centerIn: parent
            running: true
            height: constant.graphicSizeSmall + constant.paddingSmall
            width: constant.graphicSizeSmall + constant.paddingSmall
        }

    }

    Component{
        id: countBubbleComponent

        CountBubble{
            value: root.countBubbleValue
        }
    }

    MouseArea{
        id: mouseArea
        anchors.fill: parent
        onClicked: root.clicked()
        onPressed: basicHapticEffect.play()
        onReleased: basicHapticEffect.play()
    }
}
