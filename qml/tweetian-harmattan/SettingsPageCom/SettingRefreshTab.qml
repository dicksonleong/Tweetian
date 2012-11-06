import QtQuick 1.1
import com.nokia.meego 1.0
import "../Component"

Page{
    id: root

    Flickable{
        anchors.fill: parent
        contentHeight: mainColumn.height

        Column{
            id: mainColumn
            width: parent.width
            height: childrenRect.height

            SectionHeader{ text: qsTr("Streaming") }

            SettingSwitch{
                id: streamingSwitch
                text: qsTr("Enable streaming")
                checked: settings.enableStreaming
                infoButtonVisible: true
                onCheckedChanged: settings.enableStreaming = checked
                onInfoClicked: dialog.createMessageDialog(qsTr("Streaming"), infoText.streaming)
            }

            SectionHeader{ text: qsTr("Auto Refresh Frequency") }

            SettingSlider{
                enabled: !streamingSwitch.checked
                text: qsTr("Timeline") + ": " +
                      (enabled ? (value === 0 ? qsTr("Off") : qsTr("%n min(s)", "", value)) : qsTr("Disabled"))
                maximumValue: 30
                stepSize: 1
                value: settings.timelineRefreshFreq
                onReleased: settings.timelineRefreshFreq = value
            }

            SettingSlider{
                enabled: !streamingSwitch.checked
                text: qsTr("Mentions") + ": " +
                      (enabled ? (value === 0 ? qsTr("Off") : qsTr("%n min(s)", "", value)) : qsTr("Disabled"))
                maximumValue: 30
                stepSize: 1
                value: settings.mentionsRefreshFreq
                onReleased: settings.mentionsRefreshFreq = value
            }

            SettingSlider{
                enabled: !streamingSwitch.checked
                text: qsTr("Direct messages") + ": " +
                      (enabled ? (value === 0 ? qsTr("Off") : qsTr("%n min(s)", "", value)) : qsTr("Disabled"))
                maximumValue: 30
                stepSize: 1
                value: settings.directMsgRefreshFreq
                onReleased: settings.directMsgRefreshFreq = value
            }

            SectionHeader{ text: qsTr("Notifications") }

            SettingSwitch{
                text: qsTr("Mentions")
                checked: settings.mentionNotification
                onCheckedChanged: settings.mentionNotification = checked
            }

            SettingSwitch{
                text: qsTr("Direct messages")
                checked: settings.messageNotification
                onCheckedChanged: settings.messageNotification = checked
            }
        }
    }
}
