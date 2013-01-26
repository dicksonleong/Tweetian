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

Qt.include("../Utils/Parser.js")

WorkerScript.onMessage = function(msg) {
    var usersArray = [];
    var screenNames = [];

    if (msg.type === "all") {
        msg.model.clear()
        msg.model.sync()
    }

    if (Array.isArray(msg.userIdsArray)) {
        msg.userIdsArray.forEach(function(id) {
            msg.data.some(function(userJson) {
                if (id !== userJson.id_str)
                    return false;

                usersArray.push(parseUser(userJson));
                return true;
            })
        })
    }
    else {
        msg.data.forEach(function(userJson) {
            usersArray.push(parseUser(userJson));
        })
    }

    usersArray.forEach(function(user) {
        screenNames.push(user.screenName);
        msg.model.append(user);
    })

    msg.model.sync();
    WorkerScript.sendMessage({screenNames: screenNames})
}
