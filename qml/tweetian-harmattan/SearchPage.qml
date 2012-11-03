import QtQuick 1.1
import com.nokia.meego 1.0
import "twitter.js" as Twitter
import "Utils/Calculations.js" as Calculate
import "Component"
import "Delegate"

Page{
    id: searchPage

    property string searchName

    property bool isSavedSearch: false
    property string savedSearchId: ""

    onSearchNameChanged: internal.refresh("all")

    Component.onCompleted: if(!isSavedSearch || !savedSearchId) internal.checkIsSavedSearch()

    tools: ToolBarLayout{
        ToolIcon{
            id: backButton
            platformIconId: "toolbar-back" + (enabled ? "" : "-dimmed")
            onClicked: pageStack.pop()
        }
        ToolIcon{
            platformIconId: isSavedSearch ? "toolbar-delete" : "toolbar-add"
            onClicked: isSavedSearch ? internal.createRemoveSavedSearchDialog() : internal.createSaveSearchDialog()
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
                text: "Refresh Cache"
                enabled: !header.busy
                onClicked: internal.refresh("all")
            }
        }
    }

    AbstractListView{
        id: searchListView
        property bool stayAtCurrentPosition: internal.reloadType === "newer"
        anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        footer: LoadMoreButton{
            visible: searchListView.count > 0
            enabled: !header.busy
            onClicked: internal.refresh("older")
        }
        delegate: TweetDelegate{}
        model: ListModel{}
        onPullDownRefresh: internal.refresh("newer")
        onAtYBeginningChanged: if(atYBeginning) header.countBubbleValue = 0
        onContentYChanged: refreshUnreadCountTimer.running = true

        Timer{
            id: refreshUnreadCountTimer
            interval: 250
            repeat: false
            onTriggered: header.countBubbleValue = Math.min(searchListView.indexAt(0, searchListView.contentY + 5) + 1,
                                                            header.countBubbleValue)
        }
    }

    Text{
        anchors.centerIn: parent
        font.pixelSize: constant.fontSizeXXLarge
        color: constant.colorMid
        text: "No search result"
        visible: searchListView.count == 0 && !header.busy
    }

    ScrollDecorator{ flickableItem: searchListView }

    PageHeader{
        id: header
        headerIcon: "image://theme/icon-m-toolbar-search-white-selected"
        headerText: "Search: \"" + searchName + "\""
        onClicked: searchListView.positionViewAtBeginning()
    }

    WorkerScript{
        id: searchParser
        source: "WorkerScript/SearchParser.js"
        onMessage: {
            backButton.enabled = true
            if(internal.reloadType === "newer") {
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

    QtObject{
        id: internal

        property string reloadType: "all"

        function refresh(type){
            var sinceId = "", maxId = ""
            if(searchListView.count > 0){
                if(type === "newer") sinceId = searchListView.model.get(0).tweetId
                else if(type === "older") maxId =  searchListView.model.get(searchListView.count - 1).tweetId
                else if(type === "all") searchListView.model.clear()
            }
            else type = "all"
            internal.reloadType = type
            Twitter.getSearch(searchName, sinceId, Calculate.minusOne(maxId), searchOnSuccess, searchOnFailure)
            header.busy = true
        }

        function searchOnSuccess(data){
            if(reloadType != "older") searchListView.lastUpdate = new Date().toString()
            backButton.enabled = false
            searchParser.sendMessage({'model': searchListView.model, 'data': data, 'reloadType': reloadType})
        }

        function searchOnFailure(status, statusText){
            if(status === 0) infoBanner.alert("Connection error.")
            else infoBanner.alert("Error:" +status+" "+statusText)
            header.busy = false
        }

        function savedSearchOnSuccess(data){
            if(cache.trendsModel.count > 0)
                cache.trendsModel.insert(0,{"title": data.name, "query": data.query, "id": data.id, "type": "Saved Searches"})
            isSavedSearch = true
            savedSearchId = data.id
            loadingRect.visible = false
            infoBanner.alert("The search \"" + data.name + "\" is saved.")
        }

        function savedSearchOnFailure(status, statusText){
            if(status === 0) infoBanner.alert("Connection error.")
            else infoBanner.alert("Error: " + status + " " + statusText)
            loadingRect.visible = false
        }

        function removeSearchOnSuccess(data){
            for(var i=0; i<cache.trendsModel.count; i++){
                if(cache.trendsModel.get(i).title === data.name){
                    cache.trendsModel.remove(i)
                    break
                }
            }
            isSavedSearch = false
            savedSearchId = ""
            loadingRect.visible = false
            infoBanner.alert("The saved search \"" + data.name + "\" is removed.")
        }

        function removeSearchOnFailure(status, statusText){
            if(status === 0) infoBanner.alert("Connection error.")
            else infoBanner.alert("Error: " + status + " " + statusText)
            loadingRect.visible = false
        }

        function checkIsSavedSearch(){
            for(var i=0; i<cache.trendsModel.count; i++){
                if(cache.trendsModel.get(i).type !== "Saved Searches")
                    break
                if(cache.trendsModel.get(i).title === searchName){
                    isSavedSearch = true
                    savedSearchId = cache.trendsModel.get(i).id
                    break
                }
            }
        }

        function createSaveSearchDialog(){
            var message = "Do you want to save the search \""+searchName+"\"?"
            dialog.createQueryDialog("Save Search", "", message, function(){
                Twitter.postSavedSearches(searchName, savedSearchOnSuccess, savedSearchOnFailure)
                loadingRect.visible = true
            })
        }

        function createRemoveSavedSearchDialog(){
            var message = "Do you want to remove the saved search \"" + searchName + "\"?"
            dialog.createQueryDialog("Remove Saved Search", "", message, function(){
                Twitter.postRemoveSavedSearch(searchPage.savedSearchId, removeSearchOnSuccess, removeSearchOnFailure)
                loadingRect.visible = true
            })
        }
    }
}
