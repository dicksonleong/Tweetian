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

AbstractDelegate {
    id: root
    height: Math.max(textColumn.height, profileImage.height) + 2 * constant.paddingMedium
    imageSource: sentMsg ? settings.userProfileImage : profileImageUrl

    Column {
        id: textColumn
        anchors {
            top: parent.top
            left: profileImage.right; leftMargin: constant.paddingSmall
            right: parent.right
            margins: constant.paddingMedium
        }
        height: childrenRect.height

        Item {
            anchors { left: parent.left; right: parent.right }
            height: userNameText.height

            Text {
                id: userNameText
                anchors.left: parent.left
                width: Math.min(implicitWidth, parent.width)
                font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
                font.bold: true
                color: highlighted ? constant.colorHighlighted : constant.colorLight
                elide: Text.ElideRight
                text: sentMsg ? settings.userFullName : userName
            }

            Text {
                anchors { left: userNameText.right; leftMargin: constant.paddingMedium; right: parent.right }
                font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
                color: highlighted ? constant.colorHighlighted : constant.colorMid
                elide: Text.ElideRight
                text: "@" + (sentMsg ? settings.userScreenName : screenName)
            }
        }

        Text {
            anchors { left: parent.left; right: parent.right }
            font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
            wrapMode: Text.Wrap
            color: highlighted ? constant.colorHighlighted : constant.colorLight
            text: tweetText
        }

        Text {
            anchors { left: parent.left; right: parent.right }
            horizontalAlignment: Text.AlignRight
            font.pixelSize: settings.largeFontSize ? constant.fontSizeSmall : constant.fontSizeXSmall
            color: highlighted ? constant.colorHighlighted : constant.colorMid
            text: timeDiff
        }
    }

    onClicked: internal.createDMDialog(model)
}
