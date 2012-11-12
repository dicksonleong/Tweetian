import QtQuick 1.1
import com.nokia.symbian 1.1
import "Services/Twitter.js" as Twitter
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
            toolTipText: qsTr("Back")
            onClicked: pageStack.pop()
        }
        ToolButtonWithTip{
            iconSource: "toolbar-search"
            toolTipText: qsTr("Search")
            onClicked: internal.createSearchDialog()
        }
        ToolButtonWithTip{
            iconSource: "Image/people" + (settings.invertedTheme ? "_inverse.svg" : ".svg")
            toolTipText: qsTr("Suggested Users")
            onClicked: pageStack.push(Qt.resolvedUrl("UserCategoryPage.qml"))
        }
        ToolButtonWithTip{
            iconSource: "toolbar-menu"
            toolTipText: qsTr("Menu")
            onClicked: menu.open()
        }
    }

    Menu{
        id: menu

        platformInverted: settings.invertedTheme

        MenuLayout{
            MenuItem{
                text: qsTr("Nearby Tweets")
                platformInverted: menu.platformInverted
                onClicked: pageStack.push(Qt.resolvedUrl("NearbyTweetsPage.qml"))
            }
            MenuItem{
                text: qsTr("Change trends location")
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

    ScrollDecorator{ platformInverted: settings.invertedTheme; flickableItem: trendsPageListView }

    PageHeader{
        id: header
        headerIcon: "image://theme/toolbar-search"
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
            var icon = settings.invertedTheme ? "image://theme/toolbar-delete_inverse"
                                                 : "image://theme/toolbar-delete"
            var message = qsTr("Do you want to remove the saved search %1?").arg("\""+searchName+"\"")
            dialog.createQueryDialog(qsTr("Remove Saved Search"), icon, message, function(){
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
                    text: qsTr("Remove saved search")
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
