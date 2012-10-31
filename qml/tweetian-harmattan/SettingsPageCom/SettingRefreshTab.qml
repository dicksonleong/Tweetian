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

            SectionHeader{ text: "Streaming" }

            SettingSwitch{
                id: streamingSwitch
                text: "Enable Streaming"
                checked: settings.enableStreaming
                infoButtonVisible: true
                onCheckedChanged: settings.enableStreaming = checked
                onInfoClicked: dialog.createMessageDialog("Streaming", infoText.streaming)
            }

            SectionHeader{ text: "Auto Refresh Frequency" }

            SettingSlider{
                enabled: !streamingSwitch.checked
                text: "Timeline: " + (enabled ? (value === 0 ? "Off" : value + " min") : "Disabled")
                maximumValue: 30
                stepSize: 1
                value: settings.timelineRefreshFreq
                onReleased: settings.timelineRefreshFreq = value
            }

            SettingSlider{
                enabled: !streamingSwitch.checked
                text: "Mentions: " + (enabled ? (value === 0 ? "Off" : value + " min") : "Disabled")
                maximumValue: 30
                stepSize: 1
                value: settings.mentionsRefreshFreq
                onReleased: settings.mentionsRefreshFreq = value
            }

            SettingSlider{
                enabled: !streamingSwitch.checked
                text: "Direct Messages: " + (enabled ? (value === 0 ? "Off" : value + " min") : "Disabled")
                maximumValue: 30
                stepSize: 1
                value: settings.directMsgRefreshFreq
                onReleased: settings.directMsgRefreshFreq = value
            }

            SectionHeader{ text: "Notifications" }

            SettingSwitch{
                text: "Mentions"
                checked: settings.mentionNotification
                onCheckedChanged: settings.mentionNotification = checked
            }

            SettingSwitch{
                text: "Direct Messages"
                checked: settings.messageNotification
                onCheckedChanged: settings.messageNotification = checked
            }
        }
    }
}
