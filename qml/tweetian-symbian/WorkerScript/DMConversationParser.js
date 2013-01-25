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

Qt.include("../Utils/Calculations.js")

WorkerScript.onMessage = function(msg) {
    var count = 0

    switch (msg.type) {
    case "insert":
        for (var i=0; i<msg.count; i++) {
            if (msg.fullModel.get(i).screenName !== msg.screenName)
                continue;

            var dm = msg.fullModel.get(i);
            var toBeInsertDM = {
                id: dm.id,
                richText: dm.richText,
                name: dm.name,
                screenName: dm.screenName,
                profileImageUrl: dm.profileImageUrl,
                createdAt: dm.createdAt,
                isReceiveDM: dm.isReceiveDM
            }
            toBeInsertDM.timeDiff = timeDiff(dm.createdAt)
            msg.model.insert(count, toBeInsertDM)
            count++
        }
        break
    case "remove":
        for (var iDelete=0; iDelete < msg.model.count; iDelete++) {
            if (msg.model.get(iDelete).id === msg.id) {
                msg.model.remove(iDelete)
                break
            }
        }
        break
    default:
        throw new Error("Invalid type: " + msg.type)
    }
    msg.model.sync()
    WorkerScript.sendMessage("")
}
