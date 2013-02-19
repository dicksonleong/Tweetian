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

var BASE_URL = "http://api.flickr.com/services/rest/"
var FLICKR_LINK_REGEXP = /http:\/\/(flic\.kr\/p\/\w+|(www\.)?flickr\.com\/photos\/[\w\-\d@]+\/\d+)/ig

/**
 * Only the following format of Flickr link will be accepted:
 * - http://flic.kr/p/{base-58-encoded-photo-id}
 * - http://www.flickr.com/photos/{user-id}/{photo-id}
 * - http://flickr.com/photos/{user-id}/{photo-id}
 */
function getSizes(constant, link, onSuccess) {
    var parameters = {
        method: "flickr.photos.getSizes",
        api_key: constant.flickrAPIKey,
        format: "json",
        nojsoncallback: 1,
        photo_id: __getPhotoId(link)
    }
    var url = BASE_URL + "?" + constant.encodeParameters(parameters)
    var request = new XMLHttpRequest()
    request.open("GET", url)

    request.onreadystatechange = function() {
        if (request.readyState === XMLHttpRequest.DONE && request.status == 200) {
            var data = JSON.parse(request.responseText)
            var thumb = "", full = "", medium = "";
            data.sizes.size.forEach(function(sizeObject) {
                switch (sizeObject.label) {
                case "Large Square": thumb = sizeObject.source; break;
                case "Medium 640": full = sizeObject.source; break;
                case "Medium": medium = sizeObject.source; break;
                }
            })

            // if full is not available, use medium
            if (!full) full = medium
            onSuccess(full, thumb, link)
        }
    }

    request.setRequestHeader("User-Agent", constant.userAgent)
    request.send()
}

function __getPhotoId(link) {
    var extracted = "";

    if (link.indexOf("http://flic.kr/p/") === 0)
        return __base58Decode(link.substring(17));
    else if (link.indexOf("http://www.flickr.com/photos/") === 0)
        extracted = link.substring(29);
    else if (link.indexOf("http://flickr.com/photos/") === 0)
        extracted = link.substring(25);
    else
        throw new Error("Invalid Flickr link: " + link);

    return extracted.substring(extracted.indexOf("/") + 1);
}

function __base58Decode( snipcode ) {
    var alphabet = '123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ' ;
    var num = snipcode.length ;
    var decoded = 0 ;
    var multi = 1 ;
    for ( var i = (num-1) ; i >= 0 ; i-- ) {
        decoded = decoded + multi * alphabet.indexOf( snipcode[i] ) ;
        multi = multi * alphabet.length ;
    }
    return decoded;
}
