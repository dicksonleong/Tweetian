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

ListItem {
    id: root

    property url imageSource: ""
    property string text: ""

    width: parent.width
    height: pic.height + 2 * constant.paddingLarge
    subItemIndicator: true
    platformInverted: settings.invertedTheme

    Image {
        id: pic
        anchors { verticalCenter: parent.verticalCenter; left: parent.paddingItem.left }
        sourceSize { width: constant.graphicSizeMedium; height: constant.graphicSizeMedium }
        cache: false
        source: root.imageSource
    }

    Text {
        anchors {
            verticalCenter: parent.verticalCenter
            left: pic.right; leftMargin: constant.paddingMedium
            right: parent.paddingItem.right
        }
        elide: Text.ElideRight
        font.pixelSize: constant.fontSizeMedium
        color: constant.colorLight
        text: root.text
    }
}
