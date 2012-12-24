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
var YOUTUBE_LINK_REGEXP = /https?:\/\/(youtu.be\/[\w-]{11,}|www.youtube.com\/watch\?[\w-=&]{11,})/ig

/**
 * Only 2 format of YouTube link is accepted:
 * - http(s)://youtu.be/{video-id}
 * - http(s)://www.youtube.com/watch?v={video-id}
 * (additional query string after /watch? also accepted)
 */
function getVideoThumbnailAndLink(constant, link, onSuccess) {
    var request = new XMLHttpRequest()
    request.open("GET", URL + __getVideoId(link) + "?v=2&alt=json")
    request.setRequestHeader("X-GData-Key", "key=" + constant.youtubeDevKey)
    request.setRequestHeader("User-Agent", constant.userAgent)

    request.onreadystatechange = function() {
        if (request.readyState === XMLHttpRequest.DONE) {
            if (request.status === 200) {
                var thumb = "", rstpLink = ""
                var responseData = JSON.parse(request.responseText).entry.media$group
                for (var i=0; i<responseData.media$thumbnail.length; i++) {
                    if (responseData.media$thumbnail[i].yt$name === "mqdefault" ) {
                        thumb = responseData.media$thumbnail[i].url
                        break
                    }
                }
                for (var iLink=0; iLink<responseData.media$content.length; iLink++) {
                    if (responseData.media$content[iLink].yt$format === 6) {
                        rstpLink = responseData.media$content[iLink].url
                        break
                    }
                }
                onSuccess(thumb, rstpLink)
            }
            else console.log("[Youtube] Error calling YouTube API:", request.status, request.statusText)
        }
    }

    request.send()
}

function __getVideoId(link) {
    link = link.replace("https://", "http://")

    if (link.indexOf("http://youtu.be/") === 0) {
        return link.substring(16)
    }
    else if (link.indexOf("http://www.youtube.com/watch?") === 0) {
        var queryArray = link.substring(29).split('&')
        for (var iQuery=0; iQuery<queryArray.length; iQuery++) {
            if (queryArray[iQuery].indexOf('v=') === 0) {
                return queryArray[iQuery].substring(2)
            }
        }
    }
    throw new Error("Invalid YouTube link: " + link)
}
