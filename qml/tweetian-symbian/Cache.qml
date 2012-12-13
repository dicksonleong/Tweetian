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

import QtQuick 1.1
import "Utils/Database.js" as Database

QtObject {
    id: root

    function clearAll() {
        trendsModel.clear()
        trendsLastUpdate = ""
        userInfo = undefined
        screenNames = []
        hashtags = []
        translationToken = ""
    }

    function pushToHashtags(newHashtags) {
        if (newHashtags instanceof Array && newHashtags.length > 0) {
            var tempArray = hashtags
            for (var i=0; i<newHashtags.length; i++) {
                if (tempArray.indexOf(newHashtags[i]) === -1) tempArray.push(newHashtags[i])
            }
            hashtags = tempArray
        }
    }

    property ListModel trendsModel: ListModel {}
    property string trendsLastUpdate: ""

    property variant userInfo
    onUserInfoChanged: {
        if (userInfo) {
            settings.userFullName = cache.userInfo.name
            settings.userProfileImage = cache.userInfo.profile_image_url
            settings.userScreenName = cache.userInfo.screen_name
        }
    }

    property variant screenNames: []
    property variant hashtags: []

    property string translationToken: ""

    Component.onCompleted: {
        Database.initializeScreenNames()
        screenNames = Database.getScreenNames()
    }
}
