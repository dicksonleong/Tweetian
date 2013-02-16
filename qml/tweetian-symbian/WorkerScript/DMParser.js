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
    var newDMCount = 0;

    switch (msg.type) {
    case "all":
        msg.model.clear();
        msg.model.sync();
        msg.threadModel.clear();
        msg.threadModel.sync();
        insertDMFromJSON(msg.receivedDM, msg.sentDM, msg.model, msg.threadModel, false);
        break;
    case "newer":
        newDMCount = insertDMFromJSON(msg.receivedDM, msg.sentDM, msg.model, msg.threadModel, true);
        break;
    case "database":
        insertDMFromDB(msg.data, msg.model, msg.threadModel);
        break;
    case "time":
        for (var i=0; i<msg.threadModel.count; i++) {
            msg.threadModel.setProperty(i, "timeDiff", timeDiff(msg.threadModel.get(i).createdAt))
        }
        break;
    case "delete":
        for (var iDelete=0; iDelete<msg.model.count; iDelete++) {
            if (msg.model.get(iDelete).id == msg.id) {
                msg.model.remove(iDelete);
                break;
            }
        }
        break;
    case "setReaded":
        var index = msg.index;
        if (msg.hasOwnProperty("screenName"))
            index = getIndex(msg.screenName, msg.threadModel);
        msg.threadModel.setProperty(index, "isUnread", false);
        break;
    default:
        throw new Error("Invalid type: " + msg.type)
    }

    if (msg.model) msg.model.sync()
    if (msg.threadModel) msg.threadModel.sync()

    var showNotification = msg.type === "newer" && msg.receivedDM.length > 0
    var returnMsg = { type: msg.type, newDMCount: newDMCount, showNotification: showNotification }
    WorkerScript.sendMessage(returnMsg)
}

function insertDMFromJSON(receivedDM, sentDM, dmModel, dmThreadModel, showUnread) {
    var dmArray = [];

    // Parse recieved DM
    receivedDM.forEach(function(dmObj) { dmArray.push(parseDM(dmObj, true)); })

    // Parse sent DM
    sentDM.forEach(function(dmObj) { dmArray.push(parseDM(dmObj, false)); })

    // Sort using createdAt
    dmArray.sort(function(first, second) {
        var firstDate = new Date(first.createdAt);
        var secondDate = new Date(second.createdAt);
        return (firstDate > secondDate ? -1 : 1);
    })

    // Create DM thread
    var addedScreenNameArray = [];
    var dmThreadArray = dmArray.filter(function(dm) {
        if (addedScreenNameArray.indexOf(dm.screenName) >= 0)
            return false;

        addedScreenNameArray.push(dm.screenName);
        return true;
    })

    // Fill the full model
    dmArray.forEach(function(dm, index) { dmModel.insert(index, dm); })

    // Fill the thread model
    dmThreadArray.forEach(function(dmThread, index) {
        for (var i=0; i<dmThreadModel.count; i++) {
            if (dmThread.screenName === dmThreadModel.get(i).screenName) {
                dmThreadModel.remove(i);
                break;
            }
        }
        dmThread.isUnread = (showUnread && dmThread.isReceiveDM ? true : false);
        dmThread.timeDiff = timeDiff(dmThread.createdAt);
        dmThreadModel.insert(index, dmThread)
    })

    return dmArray.length;
}

function insertDMFromDB(dbDMArray, dmModel, dmThreadModel) {
    var dmArray = [];

    dbDMArray.forEach(function(dbDM) {
        var dm = dbDM;
        dm.createdAt = new Date(dbDM.createdAt);
        dm.isReceiveDM = (dbDM.isReceiveDM == 1 ? true : false);
        dmArray.push(dm);
    })

    var addedScreenNameArray = []
    var dmThreadArray = dmArray.filter(function(dm) {
        if (addedScreenNameArray.indexOf(dm.screenName) >= 0)
            return false;

        addedScreenNameArray.push(dm.screenName);
        return true;
    })

    dmArray.forEach(function(dm) { dmModel.append(dm); })

    dmThreadArray.forEach(function(dmThread, index) {
        dmThread.timeDiff = timeDiff(dmThread.createdAt);
        dmThread.isUnread = false;
        dmThreadModel.append(dmThread);
    })
}

function getIndex(screenName, model) {
    for (var i = 0; i < model.count; ++i) {
        if (model.get(i).screenName === screenName)
            return i;
    }
    console.log("DMParser.js: index for screenName", screenName, "not found!");
    return -1;
}
