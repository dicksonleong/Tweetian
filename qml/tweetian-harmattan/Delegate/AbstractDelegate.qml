import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1

Item{
    id: root

    property string sideRectColor: ""
    property string imageSource: profileImageUrl

    // read-only
    property bool highlighted: highlight.visible
    property Item profileImage: profileImageItem

    signal clicked
    signal pressAndHold

    property int __originalHeight: height

    implicitWidth: ListView.view ? ListView.view.width : 0
    implicitHeight: constant.graphicSizeLarge // should be override by height

    Image {
        id: highlight
        anchors.fill: parent
        visible: delegateMouseArea.pressed
        source: settings.invertedTheme ? "image://theme/meegotouch-panel-background-pressed"
                                       : "image://theme/meegotouch-panel-inverted-background-pressed"
    }

    Rectangle{
        id: bottomLine
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 1
        color: constant.colorDisabled
    }

    Loader{
        id: sideRectLoader
        anchors{ left: parent.left; top: parent.top }
        sourceComponent: sideRectColor ? sideRect : undefined
    }

    Component{
        id: sideRect
        Rectangle{
            height: root.height - bottomLine.height
            width: constant.paddingSmall
            color: sideRectColor ? sideRectColor : "transparent"
        }
    }

    MaskedItem{
        id: profileImageItem
        anchors { left: parent.left; top: parent.top; margins: constant.paddingMedium }
        width: constant.graphicSizeMedium
        height: constant.graphicSizeMedium
        mask: Image{ source: "../Image/pic_mask.png"}

        Image{
            id: profileImage
            anchors.fill: parent
            sourceSize.width: parent.width
            sourceSize.height: parent.height

            function loadImage(){
                if(source == "" || source == constant.twitterBirdIcon){
                    profileImage.source = thumbnailCacher.get(root.imageSource)
                            || (networkMonitor.online ? root.imageSource : constant.twitterBirdIcon)
                }
            }

            NumberAnimation {
                id: imageLoadedEffect
                target: profileImage
                property: "opacity"
                from: 0; to: 1
                duration: 300
            }

            onStatusChanged: {
                if(status == Image.Ready){
                    imageLoadedEffect.start()
                    if(source == root.imageSource) thumbnailCacher.cache(root.imageSource, profileImage)
                }
                else if(status == Image.Error) source = constant.twitterBirdIcon
            }

            Component.onCompleted: {
                if(!root.ListView.view || !root.ListView.view.moving) profileImage.loadImage()
            }

            Connections{
                target: root.ListView.view ? networkMonitor : null
                onOnlineChanged: if(networkMonitor.online && !root.ListView.view.moving) profileImage.loadImage()
            }

            Connections{
                target: root.ListView.view
                onMovingChanged: if(!root.ListView.view.moving) profileImage.loadImage()
            }
        }
    }

    MouseArea{
        id: delegateMouseArea
        anchors.fill: parent
        enabled: root.enabled
        z: 1
        onClicked: root.clicked()
        onPressAndHold: root.pressAndHold()
    }

    Timer {
        id: pause
        interval: 250
        onTriggered: height = __originalHeight
    }

    NumberAnimation {
        id: onAddAnimation
        target: root
        property: "scale"
        duration: 250
        from: 0.25; to: 1
        easing.type: Easing.OutBack
    }

    ListView.onAdd: {
        if(root.ListView.view.stayAtCurrentPosition) {
            if(root.ListView.view.atYBeginning) root.ListView.view.contentY += 1
            __originalHeight = height
            height = 0
            pause.start()
        }
        else onAddAnimation.start()
    }
}
