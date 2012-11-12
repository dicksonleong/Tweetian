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

.pragma library

var Global = {}

Global.USER_AGENT = "Tweetian/1.6.1 (Nokia; Qt; Symbian)"

Global.encodeParameters = function(parameters){
    var encoded = ""
    for(var p in parameters){
        if(encoded) encoded += "&"
        encoded += p + "=" + encodeURIComponent(parameters[p])
    }
    return encoded
}

// Fill in the API key/secret below for respective service for certain feature to function
// The provided Twitter OAuth cousumer key pair below are only for testing
// The release version in Nokia Store have a different key pair

// Needed for entire app to function
Global.Twitter = {
    OAUTH_CONSUMER_KEY: "0FB4Dd9xsgSHiGiCJ82L1g",
    OAUTH_CONSUMER_SECRET: "VgRBngFVKH9Rm2cG9OgJHACpHr6a2IvcKXxh49FvU"
}

// Needed for fetching Flickr image preview in tweet
Global.Flickr = {
    APP_KEY: ""
}

// Needed for sign in/add page to Instapaper
Global.Instapaper = {
    CONSUMER_KEY: "",
    CONSUMER_SECRET: ""
}

// Needed for loading maps for geotagged tweet
Global.NokiaMaps = {
    APP_ID: "",
    APP_TOKEN: ""
}

// Needed for sign in/add page to Pocket
Global.Pocket = {
    API_KEY: ""
}

// Needed for tweet translation
Global.MSTranslation = {
    CLIENT_ID: "",
    CLIENT_SECRET: ""
}

// Needed for post to TwitLonger
Global.TwitLonger = {
    APPLICATION: "",
    API_KEY: ""
}

// Needed for fetching YouTube thumbnail in tweet
Global.YouTube = {
    DEV_KEY: ""
}

// Needed for uploading image to TwitPic
Global.TwitPic = {
    API_KEY: ""
}

// Needed for uploading image to Moby.ly
Global.MobyPicture = {
    API_KEY: ""
}
