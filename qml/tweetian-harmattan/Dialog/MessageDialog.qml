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

CommonDialog {
    id: root

    property string message: ""
    property bool __isClosing: false

    buttonTexts: [qsTr("Close")]
    content: Item {
        anchors {
            top: parent.top; topMargin: root.platformStyle.contentMargin
            left: parent.left; leftMargin: constant.paddingMedium
            right: parent.right; rightMargin: constant.paddingMedium
        }
        height: messageText.paintedHeight + anchors.topMargin * 2

        Text {
            id: messageText
            anchors { left: parent.left; right: parent.right }
            color: "white"
            font.pixelSize: constant.fontSizeMedium
            text: root.message
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            onLinkActivated: Qt.openUrlExternally(link)
        }
    }

    Component.onCompleted: open()

    onStatusChanged: {
        if (status === DialogStatus.Closing) __isClosing = true
        else if (status === DialogStatus.Closed && __isClosing) root.destroy(250)
    }
}
