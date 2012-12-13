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
    sideRectColor: followersCount == 0 ? "Red" : ""

    Column {
        id: textColumn
        anchors {
            top: parent.top;
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
                font.bold: true
                font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
                color: highlighted ? constant.colorHighlighted : constant.colorLight
                elide: Text.ElideRight
                text: userName
            }

            Text {
                anchors { left: userNameText.right; right: lockIconLoader.left; margins: constant.paddingMedium }
                width: parent.width - userNameText
                font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
                color: highlighted ? constant.colorHighlighted : constant.colorMid
                elide: Text.ElideRight
                text: "@" + screenName
            }

            Loader {
                id: lockIconLoader
                anchors.right: parent.right
                sourceComponent: protectedUser ? protectedIcon : undefined
            }
        }

        Text {
            anchors { left: parent.left; right: parent.right }
            font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
            visible: text != ""
            wrapMode: Text.Wrap
            color: highlighted ? constant.colorHighlighted : constant.colorLight
            text: bio
        }

        Text {
            anchors { left: parent.left; right: parent.right }
            font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
            color: highlighted ? constant.colorHighlighted : constant.colorMid
            text: qsTr("%1 following | %2 followers").arg(followingCount).arg(followersCount)
        }
    }

    Component {
        id: protectedIcon

        Image {
            sourceSize { height: constant.graphicSizeTiny; width: constant.graphicSizeTiny }
            source: settings.invertedTheme ? "../Image/lock_inverse.svg" : "../Image/lock.svg"
        }
    }

    onClicked: {
        pageStack.push(Qt.resolvedUrl("../UserPage.qml"), {
                           userInfoRawData: {
                               "profile_image_url": profileImageUrl,
                               "profile_banner_url": profileBannerUrl,
                               "screen_name": screenName,
                               "name": userName,
                               "protected": protectedUser,
                               "description": bio,
                               "url": website,
                               "location": location,
                               "created_at": createdAt,
                               "statuses_count": tweetsCount,
                               "friends_count": followingCount,
                               "followers_count": followersCount,
                               "favourites_count": favouritesCount,
                               "following": followingUser,
                               "listed_count": listedCount
                           },
                           screenName: screenName})
    }
}
