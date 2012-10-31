.pragma library

Qt.include("Global.js")
Qt.include("../Utils/Parser.js")

var POST_TWEET_URL = "http://www.twitlonger.com/api_post"
var ID_CALLBACK_URL = "http://www.twitlonger.com/api_set_id"
var GET_FULL_TWEET_URL = "http://www.twitlonger.com/api_read/"

function postTweet(username, text, inReplyToStatusId, inReplyToUser, onSuccess, onFailure) {
    var parameters = {
        application: Global.TwitLonger.APPLICATION,
        api_key: Global.TwitLonger.API_KEY,
        username: username,
        message: text
    }
    if(inReplyToStatusId) parameters.in_reply = inReplyToStatusId
    if(inReplyToUser) parameters.in_reply_user = inReplyToUser

    var body = Global.encodeParameters(parameters)
    var request = new XMLHttpRequest()
    request.open("POST", POST_TWEET_URL)

    request.onreadystatechange = function(){
        if(request.readyState === XMLHttpRequest.DONE){
            if(request.status == 200){
                var id = "", shortenTweet = ""
                var xml = request.responseXML.documentElement.childNodes
                for(var i=0; i<xml.length; i++){
                    if(xml[i].nodeName === "post"){
                        for(var i2=0; i2<xml[i].childNodes.length; i2++){
                            if(xml[i].childNodes[i2].nodeName === "id"){
                                id = xml[i].childNodes[i2].childNodes[0].nodeValue
                            }
                            else if(xml[i].childNodes[i2].nodeName === "content"){
                                shortenTweet = xml[i].childNodes[i2].childNodes[0].nodeValue
                            }
                        }
                        break
                    }
                }
                if(id && shortenTweet) onSuccess(id, shortenTweet)
                else onFailure(-1, "Response parsing error")
            }
            else onFailure(request.status, request.statusText)
        }
    }

    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    request.setRequestHeader("User-Agent", Global.USER_AGENT)
    request.send(body)
}

function postIDCallback(messageId, twitterId){
    var parameters = {
        application: Global.TwitLonger.APPLICATION,
        api_key: Global.TwitLonger.API_KEY,
        message_id: messageId,
        twitter_id: twitterId
    }
    var body = Global.encodeParameters(parameters)
    var request = new XMLHttpRequest()
    request.open("POST", ID_CALLBACK_URL)

    request.onreadystatechange = function(){
        if(request.readyState === XMLHttpRequest.DONE){
            console.log("[TwitLonger] ID Callback Status:",request.status)
        }
    }

    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    request.setRequestHeader("User-Agent", Global.USER_AGENT)
    request.send(body)
}

// TwitLonger link should be in the form of http://tl.gd/xxxxxx
function getFullTweet(twitLongerLink, onSuccess, onFailure){
    var url = GET_FULL_TWEET_URL + twitLongerLink.substring(13)
    var request = new XMLHttpRequest()
    request.open("GET", url)

    request.onreadystatechange = function(){
        if(request.readyState === XMLHttpRequest.DONE){
            if(request.status == 200){
                var fullTweetText = ""
                var xml = request.responseXML.documentElement.childNodes[1].childNodes
                for(var i=0; i<xml.length; i++){
                    if(xml[i].nodeName === "content"){
                        fullTweetText = xml[i].childNodes[0].nodeValue
                        break
                    }
                }
                if(fullTweetText) {
                    var linksArray = fullTweetText.match(/http:\/\/\S+/)
                    if(linksArray != null){
                        for(var iLink=0; iLink < linksArray.length; iLink++){
                            fullTweetText = fullTweetText.parseURL(linksArray[iLink],
                                                                   linksArray[iLink].substring(7),
                                                                   linksArray[iLink])
                        }
                    }
                    onSuccess(fullTweetText.parseUsername().parseHashtag(), twitLongerLink)
                }
                else onFailure(-1, "Response parsing error")
            }
            else onFailure(request.status, request.statusText)
        }
    }

    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    request.setRequestHeader("User-Agent", Global.USER_AGENT)
    request.send()
}
