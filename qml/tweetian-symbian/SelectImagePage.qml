/*
    Copyright (C) 2012 Dickson Leong
    This file is part of Tweetian.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 1.1
import com.nokia.symbian 1.1
import QtMobility.gallery 1.1
import "Component"

Page {
    id: selectImagePage

    property Item newTweetPage: null

    tools: ToolBarLayout {
        ToolButtonWithTip {
            toolTipText: qsTr("Back")
            iconSource: "toolbar-back"
            onClicked: pageStack.pop()
        }
    }

    ContextMenu {
        id: imageMenu

        property string selectedImageUrl: ""
        property string selectedImagePath: ""

        platformInverted: settings.invertedTheme
        content: MenuLayout {
            MenuItem {
                text: qsTr("Select image")
                platformInverted: imageMenu.platformInverted
                onClicked: {
                    newTweetPage.imageUrl = imageMenu.selectedImageUrl
                    newTweetPage.imagePath = imageMenu.selectedImagePath
                    pageStack.pop()
                }
            }
            MenuItem {
                text: qsTr("Preview")
                platformInverted: imageMenu.platformInverted
                onClicked: Qt.openUrlExternally(imageMenu.selectedImageUrl)
            }
        }
    }

    GridView {
        id: galleryGridView
        anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        cellWidth: inPortrait ? width / 3 : width / 5
        cellHeight: cellWidth
        delegate: imageDelegate
        model: galleryModel.ready ? galleryModel : undefined
    }

    Text {
        anchors.centerIn: parent
        font.pixelSize: constant.fontSizeXXLarge
        color: constant.colorMid
        text: qsTr("No image")
        visible: galleryModel.ready && galleryModel.count == 0
    }

    ScrollDecorator {
        platformInverted: settings.invertedTheme
        flickableItem: galleryModel.ready ? galleryGridView : null
    }

    PageHeader {
        id: header
        headerText: qsTr("Select Image")
        headerIcon: "Image/photos.svg"
        onClicked: galleryGridView.positionViewAtBeginning()
    }

    // Filter doesn't work on Symbian
    // More info - https://bugreports.qt-project.org/browse/QTMOBILITY-1656

    DocumentGalleryModel {
        id: galleryModel

        property bool ready: status === DocumentGalleryModel.Idle || status === DocumentGalleryModel.Finished

        autoUpdate: true
        properties: ["filePath", "url"]
        sortProperties: ["-lastModified"]
        rootType: DocumentGallery.Image
        onStatusChanged: {
            if (status === DocumentGalleryModel.Active) header.busy = true
            else if (status === DocumentGalleryModel.Error) {
                header.busy = false
                infoBanner.showText(qsTr("Error loading image from gallery"))
            }
            else header.busy = false
        }
    }

    Component {
        id: imageDelegate
        Item {
            width: GridView.view.cellWidth
            height: width
            scale: mouseArea.pressed ? 0.9 : 1.0

            Behavior on scale { NumberAnimation { duration: 100 } }

            Image {
                id: image
                asynchronous: true
                source: url
                sourceSize.width: width
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                cache: false
                clip: true
            }

            Loader {
                id: iconLoader
                anchors.centerIn: parent
                sourceComponent: {
                    switch (image.status) {
                    case Image.Null:
                    case Image.Error:
                        return icon
                    case Image.Loading:
                        return busy
                    case Image.Ready:
                        return undefined
                    }
                }

                Component {
                    id: icon

                    Image {
                        sourceSize { width: constant.graphicSizeMedium; height: constant.graphicSizeMedium }
                        source: settings.invertedTheme ? "Image/photos_inverse.svg" : "Image/photos.svg"
                    }
                }

                Component {
                    id: busy

                    BusyIndicator {
                        width: constant.graphicSizeMedium; height: constant.graphicSizeMedium
                        running: true
                        platformInverted: !settings.invertedTheme
                    }
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: {
                    imageMenu.selectedImageUrl = url
                    imageMenu.selectedImagePath = filePath
                    imageMenu.open()
                }
            }
        }
    }
}
