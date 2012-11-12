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

CommonDialog{
    id: root

    property bool __isClosing: false

    platformInverted: settings.invertedTheme
    buttonTexts: [qsTr("Search"), qsTr("Advanced"), qsTr("Cancel")]
    titleText: qsTr("Search Twitter")
    titleIcon: platformInverted ? "image://theme/toolbar-search_inverse"
                                : "image://theme/toolbar-search"
    content: Item{
        id: dialogContent
        anchors{
            top: parent.top
            left: parent.left
            right: parent.right
            margins: constant.paddingMedium
        }
        height: searchTypeRow.height + searchTextField.height + searchTypeRow.anchors.topMargin + 2 * anchors.margins

        TextField{
            id: searchTextField
            anchors{ top: parent.top; left: parent.left; right: parent.right }
            placeholderText: qsTr("Enter your search query...")
            font.pixelSize: constant.fontSizeLarge
            platformInverted: root.platformInverted
            inputMethodHints: Qt.ImhNoPredictiveText
        }

        Text{
            id: searchTypeText
            anchors.verticalCenter: searchTypeRow.verticalCenter
            font.pixelSize: constant.fontSizeMedium
            color: constant.colorLight
            text: qsTr("Search for:")
        }

        ButtonRow{
            id: searchTypeRow
            anchors{
                left: searchTypeText.right; leftMargin: constant.paddingLarge
                top: searchTextField.bottom; topMargin: constant.paddingLarge
                right: parent.right
            }
            height: childrenRect.height

            Button{
                id: tweetType
                text: qsTr("Tweet")
                platformInverted: root.platformInverted
            }
            Button{
                id: userType
                text: qsTr("User")
                platformInverted: root.platformInverted
            }
        }
    }
    onButtonClicked: {
        if(index === 0){
            if(tweetType.checked)
                pageStack.push(Qt.resolvedUrl("../SearchPage.qml"), {searchName: searchTextField.text})
            else if(userType.checked)
                pageStack.push(Qt.resolvedUrl("../UserSearchPage.qml"), {userSearchQuery: searchTextField.text})
        }
        else if(index === 1) pageStack.push(Qt.resolvedUrl("../AdvSearchPage.qml"), {searchQuery: searchTextField.text})
    }

    Component.onCompleted: open()

    onStatusChanged: {
        if(status === DialogStatus.Closing) __isClosing = true
        else if(status === DialogStatus.Closed && __isClosing) root.destroy()
    }
}
