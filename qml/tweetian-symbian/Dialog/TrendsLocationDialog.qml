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

SelectionDialog {
    id: root

    property bool __isClosing: false

    platformInverted: settings.invertedTheme
    titleText: qsTr("Trends Location")
    delegate: MenuItem {
        platformInverted: root.platformInverted
        text: model.name
        onClicked: {
            selectedIndex = index
            accept()
        }

        Image {
            anchors {
                right: parent.right; rightMargin: constant.paddingMedium
                verticalCenter: parent.verticalCenter
            }
            sourceSize { height: constant.graphicSizeSmall; width: constant.graphicSizeSmall }
            source: settings.trendsLocationWoeid === model.woeid.toString() ?
                        (platformInverted ? "../Image/selection_indicator_inverse.svg"
                                          : "../Image/selection_indicator.svg") : ""

        }
    }

    Component.onCompleted: open()

    onStatusChanged: {
        if (status === DialogStatus.Closing) __isClosing = true
        else if (status === DialogStatus.Closed && __isClosing) root.destroy()
    }
}
