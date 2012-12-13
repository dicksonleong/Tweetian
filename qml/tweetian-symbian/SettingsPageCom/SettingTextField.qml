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

Item {
    id: root

    property string settingText: ""
    property alias textFieldText: textField.text
    property alias placeHolderText: textField.placeholderText
    property alias validator: textField.validator

    property alias acceptableInput: textField.acceptableInput

    implicitHeight: column.height
    implicitWidth: parent.width

    Column {
        id: column
        anchors {
            left: parent.left; leftMargin: constant.paddingMedium
            right: parent.right; rightMargin: constant.paddingLarge // for scroll bar
        }
        height: childrenRect.height
        spacing: constant.paddingMedium

        Text {
            anchors { left: parent.left; right: parent.right }
            font.pixelSize: constant.fontSizeMedium
            color: constant.colorLight
            text: settingText
        }

        TextField {
            id: textField
            anchors { left: parent.left; right: parent.right }
            platformInverted: settings.invertedTheme
        }
    }
}
