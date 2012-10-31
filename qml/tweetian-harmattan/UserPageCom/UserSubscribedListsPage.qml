import QtQuick 1.1
import com.nokia.meego 1.0
import "../Delegate"
import "../twitter.js" as Twitter

AbstractUserPage{
    id: userSubscribedListsPage

    headerText: "Subscribed Lists"
    headerNumber: listView.count
    emptyText: "No list"
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
            if(status === 0) infoBanner.alert("Connection error.")
            else infoBanner.alert("Error: " + status + " " + statusText)
            loadingRect.visible = false
        })
        loadingRect.visible = true
    }
}
