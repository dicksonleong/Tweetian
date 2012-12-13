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

    buttonTexts: [qsTr("Search"), qsTr("Advanced"), qsTr("Cancel")]
    titleText: qsTr("Search Twitter")
    titleIcon: "image://theme/icon-l-search"
    content: Item {
        id: dialogContent
        anchors {
            top: parent.top; topMargin: root.platformStyle.contentMargin
            left: parent.left
            right: parent.right
            margins: constant.paddingLarge
        }
        height: searchTypeRow.height + searchTextField.height + 2 * anchors.topMargin +
                searchTypeRow.anchors.topMargin

        TextField {
            id: searchTextField
            anchors { left: parent.left; right: parent.right }
            placeholderText: qsTr("Enter your search query...")
            font.pixelSize: constant.fontSizeLarge
            inputMethodHints: Qt.ImhNoPredictiveText
            platformSipAttributes: SipAttributes {
                actionKeyEnabled: searchTextField.text.length > 0
                actionKeyHighlighted: true
                actionKeyLabel: qsTr("Search")
            }
            Keys.onReturnPressed: {
                searchTextField.platformCloseSoftwareInputPanel()
                root.accept()
            }
        }

        Text {
            id: searchTypeText
            anchors.verticalCenter: searchTypeRow.verticalCenter
            font.pixelSize: constant.fontSizeMedium
            color: "white"
            text: qsTr("Search for:")
        }

        ButtonRow {
            id: searchTypeRow
            anchors {
                top: searchTextField.bottom; topMargin: constant.paddingLarge
                left: searchTypeText.right; leftMargin: constant.paddingLarge
                right: parent.right
            }
            height: childrenRect.height

            Button {
                id: tweetType
                text: qsTr("Tweet")
            }
            Button {
                id: userType
                text: qsTr("User")
            }
        }
    }

    onAccepted: {
        if (tweetType.checked)
            pageStack.push(Qt.resolvedUrl("../SearchPage.qml"), {searchName: searchTextField.text})
        else if (userType.checked)
            pageStack.push(Qt.resolvedUrl("../UserSearchPage.qml"), {userSearchQuery: searchTextField.text})
    }

    onButtonClicked: {
        if (index === 1) pageStack.push(Qt.resolvedUrl("../AdvSearchPage.qml"), {searchQuery: searchTextField.text})
    }

    Component.onCompleted: open()

    onStatusChanged: {
        if (status === DialogStatus.Closing) __isClosing = true
        else if (status === DialogStatus.Closed && __isClosing) root.destroy(250)
    }
}
