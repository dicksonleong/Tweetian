import QtQuick 1.1
import com.nokia.meego 1.0

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
            text: qsTr("Load more")
            width: root.width * 0.75
            onClicked: root.clicked()
        }
    }
}
