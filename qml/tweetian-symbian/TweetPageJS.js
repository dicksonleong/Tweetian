function deleteTweetOnSuccess(data){
    mainPage.timeline.parseData("delete", data)
    loadingRect.visible = false
    infoBanner.alert(qsTr("Tweet deleted successfully"))
    pageStack.pop()
}

function favouriteOnSuccess(data, isFavourite){
    mainPage.timeline.parseData("favourite", data)
    favouritedTweet = isFavourite
    if(favouritedTweet) infoBanner.alert(qsTr("Tweet favourited succesfully"))
    else infoBanner.alert(qsTr("Tweet unfavourited successfully"))
    header.busy = false
}

function getTwitLongerTextOnSuccess(fullTweetText, link){
    tweetTextText.text = fullTweetText + "<br><i>(" + qsTr("Expanded from TwitLonger") + " - "
            + link.parseURL(link, link.substring(7), link) + ")</i>"
    header.busy = false
}

function commonOnFailure(status, statusText){
    infoBanner.showHttpError(status, statusText)
    header.busy = false
    loadingRect.visible = false
}

function getAllMentions(text){
    var mentionsText = "@" + currentTweet.screenName + " "

    if(currentTweet.screenName !== currentTweet.displayScreenName)
        mentionsText += "@" + currentTweet.displayScreenName + " "

    var mentionsArray = text.match(/href="@\w+/g)
    if(mentionsArray != null){
        for(var i=0; i<mentionsArray.length; i++){
            var name = mentionsArray[i].substring(6)
            if(name.toLowerCase() !== "@" + settings.userScreenName.toLowerCase()) mentionsText += name + " "
        }
    }

    return mentionsText
}

function getAllHashtags(text){
    if(!settings.hashtagsInReply)
        return ""

    var hashtags = ""
    var hashtagsArray = text.match(/href="#[^"\s]+/g)
    if(hashtagsArray != null)
        for(var i=0; i<hashtagsArray.length; i++) hashtags += hashtagsArray[i].substring(6) + " "

    return hashtags
}

function conversationOnSuccess(data){
    if(tweetPage.status !== PageStatus.Deactivating){
        backButton.enabled = false
        conversationParser.sendMessage({"data": data, "ancestorModel": ancestorModel, "descendantModel":descendantModel})
    }
}

function translateTokenOnSuccess(token){
    cache.translationToken = token
    Translate.translate(cache.translationToken, currentTweet.tweetText, translateOnSuccess, commonOnFailure)
}

function translateOnSuccess(data){
    if(data.indexOf("ArgumentOutOfRangeException") === 0){
        infoBanner.alert(qsTr("Unable to translate tweet"))
        return
    }

    translatedTweetLoader.sourceComponent = translatedTweet
    translatedTweetLoader.item.text = data
    header.busy = false
}

//check the stored translate access token is expired or not (will expired after 10mins)
function checkExpire(translateToken){
    var time = translateToken.substr(translateToken.indexOf('ExpiresOn=') + 10, 10) * 1000
    var diff = time - new Date().getTime()
    return diff > 0
}

function addToPocket(link){
    if(!settings.pocketUsername || !settings.pocketPassword){
        var message = qsTr("You are not sign in to your Pocket account. Please sign in to your Pocket account first under the \"Account\" tab in the Settings.")
        dialog.createMessageDialog(qsTr("Pocket - Not Signed In"), message)
        return
    }

    Pocket.addPage(settings.pocketUsername, settings.pocketPassword, link, currentTweet.tweetText,
                   currentTweet.tweetId, pocketSuccessCallback, pocketFailureCallback)
    loadingRect.visible = true
}

function addToInstapaper(link){
    if(!settings.instapaperToken || !settings.instapaperTokenSecret){
        var message = qsTr("You are not sign in to your Instapaper account. Please sign in to your Instapaper account first under the \"Account\" tab in the Settings.")
        dialog.createMessageDialog(qsTr("Instapaper - Not Signed In"), message)
        return
    }

    Instapaper.addBookmark(settings.instapaperToken, settings.instapaperTokenSecret, link,
                           currentTweet.tweetText, instapaperSuccessCallback, instapaperFailureCallback)
    loadingRect.visible = true
}

function pocketSuccessCallback(){
    loadingRect.visible = false
    infoBanner.alert(qsTr("The link has been sent to Pocket successfully"))
}

function pocketFailureCallback(errorCode){
    loadingRect.visible = false
    infoBanner.alert(qsTr("Error sending link to Pocket (%1)").arg(errorCode))
}

function instapaperSuccessCallback(){
    loadingRect.visible = false
    infoBanner.alert(qsTr("The link has been sent to Instapaper successfully"))
}

function instapaperFailureCallback(errorCode){
    loadingRect.visible = false
    infoBanner.alert(qsTr("Error sending link to Instapaper (%1)").arg(errorCode))
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
    var icon = platformInverted ? "image://theme/toolbar-delete_inverse" : "image://theme/toolbar-delete"
    var message = qsTr("Do you want to delete this tweet?")
    dialog.createQueryDialog(qsTr("Delete Tweet"), icon, message, function(){
        Twitter.postDeleteStatus(currentTweet.tweetId, deleteTweetOnSuccess, commonOnFailure)
        loadingRect.visible = true
    })
}
