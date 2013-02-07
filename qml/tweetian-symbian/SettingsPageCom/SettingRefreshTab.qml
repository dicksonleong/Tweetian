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

Page {
    id: root

    Flickable {
        anchors.fill: parent
        contentHeight: mainColumn.height

        Column {
            id: mainColumn
            anchors { left: parent.left; right: parent.right }
            height: childrenRect.height

            SectionHeader { text: qsTr("Streaming") }

            SettingSwitch {
                id: streamingSwitch
                text: qsTr("Enable streaming")
                checked: settings.enableStreaming
                infoButtonVisible: true
                onCheckedChanged: settings.enableStreaming = checked
                onInfoClicked: dialog.createMessageDialog(qsTr("Streaming"), infoText.streaming)
            }

            SectionHeader { text: qsTr("Auto Refresh Frequency") }

            SettingSlider {
                enabled: !streamingSwitch.checked
                text: qsTr("Timeline") + ": " +
                      (enabled ? (value === 0 ? qsTr("Off") : qsTr("%n min(s)", "", value)) : qsTr("Disabled"))
                maximumValue: 30
                stepSize: 5
                value: settings.timelineRefreshFreq
                onReleased: settings.timelineRefreshFreq = value
            }

            SettingSlider {
                enabled: !streamingSwitch.checked
                text: qsTr("Mentions") + ": " +
                      (enabled ? (value === 0 ? qsTr("Off") : qsTr("%n min(s)", "", value)) : qsTr("Disabled"))
                maximumValue: 30
                stepSize: 5
                value: settings.mentionsRefreshFreq
                onReleased: settings.mentionsRefreshFreq = value
            }

            SettingSlider {
                enabled: !streamingSwitch.checked
                text: qsTr("Direct messages") + ": " +
                      (enabled ? (value === 0 ? qsTr("Off") : qsTr("%n min(s)", "", value)) : qsTr("Disabled"))
                maximumValue: 30
                stepSize: 5
                value: settings.directMsgRefreshFreq
                onReleased: settings.directMsgRefreshFreq = value
            }
        }
    }
}
