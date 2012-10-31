Qt.include("../Utils/Calculations.js")

WorkerScript.onMessage = function (msg){
            var count = 0

            switch(msg.type){
            case "insert":
                for(var i=0; i < msg.count; i++){
                    if(msg.fullModel.get(i).screenName === msg.screenName){
                        var obj = {
                            tweetId: msg.fullModel.get(i).tweetId,
                            userName: msg.fullModel.get(i).userName,
                            screenName: msg.fullModel.get(i).screenName,
                            tweetText: msg.fullModel.get(i).tweetText,
                            profileImageUrl: msg.fullModel.get(i).profileImageUrl,
                            createdAt: msg.fullModel.get(i).createdAt,
                            timeDiff: timeDiff(msg.fullModel.get(i).createdAt),
                            sentMsg: msg.fullModel.get(i).sentMsg
                        }
                        msg.model.insert(count, obj)
                        count++
                    }
                }
                break
            case "remove":
                for(var iDelete=0; iDelete < msg.model.count; iDelete++){
                    if(msg.model.get(iDelete).tweetId === msg.tweetId){
                        msg.model.remove(iDelete)
                        break
                    }
                }
                break
            default:
                throw new Error("Invalid type: " + msg.type)
            }
            msg.model.sync()
            WorkerScript.sendMessage("")
        }
