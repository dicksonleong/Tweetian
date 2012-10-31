import QtQuick 1.1
import com.nokia.meego 1.0

Page{
    id: muteTab

    Column{
        id: muteTabColumn
        anchors{ fill: parent; margins: constant.paddingMedium }
        spacing: constant.paddingMedium

        TextArea{
            id: muteTextArea
            width: parent.width
            height: inputContext.softwareInputPanelVisible ? parent.height : parent.height / 2
            textFormat: TextEdit.PlainText
            font.pixelSize: constant.fontSizeXLarge
            text: settings.muteString
            placeholderText: "Example:\n@nokia #SwitchtoLumia\nsource:Tweet_Button\niPhone"
        }

        Button{
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.75
            text: "Help"
            onClicked: dialog.createMessageDialog("Mute", infoText.mute)
        }

        Button{
            id: saveButton
            anchors.horizontalCenter: parent.horizontalCenter
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
