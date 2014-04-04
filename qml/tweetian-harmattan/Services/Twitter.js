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

var OAUTH_CONSUMER_KEY
var OAUTH_CONSUMER_SECRET
var OAUTH_TOKEN
var OAUTH_TOKEN_SECRET
var USER_AGENT

// OAUTH
var REQUEST_TOKEN_URL = "https://api.twitter.com/oauth/request_token"
var ACCESS_TOKEN_URL = "https://api.twitter.com/oauth/access_token"

// GET
var GET_TIMELIME_URL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
var GET_MENTIONS_URL = "https://api.twitter.com/1.1/statuses/mentions_timeline.json"
var GET_DIRECT_MSG_URL = "https://api.twitter.com/1.1/direct_messages.json"
var GET_SENT_DIRECT_MSG_URL = "https://api.twitter.com/1.1/direct_messages/sent.json"
var GET_SHOW_USERS_URL = "https://api.twitter.com/1.1/users/show.json"
var GET_USER_TWEETS_URL = "https://api.twitter.com/1.1/statuses/user_timeline.json"
var GET_VERIFY_CREDENTIALS_URL = "https://api.twitter.com/1.1/account/verify_credentials.json"
var GET_USER_FAVOURITES_URL = "https://api.twitter.com/1.1/favorites/list.json"
var GET_USER_LISTS_ALL_URL = "https://api.twitter.com/1.1/lists/list.json"
var GET_USER_LISTS_MEMBERSHIPS_URL = "https://api.twitter.com/1.1/lists/memberships.json"
var GET_LIST_TIMELINE_URL = "https://api.twitter.com/1.1/lists/statuses.json"
var GET_LIST_MEMBER_URL = "https://api.twitter.com/1.1/lists/members.json"
var GET_LIST_SUBSCRIBERS_URL = "https://api.twitter.com/1.1/lists/subscribers.json"
var GET_TRENDS_URL = "https://api.twitter.com/1.1/trends/place.json"
var GET_TRENDS_AVAILABLE_URL = "https://api.twitter.com/1.1/trends/available.json"
var GET_SAVED_SEARCHES_URL = "https://api.twitter.com/1.1/saved_searches/list.json"
var GET_SEARCH_URL = "https://api.twitter.com/1.1/search/tweets.json"
var GET_FOLLOWING_ID_URL = "https://api.twitter.com/1.1/friends/ids.json"
var GET_FOLLOWERS_ID_URL = "https://api.twitter.com/1.1/followers/ids.json"
var GET_USERS_LOOKUP_URL = "https://api.twitter.com/1.1/users/lookup.json"
var GET_USERS_SEARCH_URL = "https://api.twitter.com/1.1/users/search.json"
var GET_STATUS_SHOW_URL = "https://api.twitter.com/1.1/statuses/show.json"
var GET_SUGGESTED_USER_CATERGORIES = "https://api.twitter.com/1.1/users/suggestions.json"
var GET_SUGGESTED_USER = "https://api.twitter.com/1.1/users/suggestions/%1.json"
var GET_PRIVACY_URL = "https://api.twitter.com/1.1/help/privacy.json"
var GET_TOS_URL = "https://api.twitter.com/1.1/help/tos.json"

var GET_USER_STREAM_URL = "https://userstream.twitter.com/1.1/user.json"

// POST
var POST_STATUS_URL = "https://api.twitter.com/1.1/statuses/update.json"
var POST_RETWEET_URL = "https://api.twitter.com/1.1/statuses/retweet/%1.json"
var POST_FAVOURITE_URL = "https://api.twitter.com/1.1/favorites/create.json"
var POST_UNFAVOURITE_URL = "https://api.twitter.com/1.1/favorites/destroy.json"
var POST_DIRECT_MSG_URL = "https://api.twitter.com/1.1/direct_messages/new.json"
var POST_BLOCK_USER_URL = "https://api.twitter.com/1.1/blocks/create.json"
var POST_REPORT_SPAM_URL = "https://api.twitter.com/1.1/users/report_spam.json"
var POST_SAVED_SEARCHES_URL = "https://api.twitter.com/1.1/saved_searches/create.json"
var POST_REMOVE_SAVED_SEARCH_URL = "https://api.twitter.com/1.1/saved_searches/destroy/%1.json"
var POST_DIRECT_MSG_DELETE_URL = "https://api.twitter.com/1.1/direct_messages/destroy.json"
var POST_FOLLOW_URL = "https://api.twitter.com/1.1/friendships/create.json"
var POST_UNFOLLOW_URL = "https://api.twitter.com/1.1/friendships/destroy.json"
var POST_DELETE_STATUS_URL = "https://api.twitter.com/1.1/statuses/destroy/%1.json"
var POST_SUBSCRIBE_LIST_URL = "https://api.twitter.com/1.1/lists/subscribers/create.json"
var POST_UNSUBSCRIBE_LIST_URL = "https://api.twitter.com/1.1/lists/subscribers/destroy.json"
var POST_DELETE_LIST_URL = "https://api.twitter.com/1.1/lists/destroy.json"
var TWITTER_IMAGE_UPLOAD_URL = "https://api.twitter.com/1.1/statuses/update_with_media.json"

