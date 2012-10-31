import QtQuick 1.1
import com.nokia.symbian 1.1

Item{
    id: root

    property string text: ""
    property alias checked: switchItem.checked
    property bool infoButtonVisible: false
    signal infoClicked

    width: parent.width
    height: switchItem.height + 2 * constant.paddingMedium

    Text{
        anchors{
            left: parent.left
            right: infoButtonVisible ? infoIconLoader.left : switchItem.left
            margins: constant.paddingMedium
            verticalCenter: parent.verticalCenter
        }
        font.pixelSize: constant.fontSizeLarge
        maximumLineCount: 2
        color: constant.colorLight
        wrapMode: Text.Wrap
        elide: Text.ElideRight
        text: root.text
    }

    Loader{
        id: infoIconLoader
        anchors.right: switchItem.left
        anchors.rightMargin: constant.paddingMedium
        anchors.verticalCenter: parent.verticalCenter
        sourceComponent: infoButtonVisible ? infoIcon : undefined

        MouseArea{
            anchors.fill: parent
            onClicked: root.infoClicked()
        }
    }

    Component{
        id: infoIcon

        Image{
            source: settings.invertedTheme ? "../Image/info_inverse.png" : "../Image/info.png"
            sourceSize.width: constant.graphicSizeSmall + constant.paddingMedium
            sourceSize.height: constant.graphicSizeSmall + constant.paddingMedium
            cache: false
        }
    }

    Switch{
        id: switchItem
        anchors{ right: parent.right; top: parent.top; margins: constant.paddingMedium }
        platformInverted: settings.invertedTheme
    }
}
