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
        tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT UNIQUE, value TEXT)');
    })
}

//"settings" must be a double dimensional array, eg. [["setting1", "value1"], ["setting2", "value2"], ...]
function setSetting(settings) {
    db.transaction(function(tx) {
        for(var i=0; i<settings.length; i++){
            var rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', [settings[i][0],settings[i][1]])
        }
    })
}

//"setting" can be a string or array of settings
function getSetting(setting) {
    var res
    db.readTransaction(function(tx) {
        if(setting instanceof Array){
            res = []
            for(var i=0; i<setting.length; i++){
                var rs = tx.executeSql('SELECT value FROM settings WHERE setting=?;', [setting[i]])
                res.push(rs.rows.length > 0 ? rs.rows.item(0).value : "")
            }
        }
        else{
            var rs2 = tx.executeSql('SELECT value FROM settings WHERE setting=?;', [setting])
            res = rs.rows.length > 0 ? rs.rows.item(0).length : ""
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
                      'tweetId TEXT UNIQUE,' +
                      'tweetText TEXT,' +
                      'userName TEXT);')}
    )
}

function storeTweets(tableName, tweets){
    db.transaction(function(tx){
        tx.executeSql('DELETE FROM ' + tableName)
        for(var i=0; i<tweets.length; i++){
            tx.executeSql('INSERT OR REPLACE INTO '+ tableName +' VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);',
                                   [tweets[i].createdAt.toString(),
                                    tweets[i].displayScreenName,
                                    tweets[i].displayTweetText,
                                    tweets[i].favourited,
                                    tweets[i].inReplyToScreenName,
                                    tweets[i].inReplyToStatusId,
                                    tweets[i].latitude,
                                    tweets[i].longitude,
                                    tweets[i].mediaExpandedUrl,
                                    tweets[i].mediaViewUrl,
                                    tweets[i].mediaThumbnail,
                                    tweets[i].profileImageUrl,
                                    tweets[i].retweetId,
                                    tweets[i].screenName,
                                    tweets[i].source,
                                    tweets[i].tweetId,
                                    tweets[i].tweetText,
                                    tweets[i].userName])
        }
    })
}

function getTweets(tableName){
    var tweets = []
    db.readTransaction(function(tx){
        var rs = tx.executeSql('SELECT * FROM '+ tableName +' ORDER BY tweetId DESC')
        for(var i=0; i<rs.rows.length; i++){
            tweets[i] = new Object(rs.rows.item(i))
        }
    })
    return tweets
}

function initializeDirectMsg(){
    db.transaction(function(tx){
        tx.executeSql('CREATE TABLE IF NOT EXISTS DirectMsg(' +
                      'tweetId TEXT UNIQUE,' +
                      'userName TEXT,' +
                      'screenName TEXT,' +
                      'tweetText TEXT,' +
                      'profileImageUrl TEXT,' +
                      'createdAt TEXT,' +
                      'sentMsg INTEGER)')}
    )
}

function storeDM(dm){
    db.transaction(function(tx){
        tx.executeSql('DELETE FROM DirectMsg')
        for(var i=0;i<dm.length;i++){
            tx.executeSql('INSERT OR REPLACE INTO DirectMsg VALUES(?,?,?,?,?,?,?);',
                                   [dm[i].tweetId,
                                    dm[i].userName,
                                    dm[i].screenName,
                                    dm[i].tweetText,
                                    dm[i].profileImageUrl,
                                    dm[i].createdAt.toString(),
                                    dm[i].sentMsg])
        }
    })
}

function getDM(){
    var dm = []
    db.readTransaction(function(tx){
        var rs = tx.executeSql('SELECT * FROM DirectMsg ORDER BY tweetId DESC')
        for(var i=0; i<rs.rows.length; i++){
            dm[i] = rs.rows.item(i)
        }
    })
    return dm
}

function initializeScreenNames(){
    db.transaction(function(tx){
        tx.executeSql('CREATE TABLE IF NOT EXISTS ScreenNames(screenNames TEXT UNIQUE)')
    })
}

function storeScreenNames(screenNames){
    var totalScreenNames = []
    db.transaction(function(tx){
        for(var i=0;i<screenNames.length;i++){
            var rs = tx.executeSql('INSERT OR REPLACE INTO ScreenNames VALUES(?)', screenNames[i])
        }
        var rs2 = tx.executeSql('SELECT * FROM ScreenNames ORDER BY screenNames ASC')
        for(var i2=0; i2<rs2.rows.length; i2++){
            totalScreenNames[i2] = rs2.rows.item(i2).screenNames
        }
    })
    return totalScreenNames
}

function getScreenNames(){
    var screenNames = []
    db.readTransaction(function(tx){
        var rs = tx.executeSql('SELECT * FROM ScreenNames ORDER BY screenNames ASC')
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
