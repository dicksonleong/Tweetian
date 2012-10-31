import QtQuick 1.1
import com.nokia.symbian 1.1

Page{
    id: muteTab

    Column{
        id: muteTabColumn
        anchors{ fill: parent; margins: constant.paddingMedium }
        spacing: constant.paddingMedium

        TextArea{
            id: muteTextArea
            platformInverted: settings.invertedTheme
            width: parent.width
            height: inputContext.visible ? parent.height : parent.height / 2
            textFormat: TextEdit.PlainText
            font.pixelSize: constant.fontSizeXLarge
            placeholderText: "Example:\n@nokia #SwitchtoLumia\nsource:Tweet_Button\niPhone"
            text: settings.muteString
        }

        Button{
            anchors.horizontalCenter: parent.horizontalCenter
            platformInverted: settings.invertedTheme
            width: parent.width * 0.75
            text: "Help"
            onClicked: dialog.createMessageDialog("Mute", infoText.mute)
        }

        Button{
            id: saveButton
            anchors.horizontalCenter: parent.horizontalCenter
            platformInverted: settings.invertedTheme
            width: parent.width * 0.75
            text: "Save"
            enabled: settings.muteString !== muteTextArea.text
            onClicked: settings.muteString = muteTextArea.text
        }

        Text{
            width: parent.width
            visible: saveButton.enabled
            wrapMode: Text.Wrap
            text: "Changes will not be save until you press the save button."
            font.pixelSize: constant.fontSizeSmall
            color: constant.colorLight
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
