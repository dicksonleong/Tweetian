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

    property int value: 0

    height: valueText.paintedHeight + 2 * constant.paddingSmall
    width: Math.max(height, valueText.paintedWidth + 2 * constant.paddingMedium)

    BorderImage {
        anchors.fill: parent
        source: "../Image/countbubble.png"
        border { left: 10; right: 10; top: 10; bottom: 10 }
    }

    Text {
        id: valueText
        anchors.centerIn: parent
        color: "white"
        font.pixelSize: constant.fontSizeSmall
        text: root.value
    }
}
