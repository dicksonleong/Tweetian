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

var URL = "https://gdata.youtube.com/feeds/api/videos/"

function getVideoThumbnailAndLink(constant, videoId, onSuccess) {
    var request = new XMLHttpRequest()
    request.open("GET", URL + videoId + "?v=2&alt=json")
    request.setRequestHeader("X-GData-Key", "key=" + constant.youtubeDevKey)
    request.setRequestHeader("User-Agent", constant.userAgent)
    request.send()
    request.onreadystatechange = function(){
        if(request.readyState === XMLHttpRequest.DONE){
            if(request.status === 200){
                var thumb = "", rstpLink = ""
                var responseData = JSON.parse(request.responseText).entry.media$group
                for(var i=0; i<responseData.media$thumbnail.length; i++){
                    if(responseData.media$thumbnail[i].yt$name === "mqdefault"){
                        thumb = responseData.media$thumbnail[i].url
                        break
                    }
                }
                for(var iLink=0; iLink<responseData.media$content.length; iLink++){
                    if(responseData.media$content[iLink].yt$format === 6){
                        rstpLink = responseData.media$content[iLink].url
                        break
                    }
                }
                onSuccess(thumb, rstpLink)
            }
            else console.log("[Youtube] Error calling YouTube API:", request.status, request.statusText)
        }
    }
}
