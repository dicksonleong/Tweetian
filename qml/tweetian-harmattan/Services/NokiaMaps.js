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

var URL = "http://m.nok.it/"

function getMaps(constant, latitude, longitude, width, height) {
    var parameters = {
        app_id: constant.nokiaMapsAppId,
        token: constant.nokiaMapsAppToken,
        h: height,
        w: width,
        lat: latitude,
        lon: longitude,
        nord: "",
        z: 5
    }

    var requestURL = URL

    for (var p in parameters) {
        if (requestURL.indexOf('?') < 0) requestURL += '?'
        else requestURL += '&'

        if (parameters[p] === "") requestURL += p
        else requestURL += p + '=' + parameters[p]
    }
    return requestURL
}
