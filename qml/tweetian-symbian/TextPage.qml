import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"

Page{
    id: textPage

    property alias text: mainText.text
    property string headerText: ""
    property url headerIcon: ""

    tools: ToolBarLayout{
        ToolButtonWithTip{
            iconSource: "toolbar-back"
            toolTipText: "Back"
            onClicked: pageStack.pop()
        }
    }

    Flickable{
        id: textFlickable
        anchors { top: pageHeader.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        flickableDirection: Flickable.VerticalFlick
        contentHeight: mainText.paintedHeight + 2 * mainText.anchors.margins

        Text{
            id: mainText
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: constant.paddingMedium }
            font.pixelSize: constant.fontSizeMedium
            color: constant.colorLight
            wrapMode: Text.Wrap
        }
    }

    ScrollDecorator{ platformInverted: settings.invertedTheme; flickableItem: textFlickable }

    PageHeader{
        id: pageHeader
        headerText: textPage.headerText
        headerIcon: textPage.headerIcon
        onClicked: textFlickable.contentY = 0
    }
}
