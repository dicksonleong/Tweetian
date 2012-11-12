import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Delegate"
import "../Services/Twitter.js" as Twitter

AbstractUserPage{
    id: userListedPage

    property string nextCursor: ""

    headerText: qsTr("Listed")
    headerNumber: userInfoData.listedCount
    emptyText: qsTr("No list")
    loadMoreButtonVisible: listView.count > 0 && listView.count % 20 === 0
    delegate: ListDelegate{}

    onReload: {
        if(reloadType === "all") nextCursor = ""
        Twitter.getUserListsMemberships(userInfoData.screenName, nextCursor, function(data){
            for(var i=0; i<data.lists.length; i++){
                var obj = {
                    "listName": data.lists[i].name,
                    "subscriberCount": data.lists[i].subscriber_count,
                    "listId": data.lists[i].id_str,
                    "memberCount": data.lists[i].member_count,
                    "listDescription": data.lists[i].description,
                    "ownerUserName": data.lists[i].user.name,
                    "ownerScreenName": data.lists[i].user.screen_name,
                    "profileImageUrl": data.lists[i].user.profile_image_url,
                    "protectedList": data.lists[i].mode === "private",
                    "following": data.lists[i].following
                }
                listView.model.append(obj)
            }
            nextCursor = data.next_cursor_str
            loadingRect.visible = false
        }, function(status, statusText){
            infoBanner.showHttpError(status, statusText)
            loadingRect.visible = false
        })
        loadingRect.visible = true
    }
}
