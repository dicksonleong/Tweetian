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

AbstractUserPage {
    id: userSubscribedListsPage

    headerText: qsTr("Subscribed Lists")
    headerNumber: listView.count
    emptyText: qsTr("No list")
    loadMoreButtonVisible: false
    delegate: ListDelegate {}

    onReload: {
        Twitter.getUserLists(user.screenName, function(data) {
            for (var i=0; i<data.length; i++) {
                var obj = {
                        "listName": data[i].name,
                        "subscriberCount": data[i].subscriber_count,
                        "listId": data[i].id_str,
                        "memberCount": data[i].member_count,
                        "listDescription": data[i].description,
                        "ownerUserName": data[i].user.name,
                        "ownerScreenName": data[i].user.screen_name,
                        "profileImageUrl": data[i].user.profile_image_url,
                        "protectedList": data[i].mode === "private",
                        "following": data[i].following
                }
                listView.model.append(obj)
            }
            loadingRect.visible = false
        }, function(status, statusText) {
            infoBanner.showHttpError(status, statusText)
            loadingRect.visible = false
        })
        loadingRect.visible = true
    }
}
