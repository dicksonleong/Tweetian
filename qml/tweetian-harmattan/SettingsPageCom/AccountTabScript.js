function pocketSuccessCallback(username, password){
    settings.pocketUsername = username
    settings.pocketPassword = password
    loadingRect.visible = false
    infoBanner.alert("Signed in to Pocket successfully.")
}

function pocketFailureCallback(errorText){
    loadingRect.visible = false
    infoBanner.alert("Error: " + errorText)
}

function instapaperSuccessCallback(oauthToken, oauthTokenSecret){
    settings.instapaperToken = oauthToken
    settings.instapaperTokenSecret = oauthTokenSecret
    loadingRect.visible = false
    infoBanner.alert("Signed in to Instapaper successfully.")
}

function instapaperFailureCallback(errorText){
    loadingRect.visible = false
    infoBanner.alert("Error: " + errorText)
}

var __signInDialog = null

function createPocketSignInDialog(){
    if(!__signInDialog) __signInDialog = Qt.createComponent("../Dialog/SignInDialog.qml")
    var dialog = __signInDialog.createObject(settingPage, { titleText: "Sign In to Pocket" })
    dialog.signIn.connect(function(username, password){
        Pocket.authenticate(username, password, Script.pocketSuccessCallback, Script.pocketFailureCallback)
        loadingRect.visible = true
    })
}

function createInstapaperSignInDialog(){
    if(!__signInDialog) __signInDialog = Qt.createComponent("../Dialog/SignInDialog.qml")
    var dialog = __signInDialog.createObject(settingPage, { titleText: "Sign In to Instapaper"})
    dialog.signIn.connect(function(username, password){
        Instapaper.getAccessToken(username, password, Script.instapaperSuccessCallback,
                                  Script.instapaperFailureCallback)
        loadingRect.visible = true
    })
}

function createTwitterSignOutDialog(){
    var message = "Do you want to sign out from your Twitter account? All other accounts will also automatically \
sign out. All settings will be reset."
    dialog.createQueryDialog("Twitter Sign Out", "", message, function(){
        Storage.clearTable("Timeline")
        mainPage.timeline.parseData("all", [])
        Storage.clearTable("Mentions")
        mainPage.mentions.parseData("all", [])
        Storage.clearTable("DirectMsg")
        mainPage.directMsg.parser.clearAndInsert([],[])
        Storage.clearTable("ScreenNames")
        settings.resetAll()
        cache.clearAll()
        window.pageStack.push(Qt.resolvedUrl("../SignInPage.qml"))
    })
}

function createPocketSignOutDialog(){
    var message = "Do you want to sign out from your Pocket account?"
    dialog.createQueryDialog("Pocket Sign Out", "", message, function(){
        settings.pocketUsername = ""
        settings.pocketPassword = ""
        infoBanner.alert("Signed out from your Pocket account successfully.")
    })
}

function createInstapaperSignOutDialog(){
    var message = "Do you want to sign out from your Instapaper account?"
    dialog.createQueryDialog("Instapaper Sign Out", "", message, function(){
        settings.instapaperToken = ""
        settings.instapaperTokenSecret = ""
        infoBanner.alert("Signed out from your Instapaper account successfully.")
    })
}
