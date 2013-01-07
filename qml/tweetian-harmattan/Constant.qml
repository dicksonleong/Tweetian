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

import QtQuick 1.1
import com.nokia.meego 1.0

QtObject {
    id: constant

    // color
    property color colorHighlighted: colorLight
    property color colorLight: settings.invertedTheme ? "#191919" : "#ffffff"
    property color colorMid: settings.invertedTheme ? "#666666" : "#8c8c8c"
    property color colorTextSelection: "#4591ff"
    property color colorDisabled: settings.invertedTheme ? "#b2b2b4" : "#444444"

    // padding size
    property int paddingSmall: 4
    property int paddingMedium: 8
    property int paddingLarge: 12
    property int paddingXLarge: 16

    // font size
    property int fontSizeXSmall: 20
    property int fontSizeSmall: 22
    property int fontSizeMedium: 24
    property int fontSizeLarge: 26
    property int fontSizeXLarge: 28
    property int fontSizeXXLarge: 32

    // graphic size
    property int graphicSizeTiny: 24
    property int graphicSizeSmall: 32
    property int graphicSizeMedium: 48
    property int graphicSizeLarge: 72

    property int thumbnailSize: 150

    // other
    property int headerHeight: inPortrait ? 65 : 55

    property int charReservedPerMedia: 23
    property url twitterBirdIcon: settings.invertedTheme ? "Image/twitter-bird-light.png" : "Image/twitter-bird-dark.png"

    property string userAgent: QMLUtils.userAgent()

    // -------- API Key/Secret ---------- //

    // Fill in the API key/secret below for respective service for certain feature to function
    // The provided Twitter OAuth cousumer key pair below are only for testing
    // The release version in Nokia Store have a different key pair

    property string twitterConsumerKey: "0FB4Dd9xsgSHiGiCJ82L1g"
    property string twitterConsumerSecret: "VgRBngFVKH9Rm2cG9OgJHACpHr6a2IvcKXxh49FvU"

    // Needed for uploading image to TwitPic
    property string twitpicAPIKey: ""

    // Needed for uploading image to Moby.ly
    property string mobypictureAPIKey: ""

    // Needed for sign in/add page to Pocket
    property string pocketAPIKey: ""

    // Needed for sign in/add page to Instapaper
    property string instapaperConsumerKey: ""
    property string instapaperConsumerSecret: ""

    // Needed for post to TwitLonger
    property string twitlongerApp: ""
    property string twitlongerAPIKey: ""

    // Needed for tweet translation
    property string msTranslationCliendId: ""
    property string msTranslationCliendSecret: ""

    // Needed for loading maps for geotagged tweet
    property string nokiaMapsAppId: ""
    property string nokiaMapsAppToken: ""

    // Needed for fetching Flickr image preview in tweet
    property string flickrAPIKey: ""

    // Needed for fetching YouTube thumbnail & streaming link in tweet
    property string youtubeDevKey: ""

    // TODO: move the following function to a more suitable place
    function encodeParameters(parameters) {
        var encoded = ""
        for (var p in parameters) {
            if (encoded) encoded += "&"
            encoded += p + "=" + encodeURIComponent(parameters[p])
        }
        return encoded
    }
}
