.pragma library

Qt.include("Global.js")

var URL = "https://gdata.youtube.com/feeds/api/videos/"

function getVideoThumbnailAndLink(videoId, onSuccess) {
    var request = new XMLHttpRequest()
    request.open("GET", URL + videoId + "?v=2&alt=json")
    request.setRequestHeader("X-GData-Key", "key=" + Global.YouTube.DEV_KEY)
    request.setRequestHeader("User-Agent", Global.USER_AGENT)
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
