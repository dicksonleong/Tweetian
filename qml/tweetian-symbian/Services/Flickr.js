.pragma library

Qt.include("Global.js")

var BASE_URL = "http://api.flickr.com/services/rest/"

function getSizes(photoId, onSuccess) {
    var parameters = {
        method: "flickr.photos.getSizes",
        api_key: Global.Flickr.APP_KEY,
        format: "json",
        nojsoncallback: 1,
        photo_id: __base58Decode(photoId)
    }
    var url = BASE_URL + "?" + Global.encodeParameters(parameters)
    var request = new XMLHttpRequest()
    request.open("GET", url)

    request.onreadystatechange = function (){
        if(request.readyState === XMLHttpRequest.DONE && request.status == 200){
            var data = JSON.parse(request.responseText)
            var thumb = "",full = "", medium
            for(var i=0; i<data.sizes.size.length; i++){
                if(data.sizes.size[i].label === "Square") thumb = data.sizes.size[i].source
                else if(data.sizes.size[i].label === "Medium 640") full = data.sizes.size[i].source
                else if(data.sizes.size[i].label === "Medium") medium = data.sizes.size[i].source
            }
            // if full is not available, use medium
            if(!full) full = medium
            onSuccess(full, thumb)
        }
    }

    request.setRequestHeader("User-Agent", Global.USER_AGENT)
    request.send()
}

function __base58Decode( snipcode ) {
    var alphabet = '123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ' ;
    var num = snipcode.length ;
    var decoded = 0 ;
    var multi = 1 ;
    for ( var i = (num-1) ; i >= 0 ; i-- ) {
        decoded = decoded + multi * alphabet.indexOf( snipcode[i] ) ;
        multi = multi * alphabet.length ;
    }
    return decoded;
}
