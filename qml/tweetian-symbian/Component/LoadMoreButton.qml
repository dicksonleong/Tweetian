import QtQuick 1.1
import com.nokia.symbian 1.1

Item{
    id: root

    signal clicked

    implicitWidth: parent.width
    height: visible ? buttonLoader.height + 2 * constant.paddingMedium : 0

    Loader{
        id: buttonLoader
        anchors.centerIn: parent
        sourceComponent: visible ? loadMoreButton : undefined
    }

    Component{
        id: loadMoreButton

        Button{
            text: "Load more"
            width: root.width * 0.75
            platformInverted: settings.invertedTheme
            onClicked: root.clicked()
        }
    }
}