function init(constant, token, tokenSecret) {
    OAUTH_CONSUMER_KEY = constant.twitterConsumerKey
    OAUTH_CONSUMER_SECRET = constant.twitterConsumerSecret
    OAUTH_TOKEN = token
    OAUTH_TOKEN_SECRET = tokenSecret
    USER_AGENT = constant.userAgent
}

function OAuthRequest(method, url) {
    this.accessor = {
        consumerKey: OAUTH_CONSUMER_KEY,
        consumerSecret: OAUTH_CONSUMER_SECRET,
        token: OAUTH_TOKEN,
        tokenSecret: OAUTH_TOKEN_SECRET
    }
    this.message = {
        action: url,
        method: method
    }
}

OAuthRequest.prototype.setParameters = function(parameters) {
    this.message.parameters = parameters
}

OAuthRequest.prototype.sendRequest = function(onSuccess, onFailure) {
    var encoded = OAuth.formEncode(this.message.parameters)
    var encodedURL = this.message.method == "GET" && encoded.length > 0 ? this.message.action + '?' + encoded
                                                                        : this.message.action
    OAuth.completeRequest(this.message, this.accessor)
    var authorizationHeader = OAuth.getAuthorizationHeader(this.message.action, this.message.parameters)
    var request = new XMLHttpRequest()
    request.open(this.message.method, encodedURL)

    request.onreadystatechange = function() {
        if (request.readyState == XMLHttpRequest.DONE) {
            if (request.status === 200) {
                if (request.responseText != "") onSuccess(JSON.parse(request.responseText))
                else onSuccess("")
            }
            else onFailure(request.status, request.statusText)
        }
    }

    request.setRequestHeader("Authorization", authorizationHeader)
    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    request.setRequestHeader("User-Agent", USER_AGENT)
    request.send(encoded)
}

function getHomeTimeline(sinceId, maxId, onSuccess, onFailure) {
    var timelineRequest = new OAuthRequest("GET", GET_TIMELIME_URL)
    var parameters = [["count", "200"], ["include_rts", true]]
    if (maxId) parameters.push(["max_id", maxId])
    else if (sinceId) parameters.push(["since_id", sinceId])
    timelineRequest.setParameters(parameters)
    timelineRequest.sendRequest(onSuccess, onFailure)
}

function getMentions(sinceId, maxId, onSuccess, onFailure) {
    var mentionsRequest = new OAuthRequest("GET", GET_MENTIONS_URL)
    var parameters = [["count", "200"], ["include_rts", true]]
    if (maxId) parameters.push(["max_id", maxId])
    else if (sinceId) parameters.push(["since_id", sinceId])
    mentionsRequest.setParameters(parameters)
    mentionsRequest.sendRequest(onSuccess, onFailure)
}

function getDirectMsg(sinceId, maxId, onSuccess, onFailure) {
    var directMsgRequest = new OAuthRequest("GET", GET_DIRECT_MSG_URL)
    var parameters = [["count", "100"]]
    if (maxId) parameters.push(["max_id", maxId])
    else if (sinceId) parameters.push(["since_id", sinceId])
    directMsgRequest.setParameters(parameters)
    directMsgRequest.sendRequest(function(data) {
                                     getSentDirectMsg(sinceId, maxId, data, onSuccess, onFailure)
                                 },onFailure)
}

function getSentDirectMsg(sinceId, maxId, dmRecieve, onSucces, onFailure) {
    var directMsgSent = new OAuthRequest("GET", GET_SENT_DIRECT_MSG_URL)
    var parameters = [["count", "100"]]
    if (maxId) parameters.push(["max_id", maxId])
    else if (sinceId) parameters.push(["since_id", sinceId])
    directMsgSent.setParameters(parameters)
    directMsgSent.sendRequest(function(data) {onSucces(dmRecieve, data)}, onFailure)
}

