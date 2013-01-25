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

var QUERY = {
    CREATE_SETTINGS_TABLE: 'CREATE TABLE Settings(setting TEXT UNIQUE, value TEXT);',
    CREATE_TIMELINE_TABLE: 'CREATE TABLE Timeline(id INTEGER UNIQUE, plainText TEXT, richText TEXT, ' +
                           'name TEXT, screenName TEXT, profileImageUrl TEXT, inReplyToScreenName TEXT, ' +
                           'inReplyToStatusId TEXT, latitude REAL, longitude REAL, mediaUrl TEXT, source TEXT, ' +
                           'createdAt TEXT, isFavourited INTEGER, isRetweet INTEGER, retweetScreenName TEXT);',
    CREATE_MENTIONS_TABLE: 'CREATE TABLE Mentions(id INTEGER UNIQUE, plainText TEXT, richText TEXT, ' +
                           'name TEXT, screenName TEXT, profileImageUrl TEXT, inReplyToScreenName TEXT, ' +
                           'inReplyToStatusId TEXT, latitude REAL, longitude REAL, mediaUrl TEXT, source TEXT, ' +
                           'createdAt TEXT, isFavourited INTEGER, isRetweet INTEGER, retweetScreenName TEXT);',
    CREATE_DM_TABLE: 'CREATE TABLE DM(id INTEGER UNIQUE, richText TEXT, name TEXT, ' +
                     'screenName TEXT, profileImageUrl TEXT, createdAt TEXT, isReceiveDM INTEGER)',
    CREATE_SCREEN_NAMES_TABLE: 'CREATE TABLE ScreenNames(screenNames TEXT UNIQUE);'
}

var db = openDatabaseSync("Tweetian", "", "Tweetian Database", 1000000, function(db) {
    db.changeVersion(db.version, "1.1", function(tx) {
        tx.executeSql(QUERY.CREATE_SETTINGS_TABLE);
        tx.executeSql(QUERY.CREATE_TIMELINE_TABLE);
        tx.executeSql(QUERY.CREATE_MENTIONS_TABLE);
        tx.executeSql(QUERY.CREATE_DM_TABLE);
        tx.executeSql(QUERY.CREATE_SCREEN_NAMES_TABLE);
    })
});

if (db.version === "1.0") {
    db.changeVersion(db.version, "1.1", function(tx) {
        tx.executeSql('DROP TABLE Timeline');
        tx.executeSql('DROP TABLE Mentions');
        tx.executeSql('DROP TABLE DirectMsg');
        tx.executeSql(QUERY.CREATE_TIMELINE_TABLE);
        tx.executeSql(QUERY.CREATE_MENTIONS_TABLE);
        tx.executeSql(QUERY.CREATE_DM_TABLE);
    });
}

function setSetting(settings) {
    db.transaction(function(tx) {
        for (var s in settings) {
            tx.executeSql('INSERT OR REPLACE INTO Settings VALUES(?,?);', [s, settings[s]])
        }
    })
}

function getSetting(setting) {
    var res = ""
    db.readTransaction(function(tx) {
        var rs = tx.executeSql('SELECT value FROM Settings WHERE setting=?;', [setting])
        if (rs.rows.length > 0) res = rs.rows.item(0).value
    })
    return res
}

function getAllSettings() {
    var res = {}
    db.readTransaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM Settings;')
        for (var i=0; i<rs.rows.length; i++) {
            res[rs.rows.item(i).setting] = rs.rows.item(i).value
        }
    })
    return res
}

function storeTimeline(model) {
    __storeTweetsShared("Timeline", model);
}

function getTimeline() {
    return __getTweetsShared("Timeline");
}

function storeMentions(model) {
    __storeTweetsShared("Mentions", model);
}

function getMentions() {
    return __getTweetsShared("Mentions");
}

function storeDMs(model) {
    db.transaction(function(tx) {
        tx.executeSql('DELETE FROM DM;')
        for (var i = 0; i < Math.min(model.count, 100); i++) {
            var sqlText = 'INSERT INTO DM VALUES(?,?,?,?,?,?,?);'
            var dm = model.get(i);
            var binding = [dm.id, dm.richText, dm.name, dm.screenName, dm.profileImageUrl,
                           dm.createdAt.toString(), (dm.isReceiveDM ? 1 : 0)];
            tx.executeSql(sqlText, binding)
        }
    })
}

function getDMs() {
    var dms = []
    db.readTransaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM DM ORDER BY id DESC;')
        for (var i=0; i<rs.rows.length; i++) {
            dms.push(rs.rows.item(i));
        }
    })
    return dms
}

function storeScreenNames(screenNames) {
    var allScreenNames = []
    db.transaction(function(tx) {
        for (var i = 0; i < screenNames.length; i++) {
            tx.executeSql('INSERT OR REPLACE INTO ScreenNames VALUES(?);', screenNames[i])
        }
        var rs = tx.executeSql('SELECT * FROM ScreenNames ORDER BY screenNames ASC;')
        for (var i2=0; i2<rs.rows.length; i2++) {
            allScreenNames.push(rs.rows.item(i2).screenNames);
        }
    })
    return allScreenNames;
}

function getScreenNames() {
    var screenNames = []
    db.readTransaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM ScreenNames ORDER BY screenNames ASC;')
        for (var i=0; i<rs.rows.length; i++) {
            screenNames.push(rs.rows.item(i).screenNames);
        }
    })
    return screenNames
}

function clearTable(tableName) {
    db.transaction(function(tx) {
        tx.executeSql('DELETE FROM ' + tableName)
    })
}

function dropTable(tableName) {
    db.transaction(function(tx) {
        tx.executeSql('DROP TABLE ' + tableName)
    })
}

function __storeTweetsShared(tableName, model) {
    db.transaction(function(tx) {
        tx.executeSql('DELETE FROM ' + tableName)
        for (var i=0; i<Math.min(model.count, 100); i++) {
            var sqlText = 'INSERT INTO ' + tableName + ' VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);'
            var tweet = model.get(i);
            var binding = [tweet.id, tweet.plainText, tweet.richText, tweet.name, tweet.screenName,
                           tweet.profileImageUrl, tweet.inReplyToScreenName, tweet.inReplyToStatusId,
                           tweet.latitude, tweet.longitude, tweet.mediaUrl, tweet.source, tweet.createdAt.toString(),
                           (tweet.isFavourited ? 1 : 0), (tweet.isRetweet ? 1 : 0), tweet.retweetScreenName];
            tx.executeSql(sqlText, binding)
        }
    })
}

function __getTweetsShared(tableName) {
    var tweets = []
    db.readTransaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM ' + tableName + ' ORDER BY id DESC;')
        for (var i=0; i<rs.rows.length; i++) {
            tweets.push(rs.rows.item(i));
        }
    })
    return tweets
}

