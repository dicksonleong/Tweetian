WorkerScript.onMessage = function(msg){
    msg.model.clear()
    if(msg.word.indexOf('@') === 0){
        for(var i=0; i<msg.screenNames.length; i++){
            if(msg.screenNames[i].toLowerCase().indexOf(msg.word.substring(1).toLowerCase()) === 0){
                msg.model.append({"buttonText": "@"+msg.screenNames[i]})
            }
        }
    }
    else if(msg.word.indexOf('#') === 0){
        for(var h=0; h<msg.hashtags.length; h++){
            if(msg.hashtags[h].toLowerCase().indexOf(msg.word.substring(1).toLowerCase()) === 0){
                msg.model.append({"buttonText": "#"+msg.hashtags[h]})
            }
        }
    }
    msg.model.sync()
}
