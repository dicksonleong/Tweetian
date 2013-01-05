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

    Item {
        id: titleContainer
        anchors { left: parent.left; right: parent.right }
        height: listNameText.height

        Text {
            id: listNameText
            anchors.left: parent.left
            width: Math.min(parent.width, implicitWidth)
            font.bold: true
            font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
            color: highlighted ? constant.colorHighlighted : constant.colorLight
            elide: Text.ElideRight
            text: listName
        }

        Text {
            anchors { left: listNameText.right; leftMargin: constant.paddingSmall; right: parent.right }
            font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
            color: highlighted ? constant.colorHighlighted : constant.colorMid
            elide: Text.ElideRight
            text: qsTr("By %1").arg(ownerUserName)
        }
    }

    Text {
        anchors { left: parent.left; right: parent.right }
        visible: text != ""
        wrapMode: Text.Wrap
        font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
        color: highlighted ? constant.colorHighlighted : constant.colorLight
        text: listDescription
    }

    Text {
        anchors { left: parent.left; right: parent.right }
        font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
        color: highlighted ? constant.colorHighlighted : constant.colorMid
        elide: Text.ElideRight
        text: qsTr("%1 members | %2 subscribers").arg(memberCount).arg(subscriberCount)
    }

    onClicked: {
        var parameters = {
            listName: listName,
            listId: listId,
            listDescription: listDescription,
            ownerScreenName: ownerScreenName,
            memberCount: memberCount,
            subscriberCount: subscriberCount,
            protectedList: protectedList,
            followingList: following,
            ownerProfileImageUrl: profileImageUrl
        }
        window.pageStack.push(Qt.resolvedUrl("../ListPage.qml"), parameters)
    }
}
