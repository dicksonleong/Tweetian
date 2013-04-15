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
import "../Component"

ContextMenu {
    id: root

    property variant model
    property bool __isClosing: false

    platformInverted: settings.invertedTheme

    MenuLayout {
        MenuItemWithIcon {
            iconSource: platformInverted ? "../Image/reply_inverse.png" : "../Image/reply.png"
            text: qsTr("Reply")
            onClicked: {
                var prop = {
                    type: "Reply",
                    tweetId: model.id,
                    placedText: "@" + model.retweetScreenName + " "
                }
                pageStack.push(Qt.resolvedUrl("../NewTweetPage.qml"), prop)
            }
        }
        MenuItemWithIcon {
            iconSource: platformInverted ? "../Image/retweet_inverse.png" : "../Image/retweet.png"
            text: qsTr("Retweet")
            onClicked: {
                var text = "RT @" + model.retweetScreenName + ": ";
                if (model.isRetweet) text += "RT @" + model.screenName + ": ";
                text += model.plainText;
                pageStack.push(Qt.resolvedUrl("../NewTweetPage.qml"), {type: "RT", placedText: text, tweetId: model.id})
            }
        }
        MenuItemWithIcon {
            iconSource: platformInverted ? "../Image/contacts_inverse.svg" : "../Image/contacts.svg"
            text: qsTr("%1 Profile").arg("<font color=\"LightSeaGreen\">@" + model.retweetScreenName + "</font>")
            onClicked: pageStack.push(Qt.resolvedUrl("../UserPage.qml"), { screenName: model.retweetScreenName })
        }
        MenuItemWithIcon {
            iconSource: platformInverted ? "../Image/contacts_inverse.svg" : "../Image/contacts.svg"
            text: qsTr("%1 Profile").arg("<font color=\"LightSeaGreen\">@" + model.screenName + "</font>")
            visible: model.isRetweet
            onClicked: pageStack.push(Qt.resolvedUrl("../UserPage.qml"), { screenName: model.screenName })
        }
    }

    Component.onCompleted: open()

    onStatusChanged: {
        if (status === DialogStatus.Closing) __isClosing = true
        else if (status === DialogStatus.Closed && __isClosing) root.destroy()
    }
}
