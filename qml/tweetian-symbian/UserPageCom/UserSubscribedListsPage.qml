import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Delegate"
import "../Services/Twitter.js" as Twitter

AbstractUserPage{
    id: userSubscribedListsPage

    headerText: qsTr("Subscribed Lists")
    headerNumber: listView.count
    emptyText: qsTr("No list")
    loadMoreButtonVisible: listView.count > 0 && listView.count % 50 === 0
    delegate: ListDelegate{}

    onReload: {
        Twitter.getUserLists(userInfoData.screenName, function(data){
            for(var i=0; i<data.length; i++){
                var obj = {
                        "listName": data[i].name,
                        "subscriberCount": data[i].subscriber_count,
                        "listId": data[i].id_str,
                        "memberCount": data[i].member_count,
                        "listDescription": data[i].description,
                        "ownerUserName": data[i].user.name,
                        "ownerScreenName": data[i].user.screen_name,
                        "profileImageUrl": data[i].user.profile_image_url,
                        "protectedList": data[i].mode === "private",
                        "following": data[i].following
                }
                listView.model.append(obj)
            }
            loadingRect.visible = false
        }, function(status, statusText){
            infoBanner.showHttpError(status, statusText)
            loadingRect.visible = false
        })
        loadingRect.visible = true
    }
}
