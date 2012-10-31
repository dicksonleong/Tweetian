.pragma library

function tweetsFrequency(date, tweetsCount) {
    var startDate = new Date(date) //incase the date isn't a date object
    var days = (new Date().getTime() - startDate.getTime()) / 1000 / 60 / 60 / 24 //calculate the numbers of days
    var freq = days >= 1 ? tweetsCount / days : tweetsCount
    if(freq > 1) return "~" + Math.round(freq) + " per day"
    else if(freq * 7 > 1) return "~" + Math.round(freq * 7) + " per week"
    else if(freq * 30 > 1) return "~" + Math.round(freq * 30) + " per month"
    else return "< 1 per month"
}

function timeDiff(tweetTimeStr) {
    var tweetTime = new Date(tweetTimeStr)
    var diff = new Date().getTime() - tweetTime.getTime()

    if(diff <= 0) return "Now"

    var daysDiff = Math.floor(diff/1000/60/60/24)
    diff -= daysDiff * 1000 * 60 * 60 * 24

    var hoursDiff = Math.floor(diff/1000/60/60)
    diff -= hoursDiff * 1000 * 60 * 60

    var minutesDiff = Math.floor(diff/1000/60)
    diff -= minutesDiff * 1000 * 60

    var secondsDiff = Math.floor(diff/1000)

    if(daysDiff >= 7) return Qt.formatDateTime(tweetTime, "d MMM yy")
    else if(daysDiff > 1) return Qt.formatDateTime(tweetTime, "ddd d MMM")
    else if(daysDiff == 1) return "Yesterday "+ Qt.formatDateTime(tweetTime, "h:mm AP")
    else if(hoursDiff > 1) return hoursDiff + " hrs"
    else if(hoursDiff == 1) return "1 hr"
    else if(minutesDiff > 1) return minutesDiff + " mins"
    else if(minutesDiff == 1) return "1 min"
    else return "Just now"
}

function toDegree(latitude, longitude){
    var latD = latitude > 0 ? "N" : "S"
    latitude = Math.abs(latitude)
    var latDeg = Math.floor(latitude)
    var latMin = Math.floor((latitude - latDeg) * 60)
    var latSec = ((((latitude - latDeg) * 60) - latMin) * 60).toFixed(2)

    var longD = longitude > 0 ? "E" : "W"
    longitude = Math.abs(longitude)
    var longDeg = Math.floor(longitude)
    var longMin = Math.floor((longitude - longDeg) * 60)
    var longSec = ((((longitude - longDeg) * 60) - longMin) * 60).toFixed(2)

    return latDeg + "° " + latMin + "' " + latSec + "\" " + latD + ", " +
            longDeg + "° "+ longMin + "' " + longSec + "\" " + longD
}

function minusOne(numberStr){
    if(numberStr){
        var lastNumber = parseInt(numberStr.substring(numberStr.length - 2))
        if(lastNumber === 0) return numberStr
        lastNumber--
        return (numberStr.substring(0, numberStr.length - 2) + lastNumber.toString())
    }
    else return ""
}
