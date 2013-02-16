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
    if (flickrLinks != null) {
        for (var iFlickr=0; iFlickr<flickrLinks.length; iFlickr++) {
            Flickr.getSizes(constant, flickrLinks[iFlickr], function(full, thumb, link) {
                thumbnailModel.append({type: "image", full: full, thumb: thumb, link: link})
            })
        }
    }

    for (var service in PIC_SERVICES) {
        var links = tweet.richText.match(PIC_SERVICES[service].regexp)
        if (links == null) continue
        for (var i=0; i<links.length; i++) {
            var urls = PIC_SERVICES[service].getPicUrl(links[i])
            var picObj = { type: "image", full: urls.full, thumb: urls.thumb, link: links[i] }
            thumbnailModel.append(picObj)
        }
    }
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

function getRTAndFavCount() {
    Twitter.getTweetActivitySummary(tweet.id, function(data) {
        var rtCount = parseInt(data.retweeters_count, 10)
        var favCount = parseInt(data.favoriters_count, 10)
        if (rtCount > 0) {
            var rtObj = {
                text: qsTr("%n retweet(s)", "", rtCount),
                headerText: qsTr("Retweeters"),
                count: rtCount,
                icon: settings.invertedTheme ? "Image/retweet_inverse.png" : "Image/retweet.png"
            }
            rtAndFavCountRepeater.model.append(rtObj)
        }
        if (favCount > 0) {
            var favObj = {
                text: qsTr("%n favourite(s)", "", favCount),
                headerText: qsTr("Favouriters"),
                count: favCount,
                icon: "image://theme/icon-m-toolbar-favorite-mark" + (settings.invertedTheme ? "" : "-white") + "-selected"
            }
            rtAndFavCountRepeater.model.append(favObj)
        }
        retweeters = data.retweeters
        favoriters = data.favoriters
    }, function(status, statusText) {
        console.log("Error calling Twitter.getTweetActivitySummary():",status, statusText)
    })
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

function getConversationFromTwitter() {
    if (!networkMonitor.online) return
    Twitter.getConversation(tweet.id, function(data) {
        if (tweetPage.status === PageStatus.Deactivating) return
        backButton.enabled = false
        conversationParser.sendMessage({data: data, ancestorModel: ancestorModel, descendantModel:descendantModel})
    }, function(status, statusText) {
        console.log("Error caliing Twitter.getConversation():", status, statusText)
        header.busy = false
    })
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

    // check for hashtag in the tweet if hashtagsInReply is enabled
    if (settings.hashtagsInReply) {
        var hashtagsArray = tweet.richText.match(/href="#[^"\s]+/g) || []
        hashtagsArray.forEach(function(hashtag) {
            replyText += hashtag.substring(6) + " "
        })
    }
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
    var message = qsTr("Do you want to delete this tweet?")
    dialog.createQueryDialog(qsTr("Delete Tweet"), "", message, function() {
        Twitter.postDeleteStatus(tweet.id, deleteTweetOnSuccess, commonOnFailure)
        loadingRect.visible = true
    })
}
