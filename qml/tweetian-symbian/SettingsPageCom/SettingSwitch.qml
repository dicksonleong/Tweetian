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

Item {
    id: root

    property string text: ""
    property alias checked: switchItem.checked
    property bool infoButtonVisible: false

    signal infoClicked

    width: parent.width
    height: switchItem.height + 2 * switchItem.anchors.margins

    Text {
        anchors {
            left: parent.left
            right: infoButtonVisible ? infoIconLoader.left : switchItem.left
            margins: constant.paddingMedium
            verticalCenter: parent.verticalCenter
        }
        font.pixelSize: constant.fontSizeLarge
        maximumLineCount: 2
        color: constant.colorLight
        wrapMode: Text.Wrap
        elide: Text.ElideRight
        text: root.text
    }

    Loader {
        id: infoIconLoader
        anchors { right: switchItem.left; rightMargin: constant.paddingMedium; verticalCenter: parent.verticalCenter }
        sourceComponent: infoButtonVisible ? infoIcon : undefined

        MouseArea {
            anchors.fill: parent
            onClicked: root.infoClicked()
        }
    }

    Component {
        id: infoIcon

        Image {
            sourceSize.width: constant.graphicSizeSmall + constant.paddingMedium
            sourceSize.height: constant.graphicSizeSmall + constant.paddingMedium
            cache: false
            source: settings.invertedTheme ? "../Image/info_inverse.png" : "../Image/info.png"
        }
    }

    Switch {
        id: switchItem
        anchors { verticalCenter: parent.verticalCenter; right: parent.right; margins: constant.paddingMedium }
        platformInverted: settings.invertedTheme
    }
}