function getStatus(statusId, onSuccess, onFailure) {
    var statusRequest = new OAuthRequest("GET", GET_STATUS_SHOW_URL)
    statusRequest.setParameters([["id", statusId]])
    statusRequest.sendRequest(onSuccess, onFailure)
}

function getUserInfo(screenName, onSuccess, onFailure) {
    var userInfoRequest = new OAuthRequest("GET", GET_SHOW_USERS_URL)
    userInfoRequest.setParameters([["screen_name", screenName]])
    userInfoRequest.sendRequest(onSuccess, onFailure)
}

function getUserTweets(screenName, maxId, onSuccess, onFailure) {
    var userTweetsRequest = new OAuthRequest("GET", GET_USER_TWEETS_URL)
    var parameters = [["screen_name", screenName], ["count", 50], ["include_rts", true]]
    if (maxId) parameters.push(["max_id", maxId])
    userTweetsRequest.setParameters(parameters)
    userTweetsRequest.sendRequest(onSuccess, onFailure)
}

function getUserFavourites(screenName, maxId, onSuccess, onFailure) {
    var favouritesRequest = new OAuthRequest("GET", GET_USER_FAVOURITES_URL)
    var parameters = [["screen_name", screenName], ["count", 50]]
    if (maxId) parameters.push(["max_id", maxId])
    favouritesRequest.setParameters(parameters)
    favouritesRequest.sendRequest(onSuccess, onFailure)
}

function getUserLists(screenName, onSuccess, onFailure) {
    var listsRequest = new OAuthRequest("GET", GET_USER_LISTS_ALL_URL)
    listsRequest.setParameters([["screen_name", screenName]])
    listsRequest.sendRequest(onSuccess, onFailure)
}

function getUserListsMemberships(screenName, cursor, onSuccess, onFailure) {
    cursor = cursor || -1
    var listsMemberRequest = new OAuthRequest("GET", GET_USER_LISTS_MEMBERSHIPS_URL)
    listsMemberRequest.setParameters([["screen_name", screenName], ["cursor", cursor]])
    listsMemberRequest.sendRequest(onSuccess, onFailure)
}

function getListTimeline(listId, sinceId, maxId, onSuccess, onFailure) {
    var listTimelineRequest = new OAuthRequest("GET", GET_LIST_TIMELINE_URL)
    var parameters = [["list_id", listId], ["per_page", 100], ["include_rts", true]]
    if (sinceId) parameters.push(["since_id", sinceId])
    else if (maxId) parameters.push(["max_id", maxId])
    listTimelineRequest.setParameters(parameters)
    listTimelineRequest.sendRequest(onSuccess, onFailure)
}

function getListMembers(listId, cursor, onSuccess, onFailure) {
    var listMemberRequest = new OAuthRequest("GET", GET_LIST_MEMBER_URL)
    listMemberRequest.setParameters([["list_id", listId], ["cursor", cursor], ["skip_status", true]])
    listMemberRequest.sendRequest(onSuccess, onFailure)
}

function getListSubscribers(listId, cursor, onSuccess, onFailure) {
    var listSubscribersRequest = new OAuthRequest("GET", GET_LIST_SUBSCRIBERS_URL)
    listSubscribersRequest.setParameters([["list_id", listId], ["cursor", cursor], ["skip_status", true]])
    listSubscribersRequest.sendRequest(onSuccess, onFailure)
}

function getTrends(woeid, onSuccess, onFailure) {
    var trendsRequest = new OAuthRequest("GET", GET_TRENDS_URL)
    trendsRequest.setParameters([["id", woeid]])
    trendsRequest.sendRequest(onSuccess, onFailure)
}

function getTrendsAvailable(onSuccess, onFailure) {
    var trendsAvailableRequest = new OAuthRequest("GET", GET_TRENDS_AVAILABLE_URL)
    trendsAvailableRequest.sendRequest(onSuccess, onFailure)
}

function getSavedSearches(onSuccess, onFailure) {
    var savedSearchRequest = new OAuthRequest("GET", GET_SAVED_SEARCHES_URL)
    savedSearchRequest.sendRequest(onSuccess, onFailure)
}

function getSearch(query, sinceId, maxId, onSuccess, onFailure) {
    var searchRequest = new OAuthRequest("GET", GET_SEARCH_URL)
    var parameters = [["q", query], ["count", 50]]
    if (maxId) parameters.push(["max_id", maxId])
    else if (sinceId) parameters.push(["since_id", sinceId])
    searchRequest.setParameters(parameters)
    searchRequest.sendRequest(onSuccess, onFailure)
}

