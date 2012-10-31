.pragma library

Qt.include("Global.js")

var REQUEST_TOKEN_URL = "https://datamarket.accesscontrol.windows.net/v2/OAuth2-13"
var TRANSLATE_URL = "http://api.microsofttranslator.com/V2/Ajax.svc/Translate"

function requestToken(onSuccess, onFailure) {
    var parameters = {
        client_id: Global.MSTranslation.CLIENT_ID,
        client_secret: Global.MSTranslation.CLIENT_SECRET,
        scope: "http://api.microsofttranslator.com",
        grant_type: "client_credentials"
    }
    var body = Global.encodeParameters(parameters)
    var request = new XMLHttpRequest()
    request.open("POST", REQUEST_TOKEN_URL)

    request.onreadystatechange = function(){
        if(request.readyState === XMLHttpRequest.DONE){
            if(request.status == 200) onSuccess(JSON.parse(request.responseText).access_token)
            else onFailure(request.status, request.statusText)
        }
    }

    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    request.setRequestHeader("User-Agent", Global.USER_AGENT)
    request.send(body)
}

function translate(accessToken, text, onSuccess, onFailure){
    var parameters = {
        text: text,
        to: "en",
        contentType: "text/plain",
        category: "general"
    }
    var url = TRANSLATE_URL + "?" + Global.encodeParameters(parameters)
    var request = new XMLHttpRequest()
    request.open("GET", url)

    request.onreadystatechange = function(){
        if(request.readyState === XMLHttpRequest.DONE){
            if(request.status == 200) onSuccess(JSON.parse(request.responseText))
            else onFailure(request.status, request.statusText)
        }
    }

    request.setRequestHeader("Authorization", "Bearer" + " " + accessToken)
    request.setRequestHeader("User-Agent", Global.USER_AGENT)
    request.send()
}
