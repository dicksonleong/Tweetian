import QtQuick 1.1
import "storage.js" as Database

QtObject{
    id: settings

    signal settingsLoaded

    // TODO: QSettings
    function loadSettings(){
        Database.initializeSettings()
        var request = ["oauthToken", "oauthTokenSecret", "userScreenName", "userFullName", "userProfileImage",
                       "timelineLastUpdate", "mentionsLastUpdate", "directMsgLastUpdate",
                       "trendsLocationWoeid", "imageUploadService",
                       "invertedTheme", "hashtagsInReply", "enableTwitLonger", "largeFontSize",
                       "enableStreaming" ,"timelineRefreshFreq", "mentionsRefreshFreq", "directMsgRefreshFreq",
                       "mentionNotification", "messageNotification",
                       "pocketUsername", "pocketPassword",
                       "instapaperToken", "instapaperTokenSecret", "muteString"]
        var settingsArray = Database.getSetting(request)
        oauthToken = settingsArray[0]
        oauthTokenSecret = settingsArray[1]
        userScreenName = settingsArray[2]
        userFullName = settingsArray[3]
        userProfileImage = settingsArray[4]
        timelineLastUpdate = settingsArray[5]
        mentionsLastUpdate = settingsArray[6]
        directMsgLastUpdate = settingsArray[7]
        if(settingsArray[8]) trendsLocationWoeid = settingsArray[8]
        if(settingsArray[9]) imageUploadService = settingsArray[9]
        invertedTheme = settingsArray[10] === "true"
        theme.inverted = !invertedTheme
        hashtagsInReply = settingsArray[11] !== "false"
        enableTwitLonger = settingsArray[12] === "true"
        largeFontSize = settingsArray[13] === "true"
        enableStreaming = settingsArray[14] === "true"
        if(settingsArray[15]) timelineRefreshFreq = settingsArray[15]
        if(settingsArray[16]) mentionsRefreshFreq = settingsArray[16]
        if(settingsArray[17]) directMsgRefreshFreq = settingsArray[17]
        mentionNotification = settingsArray[18] !== "false"
        messageNotification = settingsArray[19] !== "false"
        if(settingsArray[20]) pocketUsername = settingsArray[20]
        if(settingsArray[21]) pocketPassword = settingsArray[21]
        if(settingsArray[22]) instapaperToken = settingsArray[22]
        if(settingsArray[23]) instapaperTokenSecret = settingsArray[23]
        muteString = settingsArray[24]
        Database.initializeTweetsTable("Timeline")
        Database.initializeTweetsTable("Mentions")
        Database.initializeDirectMsg()
        settingsLoaded()
    }

    function resetAll(){
        oauthToken = ""
        oauthTokenSecret = ""
        userScreenName = ""
        userFullName = ""
        userProfileImage = ""
        timelineLastUpdate = ""
        mentionsLastUpdate = ""
        directMsgLastUpdate = ""
        trendsLocationWoeid = "1"
        imageUploadService = 0
        invertedTheme = false
        hashtagsInReply = true
        enableTwitLonger = false
        largeFontSize = false
        enableStreaming = false
        timelineRefreshFreq = 0
        mentionsRefreshFreq = 0
        directMsgRefreshFreq = 0
        mentionNotification = true
        messageNotification = true
        pocketUsername = ""
        pocketPassword = ""
        instapaperToken = ""
        instapaperTokenSecret = ""
        muteString = ""
        Database.clearTable("settings")
    }

    property string oauthToken: ""
    onOauthTokenChanged: Database.setSetting([["oauthToken", oauthToken]])
    property string oauthTokenSecret: ""
    onOauthTokenSecretChanged: Database.setSetting([["oauthTokenSecret", oauthTokenSecret]])
    property string userScreenName: ""
    onUserScreenNameChanged: Database.setSetting([["userScreenName", userScreenName]])
    property string userFullName: ""
    onUserFullNameChanged: Database.setSetting([["userFullName", userFullName]])
    property string userProfileImage: ""
    onUserProfileImageChanged: Database.setSetting([["userProfileImage", userProfileImage]])

    //those settings is set directly using storage.js from the ListView as this object have been destroyed
    //when ListView onDestruction is triggered
    property string timelineLastUpdate: ""
    property string mentionsLastUpdate: ""
    property string directMsgLastUpdate: ""

    property string trendsLocationWoeid: "1"
    onTrendsLocationWoeidChanged: Database.setSetting([["trendsLocationWoeid", trendsLocationWoeid]])
    property int imageUploadService: 0
    onImageUploadServiceChanged: Database.setSetting([["imageUploadService", imageUploadService.toString()]])

    property bool invertedTheme: false
    onInvertedThemeChanged: {
        theme.inverted = !invertedTheme
        Database.setSetting([["invertedTheme", invertedTheme.toString()]])
    }
    property bool hashtagsInReply: true
    onHashtagsInReplyChanged: Database.setSetting([["hashtagsInReply", hashtagsInReply.toString()]])
    property bool enableTwitLonger: false
    onEnableTwitLongerChanged: Database.setSetting([["enableTwitLonger", enableTwitLonger.toString()]])
    property bool largeFontSize: false
    onLargeFontSizeChanged: Database.setSetting([["largeFontSize", largeFontSize.toString()]])

    property bool enableStreaming: false
    onEnableStreamingChanged: Database.setSetting([["enableStreaming", enableStreaming.toString()]])
    property int timelineRefreshFreq: 0
    onTimelineRefreshFreqChanged: Database.setSetting([["timelineRefreshFreq", timelineRefreshFreq.toString()]])
    property int mentionsRefreshFreq: 0
    onMentionsRefreshFreqChanged: Database.setSetting([["mentionsRefreshFreq", mentionsRefreshFreq.toString()]])
    property int directMsgRefreshFreq: 0
    onDirectMsgRefreshFreqChanged: Database.setSetting([["directMsgRefreshFreq", directMsgRefreshFreq.toString()]])

    property bool mentionNotification: true
    onMentionNotificationChanged: Database.setSetting([["mentionNotification", mentionNotification.toString()]])
    property bool messageNotification: true
    onMessageNotificationChanged: Database.setSetting([["messageNotification", messageNotification.toString()]])

    property string pocketUsername: ""
    onPocketUsernameChanged: Database.setSetting([["pocketUsername", pocketUsername]])
    property string pocketPassword: ""
    onPocketPasswordChanged: Database.setSetting([["pocketPassword", pocketPassword]])

    property string instapaperToken: ""
    onInstapaperTokenChanged: Database.setSetting([["instapaperToken", instapaperToken]])
    property string instapaperTokenSecret: ""
    onInstapaperTokenSecretChanged: Database.setSetting([["instapaperTokenSecret", instapaperTokenSecret]])

    property string muteString: ""
    onMuteStringChanged: Database.setSetting([["muteString", muteString]])
}
