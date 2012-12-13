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

Item {
    id: root

    property string primaryText: ""
    property string secondaryText: ""
    property url imageSource: ""
    property bool showProtectedIcon: false
    signal clicked

    anchors { left: parent.left; right: parent.right; top: parent.top }
    height: firstLineText.height + secondLineText.height + 2 * constant.paddingMedium

    Image {
        id: background
        anchors.fill: parent
        source: "image://theme/color6-meegotouch-view-header-fixed" + (mouseArea.pressed ? "-pressed" : "")
    }

    Text {
        id: firstLineText
        anchors { left: profileImage.right; top: parent.top; right: protectedIcon.left; margins: constant.paddingMedium }
        font.pixelSize: constant.fontSizeLarge
        font.bold: true
        color: "white"
        text: primaryText
        elide: Text.ElideRight
    }

    Text {
        id: secondLineText
        anchors {
            top: firstLineText.bottom
            left: profileImage.right; leftMargin: constant.paddingMedium
            right: protectedIcon.left
        }
        font.pixelSize: constant.fontSizeMedium
        color: "white"
        text: secondaryText
        elide: Text.ElideRight
    }

    Image {
        id: protectedIcon
        anchors { right: parent.right; rightMargin: constant.paddingMedium; verticalCenter: parent.verticalCenter }
        sourceSize { height: constant.graphicSizeSmall; width: constant.graphicSizeSmall }
        source: showProtectedIcon ? "../Image/lock.svg" : ""
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: root.clicked()
    }

    Image {
        id: profileImage
        anchors { left: parent.left; margins: constant.paddingMedium; verticalCenter: parent.verticalCenter }
        height: 50; width: 50
        cache: false
        source: root.imageSource

        MouseArea {
            id: imageClicked
            anchors.fill: parent
            enabled: profileImage.status == Image.Ready
            onClicked: {
                var prop = { "imageUrl": profileImage.source.toString().replace("_normal", "") }
                pageStack.push(Qt.resolvedUrl("../TweetImage.qml"), prop)
            }
        }

        Rectangle {
            anchors.fill: parent
            color: imageClicked.pressed ? "black" : "transparent"
            opacity: 0.75

            Behavior on color { ColorAnimation { duration: 100 } }
        }
    }
}
