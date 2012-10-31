import QtQuick 1.1
import com.nokia.symbian 1.1

MenuItem{
    id: root

    property url iconSource: ""

    platformLeftMargin: icon.sourceSize.width + 2 * constant.paddingMedium
    platformInverted: settings.invertedTheme

    Image{
        id: icon
        anchors{ left: parent.left; leftMargin: constant.paddingMedium; verticalCenter: parent.verticalCenter }
        sourceSize.width: constant.graphicSizeSmall
        sourceSize.height: constant.graphicSizeSmall
        source: root.iconSource
    }
}
