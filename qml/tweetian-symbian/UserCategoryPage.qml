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
import "Services/Twitter.js" as Twitter

Page {
    id: userCategoryPage

    Component.onCompleted: script.refresh()

    tools: ToolBarLayout {
        ToolButtonWithTip {
            iconSource: "toolbar-back"
            toolTipText: qsTr("Back")
            onClicked: pageStack.pop()
        }
    }

    ListView {
        id: userCategoryView
        anchors { top: header.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
        delegate: userCategoryDelegate
        model: ListModel {}
    }

    ScrollDecorator { platformInverted: settings.invertedTheme; flickableItem: userCategoryView }

    PageHeader {
        id: header
        headerText: qsTr("Suggested User Categories")
        headerIcon: "Image/people.svg"
        onClicked: userCategoryView.positionViewAtBeginning()
    }

    QtObject {
        id: script

        function onSuccess(data) {
            for (var i=0; i<data.length; i++) {
                userCategoryView.model.append(data[i])
            }
            header.busy = false
        }

        function onFailure(status, statusText) {
            infoBanner.showHttpError(status, statusText)
            header.busy = false
        }

        function refresh() {
            userCategoryView.model.clear()
            Twitter.getSuggestedUserCategories(onSuccess, onFailure)
            header.busy = true
        }
    }

    Component {
        id: userCategoryDelegate

        ListItem {
            id: userCategoryItem
            platformInverted: settings.invertedTheme
            width: ListView.view.width
            height: Math.max(categoryText.height + 2 * constant.paddingLarge, implicitHeight)
            subItemIndicator: true

            Text {
                id: categoryText
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: userCategoryItem.paddingItem.left
                    right: countBubble.left; rightMargin: constant.paddingMedium
                }
                elide: Text.ElideRight
                text: model.name
                font.pixelSize: constant.fontSizeLarge
                color: constant.colorLight
            }

            CountBubble {
                id: countBubble
                anchors { right: userCategoryItem.paddingItem.right; verticalCenter: parent.verticalCenter }
                value: model.size
            }

            onClicked: pageStack.push(Qt.resolvedUrl("SuggestedUserPage.qml"), {slug: model.slug})
        }
    }
}
