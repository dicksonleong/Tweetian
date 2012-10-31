Qt.include("../Utils/Parser.js")
Qt.include("../Utils/Calculations.js")

WorkerScript.onMessage = function(msg){
    var screenNames = []

    if(msg.reloadType === "all"){
        msg.model.clear()
        msg.model.sync()
    }

    if(msg.userIds){
        for(var iArray=0; iArray < msg.userIds.length; iArray++){
            for(var iData=0; iData < msg.data.length; iData++){
                if(msg.userIds[iArray] === msg.data[iData].id_str){
                    var userObject = {
                        userName: msg.data[iData].name,
                        screenName: msg.data[iData].screen_name,
                        location: (msg.data[iData].location ? msg.data[iData].location : ""),
                        profileImageUrl: msg.data[iData].profile_image_url,
                        createdAt: msg.data[iData].created_at,
                        favouritesCount: msg.data[iData].favourites_count,
                        website: msg.data[iData].url,
                        followersCount: msg.data[iData].followers_count,
                        bio: (msg.data[iData].description ? msg.data[iData].description : ""),
                        followingCount: msg.data[iData].friends_count,
                        tweetsCount: msg.data[iData].statuses_count,
                        followingUser: msg.data[iData].following,
                        protectedUser: msg.data[iData].protected,
                        listedCount: msg.data[iData].listed_count
                    }
                    msg.model.append(userObject)
                    screenNames.push(msg.data[iData].screen_name)
                    break
                }
            }
        }
    }
    else{
        for(var iData2=0; iData2 < msg.data.length; iData2++){
            var userObject2 = {
                userName: msg.data[iData2].name,
                screenName: msg.data[iData2].screen_name,
                location: (msg.data[iData2].location ? msg.data[iData2].location : ""),
                profileImageUrl: msg.data[iData2].profile_image_url,
                createdAt: msg.data[iData2].created_at,
                favouritesCount: msg.data[iData2].favourites_count,
                website: msg.data[iData2].url,
                followersCount: msg.data[iData2].followers_count,
                bio: (msg.data[iData2].description ? msg.data[iData2].description : ""),
                followingCount: msg.data[iData2].friends_count,
                tweetsCount: msg.data[iData2].statuses_count,
                followingUser: msg.data[iData2].following,
                protectedUser: msg.data[iData2].protected,
                listedCount: msg.data[iData2].listed_count
            }
            msg.model.append(userObject2)
        }
    }

    msg.model.sync()
    WorkerScript.sendMessage({screenNames: screenNames})
}
