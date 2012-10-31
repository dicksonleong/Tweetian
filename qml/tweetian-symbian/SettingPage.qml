import QtQuick 1.1
import com.nokia.symbian 1.1
import "SettingsPageCom"
import "Component"
import "storage.js" as Storage
import "Dialog"

Page{
    id: settingPage

    tools: ToolBarLayout{
        ToolButtonWithTip{
            iconSource: "toolbar-back"
            toolTipText: "Back"
            onClicked: pageStack.pop()
        }
        ToolButtonWithTip{
            iconSource: "toolbar-menu"
            toolTipText: "Menu"
            onClicked: settingPageMenu.open()
        }
    }

    Menu{
        id: settingPageMenu
        platformInverted: settings.invertedTheme

        MenuLayout{
            MenuItem{
                text: "Clear cache & database"
                platformInverted: settingPageMenu.platformInverted
                onClicked: internal.createClearCacheDialog()
            }
            MenuItem{
                text: "Clear thumbnails cache"
                platformInverted: settingPageMenu.platformInverted
                onClicked: internal.createClearThumbnailDialog()
            }
        }
    }

    TabGroup{
        id: settingTabGroup
        anchors { left: parent.left; right: parent.right; top: settingTabBarLayout.bottom; bottom: parent.bottom }

        SettingGeneralTab{ id: generalTab }
        SettingRefreshTab{ id: refreshTab }
        AccountTab{ id: accountTab }
        MuteTab{ id: muteTab }
    }

    TabBarLayout{
        id: settingTabBarLayout
        anchors { left: parent.left; right: parent.right; top: parent.top }
        TabButton{ tab: generalTab; text: "General"}
        TabButton{ tab: refreshTab; text: "Update" }
        TabButton{ tab: accountTab; text: "Account" }
        TabButton{ tab: muteTab; text: "Mute" }
    }

    QtObject{
        id: infoText

        property string twitLonger: "TwitLonger is a third party service that allow you to post long tweet \
having more than 140 characters.<br>\
More info about TwitLonger:<br>\
<a href=\"http://www.twitlonger.com/about\">www.twitlonger.com/about</a><br>\
By enable this service, you agree to TwitLonger privacy policy:<br>\
<a href=\"http://www.twitlonger.com/privacy\">www.twitlonger.com/privacy</a>"

        property string pocket: "Pocket is a third party service for saving web page links \
so that you can read it later.<br>\
More about Pocket:<br>\
<a href=\"http://getpocket.com/about\">http://getpocket.com/about</a><br>\
By signing in, you agree to Pocket privacy policy:<br>\
<a href=\"http://getpocket.com/privacy\">http://getpocket.com/privacy</a>"

        property string instapaper: "More about Instapaper:<br>\
<a href=\"http://www.instapaper.com/\">http://www.instapaper.com/</a><br>\
By signing in, you agree to Instapaper privacy policy:<br>\
<a href=\"http://www.instapaper.com/privacy-policy\">http://www.instapaper.com/privacy-policy</a>"

        property string mute: "Mute allow you to mute tweets from your timeline with some specific keywords. \
Separate the keywords by space to mute tweet when ALL of the keywords are matched or separate by newline \
to mute tweet when ANY of the keywords are matched.\n\
Keywords format: @user, #hashtag, source:Tweet_Button or plain words."

        property string streaming: "Streaming enable Tweetian to deliver real time update of timeline, mentions \
and direct messages without the needs of refreshing periodically. Auto refresh and manual refresh will be disabled \
when streaming is connected. It is not recommended to enable streaming when you are on a weak internet connection \
(eg. mobile data)."
    }

    QtObject{
        id: internal

        function createClearCacheDialog(){
            var icon = settings.invertedTheme ? "image://theme/toolbar-delete_inverse"
                                              : "image://theme/toolbar-delete"
            var message = "This action will clear all temporary caches and database. \
Twitter credential and app settings will not be reset. Continue?"
            dialog.createQueryDialog("Clear Cache & Database", icon, message, function(){
                Storage.dropTable("Timeline")
                Storage.dropTable("Mentions")
                Storage.dropTable("DirectMsg")
                Storage.initializeTweetsTable("Timeline")
                Storage.initializeTweetsTable("Mentions")
                Storage.initializeDirectMsg()
                Storage.clearTable("ScreenNames")
                cache.clearAll()
                infoBanner.alert("All cache cleared.")
            })
        }

        function createClearThumbnailDialog(){
            var icon = settings.invertedTheme ? "image://theme/toolbar-delete_inverse"
                                              : "image://theme/toolbar-delete"
            var message = "Delete all cached thumbnails?"
            dialog.createQueryDialog("Clear Thumbnails Cache", icon, message, function(){
                var deleteCount = thumbnailCacher.clearAll()
                infoBanner.alert(deleteCount + " thumbnails cache cleared.")
            })
        }
    }
}
