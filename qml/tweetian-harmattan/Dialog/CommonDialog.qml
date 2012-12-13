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

Dialog {
    id: root
    objectName: "commonDialog"

    property string titleText: ""
    property alias titleIcon: iconImage.source
    property variant buttonTexts: []

    signal buttonClicked(int index)

    platformStyle: DialogStyle {
        property int contentMargin: 21
        leftMargin: constant.paddingLarge
        rightMargin: constant.paddingLarge
    }
    title: Item {
        id: titleField
        width: parent.width
        height: titleText == "" ? titleBarIconField.height :
                    titleBarIconField.height + titleTextText.height + titleFieldCol.spacing
        Column {
            id: titleFieldCol
            anchors { left: parent.left; right:  parent.right; top:  parent.top }
            spacing: 17

            Item {
                id: titleBarIconField
                anchors { left: parent.left; right: parent.right }
                height: iconImage.height

                Image {
                    id: iconImage
                    anchors.horizontalCenter: titleBarIconField.horizontalCenter
                }
            }

            Item {
                id: titleBarTextField
                anchors { left: parent.left; right: parent.right }
                height: titleTextText.height

                Text {
                    id: titleTextText
                    anchors { left: parent.left; right: parent.right }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: constant.fontSizeXXLarge
                    font.bold: true
                    color: "white"
                    elide: root.platformStyle.titleElideMode
                    wrapMode: elide == Text.ElideNone ? Text.Wrap : Text.NoWrap
                    text: root.titleText
                }
            }
        }
    }

    buttons: Item {
        anchors { left: parent.left; right: parent.right }
        height: buttonCol.height + buttonCol.anchors.topMargin

        Column {
            id: buttonCol
            anchors {
                top: parent.top
                topMargin: root.platformStyle.buttonsTopMargin
                horizontalCenter: parent.horizontalCenter
            }
            spacing: root.platformStyle.buttonsColumnSpacing
            height: childrenRect.height

            Repeater {
                model: buttonTexts

                Button {
                    text: modelData
                    onClicked: {
                        buttonClicked(index)
                        if (index === 0) accept()
                        else reject()
                    }
                    platformStyle: ButtonStyle {
                        inverted: true
                        background: index === 0 ? "image://theme/meegotouch-dialog-button-positive"
                                                : "image://theme/meegotouch-dialog-button-negative"
                        pressedBackground: index === 0 ? "image://theme/meegotouch-dialog-button-positive-pressed"
                                                       : "image://theme/meegotouch-dialog-button-negative-pressed"
                    }
                }
            }
        }
    }
}
