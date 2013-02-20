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

Qt.include("Calculations.js")

function linkText(text, href, italic) {
    var html = "";
    if (italic) html = "<i><a style=\"color: LightSeaGreen; text-decoration: none\" href=\"%1\">%2</a></i>";
    else html = "<a style=\"color: LightSeaGreen; text-decoration: none\" href=\"%1\">%2</a>";

    return html.arg(href).arg(text);
}

function parseTweet(tweetJson) {
    var tweet = {
        id: tweetJson.id_str,
        source: tweetJson.source.replace(/<[^>]+>/ig, ""),
        createdAt: new Date(tweetJson.created_at),
        isFavourited: tweetJson.favorited,
        isRetweet: false,
        retweetScreenName: tweetJson.user.screen_name,
        timeDiff: timeDiff(tweetJson.created_at)
    }

    var originalTweetJson = {};
    if (tweetJson.retweeted_status) {
        originalTweetJson = tweetJson.retweeted_status;
        tweet.isRetweet = true;
    }
    else originalTweetJson = tweetJson;

    tweet.plainText = __unescapeHtml(originalTweetJson.text);
    tweet.richText = __toRichText(originalTweetJson.text, originalTweetJson.entities);
    tweet.name = originalTweetJson.user.name;
    tweet.screenName = originalTweetJson.user.screen_name;
    tweet.profileImageUrl = originalTweetJson.user.profile_image_url;
    tweet.inReplyToScreenName = originalTweetJson.in_reply_to_screen_name;
    tweet.inReplyToStatusId = originalTweetJson.in_reply_to_status_id_str;
    tweet.latitude = "";
    tweet.longitude = "";
    tweet.mediaUrl = "";

    if (originalTweetJson.geo) {
        tweet.latitude = originalTweetJson.geo.coordinates[0];
        tweet.longitude = originalTweetJson.geo.coordinates[1];
    }

    if (Array.isArray(originalTweetJson.entities.media) && originalTweetJson.entities.media.length > 0) {
        tweet.mediaUrl = originalTweetJson.entities.media[0].media_url;
    }

    return tweet;
}

function parseDM(dmJson, isReceiveDM) {
    var dm = {
        id: dmJson.id_str,
        richText: __toRichText(dmJson.text, dmJson.entities),
        name: (isReceiveDM ? dmJson.sender.name : dmJson.recipient.name),
        screenName: (isReceiveDM ? dmJson.sender_screen_name : dmJson.recipient_screen_name),
        profileImageUrl: (isReceiveDM ? dmJson.sender.profile_image_url : dmJson.recipient.profile_image_url),
        createdAt: dmJson.created_at,
        isReceiveDM: isReceiveDM
    }
    return dm;
}

function parseUser(userJson) {
    var user = {
        name: userJson.name,
        screenName: userJson.screen_name,
        description: userJson.description || "",
        location: userJson.location || "",
        url: userJson.url || "",
        profileImageUrl: userJson.profile_image_url,
        profileBannerUrl: userJson.profile_banner_url || "",
        createdAt: new Date(userJson.created_at),
        tweetsCount: userJson.statuses_count,
        followersCount: userJson.followers_count,
        followingCount: userJson.friends_count,
        favouritesCount: userJson.favourites_count,
        listedCount: userJson.listed_count,
        isFollowing: userJson.following || false,
        isProtected: userJson.protected
    }

    var userUrlExpanded = null;
    try {
        userUrlExpanded = userJson.entities.url.urls[0].expanded_url;
    } catch (e) {}

    if (userUrlExpanded !== null)
        user.url = userUrlExpanded;

    return user;
}

var __HTML_ENTITIES = {
    "&amp;": "&",
    "&lt;": "<",
    "&gt;": ">"
}

function __unescapeHtml(text) {
    return text && text.replace(/(&amp;|&lt;|&gt;)/ig, function(html) {
        return __HTML_ENTITIES[html]
    })
}

function __toRichText(text, entities) {
    if (!entities) return;

    var richText = text;
    richText = __linkHashtags(richText, entities.hashtags);

    entities.urls.forEach(function(urlObject) {
        richText = richText.replace(urlObject.url, linkText(urlObject.display_url, urlObject.expanded_url, true));
    })

    if (entities.hasOwnProperty("media")) {
        entities.media.forEach(function(mediaObject) {
            richText = richText.replace(mediaObject.url,
                                        linkText(mediaObject.display_url, mediaObject.expanded_url, true));
        })
    }

    richText = __linkUserMentions(richText, entities.user_mentions);
    richText = __linkCashtag(richText);
    return richText;
}

function __linkUserMentions(text, userMentionsEntities) {
    if (!Array.isArray(userMentionsEntities) || userMentionsEntities.length === 0)
        return text;

    var mentionsArray = [];

    userMentionsEntities.forEach(function(mentionObject) {
        mentionsArray.push(mentionObject.screen_name);
    })

    var mentionsRegExp = new RegExp("@\\b(" + mentionsArray.join("|") + ")\\b", "ig");
    var linkedText = text.replace(mentionsRegExp, function(t) { return linkText(t, t, false) })
    return linkedText;
}

function __linkHashtags(text, hashtagsEntities) {
    if (!Array.isArray(hashtagsEntities) || hashtagsEntities.length === 0)
        return text;

    // TODO: better algorithm?
    var hashtagsArray = hashtagsEntities;
    hashtagsArray.sort(function(a, b) { return a.indices[0] - b.indices[0] });

    var linkedText = text;
    var offset = 0;
    hashtagsArray.forEach(function(hashtag) {
        var linkedHashtag = linkText("#" + hashtag.text, "#" + hashtag.text, false);
        linkedText = linkedText.substring(0, hashtag.indices[0] + offset) +
            linkedHashtag + linkedText.substring(hashtag.indices[1] + offset);
        offset = (offset - (hashtag.indices[1] - hashtag.indices[0])) + linkedHashtag.length;
    })

    return linkedText;
}

// Following RegExp took and modified from:
// https://github.com/twitter/twitter-text-js/blob/b93ae29/twitter-text.js#L279
var CASHTAG_REGEXP = /(?:^|\s)(\$[a-z]{1,6}(?:[._][a-z]{1,2})?)(?=$|[\s\!'#%&"\(\)*\+,\\\-\.\/:;<=>\?@\[\]\^_{|}~\$])/gi;

function __linkCashtag(text) {
    return text.replace(CASHTAG_REGEXP, function(matched) {
        var text = matched;
        var firstChar = text.charAt(0);
        if (/\s/.test(firstChar)) {
            text = text.substring(1);
            return firstChar + linkText(text, text, false);
        }
        return linkText(text, text, false);
    })
}
