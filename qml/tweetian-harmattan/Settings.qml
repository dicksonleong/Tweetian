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
import "Utils/Database.js" as Database

QtObject {
    id: settings

    signal settingsLoaded

    // TODO: Use QSettings but some of the values like oauthToken & pocketPassword can not store as plain text
    function loadSettings() {
        var results = Database.getAllSettings()
        for (var s in results) {
            if (settings.hasOwnProperty(s)) {
                settings[s] = results[s]
            }
        }
        theme.inverted = !invertedTheme
        settingsLoaded()
    }

    function resetAll() {
        oauthToken = ""
        oauthTokenSecret = ""
        userScreenName = ""
        userFullName = ""
        userProfileImage = ""
        trendsLocationWoeid = "1"
        imageUploadService = 0
        invertedTheme = false
        enableTwitLonger = false
        largeFontSize = false
        translateLangName = "English"
        translateLangCode = "en"
        enableStreaming = false
        autoRefreshInterval = 0
        enableNotification = true
        pocketUsername = ""
        pocketPassword = ""
        instapaperToken = ""
        instapaperTokenSecret = ""
        muteString = ""
        Database.clearTable("settings")
    }

    property string oauthToken: ""
    onOauthTokenChanged: Database.setSetting({"oauthToken": oauthToken})
    property string oauthTokenSecret: ""
    onOauthTokenSecretChanged: Database.setSetting({"oauthTokenSecret": oauthTokenSecret})
    property string userScreenName: ""
    onUserScreenNameChanged: Database.setSetting({"userScreenName": userScreenName})
    property string userFullName: ""
    onUserFullNameChanged: Database.setSetting({"userFullName": userFullName})
    property string userProfileImage: ""
    onUserProfileImageChanged: Database.setSetting({"userProfileImage": userProfileImage})

    property string trendsLocationWoeid: "1"
    onTrendsLocationWoeidChanged: Database.setSetting({"trendsLocationWoeid": trendsLocationWoeid})
    property int imageUploadService: 0
    onImageUploadServiceChanged: Database.setSetting({"imageUploadService": imageUploadService.toString()})

    property bool invertedTheme: false
    onInvertedThemeChanged: {
        theme.inverted = !invertedTheme
        Database.setSetting({"invertedTheme": invertedTheme.toString()})
    }
    property bool enableTwitLonger: false
    onEnableTwitLongerChanged: Database.setSetting({"enableTwitLonger": enableTwitLonger.toString()})
    property bool largeFontSize: false
    onLargeFontSizeChanged: Database.setSetting({"largeFontSize": largeFontSize.toString()})

    property string translateLangName: "English"
    onTranslateLangNameChanged: Database.setSetting({"translateLangName": translateLangName})
    property string translateLangCode: "en"
    onTranslateLangCodeChanged: Database.setSetting({"translateLangCode": translateLangCode})

    property bool enableStreaming: false
    onEnableStreamingChanged: Database.setSetting({"enableStreaming": enableStreaming.toString()})
    property int autoRefreshInterval: 0
    onAutoRefreshIntervalChanged: Database.setSetting({"autoRefreshInterval": autoRefreshInterval.toString()})
    property bool enableNotification: true
    onEnableNotificationChanged: Database.setSetting({"enableNotification": enableNotification.toString()})

    property string pocketUsername: ""
    onPocketUsernameChanged: Database.setSetting({"pocketUsername": pocketUsername})
    property string pocketPassword: ""
    onPocketPasswordChanged: Database.setSetting({"pocketPassword": pocketPassword})

    property string instapaperToken: ""
    onInstapaperTokenChanged: Database.setSetting({"instapaperToken": instapaperToken})
    property string instapaperTokenSecret: ""
    onInstapaperTokenSecretChanged: Database.setSetting({"instapaperTokenSecret": instapaperTokenSecret})

    property string muteString: ""
    onMuteStringChanged: Database.setSetting({"muteString": muteString})
}
