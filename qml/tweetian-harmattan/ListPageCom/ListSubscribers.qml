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
import com.nokia.meego 1.0
import "../Delegate"
import "../Services/Twitter.js" as Twitter

AbstractListPageItem {
    id: listSubscribers

    property string nextCursor: "-1"

    width: listPageListView.width; height: listPageListView.height
    workerScriptSource: "../WorkerScript/UserParser.js"
    headerText: qsTr("Subscribers (%1)").arg(subscriberCount)
    emptyText: qsTr("No subscriber")
    showLoadMoreButton: nextCursor != "0"
    refreshTimeStamp: false
    delegate: UserDelegate {}
    onRefresh: {
        if (type === "newer" || type === "all") {
            reloadType = "all"
            model.clear()
            Twitter.getListSubscribers(listId, -1, successCallback, failureCallback)
        }
        else {
            reloadType = "older"
            Twitter.getListSubscribers(listId, nextCursor, successCallback, failureCallback)
        }
    }
    onDataRecieved: {
        nextCursor = data.next_cursor_str
        sendToWorkerScript(data.users)
    }
}
