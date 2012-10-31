import QtQuick 1.1
import "storage.js" as Database

QtObject{
    id: root

    function clearAll(){
        trendsModel.clear()
        trendsLastUpdate = ""
        userInfo = undefined
        screenNames = []
        hashtags = []
        translationToken = ""
    }

    function pushToHashtags(newHashtags){
        if(newHashtags instanceof Array && newHashtags.length > 0){
            var tempArray = hashtags
            for(var i=0; i<newHashtags.length; i++){
                if(tempArray.indexOf(newHashtags[i]) == -1) tempArray.push(newHashtags[i])
            }
            hashtags = tempArray
        }
    }

    property ListModel trendsModel: ListModel{}
    property string trendsLastUpdate: ""

    property variant userInfo
    onUserInfoChanged: {
        if(userInfo){
            settings.userFullName = cache.userInfo.name
            settings.userProfileImage = cache.userInfo.profile_image_url
            settings.userScreenName = cache.userInfo.screen_name
        }
    }

    property variant screenNames: []
    property variant hashtags: []

    property string translationToken: ""

    Component.onCompleted: {
        Database.initializeScreenNames()
        screenNames = Database.getScreenNames()
    }
}
