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

/*
  Every tweet object contain 16 properties:

  - id (String) : id of the tweet/retweet
  - plainText* (String) : text of the tweet, without any formatting
  - richText* (String) : text of the tweet, with urls, hashtags, @mentions formatted with html
  - name* (String) : full name of the user who create this tweet
  - screenName* (String) : screen name of the user who create this tweet
  - profileImageUrl* (String) : profile image url of the user who create this tweet
  - inReplyToScreenName* (String) : screen name of the user of this tweet reply to
  - inReplyToStatusId* (String) : id of the tweet of this tweet reply to
  - latitude* (real) : latitude of the geo-tagged tweet
  - longitude* (real) : longitude of the geo-tagged tweet
  - mediaUrl* (String) : url of the Twitter pic, if there is pic uploaded with this tweet
  - source (String) : source of the tweet (html removed)
  - createdAt (String) : the date of this tweet created
  - isFavourited (bool) : indicate this tweet is favourited by the user
  - isRetweet (bool) : indicate this tweeet is a retweet
  - retweetScreenName (String) : screen name of the user who made the retweet

  Derived property:
  - timeDiff (String): user-visible string describing the time different of when this is created

  Note: Properties marked with '*' means those value is belong to the retweeted_status if this is a retweet
*/

Qt.include("../Utils/Parser.js")

WorkerScript.onMessage = function(msg) {
    var newTweetCount = 0
    var hashtags = []
    var screenNames = []

    switch (msg.type) {
    case "all":
        msg.model.clear()
        msg.model.sync()
        // fallthrough
    case "older":
        if (msg.data.length === 0)
            break;

        msg.data.forEach(function(tweetJson) {
            collectScreenNamesAndHashtags(tweetJson, screenNames, hashtags);
        });

        appendTweetsFromJson(msg.data, msg.model, msg.muteString);
        break
    case "newer":
        if (msg.data.length === 0)
            break;

        msg.data.forEach(function(tweetJson) {
            collectScreenNamesAndHashtags(tweetJson, screenNames, hashtags);
        });

        newTweetCount = prependTweetsFromJson(msg.data, msg.model, msg.muteString);
        break;
    case "database":
        msg.data.forEach(function(tweetDB) {
                var matchedHashtags = tweetDB.richText.match(/#\w+/g) || [];
                matchedHashtags.forEach(function(hashtag) {
                hashtags.push(hashtag.substring(1));
            })
        })

        appendTweetsFromDB(msg.data, msg.model);
        break;
    case "remove":
        for (var iRemove=0; iRemove<msg.model.count; iRemove++) {
            if (msg.model.get(iRemove).id === msg.id) {
                msg.model.remove(iRemove);
                break;
            }
        }
        break;
    case "favourite":
        for (var iFav=0; iFav<msg.model.count; iFav++) {
            if (msg.model.get(iFav).id === msg.id) {
                msg.model.setProperty(iFav, "isFavourited", !msg.model.get(iFav).isFavourited);
                break;
            }
        }
        break
    case "time":
        for (var iTime=0; iTime<msg.model.count; iTime++) {
            msg.model.setProperty(iTime, "timeDiff", timeDiff(msg.model.get(iTime).createdAt))
        }
        break
    default:
        throw new Error("Invalid method: "+ msg.type)
    }

    msg.model.sync()
    var returnObj = {type: msg.type, newTweetCount: newTweetCount, screenNames: screenNames, hashtags: hashtags}
    WorkerScript.sendMessage(returnObj);
}

function collectScreenNamesAndHashtags(tweetJson, screenNames, hashtags) {
    if (tweetJson.user.following && screenNames.indexOf(tweetJson.user.screen_name) == -1)
        screenNames.push(tweetJson.user.screen_name);

    if (tweetJson.hasOwnProperty("entities")) {
        tweetJson.entities.hashtags.forEach(function(hashtagObj) {
            if (hashtags.indexOf(hashtagObj.text) == -1)
                hashtags.push(hashtagObj.text);
        })
    }
}

function appendTweetsFromJson(tweetsJson, model, muteString) {
    var tweetsArray = [];

    tweetsJson.forEach(function(tweetJson) {
        tweetsArray.push(parseTweet(tweetJson));
    })

    if (muteString) {
        tweetsArray = tweetsArray.filter(function(tweet) {
            return filterMute(tweet, muteString);
        })
    }

    tweetsArray.forEach(function(tweet) { model.append(tweet); })
}

function prependTweetsFromJson(tweetsJson, model, muteString) {
    var tweetsArray = [];

    tweetsJson.forEach(function(tweetJson) {
        tweetsArray.push(parseTweet(tweetJson));
    })

    if (muteString) {
        tweetsArray = tweetsArray.filter(function(tweet) {
            return filterMute(tweet, muteString);
        })
    }

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

function appendTweetsFromDB(tweetsDB, model) {
    var tweetsArray = [];

    tweetsDB.forEach(function(tweetDB) {
        var tweet = tweetDB;
        tweet.createdAt = new Date(tweet.createdAt);
        tweet.isFavourited = (tweet.isFavourited == 1 ? true : false);
        tweet.isRetweet = (tweet.isRetweet == 1 ? true : false);
        tweet.timeDiff = timeDiff(tweet.createdAt);
        tweetsArray.push(tweet);
    })

    tweetsArray.forEach(function(tweet) {
        model.append(tweet);
    })
}

function filterMute(tweet, muteString) {

    function checkMute(muteKeyword) {
        if (muteKeyword.indexOf("@") === 0) { // @user
            if (tweet.screenName.toLowerCase() === muteKeyword.substring(1).toLowerCase())
                return true;

            var mentionsRegexp = new RegExp("@\\b" + muteKeyword.substring(1) + "\\b", "i");
            if (mentionsRegexp.test(tweet.richText))
                return true;
        }
        else if (muteKeyword.indexOf("#") === 0) {
            var hashRegExp = new RegExp("#\\b" + muteKeyword.substring(1) + "\\b", "i");
            if (hashRegExp.test(tweet.richText))
                return true;
        }
        else if (muteKeyword.indexOf("source:") === 0) { // source:Tweet_Button
            if (tweet.source.toLowerCase() === muteKeyword.substring(7).toLowerCase().replace(/_/g, " "))
                return true;
        }
        else { // plain word
            var wordRegexp = new RegExp("\\b" + muteKeyword + "\\b", "i");
            if (wordRegexp.test(tweet.richText))
                return true;
        }
        return false;
    }

    var muteArrayOR = muteString.split("\n");
    var isMuted = muteArrayOR.some(function(muteLine) {
        var muteArrayAND = muteLine.split(" ");
        return muteArrayAND.every(checkMute);
    })
    return !isMuted;
}
