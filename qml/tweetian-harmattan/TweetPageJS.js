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

function deleteTweetOnSuccess(data) {
    mainPage.timeline.parseData("delete", data)
    loadingRect.visible = false
    infoBanner.showText(qsTr("Tweet deleted successfully"))
    pageStack.pop()
}

function favouriteOnSuccess(data, isFavourite) {
    mainPage.timeline.parseData("favourite", data)
    favouritedTweet = isFavourite
    if (favouritedTweet) infoBanner.showText(qsTr("Tweet favourited succesfully"))
    else infoBanner.showText(qsTr("Tweet unfavourited successfully"))
    header.busy = false
}

function getTwitLongerTextOnSuccess(fullTweetText, link) {
    tweetTextText.text = fullTweetText + "<br><i>(" + qsTr("Expanded from TwitLonger") + " - "
            + link.parseURL(link, link.substring(7), link) + ")</i>"
    header.busy = false
}

function commonOnFailure(status, statusText) {
    infoBanner.showHttpError(status, statusText)
    header.busy = false
    loadingRect.visible = false
}

function getAllMentions(text) {
    var mentionsText = "@" + currentTweet.screenName + " "

    if (currentTweet.screenName !== currentTweet.displayScreenName)
        mentionsText += "@" + currentTweet.displayScreenName + " "

    var mentionsArray = text.match(/href="@\w+/g)
    if (mentionsArray != null) {
        for (var i=0; i<mentionsArray.length; i++) {
            var name = mentionsArray[i].substring(6)
            if (name.toLowerCase() !== "@" + settings.userScreenName.toLowerCase()) mentionsText += name + " "
        }
    }

    return mentionsText
}

function getAllHashtags(text) {
    if (!settings.hashtagsInReply) return ""
    var hashtags = ""
    var hashtagsArray = text.match(/href="#[^"\s]+/g)
    if (hashtagsArray != null)
        for (var i=0; i<hashtagsArray.length; i++) hashtags += hashtagsArray[i].substring(6) + " "

    return hashtags
}

function conversationOnSuccess(data) {
    if (tweetPage.status !== PageStatus.Deactivating) {
        backButton.enabled = false
        conversationParser.sendMessage({"data": data, "ancestorModel": ancestorModel, "descendantModel":descendantModel})
    }
}

function translateTokenOnSuccess(token) {
    cache.translationToken = token
    Translation.translate(constant, cache.translationToken, currentTweet.tweetText, settings.translateLangCode,
                          translateOnSuccess, commonOnFailure)
}

function translateOnSuccess(data) {
    if (data.indexOf("ArgumentOutOfRangeException") === 0) {
        infoBanner.showText(qsTr("Unable to translate tweet"))
    }
    else {
        translatedTweetLoader.sourceComponent = translatedTweetComponent
        translatedTweetLoader.item.translatedText = data
    }
    header.busy = false
}

function addToPocket(link) {
    if (!settings.pocketUsername || !settings.pocketPassword) {
        var message = qsTr("You are not sign in to your Pocket account. Please sign in to your Pocket account first under the \"Account\" tab in the Settings.")
        dialog.createMessageDialog(qsTr("Pocket - Not Signed In"), message)
        return
    }

    Pocket.addPage(constant, settings.pocketUsername, settings.pocketPassword, link, currentTweet.tweetText,
                   currentTweet.tweetId, pocketSuccessCallback, pocketFailureCallback)
    loadingRect.visible = true
}

function addToInstapaper(link) {
    if (!settings.instapaperToken || !settings.instapaperTokenSecret) {
        var message = qsTr("You are not sign in to your Instapaper account. Please sign in to your Instapaper account first under the \"Account\" tab in the Settings.")
        dialog.createMessageDialog(qsTr("Instapaper - Not Signed In"), message)
        return
    }

    Instapaper.addBookmark(constant, settings.instapaperToken, settings.instapaperTokenSecret, link,
                           currentTweet.tweetText, instapaperSuccessCallback, instapaperFailureCallback)
    loadingRect.visible = true
}

function pocketSuccessCallback() {
    loadingRect.visible = false
    infoBanner.showText(qsTr("The link has been sent to Pocket successfully"))
}

function pocketFailureCallback(errorCode) {
    loadingRect.visible = false
    infoBanner.showText(qsTr("Error sending link to Pocket (%1)").arg(errorCode))
}

function instapaperSuccessCallback() {
    loadingRect.visible = false
    infoBanner.showText(qsTr("The link has been sent to Instapaper successfully"))
}

function instapaperFailureCallback(errorCode) {
    loadingRect.visible = false
    infoBanner.showText(qsTr("Error sending link to Instapaper (%1)").arg(errorCode))
}

function getYouTubeVideoId(link) {
    var videoId = ""
    link = link.replace("https://", "http://")

    if (link.indexOf("http://youtu.be/") === 0) {
        videoId = link.substring(16)
    }
    else if (link.indexOf("http://www.youtube.com/watch?") === 0) {
        var queryArray = link.substring(29).split('&')
        for (var iQuery=0; iQuery<queryArray.length; iQuery++) {
            if (queryArray[iQuery].indexOf('v=') === 0) {
                videoId = queryArray[iQuery].substring(2)
                break
            }
        }
    }
    else console.log("[Youtube] Unable to parse YouTube link:", link)
    return videoId
}

function createDeleteTweetDialog() {
    var message = qsTr("Do you want to delete this tweet?")
    dialog.createQueryDialog(qsTr("Delete Tweet"), "", message, function() {
        Twitter.postDeleteStatus(currentTweet.tweetId, deleteTweetOnSuccess, commonOnFailure)
        loadingRect.visible = true
    })
}
