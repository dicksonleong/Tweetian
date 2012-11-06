// NOTES: Due to this bug <https://bugreports.qt-project.org/browse/QTBUG-15681>,
// the following line must be comment out before running lupdate
.pragma library

function tweetsFrequency(date, tweetsCount) {
    var startDate = new Date(date) //incase the date isn't a date object
    var days = (new Date().getTime() - startDate.getTime()) / 1000 / 60 / 60 / 24 //calculate the numbers of days
    var freq = days >= 1 ? tweetsCount / days : tweetsCount

    if(freq > 1) return qsTr("~%1 per day").arg(Math.round(freq))
    else if(freq * 7 > 1) return qsTr("~%1 per week").arg(Math.round(freq * 7))
    else if(freq * 30 > 1) return qsTr("~%1 per month").arg(Math.round(freq * 30))
    else return qsTr("< 1 per month")
}

function timeDiff(tweetTimeStr) {
    var tweetTime = new Date(tweetTimeStr)
    var diff = new Date().getTime() - tweetTime.getTime()

    if(diff <= 0) return qsTr("Now")

    var daysDiff = Math.floor(diff/1000/60/60/24)
    diff -= daysDiff * 1000 * 60 * 60 * 24

    var hoursDiff = Math.floor(diff/1000/60/60)
    diff -= hoursDiff * 1000 * 60 * 60

    var minutesDiff = Math.floor(diff/1000/60)
    diff -= minutesDiff * 1000 * 60

    var secondsDiff = Math.floor(diff/1000)

    if(daysDiff >= 7) return Qt.formatDateTime(tweetTime, "d MMM yy").toString()
    else if(daysDiff > 1) return Qt.formatDateTime(tweetTime, "ddd d MMM").toString()
    else if(daysDiff == 1) return qsTr("Yesterday %1").arg(Qt.formatDateTime(tweetTime, "h:mm AP").toString())
    else if(hoursDiff >= 1) return qsTr("%n hr(s)", "", hoursDiff)
    else if(minutesDiff >= 1) return qsTr("%n min(s)", "", minutesDiff)
    else return qsTr("Just now")
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
        return numberStr.substring(0, numberStr.length - 2) + lastNumber.toString()
    }
    else return ""
}
