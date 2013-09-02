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

CommonDialog {
    id: root

    property string message: ""
    property bool __isClosing: false

    platformInverted: settings.invertedTheme
    buttonTexts: [qsTr("Close")]
    content: Item {
        anchors { left: parent.left; right: parent.right; top: parent.top }
        height: messageText.paintedHeight + messageText.anchors.margins * 2

        Text {
            id: messageText
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: constant.paddingMedium }
            color: constant.colorLight
            font.pixelSize: constant.fontSizeMedium
            text: root.message
            wrapMode: Text.Wrap
            onLinkActivated: symbianUtils.openDefaultBrowser(link)
        }
    }

    Component.onCompleted: open()

    onStatusChanged: {
        if (status === DialogStatus.Closing) __isClosing = true
        else if (status === DialogStatus.Closed && __isClosing) root.destroy()
    }
}
