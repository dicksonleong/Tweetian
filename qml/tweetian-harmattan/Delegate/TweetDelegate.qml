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
    sideRectColor: {
        switch (settings.userScreenName) {
        case inReplyToScreenName: return constant.colorTextSelection
        case screenName: return constant.colorLight
        default: return "transparent"
        }
    }

    Item {
        id: titleContainer
        anchors { left: parent.left; right: parent.right }
        height: userNameText.height

        // FIXME: After changing font size from small to large the username will become elided
        // for the loaded delegate
        Text {
            id: userNameText
            anchors.left: parent.left
            width: Math.min(parent.width, implicitWidth)
            font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
            font.bold: true
            color: highlighted ? constant.colorHighlighted : constant.colorLight
            elide: Text.ElideRight
            text: userName
        }

        Text {
            anchors { left: userNameText.right; right: favouriteIconLoader.left; margins: constant.paddingSmall }
            font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
            color: highlighted ? constant.colorHighlighted : constant.colorMid
            elide: Text.ElideRight
            text: "@" + displayScreenName
        }

        Loader {
            id: favouriteIconLoader
            anchors.right: parent.right
            width: sourceComponent ? item.sourceSize.height : 0
            sourceComponent: favourited ? favouriteIcon : undefined

            Component {
                id: favouriteIcon

                Image {
                    sourceSize { height: titleContainer.height; width: titleContainer.height }
                    source: settings.invertedTheme ? "image://theme/icon-m-common-favorite-mark"
                                                   : "image://theme/icon-m-common-favorite-mark-inverse"
                }
            }
        }
    }

    Text {
        anchors { left: parent.left; right: parent.right }
        textFormat: Text.RichText
        font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
        wrapMode: Text.Wrap
        color: highlighted ? constant.colorHighlighted : constant.colorLight
        text: displayTweetText
    }

    Loader {
        id: retweetLoader
        anchors { left: parent.left; right: parent.right }
        sourceComponent: retweetId == tweetId ? undefined : retweetText

        Component {
            id: retweetText

            Text {
                font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
                wrapMode: Text.Wrap
                color: highlighted ? constant.colorHighlighted : constant.colorMid
                text: qsTr("Retweeted by %1").arg("@" + screenName)
            }
        }
    }

    Text {
        anchors { left: parent.left; right: parent.right }
        horizontalAlignment: Text.AlignRight
        font.pixelSize: settings.largeFontSize ? constant.fontSizeSmall : constant.fontSizeXSmall
        color: highlighted ? constant.colorHighlighted : constant.colorMid
        elide: Text.ElideRight
        text: source + " | " + timeDiff
    }

    onClicked: pageStack.push(Qt.resolvedUrl("../TweetPage.qml"), {currentTweet: model})
    onPressAndHold: dialog.createTweetLongPressMenu(model)
}
