.pragma library

Qt.include("Global.js")
Qt.include("../lib/oauth.js")

var ACCESS_TOKEN_URL = "https://www.instapaper.com/api/1/oauth/access_token"
var ADD_BOOKMARK_URL = "https://www.instapaper.com/api/1/bookmarks/add"

/* @param string username
 * @param string password
 * @param function onSuccess(oauth_token, oauth_token_secret)
 * @param function onFailure(errorText)
 */

function getAccessToken(username, password, onSuccess, onFailure) {
    var accessor = {
        consumerKey: Global.Instapaper.CONSUMER_KEY,
        consumerSecret: Global.Instapaper.CONSUMER_SECRET
    }
    var message = {
        action: ACCESS_TOKEN_URL,
        method: "POST",
        parameters: [["x_auth_username", username], ["x_auth_password", password], ["x_auth_mode", "client_auth"]]
    }
    var body = OAuth.formEncode(message.parameters)
    OAuth.completeRequest(message, accessor)
    //var authorizationHeader = OAuth.getAuthorizationHeader("https://www.instapaper.com/", message.parameters)
    var request = new XMLHttpRequest()
    var requestURL = OAuth.addToURL(message.action, message.parameters)
    request.open(message.method, requestURL)

    request.onreadystatechange = function(){
        if(request.readyState === XMLHttpRequest.DONE){
            if(request.status === 200){
                var oauthToken = "", oauthTokenSecret = ""
                var tokenArray = request.responseText.split('&')
                for(var i=0; i<tokenArray.length; i++){
                    if(tokenArray[i].indexOf("oauth_token=") === 0) oauthToken = tokenArray[i].substring(12)
                    else if(tokenArray[i].indexOf("oauth_token_secret=") === 0) oauthTokenSecret = tokenArray[i].substring(19)
                }
                onSuccess(oauthToken, oauthTokenSecret)
            }
            else onFailure(__getErrorText(request.status) + " (" + request.status + ")")
        }
    }

    //request.setRequestHeader("Authorization", authorizationHeader)
    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    request.setRequestHeader("User-Agent", Global.USER_AGENT)
    request.send(body)
}

/* @param string accessToken
 * @param string accessTokenSecret
 * @param string url - url to be add
 * @param string description - the tweet text
 * @param function onSuccess(responseText) - success callback
 * @param function onFailure(errorText) - failure callback
 */

function addBookmark(accessToken, accessTokenSecret, url, description, onSuccess, onFailure){
    var accessor = {
        consumerKey: Global.Instapaper.CONSUMER_KEY,
        consumerSecret: Global.Instapaper.CONSUMER_SECRET,
        token: accessToken,
        tokenSecret: accessTokenSecret
    }
    var message = {
        action: ADD_BOOKMARK_URL,
        method: "POST",
        parameters: [["url", url], ["description", description]]
    }
    var body = OAuth.formEncode(message.parameters)
    OAuth.completeRequest(message, accessor)
    //var authorizationHeader = OAuth.getAuthorizationHeader("", message.parameters)
    var request = new XMLHttpRequest()
    var requestURL = OAuth.addToURL(message.action, message.parameters)
    request.open(message.method, requestURL)

    request.onreadystatechange = function(){
        if(request.readyState === XMLHttpRequest.DONE){
            if(request.status === 200) onSuccess()
            else onFailure(__getErrorText(request.status) + " (" + request.status + ")")
        }
    }

    //request.setRequestHeader("Authorization", authorizationHeader)
    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    request.setRequestHeader("User-Agent", Global.USER_AGENT)
    request.send(body)
}

function __getErrorText(status){
    var errorText
    switch(status){
    case 0:
        errorText = "Connection error."
        break
    case 401:
        errorText = "Invalid login credential."
        break
    case 1040:
        errorText = "Rate limit exceeded. Please try again later."
        break
    case 1041:
        errorText = "Subscription account required."
        break
    case 1042:
        errorText = "Application is suspended. Please contact the developer ASAP."
        break
    case 1220:
        errorText = "This site needs to be viewed in a browser before saving to Instapaper."
        break
    case 1221:
        errorText = "The publisher of the site do not permit Instapaper usage."
        break
    case 1240:
        errorText = "Invalid URL specified."
        break
    case 1250:
        errorText = "Unexpected error when saving bookmark."
        break
    case 1500:
        errorText = "Unexpected service error."
        break
    case 1550:
        errorText = "Error generating text version of this URL."
        break
    default:
        errorText = "Unknown error."
        break
    }
    return errorText
}
