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

Qt.include("Global.js")

var AUTHENTICATE_URL = "https://readitlaterlist.com/v2/auth"
var ADD_PAGE_URL = "https://readitlaterlist.com/v2/add"

function authenticate(username, password, onSuccess, onFailure){
    var parameters = {
        apikey: Global.Pocket.API_KEY,
        username: username,
        password: password
    }
    var body = Global.encodeParameters(parameters)
    var request = new XMLHttpRequest()
    request.open("POST", AUTHENTICATE_URL)

    request.onreadystatechange = function (){
        if(request.readyState === XMLHttpRequest.DONE){
            if(request.status === 200) onSuccess(username, password)
            else onFailure(request.status)
        }
    }

    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    request.setRequestHeader("User-Agent", Global.USER_AGENT)
    request.send(body)
}

function addPage(username, password, url, title, ref_id, onSuccess, onFailure) {
    var parameters = {
        apikey: Global.Pocket.API_KEY,
        username: username,
        password: password,
        url: url,
        title: title,
        ref_id: ref_id
    }
    var body = Global.encodeParameters(parameters)
    var request = new XMLHttpRequest()
    request.open("POST", ADD_PAGE_URL)

    request.onreadystatechange = function (){
        if(request.readyState === XMLHttpRequest.DONE){
            if(request.status === 200) onSuccess()
            else onFailure(request.status)
        }
    }

    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    request.setRequestHeader("User-Agent", Global.USER_AGENT)
    request.send(body)
}
