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
    id: paneIndicator

    property ListView listView

    function show() {
        fadeOut.stop()
        opacity = 1
    }

    function hide() {
        fadeOut.start()
    }

    anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: constant.paddingMedium }
    height: constant.paddingXLarge

    SequentialAnimation {
        id: fadeOut
        PauseAnimation { duration: 1500 }
        NumberAnimation {
            target: paneIndicator
            property: "opacity"
            from: 1; to: 0.5
            duration: 400
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: constant.paddingMedium

        Repeater {
            model: listView.count

            Rectangle {
                id: dot
                height: paneIndicator.height; width: height
                radius: height
                color: listView.currentIndex == index ? border.color : "transparent"
                border.width: 1
                border.color: "lightgrey"
                smooth: true
            }
        }
    }

    Component.onCompleted: hide()
}
