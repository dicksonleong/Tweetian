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
Qt.include("../Utils/Calculations.js")

WorkerScript.onMessage = function(msg){
    var count = 0

    // for determining notification should be created or not
    var createNotification = msg.type === "insert" && msg.recieveMsg.length > 0 ? true : false

    switch(msg.type){
    case "clearAndInsert":
        msg.model.clear()
        msg.model.sync()
        msg.threadModel.clear()
        msg.threadModel.sync()
        //fallthrough
    case "insert":
        // Parse recieved DM
        for(var i=0; i<msg.recieveMsg.length; i++){
            var recieveDMObject = {
                tweetId: msg.recieveMsg[i].id_str,
                userName: msg.recieveMsg[i].sender.name,
                screenName: msg.recieveMsg[i].sender_screen_name,
                tweetText: unescapeHtml(msg.recieveMsg[i].text),
                profileImageUrl: msg.recieveMsg[i].sender.profile_image_url,
                createdAt: msg.recieveMsg[i].created_at,
                sentMsg: false
            }
            if(msg.recieveMsg[i].entities && msg.recieveMsg[i].entities.urls){
                for(var iU=0; iU<msg.recieveMsg[i].entities.urls.length; iU++){
                    recieveDMObject.tweetText = recieveDMObject.tweetText.parseURL(msg.recieveMsg[i].entities.urls[iU].url,
                                                                                   msg.recieveMsg[i].entities.urls[iU].display_url,
                                                                                   msg.recieveMsg[i].entities.urls[iU].expanded_url)
                }
            }
            msg.model.insert(i, recieveDMObject)
            count++
        }
        msg.model.sync()

        // Parse sent DM
        for(var i2=0; i2<msg.sentMsg.length; i2++){
            for(var index=0; index<msg.model.count; index++){
                if(msg.sentMsg[i2].id_str > msg.model.get(index).tweetId){
                    var sentDMObject = {
                        tweetId: msg.sentMsg[i2].id_str,
                        userName: msg.sentMsg[i2].recipient.name,
                        screenName: msg.sentMsg[i2].recipient_screen_name,
                        tweetText: unescapeHtml(msg.sentMsg[i2].text),
                        profileImageUrl: msg.sentMsg[i2].recipient.profile_image_url,
                        createdAt: msg.sentMsg[i2].created_at,
                        sentMsg: true
                    }
                    if(msg.sentMsg[i2].entities && msg.sentMsg[i2].entities.urls){
                        for(var iU2=0; iU2<msg.sentMsg[i2].entities.urls.length; iU2++){
                            sentDMObject.tweetText = sentDMObject.tweetText.parseURL(msg.sentMsg[i2].entities.urls[iU2].url,
                                                                                     msg.sentMsg[i2].entities.urls[iU2].display_url,
                                                                                     msg.sentMsg[i2].entities.urls[iU2].expanded_url)
                        }
                    }
                    msg.model.insert(index, sentDMObject)
                    count++
                    break
                }
            }
        }
        // Add to thread model when there is new data parsed (count > 0)
        if(count > 0){
            var addedThread = 0
            for(var i3=0; i3 < count; i3++){
                var added = false
                // Loop through each to see the thread is added or not
                for(var iThread=0; iThread < msg.threadModel.count; iThread++){
                    if(msg.threadModel.get(iThread).screenName === msg.model.get(i3).screenName){
                        if(msg.threadModel.get(iThread).tweetId < msg.model.get(i3).tweetId){
                            var setThreadObj = {
                                tweetId: msg.model.get(i3).tweetId,
                                tweetText: msg.model.get(i3).tweetText,
                                createdAt: msg.model.get(i3).createdAt,
                                timeDiff: timeDiff(msg.model.get(i3).createdAt),
                                newMsg: createNotification
                            }
                            msg.threadModel.set(iThread, setThreadObj)
                        }
                        added = true
                        break
                    }
                }
                if(!added){
                    var threadObj = {
                        tweetId: msg.model.get(i3).tweetId,
                        userName: msg.model.get(i3).userName,
                        screenName: msg.model.get(i3).screenName,
                        tweetText: msg.model.get(i3).tweetText,
                        profileImageUrl: msg.model.get(i3).profileImageUrl,
                        createdAt: msg.model.get(i3).createdAt,
                        timeDiff: timeDiff(msg.model.get(i3).createdAt),
                        newMsg: createNotification
                    }
                    if(msg.type === "clearAndInsert") msg.threadModel.append(threadObj)
                    else msg.threadModel.insert(addedThread, threadObj)
                    addedThread++
                }
            }
        }
        break
    case "time":
        for(var iTime=0; iTime<msg.threadModel.count; iTime++){
            msg.threadModel.setProperty(iTime, "timeDiff", timeDiff(msg.threadModel.get(iTime).createdAt))
        }
        break
    case "database":
        for(var iDB=0; iDB<msg.data.length; iDB++){
            var databaseObj = {
                tweetId: msg.data[iDB].tweetId,
                userName: msg.data[iDB].userName || "",
                screenName: msg.data[iDB].screenName,
                tweetText: msg.data[iDB].tweetText,
                profileImageUrl: msg.data[iDB].profileImageUrl,
                createdAt: new Date(msg.data[iDB].createdAt),
            }
            var added2 = false
            for(var iThread2=0; iThread2 < msg.threadModel.count; iThread2++){
                if(msg.threadModel.get(iThread2).screenName === databaseObj.screenName){
                    added2 = true
                    break
                }
            }
            if(!added2){
                databaseObj.timeDiff = timeDiff(databaseObj.createdAt)
                databaseObj.newMsg = false
                msg.threadModel.append(databaseObj)
            }
            databaseObj.sentMsg = msg.data[iDB].sentMsg == 1 ? true : false
            msg.model.append(databaseObj)
        }
        break
    case "delete":
        for(var iDelete=0; iDelete<msg.model.count; iDelete++){
            if(msg.model.get(iDelete).tweetId == msg.id){
                msg.model.remove(iDelete)
                break
            }
        }
        break
    case "setProperty":
        msg.threadModel.setProperty(msg.index, msg.property, msg.value)
        break
    default:
        throw new Error("Invalid method: " + msg.type)
    }
    if(msg.model) msg.model.sync()
    if(msg.threadModel) msg.threadModel.sync()

    WorkerScript.sendMessage({type: msg.type, count: count, createNotification: createNotification})
}
