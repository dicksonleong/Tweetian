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

    property string link
    property bool showAddPageServices: false

    signal addToPocketClicked(string link)
    signal addToInstapaperClicked(string link)

    property bool __isClosing: false

    platformInverted: settings.invertedTheme

    MenuLayout {
        Text {
            anchors { left: parent.left; right: parent.right }
            horizontalAlignment: Text.AlignHCenter
            text: link
            font.italic: true
            font.pixelSize: constant.fontSizeMedium
            color: "LightSeaGreen"
            elide: Text.ElideRight
            maximumLineCount: 2
            wrapMode: Text.WrapAnywhere
        }
        MenuItemWithIcon {
            iconSource: platformInverted ? "../Image/internet_inverse.svg" : "../Image/internet.svg"
            text: qsTr("Open link in web browser")
            platformInverted: root.platformInverted
            onClicked: {
                symbianUtils.openDefaultBrowser(link)
                infoBanner.showText(qsTr("Launching web browser..."))
            }
        }
        MenuItemWithIcon {
            iconSource: "image://theme/qtg_toolbar_copy" + (platformInverted ? "_inverse" : "" )
            text: qsTr("Copy link")
            platformInverted: root.platformInverted
            onClicked: {
                QMLUtils.copyToClipboard(link)
                infoBanner.showText(qsTr("Link copied to clipboard"))
            }
        }
        MenuItemWithIcon {
            visible: showAddPageServices
            iconSource: platformInverted ? "../Image/web_page_inverse.svg" : "../Image/web_page.svg"
            text: qsTr("Send to Pocket")
            onClicked: addToPocketClicked(link)
        }
        MenuItemWithIcon {
            visible: showAddPageServices
            iconSource: platformInverted ? "../Image/web_page_inverse.svg" : "../Image/web_page.svg"
            text: qsTr("Send to Instapaper")
            onClicked: addToInstapaperClicked(link)
        }
    }

    Component.onCompleted: open()

    onStatusChanged: {
        if (status === DialogStatus.Closing) __isClosing = true
        else if (status === DialogStatus.Closed && __isClosing) root.destroy()
    }
}
