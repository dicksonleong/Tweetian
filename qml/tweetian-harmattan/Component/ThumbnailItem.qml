import QtQuick 1.1
import com.nokia.meego 1.0

Item{
    id: root

    property url imageSource: ""
    property url iconSource: ""
    signal clicked

    width: constant.thumbnailSize
    height: constant.thumbnailSize
    clip: true

    Image{
        id: mainImage
        anchors.centerIn: parent
        source: root.imageSource
        fillMode: Image.PreserveAspectCrop
        height: parent.height
        width: parent.width
    }

    Loader{
        anchors.centerIn: parent
        sourceComponent: {
            switch(mainImage.status){
            case Image.Loading:
                return loading
            case Image.Ready:
                return undefined
            case Image.Null:
            case Image.Error:
                return iconImage
            }
        }
    }

    Component{
        id: loading
        BusyIndicator{
            running: true
            width: constant.graphicSizeSmall
            height: constant.graphicSizeSmall
        }
    }

    Component{
        id: iconImage
        Image{
            source: root.iconSource
            sourceSize.width: constant.graphicSizeMedium
            sourceSize.height: constant.graphicSizeMedium
        }
    }

    MouseArea{
        id: imagePress
        anchors.fill: parent
        onClicked: root.clicked()
    }

    Rectangle{
        id: cover
        anchors.fill: parent
        color: "transparent"
        border.width: constant.paddingSmall
        border.color: imagePress.pressed ? constant.colorTextSelection : constant.colorMid
    }
}