function getNearbyTweets(latitude, longitude, sinceId, maxId, onSuccess, onFailure) {
    var geocode = latitude + "," + longitude + ",1km"
    var nearbyTweetsRequest = new OAuthRequest("GET", GET_SEARCH_URL)
    var parameters = [["geocode", geocode], ["count", 50]]
    if (maxId) parameters.push(["max_id", maxId])
    else if (sinceId) parameters.push(["since_id", sinceId])
    nearbyTweetsRequest.setParameters(parameters)
    nearbyTweetsRequest.sendRequest(onSuccess, onFailure)
}

function getUserSearch(query, page, onSuccess, onFailure) {
    var userSearchRequest = new OAuthRequest("GET", GET_USERS_SEARCH_URL)
    userSearchRequest.setParameters([["q", query], ["page", page], ["per_page", 20]])
    userSearchRequest.sendRequest(onSuccess, onFailure)
}

function getFollowingId(screenName, onSuccess, onFailure) {
    var followingIdRequest = new OAuthRequest("GET", GET_FOLLOWING_ID_URL)
    followingIdRequest.setParameters([["screen_name", screenName], ["stringify_ids", true]])
    followingIdRequest.sendRequest(onSuccess, onFailure)
}

function getFollowersId(screenName, onSuccess, onFailure) {
    var followersIdRequest = new OAuthRequest("GET", GET_FOLLOWERS_ID_URL)
    followersIdRequest.setParameters([["screen_name", screenName], ["stringify_ids", true]])
    followersIdRequest.sendRequest(onSuccess, onFailure)
}

function getUserLookup(userId, onSuccess, onFailure) {
    var userLookupRequest = new OAuthRequest("GET", GET_USERS_LOOKUP_URL)
    userLookupRequest.setParameters([["user_id", userId]])
    userLookupRequest.sendRequest(onSuccess, onFailure)
}

function getSuggestedUserCategories(onSuccess, onFailure) {
    var userCategoriesRequest = new OAuthRequest("GET", GET_SUGGESTED_USER_CATERGORIES)
    userCategoriesRequest.sendRequest(onSuccess, onFailure)
}

function getSuggestedUser(slug, onSuccess, onFailure) {
    var suggestedUserRequest = new OAuthRequest("GET", GET_SUGGESTED_USER.arg(encodeURIComponent(slug)))
    suggestedUserRequest.sendRequest(onSuccess, onFailure)
}

function getPrivacyPolicy(onSuccess, onFailure) {
    var privacyRequest = new OAuthRequest("GET", GET_PRIVACY_URL)
    privacyRequest.sendRequest(onSuccess, onFailure)
}

function getTermsOfService(onSuccess, onFailure) {
    var tosRequest = new OAuthRequest("GET", GET_TOS_URL)
    tosRequest.sendRequest(onSuccess, onFailure)
}

function getVerifyCredentials(onSuccess, onFailure) {
    var verifyCrendtialsRequest = new OAuthRequest("GET", GET_VERIFY_CREDENTIALS_URL)
    verifyCrendtialsRequest.sendRequest(onSuccess, onFailure)
}

function postRequestToken(onSuccess, onFailure) {
    var accessor = {
        consumerKey: OAUTH_CONSUMER_KEY,
        consumerSecret: OAUTH_CONSUMER_SECRET
    }
    var message = {
        action: REQUEST_TOKEN_URL,
        method: "POST",
        parameters: [["oauth_callback", "oob"]]
    }
    OAuth.completeRequest(message, accessor)
    var authorizationHeader = OAuth.getAuthorizationHeader(message.action, message.parameters)
    var request = new XMLHttpRequest()
    request.open(message.method, message.action)

    request.onreadystatechange = function() {
        if (request.readyState === XMLHttpRequest.DONE) {
            if (request.status === 200) {
                var token, tokenSecret, callbackConfirmed
                var tokenArray = request.responseText.split('&')
                for (var i=0; i<tokenArray.length; i++) {
                    if (tokenArray[i].indexOf("oauth_token=") == 0) token = tokenArray[i].substring(12)
                    else if (tokenArray[i].indexOf("oauth_token_secret=") == 0) tokenSecret = tokenArray[i].substring(19)
                }
                onSuccess(token, tokenSecret)
            }
            else onFailure(request.status, request.statusText)
        }
    }

    request.setRequestHeader("Authorization", authorizationHeader)
    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    request.setRequestHeader("User-Agent", USER_AGENT)
    request.send()
}

