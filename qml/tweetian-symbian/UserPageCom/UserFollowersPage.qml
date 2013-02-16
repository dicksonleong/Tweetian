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
import com.nokia.symbian 1.1
import "../Delegate"
import "../Services/Twitter.js" as Twitter
import "../Utils/Database.js" as Database

AbstractUserPage {
    id: userFollowingPage

    property variant userIdsData

    // The user ids array for the current request, for sending into WorkerScript to sort the user in this array
    // order. Will be set to undefined once used to free memory.
    property variant currentRequestUserIds

    headerText: qsTr("Followers")
    headerNumber: user.followersCount
    emptyText: qsTr("No follower")
    loadMoreButtonVisible: listView.count > 0 && listView.count < user.followersCount
    delegate: UserDelegate {}

    onReload: {
        if (reloadType === "all") {
            listView.model.clear()
            Twitter.getFollowersId(user.screenName, function(data) {
                userIdsData = data
                reloadType = "older"
                reload()
            }, __failureCallback)
            loadingRect.visible = true
        }
        else {
            var userCount = Math.min(50, userIdsData.ids.length - listView.count)
            currentRequestUserIds = userIdsData.ids.slice(listView.count, listView.count + userCount)
            if (currentRequestUserIds.length > 0) {
                Twitter.getUserLookup(currentRequestUserIds.join(), function(data) {
                backButtonEnabled = false
                userFollowingParser.sendMessage({model: listView.model, data: data,
                    type: reloadType, userIdsArray: currentRequestUserIds})
                }, __failureCallback)
                loadingRect.visible = true
            }
            else {
                infoBanner.showText(qsTr("Error: No user to load?!"))
                loadingRect.visible = false
            }
        }
    }

    WorkerScript {
        id: userFollowingParser
        source: "../WorkerScript/UserParser.js"
        onMessage: {
            backButtonEnabled = true
            if (user.screenName === settings.userScreenName)
                cache.storeScreenNames(messageObject.screenNames);
            currentRequestUserIds = undefined
            loadingRect.visible = false
        }
    }

    function __failureCallback(status, statusText) {
        infoBanner.showHttpError(status, statusText)
        loadingRect.visible = false
    }
}
