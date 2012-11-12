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

Page{
    id: trendsPage

    property bool savedSearchLoading: false
    property bool trendingLoading: false
    property ListModel trendsLocationModel: ListModel{}

    Component.onCompleted: if(cache.trendsModel.count === 0) internal.refresh()

    tools: ToolBarLayout{
        ToolIcon{
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolIcon{
            platformIconId: "toolbar-search"
            onClicked: internal.createSearchDialog()
        }
        ToolIcon{
            platformIconId: "toolbar-people"
            onClicked: pageStack.push(Qt.resolvedUrl("UserCategoryPage.qml"))
        }
        ToolIcon{
            platformIconId: "toolbar-view-menu"
            onClicked: menu.open()
        }
    }

    Menu{
        id: menu

        MenuLayout{
            MenuItem{
                text: qsTr("Nearby Tweets")
                onClicked: pageStack.push(Qt.resolvedUrl("NearbyTweetsPage.qml"))
            }
            MenuItem{
                text: qsTr("Change trends location")
                onClicked: {
                    if(trendsLocationModel.count == 0) {
                        Twitter.getTrendsAvailable(internal.trendsLocationOnSuccess, internal.trendsLocationOnFailure)
                        loadingRect.visible = true
                    }
                    else internal.createTrendsLocationDialog()
                }
            }
        }
    }

    AbstractListView{
        id: trendsPageListView
        anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        model: cache.trendsModel
        lastUpdate: cache.trendsLastUpdate
        section.property: "type"
        section.delegate: SectionHeader{ text: section }
        delegate: ListItem{
            id: trendsListItem
            height: titleText.height + 2 * titleText.anchors.margins

            Text{
                id: titleText
                anchors { top: parent.top; left: parent.left; right: parent.right; margins: constant.paddingXLarge }
                font.pixelSize: constant.fontSizeMedium
                color: constant.colorLight
                elide: Text.ElideRight
                text: title
            }

            onClicked: {
                var prop = { searchName: title, isSavedSearch: type === qsTr("Saved Searches"), savedSearchId: id }
                pageStack.push(Qt.resolvedUrl("SearchPage.qml"), prop)
            }
            onPressAndHold: {
                if(type === qsTr("Saved Searches"))
                    savedSearchMenuComponent.createObject(trendsPage, { id: id, searchName: title })
            }
        }
        onPullDownRefresh: internal.refresh()
    }

    ScrollDecorator{ flickableItem: trendsPageListView }

    PageHeader{
        id: header
        headerIcon: "image://theme/icon-m-toolbar-search-white-selected"
        headerText: qsTr("Trends & Search")
        busy: savedSearchLoading || trendingLoading
        onClicked: trendsPageListView.positionViewAtBeginning()
    }

    QtObject{
        id: internal

        property Component __searchDialog: null
        property Component __trendsLocationDialog: null

        function removeSearchOnSuccess(data){
            for(var i=0; i<trendsPageListView.count; i++){
                if(trendsPageListView.model.get(i).title == data.name){
                    trendsPageListView.model.remove(i)
                    break
                }
            }
            infoBanner.alert(qsTr("The saved search %1 is removed successfully").arg("\""+data.name+"\""))
            savedSearchLoading = false
        }

        function removeSearchOnFailure(status, statusText){
            infoBanner.showHttpError(status, statusText)
            savedSearchLoading = false
        }

        function trendsOnSuccess(data){
            cache.trendsLastUpdate = new Date().toString()
            var hashtagsArray = []
            for(var i=0; i<data[0].trends.length; i++){
                var obj = {
                    "id": "",
                    "title": data[0].trends[i].name,
                    "query":data[0].trends[i].query,
                    "type": qsTr("Trends (%1)").arg(data[0].locations[0].name)
                }
                trendsPageListView.model.append(obj)
                if(data[0].trends[i].name.indexOf('#') == 0) hashtagsArray.push(data[0].trends[i].name.substring(1))
            }
            cache.pushToHashtags(hashtagsArray)
            trendingLoading = false
        }

        function trendsOnFailure(status, statusText){
            infoBanner.showHttpError(status, statusText)
            trendsPageListView.model.append({"title": qsTr("Unable to retrieve trends"), "type": qsTr("Trends")})
            trendingLoading = false
        }

        function savedSearchOnSuccess(data){
            for(var i=0; i<data.length; i++){
                var obj = {
                    "id": data[i].id,
                    "title": data[i].name,
                    "query": data[i].query,
                    "type": qsTr("Saved Searches")
                }
                trendsPageListView.model.insert(i, obj)
            }
            savedSearchLoading = false
        }

        function savedSearchOnFailure(status, statusText){
            infoBanner.showHttpError(status, statusText)
            trendsPageListView.model.insert(0,{"title": qsTr("Unabled to retrieve saved search"), "type": qsTr("Saved Searches")})
            savedSearchLoading = false
        }

        function trendsLocationOnSuccess(data){
            trendsLocationModel.append({name: qsTr("Worldwide"), woeid: 1})
            for(var i=0; i < data.length; i++){
                if(data[i].placeType.name === "Country"){
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

        function trendsLocationOnFailure(status, statusText){
            infoBanner.showHttpError(status, statusText)
            loadingRect.visible = false
        }

        function refresh(){
            trendsPageListView.model.clear()
            Twitter.getSavedSearches(savedSearchOnSuccess, savedSearchOnFailure)
            Twitter.getTrends(settings.trendsLocationWoeid, trendsOnSuccess, trendsOnFailure)
            savedSearchLoading = true
            trendingLoading = true
        }

        function createRemoveSavedSearchDialog(id, searchName){
            var message = qsTr("Do you want to remove the saved search %1?").arg("\""+searchName+"\"")
            dialog.createQueryDialog(qsTr("Remove Saved Search"), "", message, function(){
                Twitter.postRemoveSavedSearch(id, removeSearchOnSuccess, removeSearchOnFailure)
                savedSearchLoading = true
            })
        }

        function createSearchDialog(){
            if(!__searchDialog) __searchDialog = Qt.createComponent("Dialog/SearchDialog.qml")
            __searchDialog.createObject(trendsPage)
        }

        function createTrendsLocationDialog(){
            if(!__trendsLocationDialog) __trendsLocationDialog = Qt.createComponent("Dialog/TrendsLocationDialog.qml")
            var dialog = __trendsLocationDialog.createObject(trendsPage, { model: trendsLocationModel })
            dialog.accepted.connect(function(){
                settings.trendsLocationWoeid = trendsLocationModel.get(dialog.selectedIndex).woeid
                refresh()
            })
        }
    }

    Component{
        id: savedSearchMenuComponent

        ContextMenu{
            id: savedSearchMenu

            property int id
            property string searchName: ""
            property bool __isClosing: false

            MenuLayout{
                MenuItem{
                    text: qsTr("Remove saved search")
                    onClicked: internal.createRemoveSavedSearchDialog(savedSearchMenu.id, savedSearchMenu.searchName)
                }
            }

            Component.onCompleted: open()
            onStatusChanged: {
                if(status === DialogStatus.Closing) __isClosing = true
                else if(status === DialogStatus.Closed && __isClosing) savedSearchMenu.destroy(250)
            }
        }
    }
}
