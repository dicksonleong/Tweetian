import QtQuick 1.1
import com.nokia.symbian 1.1

ListHeading{
    id: root

    property string text: ""

    platformInverted: settings.invertedTheme

    Text{
        id: text
        anchors.fill: parent.paddingItem
        text: root.text
        color: constant.colorLight
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignRight
        font.pixelSize: constant.fontSizeSmall
    }
}
