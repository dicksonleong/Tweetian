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

.pragma library

Qt.include("../Utils/Parser.js")

var POST_TWEET_URL = "http://www.twitlonger.com/api_post"
var ID_CALLBACK_URL = "http://www.twitlonger.com/api_set_id"
var GET_FULL_TWEET_URL = "http://www.twitlonger.com/api_read/"

function postTweet(constant, username, text, inReplyToStatusId, inReplyToUser, onSuccess, onFailure) {
    var parameters = {
        application: constant.twitlongerApp,
        api_key: constant.twitlongerAPIKey,
        username: username,
        message: text
    }
    if (inReplyToStatusId) parameters.in_reply = inReplyToStatusId
    if (inReplyToUser) parameters.in_reply_user = inReplyToUser

    var body = constant.encodeParameters(parameters)
    var request = new XMLHttpRequest()
    request.open("POST", POST_TWEET_URL)

    request.onreadystatechange = function() {
        if (request.readyState === XMLHttpRequest.DONE) {
            if (request.status == 200) {
                var id = "", shortenTweet = ""
                var xml = request.responseXML.documentElement.childNodes
                for (var i=0; i<xml.length; i++) {
                    if (xml[i].nodeName === "post") {
                        for (var i2=0; i2<xml[i].childNodes.length; i2++) {
                            if (xml[i].childNodes[i2].nodeName === "id")
                                id = xml[i].childNodes[i2].childNodes[0].nodeValue
                            else if (xml[i].childNodes[i2].nodeName === "content")
                                shortenTweet = xml[i].childNodes[i2].childNodes[0].nodeValue
                        }
                        break
                    }
                }
                if (id && shortenTweet) onSuccess(id, shortenTweet)
                else onFailure(-1, "Response parsing error")
            }
            else onFailure(request.status, request.statusText)
        }
    }

    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    request.setRequestHeader("User-Agent", constant.userAgent)
    request.send(body)
}

function postIDCallback(constant, messageId, twitterId) {
    var parameters = {
        application: constant.twitlongerApp,
        api_key: constant.twitlongerAPIKey,
        message_id: messageId,
        twitter_id: twitterId
    }
    var body = constant.encodeParameters(parameters)
    var request = new XMLHttpRequest()
    request.open("POST", ID_CALLBACK_URL)

    request.onreadystatechange = function() {
        if (request.readyState === XMLHttpRequest.DONE) {
            console.log("[TwitLonger] ID Callback Status:",request.status)
        }
    }

    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    request.setRequestHeader("User-Agent", constant.userAgent)
    request.send(body)
}

// TwitLonger link should be in the form of http://tl.gd/xxxxxx
function getFullTweet(constant, twitLongerLink, onSuccess, onFailure) {
    var url = GET_FULL_TWEET_URL + twitLongerLink.substring(13)
    var request = new XMLHttpRequest()
    request.open("GET", url)

    request.onreadystatechange = function() {
        if (request.readyState === XMLHttpRequest.DONE) {
            if (request.status == 200) {
                var fullTweetText = ""
                var xml = request.responseXML.documentElement.childNodes[1].childNodes
                for (var i=0; i<xml.length; i++) {
                    if (xml[i].nodeName === "content") {
                        fullTweetText = xml[i].childNodes[0].nodeValue
                        break
                    }
                }
                if (fullTweetText) {
                    fullTweetText += " - " + twitLongerLink;
                    fullTweetText = fullTweetText.replace(/http:\/\/\S+/g, function(url) {
                        return linkText(url.substring(7), url, true);
                    })
                    fullTweetText = fullTweetText.replace(/@\w+/g, function(mentions) {
                        return linkText(mentions, mentions, false);
                    })
                    fullTweetText = fullTweetText.replace(/#\w+/g, function(hashtag) {
                        return linkText(hashtag, hashtag, false);
                    })
                    onSuccess(fullTweetText, twitLongerLink)
                }
                else onFailure(-1, "Response parsing error")
            }
            else onFailure(request.status, request.statusText)
        }
    }

    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    request.setRequestHeader("User-Agent", constant.userAgent)
    request.send()
}
