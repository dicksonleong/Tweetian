.pragma library

Qt.include("Global.js")

var URL = "http://m.nok.it/"

function getMaps(latitude, longitude, width, height) {
    var parameters = {
        app_id: Global.NokiaMaps.APP_ID,
        token: Global.NokiaMaps.APP_TOKEN,
        h: height,
        w: width,
        lat: latitude,
        lon: longitude,
        nord: "",
        z: 5
    }

    var requestURL = URL

    for(var p in parameters){
        if(requestURL.indexOf('?') < 0) requestURL += '?'
        else requestURL += '&'

        if(parameters[p] === "") requestURL += p
        else requestURL += p + '=' + parameters[p]
    }
    return requestURL
}
