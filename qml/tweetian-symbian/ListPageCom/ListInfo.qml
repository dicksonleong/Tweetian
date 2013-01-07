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
import "../Services/Twitter.js" as Twitter
import "../Component"

Item {
    id: listInfo
    width: listPageListView.width; height: listPageListView.height

    function initialize() {

        function addToListInfo(title, subtitle, clickedString) {
            var item = { title: title, subtitle: subtitle, clickedString: clickedString || "" }
            listInfoListView.model.append(item)
        }

        addToListInfo(qsTr("List Name"), listName)
        addToListInfo(qsTr("List Owner"), "@" + ownerScreenName,
                      "pageStack.push(Qt.resolvedUrl(\"../UserPage.qml\"), {screenName: subtitle.substring(1)})")
        if (listDescription) addToListInfo(qsTr("Description"), listDescription)
        addToListInfo(qsTr("Member"), memberCount, "listPageListView.currentIndex = 2")
        addToListInfo(qsTr("Subscriber"), subscriberCount, "listPageListView.currentIndex = 3")
    }

    function positionAtTop() {
        listInfoListView.positionViewAtBeginning()
    }

    ListView {
        id: listInfoListView
        anchors.fill: parent
        model: ListModel {}
        header: SectionHeader { id: sectionHeader; text: qsTr("List Info") }
        delegate: ListItem {
            id: listItem
            height: listItemColumn.height + 2 * constant.paddingLarge
            platformInverted: settings.invertedTheme
            subItemIndicator: model.clickedString
            onClicked: if (model.clickedString) eval(model.clickedString)

            Column {
                id: listItemColumn
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.paddingItem.left; right: parent.paddingItem.right
                }
                height: childrenRect.height

                ListItemText {
                    id: titleText
                    anchors { left: parent.left; right: parent.right }
                    platformInverted: listItem.platformInverted
                    role: "Title"
                    mode: listItem.mode
                    text: title
                    wrapMode: Text.Wrap
                    font.bold: true
                }
                ListItemText {
                    id: subTitleText
                    anchors { left: parent.left; right: parent.right }
                    platformInverted: listItem.platformInverted
                    role: "SubTitle"
                    mode: listItem.mode
                    text: subtitle
                    wrapMode: Text.Wrap
                    elide: Text.ElideNone
                    font.pixelSize: constant.fontSizeMedium
                }
            }
        }
    }
}
