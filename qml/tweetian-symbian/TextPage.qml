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
import "Component"

Page {
    id: textPage

    property alias text: mainText.text
    property string headerText: ""
    property url headerIcon: ""

    tools: ToolBarLayout {
        ToolButtonWithTip {
            iconSource: "toolbar-back"
            toolTipText: qsTr("Back")
            onClicked: pageStack.pop()
        }
    }

    Flickable {
        id: textFlickable
        anchors { top: pageHeader.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        flickableDirection: Flickable.VerticalFlick
        contentHeight: mainText.paintedHeight + 2 * mainText.anchors.margins

        Text {
            id: mainText
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: constant.paddingMedium }
            font.pixelSize: constant.fontSizeMedium
            color: constant.colorLight
            wrapMode: Text.Wrap
        }
    }

    ScrollDecorator { platformInverted: settings.invertedTheme; flickableItem: textFlickable }

    PageHeader {
        id: pageHeader
        headerText: textPage.headerText
        headerIcon: textPage.headerIcon
        onClicked: textFlickable.contentY = 0
    }
}
