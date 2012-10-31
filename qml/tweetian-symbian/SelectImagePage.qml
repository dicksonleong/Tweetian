import QtQuick 1.1
import com.nokia.symbian 1.1
import QtMobility.gallery 1.1
import "Component"

Page{
    id: selectImagePage

    property Item newTweetPage: null

    tools: ToolBarLayout{
        ToolButtonWithTip{
            toolTipText: "Back"
            iconSource: "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolButton{
            text: "Service"
            platformInverted: settings.invertedTheme
            onClicked: chooseServiceDialogComponent.createObject(selectImagePage)
        }
        ToolButton{ visible: false }
    }

    ContextMenu{
        id: imageMenu

        property string selectedImageURL: ""
        property string selectedImagePath: ""

        platformInverted: settings.invertedTheme
        content: MenuLayout{
            MenuItem{
                text: "Select image"
                platformInverted: imageMenu.platformInverted
                onClicked: {
                    newTweetPage.imageURL = imageMenu.selectedImagePath
                    pageStack.pop()
                }
            }
            MenuItem{
                text: "Preview"
                platformInverted: imageMenu.platformInverted
                onClicked: Qt.openUrlExternally(imageMenu.selectedImageURL)
            }
        }
    }

    GridView{
        id: galleryGridView
        anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        cellWidth: inPortrait ? width / 3 : width / 5
        cellHeight: cellWidth
        delegate: imageDelegate
        model: galleryModel.ready ? galleryModel : undefined
    }

    Text{
        anchors.centerIn: parent
        font.pixelSize: constant.fontSizeXXLarge
        color: constant.colorMid
        text: "No image"
        visible: galleryModel.ready && galleryModel.count == 0
    }

    ScrollDecorator{
        platformInverted: settings.invertedTheme
        flickableItem: galleryModel.ready ? galleryGridView : null
    }

    PageHeader{
        id: header
        headerText: "Select Image"
        headerIcon: "Image/photos.svg"
        onClicked: galleryGridView.positionViewAtBeginning()
    }

    // Filter doesn't work on Symbian
    // More info - https://bugreports.qt-project.org/browse/QTMOBILITY-1656

    DocumentGalleryModel{
        id: galleryModel

        property bool ready: status === DocumentGalleryModel.Idle || status === DocumentGalleryModel.Finished

        autoUpdate: true
        properties: ["filePath", "url"]
        sortProperties: ["-lastModified"]
        rootType: DocumentGallery.Image
        onStatusChanged: {
            if(status === DocumentGalleryModel.Active) header.busy = true
            else if(status === DocumentGalleryModel.Error){
                header.busy = false
                infoBanner.alert("Error loading image from gallery")
            }
            else header.busy = false
        }
    }

    Component{
        id: imageDelegate
        Item{
            width: GridView.view.cellWidth
            height: width
            scale: mouseArea.pressed ? 0.9 : 1.0

            Behavior on scale{ NumberAnimation{ duration: 100 } }

            Image{
                id: image
                asynchronous: true
                source: url
                sourceSize.width: width
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                cache: false
                clip: true
            }

            Loader{
                id: iconLoader
                anchors.centerIn: parent
                sourceComponent: {
                    switch(image.status){
                    case Image.Null:
                    case Image.Error:
                        return icon
                    case Image.Loading:
                        return busy
                    case Image.Ready:
                        return undefined
                    }
                }

                Component{
                    id: icon

                    Image{
                        sourceSize.width: constant.graphicSizeMedium
                        sourceSize.height: constant.graphicSizeMedium
                        source: settings.invertedTheme ? "Image/photos_inverse.svg" : "Image/photos.svg"
                    }
                }

                Component{
                    id: busy

                    BusyIndicator{
                        width: constant.graphicSizeMedium
                        height: constant.graphicSizeMedium
                        running: true
                        platformInverted: !settings.invertedTheme
                    }
                }
            }

            MouseArea{
                id: mouseArea
                anchors.fill: parent
                onClicked: {
                    imageMenu.selectedImageURL = url
                    imageMenu.selectedImagePath = filePath
                    imageMenu.open()
                }
            }
        }
    }

    Component{
        id: chooseServiceDialogComponent

        SelectionDialog{
            id: chooseServiceDialog
            property bool __isClosing: false
            platformInverted: settings.invertedTheme
            titleText: "Image Upload Service"
            model: ListModel{
                ListElement{ name: "Twitter"}
                ListElement{ name: "TwitPic"}
                ListElement{ name: "MobyPicture"}
                ListElement{ name: "img.ly"}
            }
            selectedIndex: settings.imageUploadService
            onAccepted: settings.imageUploadService = selectedIndex

            Component.onCompleted: open()
            onStatusChanged: {
                if(status === DialogStatus.Closing) __isClosing = true
                else if(status === DialogStatus.Closed && __isClosing) chooseServiceDialog.destroy()
            }
        }
    }
}
