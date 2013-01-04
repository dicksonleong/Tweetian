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
import "Services/Twitter.js" as Twitter
import "Component"
import "SearchPageCom"

Page {
    id: searchPage

    property string searchString

    property bool isSavedSearch: false
    property string savedSearchId: ""

    Component.onCompleted: {
        if (!isSavedSearch || !savedSearchId) internal.checkIsSavedSearch()
        if (!searchListView.currentItem.firstTimeLoaded) searchListView.currentItem.refresh("all")
    }

    tools: ToolBarLayout {
        ToolIcon {
            id: backButton
            platformIconId: "toolbar-back" + (enabled ? "" : "-dimmed")
            onClicked: pageStack.pop()
        }
        ToolIcon {
            platformIconId: isSavedSearch ? "toolbar-delete" : "toolbar-add"
            onClicked: isSavedSearch ? internal.createRemoveSavedSearchDialog() : internal.createSaveSearchDialog()
        }
        Item { width: 80; height: 64 }
    }

    ListView {
        id: searchListView

        property int __contentXOffset: 0

        function moveToColumn(index) {
            columnMovingAnimation.to = (index * width) + __contentXOffset
            columnMovingAnimation.restart()
        }

        anchors {
            top: searchTextFieldContainer.bottom; bottom: parent.bottom
            left: parent.left; right: parent.right
        }
        highlightRangeMode: ListView.StrictlyEnforceRange
        snapMode: ListView.SnapOneItem
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        model: VisualItemModel {
            TweetSearchColumn {}
            UserSearchColumn {}
        }
        onCurrentIndexChanged: if (!currentItem.firstTimeLoaded) currentItem.refresh("all")
        onWidthChanged: __contentXOffset = contentX - (currentIndex * width)

        NumberAnimation {
            id: columnMovingAnimation
            target: searchListView
            property: "contentX"
            duration: 500
            easing.type: Easing.InOutExpo
        }
    }

    Item {
        id: searchTextFieldContainer
        anchors { top: searchPageHeader.bottom; left: parent.left; right: parent.right }
        height: searchTextField.height + 2 * searchTextField.anchors.margins

        BorderImage {
            anchors.fill: parent
            border { left: 22; top: 22; right: 22; bottom: 22 }
            source: "image://theme/meegotouch-button" + (settings.invertedTheme ? "" : "-inverted")
                    + "-background-horizontal-center"
        }

        TextField {
            id: searchTextField
            anchors { top: parent.top; left: parent.left; right: searchButton.left; margins: constant.paddingMedium }
            placeholderText: qsTr("Search for tweets or users")
            text: searchString
            platformSipAttributes: SipAttributes {
                actionKeyEnabled: searchTextField.text || searchTextField.platformPreedit
                actionKeyHighlighted: true
                actionKeyLabel: qsTr("Search")
            }
            onAccepted: {
                parent.focus = true // remove activeFocus on searchTextField
                internal.changeSearch()
            }
            onActiveFocusChanged: if (!activeFocus) resetSearchTextTimer.start()
        }

        Timer {
            id: resetSearchTextTimer
            interval: 100
            onTriggered: searchTextField.text = searchString
        }

        Button {
            id: searchButton
            anchors { top: parent.top; bottom: parent.bottom; right: parent.right; margins: constant.paddingMedium }
            width: height
            // the following line will cause the button can not be clicked when there is pre-edit text
            // in textField because it will set enabled to false when keyboard closing
            //enabled: searchTextField.text || searchTextField.platformPreedit
            //opacity: enabled ? 1 : 0.25
            iconSource: "image://theme/icon-m-toolbar-search" + (settings.invertedTheme ? "" : "-white-selected")
            onClicked: internal.changeSearch()
        }
    }

    TabPageHeader {
        id: searchPageHeader
        listView: searchListView
        iconArray: [Qt.resolvedUrl("Image/chat.png"), "image://theme/icon-m-toolbar-contact-white-selected"]
    }

    QtObject {
        id: internal

        function changeSearch() {
            searchString = searchTextField.text
            for (var i=0; i<searchListView.model.children.length; i++) {
                searchListView.model.children[i].firstTimeLoaded = false
            }
            searchListView.currentItem.refresh("all")
            isSavedSearch = false
            savedSearchId = ""
            checkIsSavedSearch()
        }

        function savedSearchOnSuccess(data) {
            if (cache.trendsModel.count > 0)
                cache.trendsModel.insert(0,{"title": data.name, "query": data.query, "id": data.id, "type": qsTr("Saved Searches")})
            isSavedSearch = true
            savedSearchId = data.id
            loadingRect.visible = false
            infoBanner.showText(qsTr("The search %1 is saved successfully").arg("\""+data.name+"\""))
        }

        function savedSearchOnFailure(status, statusText) {
            infoBanner.showHttpError(status, statusText)
            loadingRect.visible = false
        }

        function removeSearchOnSuccess(data) {
            for (var i=0; i<cache.trendsModel.count; i++) {
                if (cache.trendsModel.get(i).title === data.name) {
                    cache.trendsModel.remove(i)
                    break
                }
            }
            isSavedSearch = false
            savedSearchId = ""
            loadingRect.visible = false
            infoBanner.showText(qsTr("The saved search %1 is removed successfully").arg("\""+data.name+"\""))
        }

        function removeSearchOnFailure(status, statusText) {
            infoBanner.showHttpError(status, statusText)
            loadingRect.visible = false
        }

        function checkIsSavedSearch() {
            for (var i=0; i<cache.trendsModel.count; i++) {
                if (cache.trendsModel.get(i).type !== qsTr("Saved Searches"))
                    break
                if (cache.trendsModel.get(i).title === searchString) {
                    isSavedSearch = true
                    savedSearchId = cache.trendsModel.get(i).id
                    break
                }
            }
        }

        function createSaveSearchDialog() {
            var message = qsTr("Do you want to save the search %1?").arg("\""+searchString+"\"")
            dialog.createQueryDialog(qsTr("Save Search"), "", message, function() {
                Twitter.postSavedSearches(searchString, savedSearchOnSuccess, savedSearchOnFailure)
                loadingRect.visible = true
            })
        }

        function createRemoveSavedSearchDialog() {
            var message = qsTr("Do you want to remove the saved search %1?").arg("\""+searchString+"\"")
            dialog.createQueryDialog(qsTr("Remove Saved Search"), "", message, function() {
                Twitter.postRemoveSavedSearch(searchPage.savedSearchId, removeSearchOnSuccess, removeSearchOnFailure)
                loadingRect.visible = true
            })
        }
    }
}
