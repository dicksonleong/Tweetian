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
import "Utils/Calculations.js" as Calculate
import "Component"
import "Delegate"

Page {
    id: searchPage

    property string searchName

    property bool isSavedSearch: false
    property string savedSearchId: ""

    onSearchNameChanged: internal.refresh("all")

    Component.onCompleted: if (!isSavedSearch || !savedSearchId) internal.checkIsSavedSearch()

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
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            onClicked: menu.open()
        }
    }

    Menu {
        id: menu

        MenuLayout {
            MenuItem {
                text: qsTr("Refresh cache")
                enabled: !header.busy
                onClicked: internal.refresh("all")
            }
        }
    }

    PullDownListView {
        id: searchListView
        property bool stayAtCurrentPosition: internal.reloadType === "newer"
        anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        footer: LoadMoreButton {
            visible: searchListView.count > 0
            enabled: !header.busy
            onClicked: internal.refresh("older")
        }
        delegate: TweetDelegate {}
        model: ListModel {}
        onPulledDown: internal.refresh("newer")
        onAtYBeginningChanged: if (atYBeginning) header.countBubbleValue = 0
        onContentYChanged: refreshUnreadCountTimer.running = true

        Timer {
            id: refreshUnreadCountTimer
            interval: 250
            repeat: false
            onTriggered: header.countBubbleValue = Math.min(searchListView.indexAt(0, searchListView.contentY + 5) + 1,
                                                            header.countBubbleValue)
        }
    }

    Text {
        anchors.centerIn: parent
        font.pixelSize: constant.fontSizeXXLarge
        color: constant.colorMid
        text: qsTr("No search result")
        visible: searchListView.count == 0 && !header.busy
    }

    ScrollDecorator { flickableItem: searchListView }

    PageHeader {
        id: header
        headerIcon: "image://theme/icon-m-toolbar-search-white-selected"
        headerText: qsTr("Search: %1").arg("\"" + searchName + "\"")
        onClicked: searchListView.positionViewAtBeginning()
    }

    WorkerScript {
        id: searchParser
        source: "WorkerScript/SearchParser.js"
        onMessage: {
            backButton.enabled = true
            if (internal.reloadType === "newer") {
                header.countBubbleVisible = true
                header.countBubbleValue = messageObject.count
            }
            else {
                header.countBubbleVisible = false
                header.countBubbleValue = 0
            }
            header.busy = false
        }
    }

    QtObject {
        id: internal

        property string reloadType: "all"

        function refresh(type) {
            var sinceId = "", maxId = ""
            if (searchListView.count > 0) {
                if (type === "newer") sinceId = searchListView.model.get(0).tweetId
                else if (type === "older") maxId =  searchListView.model.get(searchListView.count - 1).tweetId
                else if (type === "all") searchListView.model.clear()
            }
            else type = "all"
            internal.reloadType = type
            Twitter.getSearch(searchName, sinceId, Calculate.minusOne(maxId), searchOnSuccess, searchOnFailure)
            header.busy = true
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
                if (cache.trendsModel.get(i).title === searchName) {
                    isSavedSearch = true
                    savedSearchId = cache.trendsModel.get(i).id
                    break
                }
            }
        }

        function createSaveSearchDialog() {
            var message = qsTr("Do you want to save the search %1?").arg("\""+searchName+"\"")
            dialog.createQueryDialog(qsTr("Save Search"), "", message, function() {
                Twitter.postSavedSearches(searchName, savedSearchOnSuccess, savedSearchOnFailure)
                loadingRect.visible = true
            })
        }

        function createRemoveSavedSearchDialog() {
            var message = qsTr("Do you want to remove the saved search %1?").arg("\""+searchName+"\"")
            dialog.createQueryDialog(qsTr("Remove Saved Search"), "", message, function() {
                Twitter.postRemoveSavedSearch(searchPage.savedSearchId, removeSearchOnSuccess, removeSearchOnFailure)
                loadingRect.visible = true
            })
        }
    }
}
