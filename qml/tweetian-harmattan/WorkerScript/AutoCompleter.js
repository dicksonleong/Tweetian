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

WorkerScript.onMessage = function(msg) {
    msg.model.clear()
    if (msg.word.indexOf('@') === 0) {
        for (var i=0; i<msg.screenNames.length; i++) {
            if (msg.screenNames[i].toLowerCase().indexOf(msg.word.substring(1).toLowerCase()) === 0) {
                msg.model.append({completeWord: "@" + msg.screenNames[i]})
            }
        }
    }
    else if (msg.word.indexOf('#') === 0) {
        for (var h=0; h<msg.hashtags.length; h++) {
            if (msg.hashtags[h].toLowerCase().indexOf(msg.word.substring(1).toLowerCase()) === 0) {
                msg.model.append({completeWord: "#" + msg.hashtags[h]})
            }
        }
    }
    msg.model.sync()
}
