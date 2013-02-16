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

Page {
    id: trendsPage

    property bool savedSearchLoading: false
    property bool trendingLoading: false

    property ListModel trendsLocationModel: ListModel {}
    property ListModel autoCompleterModel: ListModel {}

    Component.onCompleted: if (cache.trendsModel.count === 0) internal.refresh()

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolIcon {
            iconSource: "image://theme/icon-s-location-picker" + (settings.invertedTheme ? "" : "-inverse")
            onClicked: pageStack.push(Qt.resolvedUrl("NearbyTweetsPage.qml"))
        }
        ToolIcon {
            iconSource: "image://theme/icon-m-toolbar-people" + (settings.invertedTheme ? "-dimmed" : "") + "-white"
            onClicked: pageStack.push(Qt.resolvedUrl("UserCategoryPage.qml"))
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
                text: qsTr("Advanced search")
                onClicked: pageStack.push(Qt.resolvedUrl("AdvSearchPage.qml"))
            }
            MenuItem {
                text: qsTr("Change trends location")
                onClicked: {
                    if (trendsLocationModel.count === 0) {
                        Twitter.getTrendsAvailable(internal.trendsLocationOnSuccess, internal.trendsLocationOnFailure)
                        loadingRect.visible = true
                    }
                    else internal.createTrendsLocationDialog()
                }
            }
        }
    }

    PullDownListView {
        id: trendsPageListView
        anchors { top: searchTextFieldContainer.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        model: cache.trendsModel
        lastUpdate: cache.trendsLastUpdate
        section.property: model == cache.trendsModel ? "type" : ""
        section.delegate: SectionHeader { text: section }
        delegate: ListItem {
            id: trendsListItem
            height: titleText.height + 2 * titleText.anchors.margins

            Text {
                id: titleText
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left; right: parent.right
                    margins: constant.paddingLarge
                }
                font.pixelSize: constant.fontSizeMedium
                color: constant.colorLight
                elide: Text.ElideRight
                text: model.title || model.completeWord
            }

            onPressed: internal.pressedOnListItem = true
            onClicked: {
                if (trendsPageListView.model === cache.trendsModel) {
                    var prop = {
                        searchString: model.title,
                        isSavedSearch: type === qsTr("Saved Searches"),
                        savedSearchId: model.id
                    }
                    pageStack.push(Qt.resolvedUrl("SearchPage.qml"), prop)
                }
                else {
                    if (model.completeWord.charAt(0) === "@")
                        pageStack.push(Qt.resolvedUrl("UserPage.qml"), {screenName: model.completeWord.slice(1)})
                    else pageStack.push(Qt.resolvedUrl("SearchPage.qml"), {searchString: model.completeWord})
                }
            }
        }
        onPulledDown: if (model === cache.trendsModel) internal.refresh()
    }

    ScrollDecorator { flickableItem: trendsPageListView }

    Item {
        id: searchTextFieldContainer
        anchors { top: header.bottom; left: parent.left; right: parent.right }
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
            platformSipAttributes: SipAttributes {
                actionKeyEnabled: searchTextField.text || searchTextField.platformPreedit
                actionKeyHighlighted: true
                actionKeyLabel: qsTr("Search")
            }
            onAccepted: {
                parent.focus = true // remove activeFocus on searchTextField
                pageStack.push(Qt.resolvedUrl("SearchPage.qml"), { searchString: searchTextField.text })
            }
            onActiveFocusChanged: {
                if (activeFocus) trendsPageListView.model = autoCompleterModel
                else if (internal.pressedOnListItem) {
                    switchToTrendsModelDelayTimer.start()
                    internal.pressedOnListItem = false
                }
                else trendsPageListView.model = cache.trendsModel
            }
            onTextChanged: internal.updateAutoCompleter()
            onPlatformPreeditChanged: internal.updateAutoCompleter()
        }

        // If trendsPageListView.model is immediately switch to trendsModel, the trendsPageListView.delegate
        // clicked action can not be trigger because the model changed and that pressed delegate is destroyed
        // Therefore, a dirty timer is used for delay switching to trendsModel if the delegate is pressed
        Timer {
            id: switchToTrendsModelDelayTimer
            interval: 250
            onTriggered: trendsPageListView.model = cache.trendsModel
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
            onClicked: pageStack.push(Qt.resolvedUrl("SearchPage.qml"), { searchString: searchTextField.text })
        }
    }

    PageHeader {
        id: header
        headerIcon: "image://theme/icon-m-toolbar-search-white-selected"
        headerText: qsTr("Trends & Search")
        busy: savedSearchLoading || trendingLoading
        onClicked: trendsPageListView.positionViewAtBeginning()
    }

    QtObject {
        id: internal

        property bool pressedOnListItem: false
        property Component __trendsLocationDialog: null

        function refresh() {
            cache.trendsModel.clear()
            Twitter.getSavedSearches(savedSearchOnSuccess, savedSearchOnFailure)
            Twitter.getTrends(settings.trendsLocationWoeid, trendsOnSuccess, trendsOnFailure)
            savedSearchLoading = true
            trendingLoading = true
        }

        function updateAutoCompleter() {
            if (trendsPage.status !== PageStatus.Active || !searchTextField.activeFocus) return
            autoCompleterModel.clear()
            var fullText = searchTextField.text.substring(0, searchTextField.cursorPosition)
                    + searchTextField.platformPreedit + searchTextField.text.substring(searchTextField.cursorPosition)
            if (!fullText) return
            switch (fullText.charAt(0)) {
            case "@": case "#": break;
            default: fullText = "@" + fullText; break;
            }
            var msg = {
                word: fullText,
                model: autoCompleterModel,
                screenNames: cache.screenNames,
                hashtags: cache.hashtags
            }
            autoCompleterWorker.sendMessage(msg)
        }

        function trendsOnSuccess(data) {
            cache.trendsLastUpdate = new Date().toString()
            var hashtagsArray = []
            for (var i=0; i<data[0].trends.length; i++) {
                var obj = {
                    "id": "",
                    "title": data[0].trends[i].name,
                    "type": qsTr("Trends (%1)").arg(data[0].locations[0].name)
                }
                cache.trendsModel.append(obj)
                if (data[0].trends[i].name.indexOf('#') === 0) hashtagsArray.push(data[0].trends[i].name.substring(1))
            }
            cache.storeHashtags(hashtagsArray);
            trendingLoading = false
        }

        function trendsOnFailure(status, statusText) {
            infoBanner.showHttpError(status, statusText)
            cache.trendsModel.append({"title": qsTr("Unable to retrieve trends"), "type": qsTr("Trends")})
            trendingLoading = false
        }

        function savedSearchOnSuccess(data) {
            for (var i=0; i<data.length; i++) {
                var obj = {
                    "id": data[i].id,
                    "title": data[i].name,
                    "type": qsTr("Saved Searches")
                }
                cache.trendsModel.insert(i, obj)
            }
            savedSearchLoading = false
        }

        function savedSearchOnFailure(status, statusText) {
            infoBanner.showHttpError(status, statusText)
            cache.trendsModel.insert(0,{"title": qsTr("Unabled to retrieve saved search"), "type": qsTr("Saved Searches")})
            savedSearchLoading = false
        }

        function trendsLocationOnSuccess(data) {
            trendsLocationModel.append({name: qsTr("Worldwide"), woeid: 1})
            for (var i=0; i < data.length; i++) {
                if (data[i].placeType.name === "Country") {
                    var obj = {
                        name: data[i].name,
                        woeid: data[i].woeid
                    }
                    trendsLocationModel.append(obj)
                }
            }
            loadingRect.visible = false
            createTrendsLocationDialog()
        }

        function trendsLocationOnFailure(status, statusText) {
            infoBanner.showHttpError(status, statusText)
            loadingRect.visible = false
        }

        function createTrendsLocationDialog() {
            if (!__trendsLocationDialog) __trendsLocationDialog = Qt.createComponent("Dialog/TrendsLocationDialog.qml")
            var dialog = __trendsLocationDialog.createObject(trendsPage, { model: trendsLocationModel })
            dialog.accepted.connect(function() {
                settings.trendsLocationWoeid = trendsLocationModel.get(dialog.selectedIndex).woeid
                refresh()
            })
        }
    }

    WorkerScript { id: autoCompleterWorker; source: "WorkerScript/AutoCompleter.js" }
}
