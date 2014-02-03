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

var retweeters = []
var favoriters = []

var PIC_SERVICES = [
    {
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
    {
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
    {
        regexp: /http:\/\/instagram\.com\/p\/[^"]+/ig,
        getPicUrl: function(link) {
            link = link.replace(/\/?$/, '/') // ensure a trailing slash
            var url = {
                full: link + "media/?size=l",
                thumb: link + "media/?size=t"
            }
            return url
        }
    },
    {
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
    {
        regexp: /http:\/\/moby.to\/\w+/ig,
        getPicUrl: function(link) {
            var url = { full: link + ":full", thumb: link + ":square" }
            return url
        }
    },
    {
        regexp: /http:\/\/lockerz.com\/[^"]+/ig,
        getPicUrl: function(link) {
            var url = {
                full: "http://api.plixi.com/api/tpapi.svc/imagefromurl?size=big&url=" + link,
                thumb: "http://api.plixi.com/api/tpapi.svc/imagefromurl?size=small&url=" + link
            }
            return url
        }
    },
    {
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
    {
        regexp: /http:\/\/(m\.)?imgur.com(?!\/a\/)\/((gallery\/)?(r\/[\w\.]+\/)?)\w+/ig,
        // "http://" (optionally "m.") then "imgur.com" then not "/a/" but either:
        // "gallery/" or "r/lettersordots/", then some letters.
        // eg http://imgur.com/gallery/iU1SwYe or http://imgur.com/iU1SwYe
        // or http://m.imgur.com/gallery/iU1SwYe or http://m.imgur.com/iU1SwYe
        // or Reddit http://imgur.com/r/funny/V1Xp2rQ or http://m.imgur.com/r/reddit.com/V1Xp2rQ
        // but not albums: http://imgur.com/a/Jexvo or http://m.imgur.com/a/Jexvo
        getPicUrl: function(link) {
            link = link.replace(/\/+$/, '') // remove trailing slashes
             // Grab the ID after last slash:
            var imgurId = link.substring(link.lastIndexOf("/") + 1)
            var url = {
                full: "http://i.imgur.com/" + imgurId + ".jpg",
                thumb: "http://i.imgur.com/" + imgurId + "s.jpg"
            }
            return url
        }
    },
    {
        regexp: /http:\/\/twitgoo.com\/\w+/ig,
        getPicUrl: function(link) {
            var url = { full: link + "/img", thumb: link + "/thumb" }
            return url
        }
    },
    {
        regexp: /http:\/\/sdrv.ms\/[^"]+/ig,
        getPicUrl: function(link) {
            var url = {
                full: "https://apis.live.net/v5.0/skydrive/get_item_preview?type=normal&url=" + link,
                thumb: "https://apis.live.net/v5.0/skydrive/get_item_preview?type=album&url=" + link
            }
            return url
        }
    },
    {
        regexp: /http:\/\/glui\.me\/\?i=\w+\/[^"/]+\//ig,
        getPicUrl: function(link) {
            link = link.replace(/\/+$/, '') // remove trailing slashes
            link = link.replace(/_/g, "%20") // replace all _ with %20
            link = link.replace("://glui.me/?i=", "://dl.dropboxusercontent.com/s/")
            var url = { full: link, thumb: link }
            return url
        }
    },
    {
        regexp: /http:\/\/www\.wikipaintings\.org\/..\/(?!tag)(?!search)[\w-]+\/[\w-]+/ig,
        getPicUrl: function(link) {
            link = link.replace(/#.*$/,'') // strip any anchor
            link = link.replace('http://www.', 'http://uploads.')
            link = link.replace(/\.org\/..\//, '.org/images/')
            link = link + ".jpg"
            var url = {
                full: link,
                thumb: link + "!BlogSmall.jpg"
            }
            return url
        }
    },
    {
        regexp: /https?:\/\/[^"]+?\.(?:jpe?g|png|gif)(?=")/gi,
        getPicUrl: function (link) { return { full: link, thumb: link }; }
    }
]

function createPicThumb() {
    // if there is no link in the tweet, just return
    if (tweet.richText.indexOf("href=\"http") < 0)
        return

    // Twitter pic
    if (tweet.mediaUrl) {
        var twitterPic = {
            type: "image",
            full: tweet.mediaUrl,
            thumb: tweet.mediaUrl + ":thumb",
            link: "http://" + tweet.richText.match(/pic.twitter.com\/\w+/)[0]
        }
        thumbnailModel.append(twitterPic)
    }

    // Flickr pic
    var flickrLinks = tweet.richText.match(Flickr.FLICKR_LINK_REGEXP)
    if (flickrLinks !== null) {
        flickrLinks.forEach(function(url) {
            Flickr.getSizes(constant, url, function(full, thumb, link) {
                thumbnailModel.append({type: "image", full: full, thumb: thumb, link: link})
            })
        })
    }

    PIC_SERVICES.forEach(function(service) {
        var links = tweet.richText.match(service.regexp)
        if (links === null) return
        links.forEach(function(link) {
            var urls = service.getPicUrl(link)
            var picObj = { type: "image", full: urls.full, thumb: urls.thumb, link: link }
            thumbnailModel.append(picObj)
        })
    })
}

function createYoutubeThumb() {
    var youtubeLinks = tweet.richText.match(YouTube.YOUTUBE_LINK_REGEXP)
    if (youtubeLinks == null) return

    for (var i=0; i<youtubeLinks.length; i++) {
        YouTube.getVideoThumbnailAndLink(constant, youtubeLinks[i], function(thumb, rstpLink) {
            thumbnailModel.append({type: "video", thumb: thumb, full: "", link: rstpLink})
        })
    }
}

function createMapThumb() {
    if (!tweet.latitude || !tweet.longitude) return

    var thumbnailURL = Maps.getMaps(constant, tweet.latitude, tweet.longitude,
                                    constant.thumbnailSize, constant.thumbnailSize)
    thumbnailModel.append({type: "map", thumb: thumbnailURL, full: "", link: ""})
}

function expandTwitLonger() {
    var twitLongerLink = tweet.richText.match(/http:\/\/tl.gd\/\w+/)
    if (twitLongerLink == null) return

    TwitLonger.getFullTweet(constant, twitLongerLink[0], getTwitLongerTextOnSuccess, commonOnFailure)
    header.busy = true
}

function getConversationFromTimelineAndMentions() {
    if (!tweet.inReplyToStatusId) return
    backButton.enabled = false
    var msg = {
        ancestorModel: ancestorModel, descendantModel: descendantModel,
        timelineModel: mainPage.timeline.model, mentionsModel: mainPage.mentions.model,
        inReplyToStatusId: tweet.inReplyToStatusId
    }
    conversationParser.sendMessage(msg)
    header.busy = true
}

function contructReplyText() {
    var replyText = "@" + tweet.retweetScreenName + " "

    // if this is a retweet, include the original author screen name
    if (tweet.isRetweet)
        replyText += "@" + tweet.screenName + " "

    // check for other mentions in the tweet
    var mentionsArray = tweet.richText.match(/href="@\w+/g) || []
    mentionsArray.forEach(function(mentions) {
        mentions = mentions.substring(6)
        if (mentions.toLowerCase() !== "@" + settings.userScreenName.toLowerCase())
            replyText += mentions + " "
    })

    return replyText
}

function contructRetweetText() {
    var retweetText = "RT @" + tweet.retweetScreenName + ": "

    // if it is a retweet, include the original author screen name
    if (tweet.isRetweet)
        retweetText += "RT @" + tweet.screenName + ": "

    retweetText += tweet.plainText
    return retweetText
}

function deleteTweetOnSuccess(data) {
    mainPage.timeline.removeTweet(data.id_str)
    loadingRect.visible = false
    infoBanner.showText(qsTr("Tweet deleted successfully"))
    pageStack.pop()
}

function favouriteOnSuccess(data, isFavourite) {
    mainPage.timeline.favouriteTweet(data.id_str)
    mainPage.mentions.favouriteTweet(data.id_str)
    favouritedTweet = isFavourite
    if (favouritedTweet) infoBanner.showText(qsTr("Tweet favourited succesfully"))
    else infoBanner.showText(qsTr("Tweet unfavourited successfully"))
    header.busy = false
}

function getTwitLongerTextOnSuccess(fullTweetText) {
    tweetTextText.text = fullTweetText;
    header.busy = false
}

function translateTokenOnSuccess(token) {
    cache.translationToken = token
    Translation.translate(constant, cache.translationToken, tweet.plainText, settings.translateLangCode,
                          translateOnSuccess, commonOnFailure)
}

function translateOnSuccess(data) {
    if (data.indexOf("ArgumentOutOfRangeException") === 0)
        infoBanner.showText(qsTr("Unable to translate tweet"))
    else if (data.indexOf("TranslateApiException") === 0)
        infoBanner.showText(qsTr("Translation limit reached"))
    else {
        translatedTweetLoader.sourceComponent = translatedTweetComponent
        translatedTweetLoader.item.translatedText = data
    }
    header.busy = false
}

function commonOnFailure(status, statusText) {
    infoBanner.showHttpError(status, statusText)
    header.busy = false
    loadingRect.visible = false
}

function addToPocket(link) {
    if (!settings.pocketUsername || !settings.pocketPassword) {
        var message = qsTr("You are not signed in to your Pocket account. Please sign in to your Pocket account first under the \"Account\" tab in Settings.")
        dialog.createMessageDialog(qsTr("Pocket - Not Signed In"), message)
        return
    }

    Pocket.addPage(constant, settings.pocketUsername, settings.pocketPassword, link, tweet.plainText,
                   tweet.id, function() {
                       loadingRect.visible = false
                       infoBanner.showText(qsTr("The link has been sent to Pocket successfully"))
                   }, function(errorCode) {
                       loadingRect.visible = false
                       infoBanner.showText(qsTr("Error sending link to Pocket (%1)").arg(errorCode))
                   })
    loadingRect.visible = true
}

function addToInstapaper(link) {
    if (!settings.instapaperToken || !settings.instapaperTokenSecret) {
        var message = qsTr("You are not sign in to your Instapaper account. Please sign in to your Instapaper account first under the \"Account\" tab in the Settings.")
        dialog.createMessageDialog(qsTr("Instapaper - Not Signed In"), message)
        return
    }

    Instapaper.addBookmark(constant, settings.instapaperToken, settings.instapaperTokenSecret, link,
                           tweet.plainText, function() {
                               loadingRect.visible = false
                               infoBanner.showText(qsTr("The link has been sent to Instapaper successfully"))
                           }, function(errorCode) {
                               loadingRect.visible = false
                               infoBanner.showText(qsTr("Error sending link to Instapaper (%1)").arg(errorCode))
                           })
    loadingRect.visible = true
}

function createDeleteTweetDialog() {
    var icon = platformInverted ? "image://theme/toolbar-delete_inverse" : "image://theme/toolbar-delete"
    var message = qsTr("Do you want to delete this tweet?")
    dialog.createQueryDialog(qsTr("Delete Tweet"), icon, message, function() {
        Twitter.postDeleteStatus(tweet.id, deleteTweetOnSuccess, commonOnFailure)
        loadingRect.visible = true
    })
}
