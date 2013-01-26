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

AbstractDelegate {
    id: root
    sideRectColor: followersCount == 0 ? "red" : "transparent"

    Item {
        anchors { left: parent.left; right: parent.right }
        height: userNameText.height

        Text {
            id: userNameText
            anchors.left: parent.left
            width: Math.min(implicitWidth, parent.width)
            font.bold: true
            font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
            color: highlighted ? constant.colorHighlighted : constant.colorLight
            elide: Text.ElideRight
            text: model.name
        }

        Text {
            anchors { left: userNameText.right; right: lockIconLoader.left; margins: constant.paddingSmall }
            width: parent.width - userNameText
            font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
            color: highlighted ? constant.colorHighlighted : constant.colorMid
            elide: Text.ElideRight
            text: "@" + model.screenName
        }

        Loader {
            id: lockIconLoader
            anchors.right: parent.right
            sourceComponent: model.isProtected ? protectedIcon : undefined

            Component {
                id: protectedIcon

                Image {
                    sourceSize { height: constant.graphicSizeTiny; width: constant.graphicSizeTiny }
                    source: settings.invertedTheme ? "../Image/lock_inverse.svg" : "../Image/lock.svg"
                }
            }
        }
    }

    Text {
        anchors { left: parent.left; right: parent.right }
        font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
        visible: text != ""
        wrapMode: Text.Wrap
        color: highlighted ? constant.colorHighlighted : constant.colorLight
        text: model.description
    }

    Text {
        anchors { left: parent.left; right: parent.right }
        font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
        color: highlighted ? constant.colorHighlighted : constant.colorMid
        elide: Text.ElideRight
        text: qsTr("%1 following | %2 followers").arg(followingCount).arg(followersCount)
    }

    onClicked: {
        pageStack.push(Qt.resolvedUrl("../UserPage.qml"), { user: model, screenName: screenName })
    }
}
