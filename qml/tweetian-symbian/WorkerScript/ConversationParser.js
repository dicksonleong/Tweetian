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

    if (msg.timelineModel && msg.mentionsModel) {
        var skipCurrentLoop = false
        var replyId = msg.inReplyToStatusId
        while (replyId && msg.ancestorModel.count < 10) {
            skipCurrentLoop = false
            for (var iTimeline=0; iTimeline < msg.timelineModel.count; iTimeline++) {
                if (msg.timelineModel.get(iTimeline).id == replyId) {
                    var timelineTweet = msg.timelineModel.get(iTimeline);
                    var toBeInsertTimelineTweet = {
                        id: timelineTweet.id,
                        plainText: timelineTweet.plainText,
                        richText: timelineTweet.richText,
                        name: timelineTweet.name,
                        screenName: timelineTweet.screenName,
                        profileImageUrl: timelineTweet.profileImageUrl,
                        inReplyToScreenName: timelineTweet.inReplyToScreenName,
                        inReplyToStatusId: timelineTweet.inReplyToStatusId,
                        latitude: timelineTweet.latitude,
                        longitude: timelineTweet.longitude,
                        mediaUrl: timelineTweet.mediaUrl,
                        source: timelineTweet.source,
                        createdAt: timelineTweet.createdAt,
                        isFavourited: timelineTweet.isFavourited,
                        isRetweet: timelineTweet.isRetweet,
                        retweetScreenName: timelineTweet.retweetScreenName,
                        timeDiff: timeDiff(timelineTweet.createdAt)
                    }
                    msg.ancestorModel.insert(0, toBeInsertTimelineTweet)
                    replyId = msg.timelineModel.get(iTimeline).inReplyToStatusId
                    skipCurrentLoop = true
                    break
                }
            }
            if (skipCurrentLoop) continue
            for (var iMentions=0; iMentions < msg.mentionsModel.count; iMentions++) {
                if (msg.mentionsModel.get(iMentions).id == replyId) {
                    var mentionsTweet = msg.mentionsModel.get(iMentions);
                    var toBeInsertMentionsTweet = {
                        id: mentionsTweet.id,
                        plainText: mentionsTweet.plainText,
                        richText: mentionsTweet.richText,
                        name: mentionsTweet.name,
                        screenName: mentionsTweet.screenName,
                        profileImageUrl: mentionsTweet.profileImageUrl,
                        inReplyToScreenName: mentionsTweet.inReplyToScreenName,
                        inReplyToStatusId: mentionsTweet.inReplyToStatusId,
                        latitude: mentionsTweet.latitude,
                        longitude: mentionsTweet.longitude,
                        mediaUrl: mentionsTweet.mediaUrl,
                        source: mentionsTweet.source,
                        createdAt: mentionsTweet.createdAt,
                        isFavourited: mentionsTweet.isFavourited,
                        isRetweet: mentionsTweet.isRetweet,
                        retweetScreenName: mentionsTweet.retweetScreenName,
                        timeDiff: timeDiff(mentionsTweet.createdAt)
                    }
                    msg.ancestorModel.insert(0, toBeInsertMentionsTweet)
                    replyId = msg.mentionsModel.get(iMentions).inReplyToStatusId
                    skipCurrentLoop = true
                    break
                }
            }
            if (skipCurrentLoop) continue
            replyId = undefined
        }
    }

    else {
        for (var i=0; i<(msg.data[0] ? msg.data[0].results.length : 0); i++) {
            var model
            var skipCurrentTweet = false
            var insertIndex = -1
            if (msg.data[0].results[i].annotations.ConversationRole === "Ancestor") {
                // check whether the tweet is already exist in the model
                for (var iAncestor=0; iAncestor < msg.ancestorModel.count; iAncestor++) {
                    if (msg.ancestorModel.get(iAncestor).id == msg.data[0].results[i].value.id_str) {
                        skipCurrentTweet = true
                        break
                    }
                    else if (new Date(msg.ancestorModel.get(iAncestor).createdAt) > new Date(msg.data[0].results[i].value.created_at)) {
                        insertIndex = iAncestor
                        break
                    }
                }
                if (skipCurrentTweet) continue;
                model = msg.ancestorModel
            }
            else model = msg.descendantModel

            var tweet = parseTweet(msg.data[0].results[i].value);

            if (insertIndex >= 0) model.insert(insertIndex, tweet)
            else model.append(tweet)
        }
    }

    msg.ancestorModel.sync()
    msg.descendantModel.sync()
    WorkerScript.sendMessage({action: msg.timelineModel && msg.mentionsModel ? "callAPI" : "end"})
}
