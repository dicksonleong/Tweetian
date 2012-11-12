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
                        bio: msg.data[iData].description || "",
                        location: msg.data[iData].location || "",
                        profileImageUrl: msg.data[iData].profile_image_url,
                        profileBannerUrl: msg.data[iData].profile_banner_url || "",
                        createdAt: msg.data[iData].created_at,
                        favouritesCount: msg.data[iData].favourites_count,
                        website: msg.data[iData].url,
                        followersCount: msg.data[iData].followers_count,
                        followingCount: msg.data[iData].friends_count,
                        tweetsCount: msg.data[iData].statuses_count,
                        listedCount: msg.data[iData].listed_count,
                        followingUser: msg.data[iData].following,
                        protectedUser: msg.data[iData].protected
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
                bio: msg.data[iData2].description || "",
                location: msg.data[iData2].location || "",
                profileImageUrl: msg.data[iData2].profile_image_url,
                profileBannerUrl: msg.data[iData2].profile_banner_url || "",
                createdAt: msg.data[iData2].created_at,
                favouritesCount: msg.data[iData2].favourites_count,
                website: msg.data[iData2].url,
                followersCount: msg.data[iData2].followers_count,
                followingCount: msg.data[iData2].friends_count,
                tweetsCount: msg.data[iData2].statuses_count,
                listedCount: msg.data[iData2].listed_count,
                followingUser: msg.data[iData2].following,
                protectedUser: msg.data[iData2].protected
            }
            msg.model.append(userObject2)
        }
    }

    msg.model.sync()
    WorkerScript.sendMessage({screenNames: screenNames})
}
