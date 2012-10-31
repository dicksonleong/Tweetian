import QtQuick 1.1
import com.nokia.symbian 1.1
import "twitter.js" as Twitter
import "Component"

Page{
    id: trendsPage

    property bool savedSearchLoading: false
    property bool trendingLoading: false
    property ListModel trendsLocationModel: ListModel{}

    Component.onCompleted: if(cache.trendsModel.count == 0) internal.refresh()

    tools: ToolBarLayout{
        ToolButtonWithTip{
            iconSource: "toolbar-back"
            toolTipText: "Back"
            onClicked: pageStack.pop()
        }
        ToolButtonWithTip{
            iconSource: "toolbar-search"
            toolTipText: "Search"
            onClicked: internal.createSearchDialog()
        }
        ToolButtonWithTip{
            iconSource: "Image/people" + (settings.invertedTheme ? "_inverse.svg" : ".svg")
            toolTipText: "Suggested Users"
            onClicked: pageStack.push(Qt.resolvedUrl("UserCategoryPage.qml"))
        }
        ToolButtonWithTip{
            iconSource: "toolbar-menu"
            toolTipText: "Menu"
            onClicked: menu.open()
        }
    }

    Menu{
        id: menu

        platformInverted: settings.invertedTheme

        MenuLayout{
            MenuItem{
                text: "Nearby Tweets"
                platformInverted: menu.platformInverted
                onClicked: pageStack.push(Qt.resolvedUrl("NearbyTweetsPage.qml"))
            }
            MenuItem{
                text: "Change trends location"
                platformInverted: menu.platformInverted
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
            height: titleText.height + 2 * constant.paddingLarge
            platformInverted: settings.invertedTheme

            ListItemText{
                id: titleText
                anchors { top: parent.paddingItem.top; left: parent.paddingItem.left; right: parent.paddingItem.right }
                mode: trendsListItem.mode
                role: "Title"
                text: title
                platformInverted: parent.platformInverted
            }

            onClicked: {
                var prop = { searchName: title, isSavedSearch: type === "Saved Searches", savedSearchId: id }
                pageStack.push(Qt.resolvedUrl("SearchPage.qml"), prop)
            }
            onPressAndHold: {
                if(type === "Saved Searches")
                    savedSearchMenuComponent.createObject(trendsPage, { id: id, searchName: title })
            }
        }
        onPullDownRefresh: internal.refresh()
    }

    ScrollDecorator{ platformInverted: settings.invertedTheme; flickableItem: trendsPageListView }

    PageHeader{
        id: header
        headerIcon: "image://theme/toolbar-search"
        headerText: "Trends & Search"
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
            infoBanner.alert("The saved search \"" + data.name + "\" is removed.")
            savedSearchLoading = false
        }

        function removeSearchOnFailure(status, statusText){
            if(status === 0) infoBanner.alert("Connection error.")
            else infoBanner.alert("Error: " + status + " " + statusText)
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
                    "type": "Trends (" + data[0].locations[0].name + ")"
                }
                trendsPageListView.model.append(obj)
                if(data[0].trends[i].name.indexOf('#') == 0) hashtagsArray.push(data[0].trends[i].name.substring(1))
            }
            cache.pushToHashtags(hashtagsArray)
            trendingLoading = false
        }

        function trendsOnFailure(status, statusText){
            if(status === 0) infoBanner.alert("Connection error.")
            else infoBanner.alert("Error: " + status + " " + statusText)
            trendsPageListView.model.append({"title": "Unable to retrieve trends", "type": "Trends"})
            trendingLoading = false
        }

        function savedSearchOnSuccess(data){
            for(var i=0; i<data.length; i++){
                var obj = {
                    "id": data[i].id,
                    "title": data[i].name,
                    "query": data[i].query,
                    "type": "Saved Searches"
                }
                trendsPageListView.model.insert(i, obj)
            }
            savedSearchLoading = false
        }

        function savedSearchOnFailure(status, statusText){
            if(status === 0) infoBanner.alert("Connection error.")
            else infoBanner.alert("Error: " + status + " " + statusText)
            trendsPageListView.model.insert(0,{"title": "Unabled to retrieve saved search", "type": "Saved Searches"})
            savedSearchLoading = false
        }

        function trendsLocationOnSuccess(data){
            trendsLocationModel.append({name: "Worldwide", woeid: 1})
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
            if(status === 0) infoBanner.alert("Connection error.")
            else infoBanner.alert("Error: " + status + " " + statusText)
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
            var icon = settings.invertedTheme ? "image://theme/toolbar-delete_inverse"
                                                 : "image://theme/toolbar-delete"
            var message = "Do you want to remove the saved search \"" + searchName + "\"?"
            dialog.createQueryDialog("Remove Saved Search", icon, message, function(){
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

            platformInverted: settings.invertedThemes

            MenuLayout{
                MenuItemWithIcon{
                    iconSource: platformInverted ? "image://theme/toolbar-delete_inverse" : "image://theme/toolbar-delete"
                    text: "Remove saved search"
                    onClicked: internal.createRemoveSavedSearchDialog(savedSearchMenu.id, savedSearchMenu.searchName)
                }
            }

            Component.onCompleted: open()
            onStatusChanged: {
                if(status === DialogStatus.Closing) __isClosing = true
                else if(status === DialogStatus.Closed && __isClosing) savedSearchMenu.destroy()
            }
        }
    }
}
