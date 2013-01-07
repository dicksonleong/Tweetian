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
import com.nokia.extras 1.1

Item {
    id: root

    property url headerIcon: ""
    property string headerText: ""

    property bool busy: false
    property bool countBubbleVisible: false
    property int countBubbleValue: 0

    signal clicked

    anchors { top: parent.top; left: parent.left; right: parent.right }
    implicitHeight: constant.headerHeight

    Image {
        id: background
        anchors.fill: parent
        source: "image://theme/color6-meegotouch-view-header-fixed" + (mouseArea.pressed ? "-pressed" : "")
    }

    Image {
        id: icon
        anchors { verticalCenter: parent.verticalCenter; left: parent.left; margins: constant.paddingLarge }
        height: sourceSize.height; width: sourceSize.width
        sourceSize { height: constant.graphicSizeSmall; width: constant.graphicSizeSmall }
        source: headerIcon
    }

    Text {
        id: mainText
        anchors {
            verticalCenter: parent.verticalCenter
            left: icon.right
            right: busyIndicatorLoader.status === Loader.Ready ? busyIndicatorLoader.left : parent.right
            margins: constant.paddingMedium
        }
        elide: Text.ElideRight
        font.pixelSize: constant.fontSizeLarge
        color: "white"
        text: headerText
    }

    Loader {
        id: busyIndicatorLoader
        anchors { right: parent.right; rightMargin: constant.paddingLarge; verticalCenter: parent.verticalCenter }
        sourceComponent: busy ? busyIndicatorComponent : (countBubbleVisible ? countBubbleComponent : undefined)
    }

    Component {
        id: busyIndicatorComponent

        BusyIndicator {
            running: true
        }
    }

    Component {
        id: countBubbleComponent

        CountBubble {
            value: root.countBubbleValue
            largeSized: true
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
