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

Qt.include("../lib/oauth.js")

var ACCESS_TOKEN_URL = "https://www.instapaper.com/api/1/oauth/access_token"
var ADD_BOOKMARK_URL = "https://www.instapaper.com/api/1/bookmarks/add"

function getAccessToken(constant, username, password, onSuccess, onFailure) {
    var accessor = {
        consumerKey: constant.instapaperConsumerKey,
        consumerSecret: constant.instapaperConsumerSecret
    }
    var message = {
        action: ACCESS_TOKEN_URL,
        method: "POST",
        parameters: [["x_auth_username", username], ["x_auth_password", password], ["x_auth_mode", "client_auth"]]
    }
    var body = OAuth.formEncode(message.parameters)
    OAuth.completeRequest(message, accessor)
    //var authorizationHeader = OAuth.getAuthorizationHeader("https://www.instapaper.com/", message.parameters)
    var request = new XMLHttpRequest()
    var requestURL = OAuth.addToURL(message.action, message.parameters)
    request.open(message.method, requestURL)

    request.onreadystatechange = function() {
        if (request.readyState === XMLHttpRequest.DONE) {
            if (request.status === 200) {
                var oauthToken = "", oauthTokenSecret = ""
                var tokenArray = request.responseText.split('&')
                for (var i=0; i<tokenArray.length; i++) {
                    if (tokenArray[i].indexOf("oauth_token=") === 0)
                        oauthToken = tokenArray[i].substring(12)
                    else if (tokenArray[i].indexOf("oauth_token_secret=") === 0)
                        oauthTokenSecret = tokenArray[i].substring(19)
                }
                onSuccess(oauthToken, oauthTokenSecret)
            }
            else onFailure(request.status)
        }
    }

    //request.setRequestHeader("Authorization", authorizationHeader)
    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    request.setRequestHeader("User-Agent", constant.userAgent)
    request.send(body)
}

function addBookmark(constant, accessToken, accessTokenSecret, url, description, onSuccess, onFailure) {
    var accessor = {
        consumerKey: constant.instapaperConsumerKey,
        consumerSecret: constant.instapaperConsumerSecret,
        token: accessToken,
        tokenSecret: accessTokenSecret
    }
    var message = {
        action: ADD_BOOKMARK_URL,
        method: "POST",
        parameters: [["url", url], ["description", description]]
    }
    var body = OAuth.formEncode(message.parameters)
    OAuth.completeRequest(message, accessor)
    //var authorizationHeader = OAuth.getAuthorizationHeader("", message.parameters)
    var request = new XMLHttpRequest()
    var requestURL = OAuth.addToURL(message.action, message.parameters)
    request.open(message.method, requestURL)

    request.onreadystatechange = function() {
        if (request.readyState === XMLHttpRequest.DONE) {
            if (request.status === 200) onSuccess()
            else onFailure(request.status)
        }
    }

    //request.setRequestHeader("Authorization", authorizationHeader)
    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    request.setRequestHeader("User-Agent", constant.userAgent)
    request.send(body)
}
