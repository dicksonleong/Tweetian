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

CommonDialog {
    id: root

    property bool __isClosing: false

    signal signIn(string username, string password)

    buttonTexts: [qsTr("Sign In"), qsTr("Cancel")]
    content: Item {
        id: contentItem
        anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: root.platformStyle.contentMargin }
        height: textFieldColumn.height + anchors.topMargin * 2

        Column {
            id: textFieldColumn
            anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
            spacing: constant.paddingLarge
            height: childrenRect.height

            TextField {
                id: usernameTextField
                anchors { left: parent.left; right: parent.right }
                placeholderText: qsTr("Username")
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                platformSipAttributes: SipAttributes {
                    actionKeyEnabled: usernameTextField.text.length > 0
                    actionKeyHighlighted: true
                    actionKeyLabel: qsTr("Next")
                }
                Keys.onReturnPressed: passwordTextField.forceActiveFocus()
            }

            TextField {
                id: passwordTextField
                anchors { left: parent.left; right: parent.right }
                placeholderText: qsTr("Password")
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                echoMode: TextInput.Password
                platformSipAttributes: SipAttributes {
                    actionKeyEnabled: passwordTextField.text.length > 0
                    actionKeyHighlighted: true
                    actionKeyLabel: qsTr("Sign In")
                }
                Keys.onReturnPressed: {
                    passwordTextField.platformCloseSoftwareInputPanel()
                    root.accept()
                }
            }
        }
    }

    onAccepted: root.signIn(usernameTextField.text, passwordTextField.text)

    Component.onCompleted:open()

    onStatusChanged: {
        if (status === DialogStatus.Closing) __isClosing = true
        else if (status === DialogStatus.Closed && __isClosing) root.destroy(250)
    }
}
