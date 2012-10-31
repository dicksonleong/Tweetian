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
