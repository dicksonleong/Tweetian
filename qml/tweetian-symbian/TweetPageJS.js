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

var PIC_SERVICES = {
    TwitPic: {
        regexp: /http:\/\/twitpic.com\/\w+/ig,
        getPicUrl: function(link) {
           var twitpicId = link.substring(19)
           var url = {
               full: "http://twitpic.com/show/full/" + twitpicId,
               thumb: "http://twitpic.com/show/thumb/" + twitpicId
           }
           return url
       }
    },
    YFrog: {
        regexp: /http:\/\/(twitter.)?yfrog.com\/\w+/ig,
        getPicUrl: function(link) {
           var yfrogId = link.substring(link.indexOf("yfrog.com/") + 10)
           var url = {
               full: "http://yfrog.com/" + yfrogId + ":medium",
               thumb: "http://yfrog.com/" + yfrogId + ":small"
           }
           return url
        }
    },
    Instagram: {
        regexp: /http:\/\/instagr.am\/p\/[^\/]+\//ig,
        getPicUrl: function(link) {
            var url = {
                full: link + "media/?size=l",
                thumb: link + "media/?size=t"
            }
            return url
        }
    },
    Imgly: {
        regexp: /http:\/\/img.ly\/\w+/ig,
        getPicUrl: function(link) {
           var imglyId = link.substring(14)
           var url = {
               full: "http://img.ly/show/full/"+ imglyId,
               thumb: "http://img.ly/show/thumb/"+ imglyId
           }
           return url
       }
    },
    NineGag: {
        regexp: /http:\/\/(m.)?9gag.com\/gag\/[^"]+/ig,
        getPicUrl: function(link) {
           var ques = link.indexOf('?')
           var idEndPos = ques === -1 ? undefined : ques
           var gagId = link.substring(link.indexOf("9gag.com/gag/") + 13, idEndPos)
           var url = {
               full: "http://d24w6bsrhbeh9d.cloudfront.net/photo/" + gagId + "_460s.jpg",
               thumb: "http://d24w6bsrhbeh9d.cloudfront.net/photo/" + gagId + "_220x145.jpg"
           }
           return url
       }
    },
    MobyPicture: {
        regexp: /http:\/\/moby.to\/\w+/ig,
        getPicUrl: function(link) {
            var url = { full: link + ":full", thumb: link + ":square" }
            return url
        }
    },
    Lockerz: {
        regexp: /http:\/\/lockerz.com\/[^"]+/ig,
        getPicUrl: function(link) {
            var url = {
                full: "http://api.plixi.com/api/tpapi.svc/imagefromurl?size=big&url=" + link,
                thumb: "http://api.plixi.com/api/tpapi.svc/imagefromurl?size=small&url=" + link
            }
            return url
        }
    },
    Molome: {
        regexp: /http:\/\/molo.me\/p\/\w+/ig,
        getPicUrl: function(link) {
            var molomeId = link.substring(17)
            var url = {
                full: "http://p.molo.me/"+ molomeId,
                thumb: "http://p135x135.molo.me/"+ molomeId +"_135x135"
            }
            return url
        }
    },
    TwitGoo: {
        regexp: /http:\/\/twitgoo.com\/\w+/ig,
        getPicUrl: function(link) {
            var url = { full: link + "/img", thumb: link + "/thumb" }
            return url
        }
    },
    Imgur: {
        regexp: /http:\/\/i.imgur.com\/[^"]+/ig,
        getPicUrl: function(link) {
            var url = {
                full: link,
                thumb: "http://i.imgur.com/" + link.substring(19).replace(".", "s.")
            }
            return url
        }
    },
    SkyDrive: {
        regexp: /http:\/\/sdrv.ms\/[^"]+/ig,
        getPicUrl: function(link) {
            var url = {
                full: "https://apis.live.net/v5.0/skydrive/get_item_preview?type=normal&url=" + link,
                thumb: "https://apis.live.net/v5.0/skydrive/get_item_preview?type=album&url=" + link
            }
            return url
        }
    }
}

function createPicThumb() {
    // if there is no link in the tweet, just return
    if (currentTweet.displayTweetText.indexOf("href=\"http") < 0)
        return

    // Twitter pic
    if (currentTweet.mediaUrl) {
        var twitterPic = {
            type: "image",
            full: currentTweet.mediaUrl,
            thumb: currentTweet.mediaUrl + ":thumb",
            link: "http://" + currentTweet.displayTweetText.match(/pic.twitter.com\/\w+/)[0]
        }
        thumbnailModel.append(twitterPic)
    }

    // Flickr pic
    var flickrLinks = currentTweet.displayTweetText.match(/http:\/\/flic.kr\/p\/\w+/ig)
    if (flickrLinks != null) {
        for (var iFlickr=0; iFlickr<flickrLinks.length; iFlickr++) {
            Flickr.getSizes(constant, flickrLinks[iFlickr], function(full, thumb, link) {
                thumbnailModel.append({type: "image", full: full, thumb: thumb, link: link})
            })
        }
    }

    for (var service in PIC_SERVICES) {
        var links = currentTweet.displayTweetText.match(PIC_SERVICES[service].regexp)
        if (links == null) continue
        for (var i=0; i<links.length; i++) {
            var urls = PIC_SERVICES[service].getPicUrl(links[i])
            var picObj = { type: "image", full: urls.full, thumb: urls.thumb, link: links[i] }
            thumbnailModel.append(picObj)
        }
    }
}

function createYoutubeThumb() {
    var youtubeLinks = currentTweet.displayTweetText.match(/https?:\/\/(youtu.be\/[\w-]{11,}|www.youtube.com\/watch\?[\w-=&]{11,})/ig)
    if (youtubeLinks == null) return

    for (var i=0; i<youtubeLinks.length; i++) {
        var videoId = ""
        var link = youtubeLinks[i].replace("https://", "http://")

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
        YouTube.getVideoThumbnailAndLink(constant, videoId, function(thumb, rstpLink) {
            thumbnailModel.append({type: "video", thumb: thumb, full: "", link: rstpLink})
        })
    }
}

function createMapThumb() {
    if (!currentTweet.latitude || !currentTweet.longitude) return

    var thumbnailURL = Maps.getMaps(constant, currentTweet.latitude, currentTweet.longitude,
                                    constant.thumbnailSize, constant.thumbnailSize)
    thumbnailModel.append({type: "map", thumb: thumbnailURL, full: "", link: ""})
}

function expandTwitLonger() {
    var twitLongerLink = currentTweet.displayTweetText.match(/http:\/\/tl.gd\/\w+/)
    if (twitLongerLink == null) return

    TwitLonger.getFullTweet(constant, twitLongerLink[0], getTwitLongerTextOnSuccess, commonOnFailure)
    header.busy = true
}


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

function createDeleteTweetDialog() {
    var icon = platformInverted ? "image://theme/toolbar-delete_inverse" : "image://theme/toolbar-delete"
    var message = qsTr("Do you want to delete this tweet?")
    dialog.createQueryDialog(qsTr("Delete Tweet"), icon, message, function() {
        Twitter.postDeleteStatus(currentTweet.tweetId, deleteTweetOnSuccess, commonOnFailure)
        loadingRect.visible = true
    })
}
