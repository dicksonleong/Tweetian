var friendIDList = []

function initialize(){
    if(networkMonitor.online && settings.enableStreaming) {
        log("App is online and streaming is enabled, connect to streaming in " + reconnectTimer.interval +"s")
        reconnectTimer.start()
    }
    streamingSettingsConnection.target = settings
    onlineConnection.target = networkMonitor
}

function streamRecieved(rawData){
    reconnectTimer.interval = 5000 // reset reconnect timer interval
    timeOutTimer.restart() // reset timeout timer
    if(rawData){
        var data = JSON.parse(rawData)
        for(var prop in data){
            if(prop === "friends") {
                log("Friends response recieved with length " + data.friends.length)
                friendIDList = data.friends
                break
            }
            else if(prop === "direct_message"){
                log("DMs response recieved")
                if(data.direct_message.recipient_screen_name === settings.userScreenName)
                    directMsg.parser.insert([data.direct_message], [])
                else
                    directMsg.parser.insert([], [data.direct_message])

                break
            }
            else if(prop === "text"){
                var isMention = false
                if(data.entities && data.entities.user_mentions){ // check entities is exists
                    for(var i=0; i < data.entities.user_mentions.length; i++){
                        if(data.entities.user_mentions[i].screen_name === settings.userScreenName){
                            mentions.parseData("newer", [data], true)
                            isMention = true
                            break
                        }
                    }
                }

                if(!isMention || __isFollowingUser(data.user.id)) timeline.parseData("newer", [data], true)

                log(isMention ? "Mentions recieved" : "Status recieved")

                break
            }
            else if(prop === "delete"){
                log("Delete response recieved")
                if(data["delete"].direct_message){
                    directMsg.parser.remove(data["delete"].direct_message.id_str)
                }
                else{
                    timeline.parseData("delete", data["delete"].status)
                    mentions.parseData("delete", data["delete"].status)
                }
                break
            }
            else if(prop === "event"){
                log("Event response recieved with event_name: " + data.event)
            }
        }
    }
    else log("Keep Alive newline recieved")
}

function reconnectStream(statusCode, errorText){
    reconnectTimer.interval = Math.min(reconnectTimer.interval * 2, 300000)
    reconnectTimer.restart()
    var logText = "Disconnected from streaming (" + statusCode + " " + errorText + "). Reconnect in "
            + reconnectTimer.interval / 1000 + " seconds."
    infoBanner.alert(logText)
    log(logText)
}

function refreshAll(){
    if(!timeline.busy) timeline.refresh("newer")
    if(!mentions.busy) mentions.refresh("newer")
    if(!directMsg.busy) directMsg.refresh("newer")
}

// This will failed if user_id size is too long (>53bit)
function __isFollowingUser(user_id){
    for(var i=0; i<friendIDList.length; i++){
        if(user_id == friendIDList[i]){
            return true
        }
    }
    return false
}

function log(message){
    var time = Qt.formatTime(new Date(), "h:mm:ss")
    console.log(time, "[UserStream]", message)
}

// This is not related to Streaming but I don't want create another JS file to put this in
function saveUserInfo(){
    if(!settings.userFullName || !settings.userProfileImage || !settings.userScreenName){
        Twitter.getVerifyCredentials(
            function(data){ cache.userInfo = data },
            function(status, statusText){console.log("[SaveUserInfo] VerifyCredentials returns:", status, statusText)}
        )
    }
}

