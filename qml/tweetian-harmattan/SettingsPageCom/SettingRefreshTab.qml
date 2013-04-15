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
import "../Component"

Page {
    id: root

    Flickable {
        anchors.fill: parent
        contentHeight: mainColumn.height

        Column {
            id: mainColumn
            anchors { left: parent.left; right: parent.right }
            height: childrenRect.height

            SettingSwitch {
                id: streamingSwitch
                text: qsTr("Enable streaming")
                checked: settings.enableStreaming
                infoButtonVisible: true
                onCheckedChanged: settings.enableStreaming = checked
                onInfoClicked: dialog.createMessageDialog(qsTr("Streaming"), infoText.streaming)
            }

            SettingSlider {
                enabled: !streamingSwitch.checked
                text: qsTr("Auto refresh interval: %1")
                .arg(enabled ? (value === 0 ? qsTr("Off") : qsTr("%n min(s)", "", value)) : qsTr("Disabled"))
                maximumValue: 30
                stepSize: 5
                value: settings.autoRefreshInterval
                onReleased: settings.autoRefreshInterval = value
            }


            SettingSwitch {
                text: qsTr("Enable notification for mentions and DMs")
                checked: settings.enableNotification
                onCheckedChanged: settings.enableNotification = checked
            }
        }
    }
}
