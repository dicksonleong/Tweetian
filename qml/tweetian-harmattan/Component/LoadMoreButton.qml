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

Item {
    id: root

    signal clicked

    implicitWidth: parent.width
    height: visible ? buttonLoader.height + 2 * constant.paddingMedium : 0

    Loader {
        id: buttonLoader
        anchors.centerIn: parent
        sourceComponent: visible ? loadMoreButton : undefined
    }

    Component {
        id: loadMoreButton

        Button {
            width: root.width * 0.75
            text: qsTr("Load more")
            onClicked: root.clicked()
        }
    }
}
