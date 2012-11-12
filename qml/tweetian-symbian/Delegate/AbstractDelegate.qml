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

Item{
    id: root

    property string sideRectColor: ""
    property string imageSource: profileImageUrl

    // read-only
    property bool highlighted: highlight.opacity === 1
    property Item profileImage: profileImageItem

    signal clicked
    signal pressAndHold

    property int __originalHeight: height

    implicitWidth: ListView.view ? ListView.view.width : 0
    implicitHeight: constant.graphicSizeLarge // should be override by height

    BorderImage {
        id: highlight
        border {
            left: constant.borderSizeMedium
            top: constant.borderSizeMedium
            right: constant.borderSizeMedium
            bottom: constant.borderSizeMedium
        }
        opacity: 0
        anchors.fill: parent
    }

    PropertyAnimation {
        id: highlightFadeOut
        target: highlight
        property: "opacity"
        to: 0
        easing.type: Easing.Linear
        duration: 150
    }

    Rectangle{
        id: bottomLine
        height: 1
        anchors { left: root.left; right: root.right }
        color: constant.colorMarginLine
        anchors.bottom: parent.bottom
    }

    Loader{
        id: sideRectLoader
        anchors{ left: parent.left; top: parent.top }
        sourceComponent: sideRectColor ? sideRect : undefined
    }

    Component{
        id: sideRect
        Rectangle{
            height: root.height - 1
            width: constant.paddingSmall
            color: sideRectColor ? sideRectColor : "transparent"
        }
    }

    Image{
        id: profileImageItem
        anchors{ left: parent.left; top: parent.top; margins: constant.paddingMedium }
        height: sourceSize.height
        width: sourceSize.width
        sourceSize.width: constant.graphicSizeMedium
        sourceSize.height: constant.graphicSizeMedium

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

    MouseArea{
        anchors.fill: parent
        enabled: root.enabled
        z: 1
        onClicked: root.clicked()
        onPressed: {
            listItemHapticEffect.play()
            highlight.source = "../Image/list_pressed.svg"
            highlight.opacity = 1
        }
        onReleased: {
            listItemHapticEffect.play()
            highlightFadeOut.restart()
        }
        onCanceled: highlightFadeOut.restart()
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
