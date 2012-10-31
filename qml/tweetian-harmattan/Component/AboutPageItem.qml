import QtQuick 1.1
import com.nokia.meego 1.0

ListItem{
    id: root

    property string text: ""

    marginLineVisible: false
    subItemIndicator: true
    imageAnchorAtCenter: true
    height: imageItem.height + 2 * constant.paddingXXLarge

    Text{
        anchors{ left: imageItem.right; leftMargin: constant.paddingMedium; verticalCenter: parent.verticalCenter }
        font.pixelSize: constant.fontSizeMedium
        color: constant.colorLight
        text: root.text
    }
}
