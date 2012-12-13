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
    property alias maximumValue: slider.maximumValue
    property alias stepSize: slider.stepSize
    property alias value: slider.value
    signal released

    implicitWidth: parent.width
    height: label.height + slider.height + 2 * constant.paddingMedium + slider.anchors.margins

    Text {
        id: label
        anchors { top: parent.top; left: parent.left; margins: constant.paddingMedium }
        font.pixelSize: constant.fontSizeLarge
        color: constant.colorLight
        text: root.text
    }

    Slider {
        id: slider
        anchors { left: parent.left; right: parent.right; top: label.bottom; margins: constant.paddingSmall }
        platformInverted: settings.invertedTheme
        enabled: root.enabled
        minimumValue: 0
        valueIndicatorText: value == 0 ? "Off" : ""
        valueIndicatorVisible: true
        onPressedChanged: if (!pressed) root.released()
    }
}
