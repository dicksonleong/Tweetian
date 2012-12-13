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

CommonDialog {
    id: root

    property bool __isClosing: false

    signal signIn(string username, string password)

    platformInverted: settings.invertedTheme
    buttonTexts: [qsTr("Sign In"), qsTr("Cancel")]
    content: Item {
        id: contentItem
        anchors { top: parent.top; left: parent.left; right: parent.right}
        height: textFieldColumn.height + textFieldColumn.anchors.margins * 2

        Column {
            id: textFieldColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: constant.paddingMedium
            }
            spacing: constant.paddingLarge
            height: childrenRect.height

            TextField {
                id: usernameTextField
                anchors { left: parent.left; right: parent.right }
                platformInverted: root.platformInverted
                placeholderText: qsTr("Username")
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
            }

            TextField {
                id: passwordTextField
                anchors { left: parent.left; right: parent.right }
                platformInverted: root.platformInverted
                placeholderText: qsTr("Password")
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                echoMode: TextInput.Password
            }
        }
    }
    onButtonClicked: index === 0 ? root.signIn(usernameTextField.text, passwordTextField.text) : close()

    Component.onCompleted: open()

    onStatusChanged: {
        if (status === DialogStatus.Closing) __isClosing = true
        else if (status === DialogStatus.Closed && __isClosing) root.destroy()
    }
}
