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

var db = openDatabaseSync("Tweetian", "1.0", "Tweetian Database", 1000000);

function initializeSettings() {
    db.transaction(function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT UNIQUE, value TEXT);');
    })
}

// @param settings - key/value pair object of settings eg. { setting1: value1, setting2: value2 }
function setSetting(settings) {
    db.transaction(function(tx) {
        for(var s in settings){
            tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', [s, settings[s]])
        }
    })
}

function getSetting(setting) {
    var res = ""
    db.readTransaction(function(tx) {
        var rs = tx.executeSql('SELECT value FROM settings WHERE setting=?;', [setting])
        if(rs.rows.length > 0) res = rs.rows.item(0).value
    })
    return res
}

function getAllSettings(){
    var res = {}
    db.readTransaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM settings;')
        for(var i=0; i<rs.rows.length; i++){
            res[rs.rows.item(i).setting] = rs.rows.item(i).value
        }
    })
    return res
}

function initializeTweetsTable(tableName){
    db.transaction(function(tx){
        tx.executeSql('CREATE TABLE IF NOT EXISTS '+ tableName +'(' +
                      'createdAt TEXT,' +
                      'displayScreenName TEXT,' +
                      'displayTweetText TEXT,' +
                      'favourited INTEGER,' +
                      'inReplyToScreenName TEXT,' +
                      'inReplyToStatusId TEXT,' +
                      'latitude REAL,' +
                      'longitude REAL,' +
                      'mediaExpandedUrl TEXT,' +
                      'mediaViewUrl TEXT,' +
                      'mediaThumbnail TEXT,' +
                      'profileImageUrl TEXT,' +
                      'retweetId TEXT,' +
                      'screenName TEXT,' +
                      'source TEXT,' +
                      'tweetId INTEGER UNIQUE,' +
                      'tweetText TEXT,' +
                      'userName TEXT);')}
    )
}

function storeTweets(tableName, model){
    db.transaction(function(tx){
        tx.executeSql('DELETE FROM ' + tableName)
        for(var i=0; i<Math.min(model.count, 100); i++){
            var sqlText = 'INSERT INTO ' + tableName + ' VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);'
            var binding = [model.get(i).createdAt.toString(), model.get(i).displayScreenName,
                           model.get(i).displayTweetText, (model.get(i).favourited ? 1 : 0),
                           model.get(i).inReplyToScreenName, model.get(i).inReplyToStatusId,
                           model.get(i).latitude, model.get(i).longitude,
                           model.get(i).mediaExpandedUrl, model.get(i).mediaViewUrl,
                           model.get(i).mediaThumbnail, model.get(i).profileImageUrl,
                           model.get(i).retweetId, model.get(i).screenName,
                           model.get(i).source, model.get(i).tweetId,
                           model.get(i).tweetText, model.get(i).userName]
            tx.executeSql(sqlText, binding)
        }
    })
}

function getTweets(tableName){
    var tweets = []
    db.readTransaction(function(tx){
        var rs = tx.executeSql('SELECT * FROM '+ tableName +' ORDER BY tweetId DESC;')
        for(var i=0; i<rs.rows.length; i++){
            tweets.push(rs.rows.item(i))
        }
    })
    return tweets
}

function initializeDirectMsg(){
    db.transaction(function(tx){
        tx.executeSql('CREATE TABLE IF NOT EXISTS DirectMsg(' +
                      'tweetId INTEGER UNIQUE,' +
                      'userName TEXT,' +
                      'screenName TEXT,' +
                      'tweetText TEXT,' +
                      'profileImageUrl TEXT,' +
                      'createdAt TEXT,' +
                      'sentMsg INTEGER);')}
    )
}

function storeDM(model){
    db.transaction(function(tx){
        tx.executeSql('DELETE FROM DirectMsg')
        for(var i=0; i<Math.min(model.count, 100); i++){
            var sqlText = 'INSERT INTO DirectMsg VALUES (?,?,?,?,?,?,?);'
            var binding = [model.get(i).tweetId, model.get(i).userName,
                           model.get(i).screenName, model.get(i).tweetText,
                           model.get(i).profileImageUrl, model.get(i).createdAt.toString(),
                           (model.get(i).sentMsg ? 1 : 0)]
            tx.executeSql(sqlText, binding)
        }
    })
}

function getDM(){
    var dm = []
    db.readTransaction(function(tx){
        var rs = tx.executeSql('SELECT * FROM DirectMsg ORDER BY tweetId DESC;')
        for(var i=0; i<rs.rows.length; i++){
            dm.push(rs.rows.item(i))
        }
    })
    return dm
}

function initializeScreenNames(){
    db.transaction(function(tx){
        tx.executeSql('CREATE TABLE IF NOT EXISTS ScreenNames(screenNames TEXT UNIQUE);')
    })
}

function storeScreenNames(screenNames){
    var totalScreenNames = []
    db.transaction(function(tx){
        for(var i=0;i<screenNames.length;i++){
            var rs = tx.executeSql('INSERT OR REPLACE INTO ScreenNames VALUES(?)', screenNames[i])
        }
        var rs2 = tx.executeSql('SELECT * FROM ScreenNames ORDER BY screenNames ASC;')
        for(var i2=0; i2<rs2.rows.length; i2++){
            totalScreenNames[i2] = rs2.rows.item(i2).screenNames
        }
    })
    return totalScreenNames
}

function getScreenNames(){
    var screenNames = []
    db.readTransaction(function(tx){
        var rs = tx.executeSql('SELECT * FROM ScreenNames ORDER BY screenNames ASC;')
        for(var i=0; i<rs.rows.length; i++){
            screenNames[i] = rs.rows.item(i).screenNames
        }
    })
    return screenNames
}

function clearTable(tableName){
    db.transaction(function(tx){
        tx.executeSql('DELETE FROM ' + tableName)
    })
}

function dropTable(tableName){
    db.transaction(function(tx){
        tx.executeSql('DROP TABLE ' + tableName)
    })
}
