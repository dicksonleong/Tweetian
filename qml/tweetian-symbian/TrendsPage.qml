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

Page {
    id: trendsPage

    property bool savedSearchLoading: false
    property bool trendingLoading: false

    property ListModel trendsLocationModel: ListModel {}
    property ListModel autoCompleterModel: ListModel {}

    Component.onCompleted: if (cache.trendsModel.count === 0) internal.refresh()

    tools: ToolBarLayout {
        ToolButtonWithTip {
            iconSource: "toolbar-back"
            toolTipText: qsTr("Back")
            onClicked: pageStack.pop()
        }
        ToolButtonWithTip {
            iconSource: settings.invertedTheme ? "Image/location_mark_inverse.svg" : "Image/location_mark.svg"
            toolTipText: qsTr("Nearby tweets")
            onClicked: pageStack.push(Qt.resolvedUrl("NearbyTweetsPage.qml"))
        }
        ToolButtonWithTip {
            iconSource: "Image/people" + (settings.invertedTheme ? "_inverse.svg" : ".svg")
            toolTipText: qsTr("Suggested Users")
            onClicked: pageStack.push(Qt.resolvedUrl("UserCategoryPage.qml"))
        }
        ToolButtonWithTip {
            iconSource: "toolbar-menu"
            toolTipText: qsTr("Menu")
            onClicked: menu.open()
        }
    }

    Menu {
        id: menu
        platformInverted: settings.invertedTheme

        MenuLayout {
            MenuItem {
                text: qsTr("Advanced search")
                platformInverted: menu.platformInverted
                onClicked: pageStack.push(Qt.resolvedUrl("AdvSearchPage.qml"))
            }
            MenuItem {
                text: qsTr("Change trends location")
                platformInverted: menu.platformInverted
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
            height: titleText.height + 2 * constant.paddingLarge
            platformInverted: settings.invertedTheme

            ListItemText {
                id: titleText
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.paddingItem.left; right: parent.paddingItem.right
                }
                platformInverted: parent.platformInverted
                mode: trendsListItem.mode
                role: "Title"
                text: model.title || model.completeWord
            }

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
                    searchTextField.parent.focus = true // remove activeFocus on searchTextField
                }
            }
        }
        onPulledDown: if (model === cache.trendsModel) internal.refresh()
    }

    ScrollDecorator { platformInverted: settings.invertedTheme; flickableItem: trendsPageListView }

    Item {
        id: searchTextFieldContainer
        anchors { top: header.bottom; left: parent.left; right: parent.right }
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
            onActiveFocusChanged: {
                if (activeFocus) trendsPageListView.model = autoCompleterModel
                else trendsPageListView.model = cache.trendsModel
            }
            onTextChanged: internal.updateAutoCompleter()
            Keys.onEnterPressed: {
                event.accepted = true
                searchTextField.parent.focus = true // remove activeFocus on searchTextField
                pageStack.push(Qt.resolvedUrl("SearchPage.qml"), { searchString: searchTextField.text })
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
            onClicked: {
                searchTextField.parent.focus = true // remove activeFocus on searchTextField
                pageStack.push(Qt.resolvedUrl("SearchPage.qml"), { searchString: searchTextField.text })
            }
        }
    }

    PageHeader {
        id: header
        headerIcon: "image://theme/toolbar-search"
        headerText: qsTr("Trends & Search")
        busy: savedSearchLoading || trendingLoading
        onClicked: trendsPageListView.positionViewAtBeginning()
    }

    QtObject {
        id: internal

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
            var fullText = searchTextField.text
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
