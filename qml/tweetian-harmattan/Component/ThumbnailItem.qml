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
