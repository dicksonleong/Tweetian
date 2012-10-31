import QtQuick 1.1
import com.nokia.symbian 1.1

Page{
    id: root

    Flickable{
        anchors.fill: parent
        contentHeight: switchColumn.height + 2 * switchColumn.anchors.topMargin

        Column{
            id: switchColumn
            anchors{ left: parent.left; right: parent.right; top: parent.top; topMargin: constant.paddingMedium }
            height: childrenRect.height
            spacing: constant.paddingMedium

            Text{
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 2 * constant.paddingMedium
                font.pixelSize: constant.fontSizeLarge
                color: constant.colorLight
                text: "Theme"
            }

            ButtonRow{
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 2 * constant.paddingMedium
                onVisibleChanged: {
                    if(visible) checkedButton = settings.invertedTheme ?  lightThemeButton : darkThemeButton
                }

                Button{
                    id: darkThemeButton
                    platformInverted: settings.invertedTheme
                    text: "Dark"
                    onClicked: settings.invertedTheme = false
                }

                Button{
                    id: lightThemeButton
                    platformInverted: settings.invertedTheme
                    text: "Light"
                    onClicked: settings.invertedTheme = true
                }
            }

            Text{
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 2 * constant.paddingMedium
                font.pixelSize: constant.fontSizeLarge
                color: constant.colorLight
                text: "Font Size"
            }

            ButtonRow{
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 2 * constant.paddingMedium
                onVisibleChanged: {
                    if(visible) checkedButton = settings.largeFontSize ? largeFontSizeButton : smallFontSizeButton
                }

                Button{
                    id: smallFontSizeButton
                    platformInverted: settings.invertedTheme
                    text: "Small"
                    onClicked: settings.largeFontSize = false
                }

                Button{
                    id: largeFontSizeButton
                    platformInverted: settings.invertedTheme
                    text: "Large"
                    onClicked: settings.largeFontSize = true
                }
            }

            SettingSwitch{
                text: "Include #hashtags in reply"
                checked: settings.hashtagsInReply
                onCheckedChanged: settings.hashtagsInReply = checked
            }

            SettingSwitch{
                text: "Enable TwitLonger"
                checked: settings.enableTwitLonger
                infoButtonVisible: true
                onCheckedChanged: settings.enableTwitLonger = checked
                onInfoClicked: dialog.createMessageDialog("About TwitLonger", infoText.twitLonger)
            }
        }
    }
}
