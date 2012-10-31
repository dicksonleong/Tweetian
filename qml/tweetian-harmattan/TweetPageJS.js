function deleteTweetOnSuccess(data){
    mainPage.timeline.parseData("delete", data)
    loadingRect.visible = false
    infoBanner.alert("Tweet deleted.")
    pageStack.pop()
}

function favouriteOnSuccess(data, isFavourite){
    mainPage.timeline.parseData("favourite", data)
    favouritedTweet = isFavourite
    if(favouritedTweet) infoBanner.alert("Tweet favourited.")
    else infoBanner.alert("Tweet unfavourited.")
    header.busy = false
}

function reportSpamOnSuccess(data){
    infoBanner.alert("Reported and blocked the user @" + data.screen_name +".")
    loadingRect.visible = false
}

function getTwitLongerTextOnSuccess(fullTweetText, link){
    tweetTextText.text = fullTweetText + "<br><i>(Expanded from TwitLonger - " + link.parseURL(link, link.substring(7), link) + ")</i>"
    header.busy = false
}

function commonOnFailure(status, statusText){
    if(status === 0) infoBanner.alert("Connection error.")
    else infoBanner.alert("Error: " + status + " " + statusText)
    header.busy = false
    loadingRect.visible = false
}

function getAllMentions(text){
    var mentionsText = ""
    var mentionsArray = text.match(/href="@\w+/g)
    if(mentionsArray != null){
        for(var i=0; i<mentionsArray.length; i++){
            var name = mentionsArray[i].substring(6)
            if(name !== "@" + settings.userScreenName) mentionsText += name + " "
        }
    }
    mentionsText = currentTweet.screenName === currentTweet.displayScreenName
            ? "@" + currentTweet.screenName + " " + mentionsText
            : "@" + currentTweet.screenName + " @" + currentTweet.displayScreenName + " " + mentionsText
    return mentionsText
}

function getAllHashtags(text){
    if(settings.hashtagsInReply){
        var hashtags = ""
        var hashtagsArray = text.match(/href="#[^"\s]+/g)
        if(hashtagsArray != null){
            for(var i=0; i<hashtagsArray.length; i++) hashtags += hashtagsArray[i].substring(6) + " "
        }
        return hashtags
    }
    else return ""
}

function conversationOnSuccess(data){
    if(tweetPage.status !== PageStatus.Deactivating){
        backButton.enabled = false
        conversationParser.sendMessage({"data": data, "ancestorModel": ancestorModel, "descendantModel":descendantModel})
    }
}

function conversationOnFailure(status, statusText){
    if(status === 0) infoBanner.alert("Connection error.")
    else infoBanner.alert("Error: " + status + " " + statusText)
    header.busy = false
}

function translateTokenOnSuccess(token){
    cache.translationToken = token
    Translate.translate(cache.translationToken, currentTweet.tweetText, translateOnSuccess, translateOnFailure)
}

function translateOnSuccess(data){
    if(data.indexOf("ArgumentOutOfRangeException") == 0){
        infoBanner.alert("Unable to translate tweet.")
    }
    else{
        translatedTweetLoader.sourceComponent = translatedTweet
        translatedTweetLoader.item.text = data
    }
    header.busy = false
}

function translateOnFailure(status, statusText){
    if(status === 0) infoBanner.alert("Connection error.")
    else infoBanner.alert("Error translating tweet: " + status + " " + statusText)
    header.busy = false
}

//check the stored translate access token is expired or not (will expired after 10mins)
function checkExpire(translateToken){
    var time = translateToken.substr(translateToken.indexOf('ExpiresOn=') + 10, 10) * 1000
    var diff = time - new Date().getTime()
    return diff > 0
}

function addToPocket(link){
    if(settings.pocketUsername && settings.pocketPassword){
        Pocket.addPage(settings.pocketUsername, settings.pocketPassword, link, currentTweet.tweetText,
                       currentTweet.tweetId, pocketSuccessCallback, pocketFailureCallback)
        loadingRect.visible = true
    }
    else{
        var message = "You are not sign in to your Pocket account. \
Please sign in to your Pocket account first under the \"Account\" tab in the Settings."
        dialog.createMessageDialog("Pocket - Not Signed In", message)
    }
}

function addToInstapaper(link){
    if(settings.instapaperToken, settings.instapaperTokenSecret){
        Instapaper.addBookmark(settings.instapaperToken, settings.instapaperTokenSecret, link,
                               currentTweet.tweetText, instapaperSuccessCallback, instapaperFailureCallback)
        loadingRect.visible = true
    }
    else{
        var message = "You are not sign in to your Instapaper account. \
Please sign in to your Instapaper account first under the \"Account\" tab in the Settings."
        dialog.createMessageDialog("Instapaper - Not Signed In", message)
    }
}

function pocketSuccessCallback(){
    loadingRect.visible = false
    infoBanner.alert("The link has been sent to Pocket successfully.")
}

function pocketFailureCallback(errorText){
    loadingRect.visible = false
    infoBanner.alert("Error: " + errorText)
}

function instapaperSuccessCallback(){
    loadingRect.visible = false
    infoBanner.alert("The link has been sent to Instapaper successfully.")
}

function instapaperFailureCallback(errorText){
    loadingRect.visible = false
    infoBanner.alert("Error: " + errorText)
}

function getYouTubeVideoId(link){
    var videoId = ""
    link = link.replace("https://", "http://")

    if(link.indexOf("http://youtu.be/") === 0) {
        videoId = link.substring(16)
    }
    else if(link.indexOf("http://www.youtube.com/watch?") === 0){
        var queryArray = link.substring(29).split('&')
        for(var iQuery=0; iQuery<queryArray.length; iQuery++) {
            if(queryArray[iQuery].indexOf('v=') === 0) {
                videoId = queryArray[iQuery].substring(2)
                break
            }
        }
    }
    else console.log("[Youtube] Unable to parse YouTube link:", link)
    return videoId
}

function createDeleteTweetDialog(){
    var message = "Do you want to delete this tweet?"
    dialog.createQueryDialog("Delete Tweet", "", message, function(){
        Twitter.postDeleteStatus(currentTweet.tweetId, deleteTweetOnSuccess, commonOnFailure)
        loadingRect.visible = true
    })
}
