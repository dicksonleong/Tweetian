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
import "../Utils/Calculations.js" as Calculate

AbstractListPageItem {
    id: listTimeline
    width: listPageListView.width; height: listPageListView.height
    workerScriptSource: "../WorkerScript/TweetsParser.js"
    headerText: qsTr("List Timeline")
    emptyText: qsTr("No tweet")
    delegate: TweetDelegate {}
    onRefresh: {
        var sinceId = "", maxId = "", mType = type
        if (model.count > 0) {
            if (mType === "newer") sinceId = model.get(0).id
            else if (mType === "older") maxId = model.get(model.count - 1).id
            else if (mType === "all") model.clear()
        }
        else mType = "all"
        reloadType = mType
        Twitter.getListTimeline(listId, sinceId, Calculate.minusOne(maxId), successCallback, failureCallback)
    }
    onDataRecieved: sendToWorkerScript(data)
}
