import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"

Page{
    id: tweetImagePage

    property string imageLink: ""
    property url imageUrl: ""

    tools: ToolBarLayout{
        ToolButtonWithTip{
            iconSource: "toolbar-back"
            toolTipText: "Back"
            onClicked: pageStack.pop()
        }
        ToolButtonWithTip{
            iconSource: platformInverted ? "Image/undo_inverse.svg" : "Image/undo.svg"
            enabled: tweetImagePreview.scale !== pinchArea.minScale
            toolTipText: "Reset Zoom"
            onClicked: {
                imageFlickable.returnToBounds()
                bounceBackAnimation.to = pinchArea.minScale
                bounceBackAnimation.start()
            }
        }
        ToolButtonWithTip{
            iconSource: platformInverted ? "Image/internet_inverse.svg" : "Image/internet.svg"
            enabled: imageLink != ""
            toolTipText: "Open Link"
            onClicked: dialog.createOpenLinkDialog(imageLink)
        }
        ToolButtonWithTip{
            iconSource: platformInverted ? "Image/save_inverse.svg" : "Image/save.svg"
            toolTipText: "Save Image"
            enabled: tweetImagePreview.status == Image.Ready
            onClicked: {
                var filePath = imageSaver.save(tweetImagePreview)
                if(filePath) infoBanner.alert("Image saved in " + filePath)
                else infoBanner.alert("Failed to save image")
            }
        }
    }

    Flickable{
        id: imageFlickable
        anchors.fill: parent
        contentWidth: imageContainer.width
        contentHeight: imageContainer.height
        clip: true
        onHeightChanged: if(tweetImagePreview.status === Image.Ready) tweetImagePreview.fitToScreen()

        Item{
            id: imageContainer
            width: Math.max(tweetImagePreview.width * tweetImagePreview.scale, imageFlickable.width)
            height: Math.max(tweetImagePreview.height * tweetImagePreview.scale, imageFlickable.height)

            Image{
                id: tweetImagePreview

                property real prevScale

                function fitToScreen(){
                    scale = Math.min(imageFlickable.width / width, imageFlickable.height / height, 1)
                    pinchArea.minScale = scale
                    prevScale = scale
                }

                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
                cache: false
                asynchronous: true
                source: imageUrl
                sourceSize.height: 1000
                smooth: !imageFlickable.moving

                onStatusChanged: {
                    if(status == Image.Ready){
                        fitToScreen()
                        loadedAnimation.start()
                    }
                }

                NumberAnimation{
                    id: loadedAnimation
                    target: tweetImagePreview
                    property: "opacity"
                    duration: 250
                    from: 0; to: 1
                    easing.type: Easing.InOutQuad
                }

                onScaleChanged: {
                    if ((width * scale) > imageFlickable.width) {
                        var xoff = (imageFlickable.width / 2 + imageFlickable.contentX) * scale / prevScale;
                        imageFlickable.contentX = xoff - imageFlickable.width / 2
                    }
                    if ((height * scale) > imageFlickable.height) {
                        var yoff = (imageFlickable.height / 2 + imageFlickable.contentY) * scale / prevScale;
                        imageFlickable.contentY = yoff - imageFlickable.height / 2
                    }
                    prevScale = scale
                }
            }
        }

        PinchArea{
            id: pinchArea

            property real minScale: 1.0
            property real maxScale: 3.0

            anchors.fill: parent
            enabled: tweetImagePreview.status === Image.Ready
            pinch.target: tweetImagePreview
            pinch.minimumScale: minScale * 0.5 // This is to create "bounce back effect"
            pinch.maximumScale: maxScale * 1.5 // when over zoomed

            onPinchFinished: {
                imageFlickable.returnToBounds()
                if(tweetImagePreview.scale < pinchArea.minScale){
                    bounceBackAnimation.to = pinchArea.minScale
                    bounceBackAnimation.start()
                }
                else if(tweetImagePreview.scale > pinchArea.maxScale){
                    bounceBackAnimation.to = pinchArea.maxScale
                    bounceBackAnimation.start()
                }
            }

            NumberAnimation{
                id: bounceBackAnimation
                target: tweetImagePreview
                duration: 250
                property: "scale"
                from: tweetImagePreview.scale
            }
        }
    }

    Loader{
        anchors.centerIn: parent
        sourceComponent: {
            switch(tweetImagePreview.status){
            case Image.Loading:
                return loadingIndicator
            case Image.Error:
                return failedLoading
            default:
                return undefined
            }
        }

        Component{
            id: loadingIndicator

            Item{
                height: childrenRect.height
                width: tweetImagePage.width

                BusyIndicator{
                    id: imageLoadingIndicator
                    anchors{ horizontalCenter: parent.horizontalCenter }
                    running: true
                    height: constant.graphicSizeLarge; width: constant.graphicSizeLarge
                }

                Text{
                    anchors{ horizontalCenter: parent.horizontalCenter; top: imageLoadingIndicator.bottom }
                    anchors.topMargin: constant.paddingXLarge
                    font.pixelSize: constant.fontSizeLarge
                    color: constant.colorLight
                    text: "Loading image..." + Math.round(tweetImagePreview.progress*100) + "%"
                }
            }
        }

        Component{
            id: failedLoading
            Text{
                font.pixelSize: constant.fontSizeLarge
                color: constant.colorLight
                text: "Error loading image"
            }
        }
    }

    ScrollDecorator{ platformInverted: settings.invertedTheme; flickableItem: imageFlickable }
}
