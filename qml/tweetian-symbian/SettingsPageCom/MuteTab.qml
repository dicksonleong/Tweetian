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
            placeholderText: qsTr("Example:\n%1").arg("@nokia #SwitchtoLumia\nsource:Tweet_Button\niPhone")
            text: settings.muteString
        }

        Button{
            anchors.horizontalCenter: parent.horizontalCenter
            platformInverted: settings.invertedTheme
            width: parent.width * 0.75
            text: qsTr("Help")
            onClicked: dialog.createMessageDialog(qsTr("Mute"), infoText.mute)
        }

        Button{
            id: saveButton
            anchors.horizontalCenter: parent.horizontalCenter
            platformInverted: settings.invertedTheme
            width: parent.width * 0.75
            text: qsTr("Save")
            enabled: settings.muteString !== muteTextArea.text
            onClicked: settings.muteString = muteTextArea.text
        }

        Text{
            width: parent.width
            visible: saveButton.enabled
            wrapMode: Text.Wrap
            text: qsTr("Changes will not be save until you press the save button")
            font.pixelSize: constant.fontSizeSmall
            color: constant.colorLight
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
