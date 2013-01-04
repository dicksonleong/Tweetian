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
import "Services/Twitter.js" as Twitter
import "Component"
import "SearchPageCom"

Page {
    id: searchPage

    property string searchString

    property bool isSavedSearch: false
    property string savedSearchId: ""

    onSearchStringChanged: if (!searchListView.currentItem.firstTimeLoaded) searchListView.currentItem.refresh("all")

    Component.onCompleted: if (searchString && (!isSavedSearch || !savedSearchId)) internal.checkIsSavedSearch()

    tools: ToolBarLayout {
        ToolButtonWithTip {
            id: backButton
            iconSource: "toolbar-back"
            toolTipText: qsTr("Back")
            onClicked: pageStack.pop()
        }
        ToolButtonWithTip {
            iconSource: isSavedSearch ? "toolbar-delete" : "toolbar-add"
            toolTipText: isSavedSearch ? qsTr("Remove saved search") : qsTr("Add to saved search")
            onClicked: isSavedSearch ? internal.createRemoveSavedSearchDialog() : internal.createSaveSearchDialog()
        }
        ToolButton { visible: false }
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
        onCurrentIndexChanged: if (searchString && !currentItem.firstTimeLoaded) currentItem.refresh("all")
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
            border { left: 20; top: 20; right: 20; bottom: 20 }
            source: "image://theme/qtg_fr_pushbutton_segmented_c_normal" + (settings.invertedTheme ? "_inverse" : "")
        }

        TextField {
            id: searchTextField
            anchors { top: parent.top; left: parent.left; right: searchButton.left; margins: constant.paddingMedium }
            platformInverted: settings.invertedTheme
            // disable predictive text because there is no way to get pre-edit text in Symbian
            inputMethodHints: Qt.ImhNoPredictiveText
            placeholderText: qsTr("Search for tweets or users")
            text: searchString
            onActiveFocusChanged: if (!activeFocus) searchTextField.text = searchString
            Keys.onEnterPressed: {
                event.accepted = true
                internal.changeSearch()
            }
        }

        // When keyboard is closed, searchTextField still on activeFocus
        // The following connection is to remove activeFocus on searchTextField when keyboard is closed
        Connections {
            target: inputContext
            onVisibleChanged: if (!inputContext.visible) searchTextField.parent.focus = true
        }

        Button {
            id: searchButton
            anchors { top: parent.top; bottom: parent.bottom; right: parent.right; margins: constant.paddingMedium }
            platformInverted: settings.invertedTheme
            width: height
            enabled: searchTextField.text
            opacity: enabled ? 1 : 0.25
            iconSource: "image://theme/toolbar-search" + (platformInverted ? "_inverse" : "")
            onClicked: internal.changeSearch()
        }
    }

    TabPageHeader {
        id: searchPageHeader
        listView: searchListView
        iconArray: [Qt.resolvedUrl("Image/chat.png"), Qt.resolvedUrl("Image/contacts.svg")]
    }

    QtObject {
        id: internal

        property string reloadType: "all"

        function changeSearch() {
            searchString = searchTextField.text
            searchTextField.parent.focus = true // remove activeFocus on searchTextField
            for (var i=0; i<searchListView.model.children.length; i++) {
                searchListView.model.children[i].firstTimeLoaded = false
            }
            searchListView.currentItem.refresh("all")
            isSavedSearch = false
            savedSearchId = ""
            checkIsSavedSearch()
        }

        function searchOnSuccess(data) {
            if (reloadType != "older") searchListView.lastUpdate = new Date().toString()
            backButton.enabled = false
            searchParser.sendMessage({'model': searchListView.model, 'data': data, 'reloadType': reloadType})
        }

        function searchOnFailure(status, statusText) {
            infoBanner.showHttpError(status, statusText)
            header.busy = false
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
            var icon = settings.invertedTheme ? "Image/save_inverse.svg" : "Image/save.svg"
            var message = qsTr("Do you want to save the search %1?").arg("\""+searchString+"\"")
            dialog.createQueryDialog(qsTr("Save Search"), icon, message, function() {
                Twitter.postSavedSearches(searchString, savedSearchOnSuccess, savedSearchOnFailure)
                loadingRect.visible = true
            })
        }

        function createRemoveSavedSearchDialog() {
            var icon = settings.invertedTheme ? "image://theme/toolbar-delete_inverse"
                                              : "image://theme/toolbar-delete"
            var message = qsTr("Do you want to remove the saved search %1?").arg("\""+searchString+"\"")
            dialog.createQueryDialog(qsTr("Remove Saved Search"), icon, message, function() {
                Twitter.postRemoveSavedSearch(searchPage.savedSearchId, removeSearchOnSuccess, removeSearchOnFailure)
                loadingRect.visible = true
            })
        }
    }
}
