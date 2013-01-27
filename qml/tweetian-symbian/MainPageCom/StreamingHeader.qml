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
    height: 0
    width: ListView.view.width

    Row {
        id: headerRow
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.top; bottomMargin: constant.paddingXLarge }
        width: childrenRect.width
        visible: root.ListView.view.__wasAtYBeginning && root.ListView.view.__initialContentY - root.ListView.view.contentY > 10
        spacing: constant.paddingMedium

        Loader {
            id: iconLoader
            sourceComponent: userStream.connected ? streamingIcon : pullIcon
        }

        Text {
            font.pixelSize: constant.fontSizeMedium
            color: constant.colorLight
            text: networkMonitor.online ? (userStream.connected ? qsTr("Streaming...") : qsTr("Connecting to streaming"))
                                        : qsTr("Offline")
        }
    }

    Component {
        id: streamingIcon

        Image {
            sourceSize { width: constant.graphicSizeSmall; height: constant.graphicSizeSmall }
            source:  "image://theme/toolbar-refresh" + (settings.invertedTheme ? "_inverse" : "")
            smooth: true

            RotationAnimation on rotation {
                from: 360; to: 0
                duration: 2000
                loops: Animation.Infinite
                running: headerRow.visible
            }
        }
    }

    Component {
        id: pullIcon

        Image {
            sourceSize { width: constant.graphicSizeSmall; height: constant.graphicSizeSmall }
            rotation: root.ListView.view.__toBeRefresh ? 270 : 90
            source: "image://theme/toolbar-next" + (settings.invertedTheme ? "_inverse" : "")

            Behavior on rotation { NumberAnimation { duration: 250 } }
        }
    }
}
