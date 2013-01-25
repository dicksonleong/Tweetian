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

Qt.include("../Utils/Parser.js")

WorkerScript.onMessage = function(msg) {
    var newTweetCount = 0

    switch (msg.type) {
    case "all":
        msg.model.clear()
        msg.model.sync()
        // fallthrough
    case "older":
        if (msg.data.statuses.length === 0)
            break;

        appendTweetsFromJson(msg.data.statuses, msg.model);
        break;
    case "newer":
        if (msg.data.statuses.length === 0)
            break;

        newTweetCount = prependTweetsFromJson(msg.data.statuses, msg.model);
        break
    default:
        throw new Error("Invalid type: " + msg.type)
    }
    msg.model.sync()
    WorkerScript.sendMessage({newTweetCount: newTweetCount})
}

function appendTweetsFromJson(tweetsJson, model) {
    var tweetsArray = [];

    tweetsJson.forEach(function(tweetJson) {
        tweetsArray.push(parseTweet(tweetJson));
    })

    tweetsArray.forEach(function(tweet) { model.append(tweet); })
}

function prependTweetsFromJson(tweetsJson, model) {
    var tweetsArray = [];

    tweetsJson.forEach(function(tweetJson) {
        tweetsArray.push(parseTweet(tweetJson));
    })

    var newTweetCount = tweetsArray.length;

    var lastTweet = tweetsArray.pop();
    model.insert(0, lastTweet);
    model.sync();

    tweetsArray.reverse();

    tweetsArray.forEach(function(tweet) {
        model.insert(0, tweet);
    })

    return newTweetCount;
}
