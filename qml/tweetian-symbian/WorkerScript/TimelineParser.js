Qt.include("../Utils/Parser.js")
Qt.include("../Utils/Calculations.js")

WorkerScript.onMessage = function(msg){
    var count = 0
    var hashtags = []
    var screenNames = []

    function getTweetObject(index){
		msg.data[index].source = unlink(msg.data[index].source)

		if(msg.muteString && isMuted(msg.muteString, msg.data[index])){
            console.log("[Mute] Muted one tweet, id:", msg.data[index].id_str)
			return ""
		}

		var tweetObject = {
			tweetId: msg.data[index].id_str,
			screenName: msg.data[index].user.screen_name,
			createdAt: new Date(msg.data[index].created_at),
			timeDiff: timeDiff(msg.data[index].created_at),
			source: msg.data[index].source
		}

		// Collecting screen name for autofill
		if(msg.data[index].user.following && screenNames.indexOf(msg.data[index].user.screen_name) == -1){
			screenNames.push(msg.data[index].user.screen_name)
		}

		// For retweeted status
		if(msg.data[index].retweeted_status) msg.data[index] = msg.data[index].retweeted_status

		tweetObject.retweetId = msg.data[index].id_str
		tweetObject.displayScreenName = msg.data[index].user.screen_name
		tweetObject.userName = msg.data[index].user.name
        tweetObject.tweetText = unescapeHtml(msg.data[index].text)
		tweetObject.displayTweetText = msg.data[index].text.parseUsername().parseHashtag(hashtags)
		tweetObject.profileImageUrl = msg.data[index].user.profile_image_url
		tweetObject.favourited = msg.data[index].favorited
		tweetObject.inReplyToScreenName = msg.data[index].in_reply_to_screen_name
		tweetObject.inReplyToStatusId = msg.data[index].in_reply_to_status_id_str
		tweetObject.latitude = msg.data[index].geo ? msg.data[index].geo.coordinates[0] : ""
		tweetObject.longitude = msg.data[index].geo ? msg.data[index].geo.coordinates[1] : ""

		// URL parsing
		if(msg.data[index].entities.urls){
			for(var i2=0; i2<msg.data[index].entities.urls.length; i2++){
				tweetObject.displayTweetText = tweetObject.displayTweetText.parseURL(msg.data[index].entities.urls[i2].url,
																					 msg.data[index].entities.urls[i2].display_url,
																					 msg.data[index].entities.urls[i2].expanded_url)
			}
		}

		// Media parsing
		if(msg.data[index].entities.media instanceof Array && msg.data[index].entities.media[0]){
			tweetObject.mediaExpandedUrl = msg.data[index].entities.media[0].expanded_url
			tweetObject.mediaViewUrl = msg.data[index].entities.media[0].media_url
			tweetObject.mediaThumbnail = msg.data[index].entities.media[0].media_url + ":thumb"
			tweetObject.displayTweetText = tweetObject.displayTweetText.parseURL(msg.data[index].entities.media[0].url,
																				 msg.data[index].entities.media[0].display_url,
																				 msg.data[index].entities.media[0].expanded_url)
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
        for(var iAll=0; iAll < msg.data.length; iAll++){
            var tweetObjAll = getTweetObject(iAll)
            if(tweetObjAll) {
                msg.model.append(tweetObjAll)
                count++
            }
        }

        break
    case "newer":
        for(var iNew=msg.data.length - 1; iNew >= 0; iNew--){
            var tweetObjNew = getTweetObject(iNew)
            if(tweetObjNew){
                msg.model.insert(0, tweetObjNew)
                count++
                if(count === 1) msg.model.sync()
            }
        }

        break
    case "database":
        for(var iDB=0; iDB<msg.data.length; iDB++){
            msg.data[iDB].tweetText.parseHashtag(hashtags)

            msg.data[iDB].createdAt = new Date(msg.data[iDB].createdAt)
            msg.data[iDB].favourited = msg.data[iDB].favourited == 1
            msg.data[iDB].timeDiff = timeDiff(msg.data[iDB].createdAt)
            msg.model.append(msg.data[iDB])
        }
        break
    case "delete":
        for(var iDelete=0; iDelete<msg.model.count; iDelete++){
            if(msg.model.get(iDelete).tweetId == msg.data.id_str){
                msg.model.remove(iDelete)
                break
            }
        }
        break
    case "favourite":
        for(var iFav=0; iFav<msg.model.count; iFav++){
            if(msg.model.get(iFav).tweetId == msg.data.id_str){
                msg.model.setProperty(iFav, "favourited", !msg.model.get(iFav).favourited)
            }
        }
        break
    case "time":
        for(var iTime=0; iTime<msg.model.count; iTime++){
            msg.model.setProperty(iTime, "timeDiff", timeDiff(msg.model.get(iTime).createdAt))
        }
        break
    default:
        throw new Error("Invalid method: "+ msg.reloadType)
    }

    msg.model.sync()
    WorkerScript.sendMessage({"type": msg.reloadType, "count": count, "screenNames": screenNames, "hashtags": hashtags})
}

function isMuted(muteString, tweetObject){

    function checkMute(muteKeyword){
        if(muteKeyword.indexOf("@") === 0){ // @user
            if(tweetObject.user.screen_name === muteKeyword.substring(1)){
                return true
            }
            else if(new RegExp(muteKeyword.concat("(\\s|$)")).test(tweetObject.text)){
                return true
            }
        }
        else if(muteKeyword.indexOf("source:") === 0){ // source:Tweet_Button
            if(tweetObject.source === muteKeyword.substring(7).replace(/_/g, " ")){
                return true
            }
        }
        else{ // plain words
            if(new RegExp(muteKeyword.concat("(\\s|$)")).test(tweetObject.text)){
                return true
            }
        }
        return false
    }

    var muteArrayOR = muteString.split("\n")
    for(var orIndex = 0; orIndex < muteArrayOR.length ; orIndex++){
        var muteArrayAND = muteArrayOR[orIndex].split(" ")
        var passedAND = true
        for(var andIndex=0; andIndex < muteArrayAND.length ; andIndex++){
            if(!checkMute(muteArrayAND[andIndex])){
                passedAND = false
                break
            }
        }
        if(passedAND) return true
    }
    return false
}
