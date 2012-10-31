import QtQuick 1.1
import com.nokia.symbian 1.1

ListItem{
    id: root

    property url imageSource: ""
    property string text: ""

    width: parent.width
    height: pic.height + 2 * constant.paddingMedium
    subItemIndicator: true
    platformInverted: settings.invertedTheme

    Image{
        id: pic
        anchors{ top: parent.top; left: parent.left; margins: constant.paddingMedium }
        source: root.imageSource
        sourceSize.width: constant.graphicSizeMedium
        sourceSize.height: constant.graphicSizeMedium
        cache: false
    }

    Text{
        anchors{ top: parent.top; bottom: parent.bottom; left: pic.right; right: parent.right }
        anchors.margins: constant.paddingMedium
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        font.pixelSize: constant.fontSizeMedium
        color: constant.colorLight
        text: root.text
    }
}
