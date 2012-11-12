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

var REQUEST_TOKEN_URL = "https://datamarket.accesscontrol.windows.net/v2/OAuth2-13"
var TRANSLATE_URL = "http://api.microsofttranslator.com/V2/Ajax.svc/Translate"

function requestToken(onSuccess, onFailure) {
    var parameters = {
        client_id: Global.MSTranslation.CLIENT_ID,
        client_secret: Global.MSTranslation.CLIENT_SECRET,
        scope: "http://api.microsofttranslator.com",
        grant_type: "client_credentials"
    }
    var body = Global.encodeParameters(parameters)
    var request = new XMLHttpRequest()
    request.open("POST", REQUEST_TOKEN_URL)

    request.onreadystatechange = function(){
        if(request.readyState === XMLHttpRequest.DONE){
            if(request.status == 200) onSuccess(JSON.parse(request.responseText).access_token)
            else onFailure(request.status, request.statusText)
        }
    }

    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    request.setRequestHeader("User-Agent", Global.USER_AGENT)
    request.send(body)
}

function translate(accessToken, text, onSuccess, onFailure){
    var parameters = {
        text: text,
        to: "en",
        contentType: "text/plain",
        category: "general"
    }
    var url = TRANSLATE_URL + "?" + Global.encodeParameters(parameters)
    var request = new XMLHttpRequest()
    request.open("GET", url)

    request.onreadystatechange = function(){
        if(request.readyState === XMLHttpRequest.DONE){
            if(request.status == 200) onSuccess(JSON.parse(request.responseText))
            else onFailure(request.status, request.statusText)
        }
    }

    request.setRequestHeader("Authorization", "Bearer" + " " + accessToken)
    request.setRequestHeader("User-Agent", Global.USER_AGENT)
    request.send()
}
