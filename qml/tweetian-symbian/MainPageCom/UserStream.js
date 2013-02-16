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

var friendIDList = []

function initialize() {
    if (networkMonitor.online && settings.enableStreaming) {
        log("App is online and streaming is enabled, connect to streaming in " + reconnectTimer.interval/1000 + "s")
        reconnectTimer.start()
    }
    streamingSettingsConnection.target = settings
    onlineConnection.target = networkMonitor
}

function streamRecieved(rawData) {
    reconnectTimer.interval = 5000 // reset reconnect timer interval
    timeOutTimer.restart() // reset timeout timer

    if (!rawData) {
        log("Keep Alive newline recieved")
        return
    }

    var data = JSON.parse(rawData);

    if (data.hasOwnProperty("friends")) {
        log("Friends response received with length " + data.friends.length)
        friendIDList = data.friends
    }
    else if (data.hasOwnProperty("direct_message")) {
        log("DMs response received")
        if (data.direct_message.recipient_screen_name === settings.userScreenName)
            directMsg.insertNewDMs([data.direct_message], [])
        else
            directMsg.insertNewDMs([], [data.direct_message])
    }
    else if (data.hasOwnProperty("text")) {
        var isMention = false;
        if (data.hasOwnProperty("entities") && Array.isArray(data.entities.user_mentions)) {
            isMention = data.entities.user_mentions.some(function(mentionsObject) {
                if (mentionsObject.screen_name !== settings.userScreenName)
                    return false;

                mentions.prependNewTweets([data]);
                return true;
            })
        }

        if (!isMention || __isFollowingUser(data.user.id)) timeline.prependNewTweets([data])
        log(isMention ? "Mentions received" : "Status received")
    }
    else if (data.hasOwnProperty("delete")) {
        log("Delete response received")
        if (data["delete"].hasOwnProperty("direct_message")) {
            directMsg.removeDM(data["delete"].direct_message.id_str)
        }
        else {
            timeline.removeTweet(data["delete"].status.id_str)
            mentions.removeTweet(data["delete"].status.id_str)
        }
    }
    else if (data.hasOwnProperty("event")) {
        log("Event response received with event_name: " + data.event)
    }
}

function reconnectStream(statusCode, errorText) {
    reconnectTimer.interval = Math.min(reconnectTimer.interval * 2, 300000)
    reconnectTimer.restart()
    var logText = "Disconnected from streaming (" + statusCode + " " + errorText + "). Reconnect in "
            + reconnectTimer.interval / 1000 + " seconds."
    infoBanner.showText(logText)
    log(logText)
}

function refreshAll() {
    if (!timeline.busy) timeline.refresh("newer")
    if (!mentions.busy) mentions.refresh("newer")
    if (!directMsg.busy) directMsg.refresh("newer")
}

// This will failed if user_id size is too long (>53bit)
function __isFollowingUser(user_id) {
    for (var i=0; i<friendIDList.length; i++) {
        if (user_id == friendIDList[i])
            return true
    }
    return false
}

function log(message) {
    var time = Qt.formatTime(new Date(), "h:mm:ss")
    console.log(time, "[UserStream]", message)
}

// This is not related to Streaming but I don't want create another JS file to put this in
function saveUserInfo() {
    if (!settings.userFullName || !settings.userProfileImage || !settings.userScreenName) {
        Twitter.getVerifyCredentials(
            function(data) { cache.userInfo = Parser.parseUser(data) },
            function(status, statusText) {console.log("[SaveUserInfo] VerifyCredentials returns:", status, statusText)}
        )
    }
}
