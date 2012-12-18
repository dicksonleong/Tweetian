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

/**
 * Powered by Microsoft Translator
 * Documentation: <http://msdn.microsoft.com/en-gb/library/ff512404.aspx>
 */

.pragma library

var REQUEST_TOKEN_URL = "https://datamarket.accesscontrol.windows.net/v2/OAuth2-13"
var GET_LANGUAGES_FOR_TRANSLATE_URL = "http://api.microsofttranslator.com/V2/Ajax.svc/GetLanguagesForTranslate"
var GET_LANGUAGES_NAMES_URL = "http://api.microsofttranslator.com/V2/Ajax.svc/GetLanguageNames"
var TRANSLATE_URL = "http://api.microsofttranslator.com/V2/Ajax.svc/Translate"

function requestToken(constant, onSuccess, onFailure) {
    var parameters = {
        client_id: constant.msTranslationCliendId,
        client_secret: constant.msTranslationCliendSecret,
        scope: "http://api.microsofttranslator.com",
        grant_type: "client_credentials"
    }
    var body = constant.encodeParameters(parameters)
    var request = new XMLHttpRequest()
    request.open("POST", REQUEST_TOKEN_URL)

    request.onreadystatechange = function() {
        if (request.readyState === XMLHttpRequest.DONE) {
            if (request.status == 200) onSuccess(JSON.parse(request.responseText).access_token)
            else onFailure(request.status, request.statusText)
        }
    }

    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    request.setRequestHeader("User-Agent", constant.userAgent)
    request.send(body)
}

function getLanguagesForTranslate(constant, accessToken, onSuccess, onFailure) {
    var request = new XMLHttpRequest()
    request.open("GET", GET_LANGUAGES_FOR_TRANSLATE_URL)

    request.onreadystatechange = function() {
        if (request.readyState === XMLHttpRequest.DONE) {
            if (request.status === 200) onSuccess(JSON.parse(request.responseText))
            else onFailure(request.status, request.statusText)
        }
    }

    request.setRequestHeader("Authorization", "Bearer " + accessToken)
    request.setRequestHeader("User-Agent", constant.userAgent)
    request.send()
}

function getLanguageNames(constant, accessToken, languageCodes, onSuccess, onFailure) {
    var parameters = {
        locale: "en", // TODO: Follow device's language
        languageCodes: languageCodes
    }
    var url = GET_LANGUAGES_NAMES_URL + "?" + constant.encodeParameters(parameters)
    var request = new XMLHttpRequest()
    request.open("GET", url)

    request.onreadystatechange = function() {
        if (request.readyState === XMLHttpRequest.DONE) {
            if (request.status == 200) onSuccess(JSON.parse(request.responseText))
            else onFailure(request.status, request.statusText)
        }
    }

    request.setRequestHeader("Authorization", "Bearer " + accessToken)
    request.setRequestHeader("User-Agent", constant.userAgent)
    request.send()
}

function translate(constant, accessToken, text, to, onSuccess, onFailure) {
    var parameters = {
        text: text,
        to:  to,
        contentType: "text/plain",
        category: "general"
    }
    var url = TRANSLATE_URL + "?" + constant.encodeParameters(parameters)
    var request = new XMLHttpRequest()
    request.open("GET", url)

    request.onreadystatechange = function() {
        if (request.readyState === XMLHttpRequest.DONE) {
            if (request.status == 200) onSuccess(JSON.parse(request.responseText))
            else onFailure(request.status, request.statusText)
        }
    }

    request.setRequestHeader("Authorization", "Bearer " + accessToken)
    request.setRequestHeader("User-Agent", constant.userAgent)
    request.send()
}
