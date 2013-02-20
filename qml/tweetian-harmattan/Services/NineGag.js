.pragma library

var BASE_URL = "http://9gag.cocacoca.it/"
var NINEGAG_URL_REGEXP = /http:\/\/(?:m\.)?9gag\.com\/gag\/[^"]+/gi

function getImageUrl(constant, gagUrl, onSuccess) {
    var url = BASE_URL + __getGagId(gagUrl);
    var gagRequest = new XMLHttpRequest();
    gagRequest.open("GET", url);
    gagRequest.setRequestHeader("User-Agent", constant.userAgent);

    gagRequest.onreadystatechange = function() {
        if (gagRequest.readyState === XMLHttpRequest.DONE) {
            if (gagRequest.status === 200) {
                var json = JSON.parse(gagRequest.responseText);
                if (!json.hasOwnProperty("gag"))
                    return;
                var bigImageUrl = json.gag;
                if (bigImageUrl.indexOf("http:") !== 0)
                    bigImageUrl = "http:" + bigImageUrl;
                onSuccess(bigImageUrl.replace("_700b", "_460s"),
                          bigImageUrl.replace("_700b", "_220x145"), gagUrl);
            }
            else console.log("Error calling", url, ":", gagRequest.status, gagRequest.statusText);
        }
    }

    gagRequest.send();
}

function __getGagId(gagUrl) {
    var matched = /9gag\.com\/gag\/(\d+)/i.exec(gagUrl);
    if (matched === null)
        throw new Error("Unable to get gagId from gagUrl: " + gagUrl);
    return matched[1];
}
