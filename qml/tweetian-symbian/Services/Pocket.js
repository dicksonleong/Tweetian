.pragma library

Qt.include("Global.js")

var AUTHENTICATE_URL = "https://readitlaterlist.com/v2/auth"
var ADD_PAGE_URL = "https://readitlaterlist.com/v2/add"

function authenticate(username, password, onSuccess, onFailure){
    var parameters = {
        apikey: Global.Pocket.API_KEY,
        username: username,
        password: password
    }
    var body = Global.encodeParameters(parameters)
    var request = new XMLHttpRequest()
    request.open("POST", AUTHENTICATE_URL)

    request.onreadystatechange = function (){
        if(request.readyState === XMLHttpRequest.DONE){
            if(request.status === 200) onSuccess(username, password)
            else onFailure(__getErrorText(request.status) + " (" + request.status + ")")
        }
    }

    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    request.setRequestHeader("User-Agent", Global.USER_AGENT)
    request.send(body)
}

function addPage(username, password, url, title, ref_id, onSuccess, onFailure) {
    var parameters = {
        apikey: Global.Pocket.API_KEY,
        username: username,
        password: password,
        url: url,
        title: title,
        ref_id: ref_id
    }
    var body = Global.encodeParameters(parameters)
    var request = new XMLHttpRequest()
    request.open("POST", ADD_PAGE_URL)

    request.onreadystatechange = function (){
        if(request.readyState === XMLHttpRequest.DONE){
            if(request.status === 200) onSuccess()
            else onFailure(__getErrorText(request.status) + " (" + request.status + ")")
        }
    }

    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    request.setRequestHeader("User-Agent", Global.USER_AGENT)
    request.send(body)
}

function __getErrorText(status){
    var errorText = ""
    switch(status){
    case 0:
        errorText = "Connection error."
        break
    case 400:
        errorText = "Invalid request. Please contact the developer."
        break
    case 401:
        errorText = "Your username and/or password is incorrect."
        break
    case 403:
        errorText = "Rate limit exceeded. Please try again later."
        break
    case 503:
        errorText = "Pocket's server is currently down. Please try again later."
        break
    default:
        errorText = "Unknown error."
        break
    }
    return errorText
}
