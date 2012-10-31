import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1

Item{
    id: root

    property bool marginLineVisible: true
    property bool subItemIndicator: false
    property bool imageAnchorAtCenter: false
    property url imageSource: ""

    // READ-ONLY
    property Item imageItem: imageLoader
    property int listItemRightMargin: subItemIndicator ? iconLoader.width + iconLoader.anchors.rightMargin : 0

    signal clicked
    signal pressAndHold

    implicitWidth: parent.width
    implicitHeight: imageAnchorAtCenter ? 0 : imageLoader.height + 2 * imageLoader.anchors.margins

    Image {
        id: background
        anchors.fill: parent
        visible: mouseArea.pressed
        source: settings.invertedTheme ? "image://theme/meegotouch-panel-background-pressed"
                                       : "image://theme/meegotouch-panel-inverted-background-pressed"
    }

    Loader {
        id: iconLoader
        anchors {
            right: parent.right
            rightMargin: constant.paddingMedium
            verticalCenter: parent.verticalCenter
        }
        sourceComponent: root.subItemIndicator ? subItemIcon : undefined
    }

    Component {
        id: subItemIcon

        Image {
            source: "image://theme/icon-m-common-drilldown-arrow"
            .concat(settings.invertedTheme ? "" : "-inverse").concat(root.enabled ? "" : "-disabled")
            sourceSize.width: constant.graphicSizeSmall
            sourceSize.height: constant.graphicSizeSmall
        }
    }

    Loader{
        id: imageLoader
        anchors.left: parent.left
        anchors.top: imageAnchorAtCenter ? undefined : parent.top
        anchors.verticalCenter: imageAnchorAtCenter ? parent.verticalCenter : undefined
        anchors.margins: constant.paddingMedium
        sourceComponent: imageSource ? imageComponent : undefined
    }

    Component{
        id: imageComponent

        MaskedItem{
            id: pic
            width: constant.graphicSizeMedium
            height: constant.graphicSizeMedium
            mask: Image{ source: "../Image/pic_mask.png"}

            Image{
                id: profileImage
                anchors.fill: parent
                source: root.imageSource
                sourceSize.width: parent.width
                sourceSize.height: parent.height
            }
        }
    }

    Rectangle{
        id: bottomLine
        height: 1
        anchors { left: root.left; right: root.right; bottom: parent.bottom }
        color: constant.colorDisabled
        visible: root.marginLineVisible
    }

    MouseArea{
        id: mouseArea
        anchors.fill: parent
        onClicked: root.clicked()
        onPressAndHold: root.pressAndHold()
    }

    ListView.onAdd: NumberAnimation{
        target: root
        property: "scale"
        duration: 250
        easing.type: Easing.OutBack
        from: 0.25; to: 1
    }

    ListView.onRemove: SequentialAnimation{
        PropertyAction { target: root; property: "ListView.delayRemove"; value: true }
        NumberAnimation {
            target: root
            property: "scale"
            duration: 250
            easing.type: Easing.InBack
            from: 1; to: 0.25
        }
        PropertyAction { target: root; property: "ListView.delayRemove"; value: false }
    }
}
