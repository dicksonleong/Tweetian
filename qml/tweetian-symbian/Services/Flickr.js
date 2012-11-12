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

var BASE_URL = "http://api.flickr.com/services/rest/"

function getSizes(photoId, onSuccess) {
    var parameters = {
        method: "flickr.photos.getSizes",
        api_key: Global.Flickr.APP_KEY,
        format: "json",
        nojsoncallback: 1,
        photo_id: __base58Decode(photoId)
    }
    var url = BASE_URL + "?" + Global.encodeParameters(parameters)
    var request = new XMLHttpRequest()
    request.open("GET", url)

    request.onreadystatechange = function (){
        if(request.readyState === XMLHttpRequest.DONE && request.status == 200){
            var data = JSON.parse(request.responseText)
            var thumb = "",full = "", medium
            for(var i=0; i<data.sizes.size.length; i++){
                if(data.sizes.size[i].label === "Square") thumb = data.sizes.size[i].source
                else if(data.sizes.size[i].label === "Medium 640") full = data.sizes.size[i].source
                else if(data.sizes.size[i].label === "Medium") medium = data.sizes.size[i].source
            }
            // if full is not available, use medium
            if(!full) full = medium
            onSuccess(full, thumb)
        }
    }

    request.setRequestHeader("User-Agent", Global.USER_AGENT)
    request.send()
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
