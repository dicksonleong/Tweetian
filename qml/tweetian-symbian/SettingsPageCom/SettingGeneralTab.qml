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

Page {
    id: root

    Flickable {
        anchors.fill: parent
        contentHeight: switchColumn.height + 2 * switchColumn.anchors.topMargin

        Column {
            id: switchColumn
            anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: constant.paddingMedium }
            height: childrenRect.height
            spacing: constant.paddingMedium

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 2 * constant.paddingMedium
                font.pixelSize: constant.fontSizeLarge
                color: constant.colorLight
                text: qsTr("Theme")
            }

            ButtonRow {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 2 * constant.paddingMedium
                onVisibleChanged: {
                    if (visible) checkedButton = settings.invertedTheme ?  lightThemeButton : darkThemeButton
                }

                Button {
                    id: darkThemeButton
                    platformInverted: settings.invertedTheme
                    text: qsTr("Dark")
                    onClicked: settings.invertedTheme = false
                }

                Button {
                    id: lightThemeButton
                    platformInverted: settings.invertedTheme
                    text: qsTr("Light")
                    onClicked: settings.invertedTheme = true
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 2 * constant.paddingMedium
                font.pixelSize: constant.fontSizeLarge
                color: constant.colorLight
                text: qsTr("Font size")
            }

            ButtonRow {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 2 * constant.paddingMedium
                onVisibleChanged: {
                    if (visible) checkedButton = settings.largeFontSize ? largeFontSizeButton : smallFontSizeButton
                }

                Button {
                    id: smallFontSizeButton
                    platformInverted: settings.invertedTheme
                    text: qsTr("Small")
                    onClicked: settings.largeFontSize = false
                }

                Button {
                    id: largeFontSizeButton
                    platformInverted: settings.invertedTheme
                    text: qsTr("Large")
                    onClicked: settings.largeFontSize = true
                }
            }

            SettingSwitch {
                text: qsTr("Include #hashtags in reply")
                checked: settings.hashtagsInReply
                onCheckedChanged: settings.hashtagsInReply = checked
            }

            SettingSwitch {
                text: qsTr("Enable TwitLonger")
                checked: settings.enableTwitLonger
                infoButtonVisible: true
                onCheckedChanged: settings.enableTwitLonger = checked
                onInfoClicked: dialog.createMessageDialog(qsTr("About TwitLonger"), infoText.twitLonger)
            }
        }
    }
}
