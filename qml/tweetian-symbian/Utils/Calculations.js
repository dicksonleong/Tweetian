/*
    Copyright (C) 2012 Dickson Leong
    This file is part of Tweetian.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

// NOTES: Due to this bug <https://bugreports.qt-project.org/browse/QTBUG-15681>,
// the following line must be comment out before running lupdate
.pragma library

function tweetsFrequency(date, tweetsCount) {
    var startDate = new Date(date) //incase the date isn't a date object
    var days = (new Date().getTime() - startDate.getTime()) / 1000 / 60 / 60 / 24 //calculate the numbers of days
    var freq = days >= 1 ? tweetsCount / days : tweetsCount

    if (freq > 1) return qsTr("~%1 per day").arg(Math.round(freq))
    else if (freq * 7 > 1) return qsTr("~%1 per week").arg(Math.round(freq * 7))
    else if (freq * 30 > 1) return qsTr("~%1 per month").arg(Math.round(freq * 30))
    else return qsTr("< 1 per month")
}

function timeDiff(tweetTimeStr) {
    var tweetTime = new Date(tweetTimeStr)
    var diff = new Date().getTime() - tweetTime.getTime() // milliseconds

    if (diff <= 0) return qsTr("Now")

    diff = Math.round(diff / 1000) // seconds

    if (diff < 60) return qsTr("Just now")

    diff = Math.round(diff / 60) // minutes

    if (diff < 60) return qsTr("%n min(s)", "", diff)

    diff = Math.round(diff / 60) // hours

    if (diff < 24) return qsTr("%n hr(s)", "", diff)

    diff = Math.round(diff / 24) // days

    if (diff === 1) return qsTr("Yesterday %1").arg(Qt.formatTime(tweetTime, "h:mm AP").toString())
    if (diff < 7 ) return Qt.formatDate(tweetTime, "ddd d MMM").toString()

    return Qt.formatDate(tweetTime, Qt.SystemLocaleShortDate).toString()
}

function toDegree(latitude, longitude) {
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

function minusOne(numberStr) {
    numberStr += "" // cast to string
    if (!numberStr) return ""

    var lastNumber = parseInt(numberStr.substring(numberStr.length - 2), 10)
    if (lastNumber === 0) return numberStr

    lastNumber--
    var lastNumberStr = lastNumber < 10 ? "0" + lastNumber.toString() : lastNumber.toString()
    return numberStr.substring(0, numberStr.length - 2).concat(lastNumberStr)
}
