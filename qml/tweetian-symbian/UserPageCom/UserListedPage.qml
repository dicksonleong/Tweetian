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
    id: userListedPage

    property string nextCursor: ""

    headerText: qsTr("Listed")
    headerNumber: user.listedCount
    emptyText: qsTr("No list")
    loadMoreButtonVisible: listView.count > 0 && listView.count < user.listedCount
    delegate: ListDelegate {}

    onReload: {
        if (reloadType === "all") nextCursor = ""
        Twitter.getUserListsMemberships(user.screenName, nextCursor, function(data) {
            for (var i=0; i<data.lists.length; i++) {
                var obj = {
                    "listName": data.lists[i].name,
                    "subscriberCount": data.lists[i].subscriber_count,
                    "listId": data.lists[i].id_str,
                    "memberCount": data.lists[i].member_count,
                    "listDescription": data.lists[i].description,
                    "ownerUserName": data.lists[i].user.name,
                    "ownerScreenName": data.lists[i].user.screen_name,
                    "profileImageUrl": data.lists[i].user.profile_image_url,
                    "protectedList": data.lists[i].mode === "private",
                    "following": data.lists[i].following
                }
                listView.model.append(obj)
            }
            nextCursor = data.next_cursor_str
            loadingRect.visible = false
        }, function(status, statusText) {
            infoBanner.showHttpError(status, statusText)
            loadingRect.visible = false
        })
        loadingRect.visible = true
    }
}