function postAccessToken(token, tokenSecret, oauthVerifier, onSuccess, onFailure) {
    var accessor = {
        consumerKey: OAUTH_CONSUMER_KEY,
        consumerSecret: OAUTH_CONSUMER_SECRET,
        token: token,
        tokenSecret: tokenSecret
    }
    var message = {
        action: ACCESS_TOKEN_URL,
        method: "POST",
        parameters: [["oauth_verifier", oauthVerifier]]
    }
    var body = OAuth.formEncode(message.parameters)
    OAuth.completeRequest(message, accessor)
    var authorizationHeader = OAuth.getAuthorizationHeader(message.action, message.parameters)
    var request = new XMLHttpRequest()
    request.open(message.method, message.action)

    request.onreadystatechange = function() {
        if (request.readyState === XMLHttpRequest.DONE) {
            if (request.status === 200) {
                var token, tokenSecret, screenName
                var tokenArray = request.responseText.split('&')
                for (var i=0; i<tokenArray.length; i++) {
                    if (tokenArray[i].indexOf("oauth_token=") == 0) token = tokenArray[i].substring(12)
                    else if (tokenArray[i].indexOf("oauth_token_secret=") == 0) tokenSecret = tokenArray[i].substring(19)
                    else if (tokenArray[i].indexOf("screen_name=") == 0) screenName = tokenArray[i].substring(12)
                }
                onSuccess(token, tokenSecret, screenName)
            }
            else onFailure(request.status, request.statusText)
        }
    }

    request.setRequestHeader("Authorization", authorizationHeader)
    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    request.setRequestHeader("User-Agent", USER_AGENT)
    request.send(body)
}

function postStatus(status, statusId, latitude, longitude, onSuccess, onFailure) {
    var postStatusRequest = new OAuthRequest("POST", POST_STATUS_URL)
    var parameters = [["status", status]]
    if (statusId) parameters.push(["in_reply_to_status_id", statusId])
    if (latitude && longitude) {
        parameters.push(["lat", latitude])
        parameters.push(["long", longitude])
    }
    postStatusRequest.setParameters(parameters)
    postStatusRequest.sendRequest(onSuccess, onFailure)
}

function postDeleteStatus(statusId, onSuccess, onFailure) {
    var deleteStatusRequest = new OAuthRequest("POST", POST_DELETE_STATUS_URL.arg(statusId + ""))
    deleteStatusRequest.sendRequest(onSuccess, onFailure)
}

function postDirectMsg(status, screenName, onSuccess, onFailure) {
    var postDirectMsgRequest = new OAuthRequest("POST", POST_DIRECT_MSG_URL)
    postDirectMsgRequest.setParameters([["text", status], ["screen_name", screenName]])
    postDirectMsgRequest.sendRequest(onSuccess, onFailure)
}

function postDeleteDirectMsg(statusId, onSuccess, onFailure) {
    var deleteDirectMsg = new OAuthRequest("POST", POST_DIRECT_MSG_DELETE_URL)
    deleteDirectMsg.setParameters([["id", statusId]])
    deleteDirectMsg.sendRequest(onSuccess, onFailure)
}

function postRetweet(statusId, onSuccess, onFailure) {
    var retweetRequest = new OAuthRequest("POST", POST_RETWEET_URL.arg(statusId + ""))
    retweetRequest.sendRequest(onSuccess, onFailure)
}

function postFavourite(statusId, onSuccess, onFailure) {
    var favouriteRequest = new OAuthRequest("POST", POST_FAVOURITE_URL)
    favouriteRequest.setParameters([["id", statusId]])
    favouriteRequest.sendRequest(function(data) {onSuccess(data, true)}, onFailure)
}

function postUnfavourite(statusId, onSuccess, onFailure) {
    var unfavouriteRequest = new OAuthRequest("POST", POST_UNFAVOURITE_URL)
    unfavouriteRequest.setParameters([["id", statusId]])
    unfavouriteRequest.sendRequest(function(data) {onSuccess(data, false)}, onFailure)
}

function postFollow(screenName, onSuccess, onFailure) {
    var followRequest = new OAuthRequest("POST", POST_FOLLOW_URL)
    followRequest.setParameters([["screen_name", screenName]])
    followRequest.sendRequest(function(data) {onSuccess(data, true)}, onFailure)
}

