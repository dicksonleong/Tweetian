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
    var count = 0

    function getTweetObject(index){
        var tweetObject = {
            tweetId: msg.data.results[index].id_str,
            displayScreenName: msg.data.results[index].from_user,
            screenName: msg.data.results[index].from_user,
            userName: msg.data.results[index].from_user_name,
            tweetText: msg.data.results[index].text,
            displayTweetText: msg.data.results[index].text.parseUsername().parseHashtag(),
            profileImageUrl: msg.data.results[index].profile_image_url,
            source: unlink(msg.data.results[index].source),
            createdAt: new Date(msg.data.results[index].created_at),
            timeDiff: timeDiff(msg.data.results[index].created_at),
            inReplyToScreenName: msg.data.results[index].to_user,
            inReplyToStatusId: "",
            favourited: false,
            retweetId: msg.data.results[index].id_str,
            latitude: (msg.data.results[index].geo ? msg.data.results[index].geo.coordinates[0] : ""),
            longitude: (msg.data.results[index].geo ? msg.data.results[index].geo.coordinates[1] : "")
        }

        if(msg.data.results[index].entities && msg.data.results[index].entities.urls){
            for(var i2=0; i2<msg.data.results[index].entities.urls.length; i2++){
                tweetObject.displayTweetText = tweetObject.displayTweetText.parseURL(msg.data.results[index].entities.urls[i2].url,
                                                                                     msg.data.results[index].entities.urls[i2].display_url,
                                                                                     msg.data.results[index].entities.urls[i2].expanded_url)
            }
        }

        /**Media entities**/
        if(msg.data.results[index].entities && msg.data.results[index].entities.media){
            tweetObject.mediaExpandedUrl = msg.data.results[index].entities.media[0].expanded_url
            tweetObject.mediaViewUrl = msg.data.results[index].entities.media[0].media_url
            tweetObject.mediaThumbnail = msg.data.results[index].entities.media[0].media_url + ":thumb"
            tweetObject.displayTweetText = tweetObject.displayTweetText.parseURL(msg.data.results[index].entities.media[0].url,
                                                                                 msg.data.results[index].entities.media[0].display_url,
                                                                                 msg.data.results[index].entities.media[0].expanded_url)
        }
        else{
            var picURL = parsePic(tweetObject.displayTweetText)
            tweetObject.mediaExpandedUrl = picURL[0]
            tweetObject.mediaViewUrl = picURL[1]
            tweetObject.mediaThumbnail = picURL[2]
        }
        return tweetObject
    }

    switch(msg.reloadType){
    case "all":
        msg.model.clear()
        msg.model.sync()
        //fallthrough
    case "older":
        for(var iAll=0; iAll < msg.data.results.length; iAll++){
            var tweetObjAll = getTweetObject(iAll)
            msg.model.append(tweetObjAll)
            count++
        }

        break
    case "newer":
        for(var iNew=msg.data.results.length - 1; iNew >= 0; iNew--){
            var tweetObjNew = getTweetObject(iNew)
            msg.model.insert(0, tweetObjNew)
            count++
            if(count === 1) msg.model.sync()
        }

        break
    }
    msg.model.sync()
    WorkerScript.sendMessage({count: count})
}