function postUnfollow(screenName, onSuccess, onFailure) {
    var unfollowRequest = new OAuthRequest("POST", POST_UNFOLLOW_URL)
    unfollowRequest.setParameters([["screen_name", screenName]])
    unfollowRequest.sendRequest(function(data) {onSuccess(data, false)}, onFailure)
}

function postSavedSearches(query, onSuccess, onFailure) {
    var savedNewSearchRequest = new OAuthRequest("POST", POST_SAVED_SEARCHES_URL)
    savedNewSearchRequest.setParameters([["query", query]])
    savedNewSearchRequest.sendRequest(onSuccess, onFailure)
}

function postRemoveSavedSearch(id, onSuccess, onFailure) {
    var removeSearchRequest = new OAuthRequest("POST", POST_REMOVE_SAVED_SEARCH_URL.arg(id + ""))
    removeSearchRequest.sendRequest(onSuccess, onFailure)
}

function postBlockUser(screenName, onSuccess, onFailure) {
    var reportSpamRequest = new OAuthRequest("POST", POST_BLOCK_USER_URL)
    var parameters = [["screen_name", screenName],
                      ["include_entities", "false"],
                      ["skip_status", "true"]]
    reportSpamRequest.setParameters(parameters)
    reportSpamRequest.sendRequest(onSuccess, onFailure)
}

function postReportSpam(screenName, onSuccess, onFailure) {
    var reportSpamRequest = new OAuthRequest("POST", POST_REPORT_SPAM_URL)
    reportSpamRequest.setParameters([["screen_name", screenName]])
    reportSpamRequest.sendRequest(onSuccess, onFailure)
}

function postSubscribeList(listId, onSuccess, onFailure) {
    var subscribeListRequest = new OAuthRequest("POST", POST_SUBSCRIBE_LIST_URL)
    subscribeListRequest.setParameters([["list_id", listId]])
    subscribeListRequest.sendRequest(onSuccess, onFailure)
}

function postUnsubscribeList(listId, onSuccess, onFailure) {
    var unsubscriberListRequest = new OAuthRequest("POST", POST_UNSUBSCRIBE_LIST_URL)
    unsubscriberListRequest.setParameters([["list_id", listId]])
    unsubscriberListRequest.sendRequest(onSuccess, onFailure)
}

function postDeleteList(listId, onSuccess, onFailure) {
    var deleteListRequest = new OAuthRequest("POST", POST_DELETE_LIST_URL)
    deleteListRequest.setParameters([["list_id", listId]])
    deleteListRequest.sendRequest(onSuccess, onFailure)
}

// functions for generating header and url for use in C++
function getTwitterImageUploadAuthHeader() {
    var accessor = {
        consumerKey: OAUTH_CONSUMER_KEY,
        consumerSecret: OAUTH_CONSUMER_SECRET,
        token: OAUTH_TOKEN,
        tokenSecret: OAUTH_TOKEN_SECRET
    }
    var message = {
        action: TWITTER_IMAGE_UPLOAD_URL,
        method: "POST"
    }
    OAuth.completeRequest(message, accessor)
    return OAuth.getAuthorizationHeader(message.action, message.parameters)
}

function getUserStreamURLAndHeader() {
    var accessor = {
        consumerKey: OAUTH_CONSUMER_KEY,
        consumerSecret: OAUTH_CONSUMER_SECRET,
        token: OAUTH_TOKEN,
        tokenSecret: OAUTH_TOKEN_SECRET
    }
    var message = {
        action: GET_USER_STREAM_URL,
        method: "GET",
        parameters: [["delimited", "length"], ["with", "followings"]]
    }
    var url = OAuth.addToURL(message.action, message.parameters)
    OAuth.completeRequest(message, accessor)
    var authorizationHeader = OAuth.getAuthorizationHeader(message.action, message.parameters)
    return {url: url, header: authorizationHeader}
}

function getOAuthEchoAuthHeader() {
    var accessor = {
        consumerKey: OAUTH_CONSUMER_KEY,
        consumerSecret: OAUTH_CONSUMER_SECRET,
        token: OAUTH_TOKEN,
        tokenSecret: OAUTH_TOKEN_SECRET
    }
    var message = {
        action: GET_VERIFY_CREDENTIALS_URL,
        method: "GET"
    }
    OAuth.completeRequest(message, accessor)
    return OAuth.getAuthorizationHeader(message.action, message.parameters)
}
