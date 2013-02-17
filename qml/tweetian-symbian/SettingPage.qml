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
import com.nokia.symbian 1.1
import "SettingsPageCom"
import "Component"
import "Utils/Database.js" as Database
import "Dialog"

Page {
    id: settingPage

    tools: ToolBarLayout {
        ToolButtonWithTip {
            iconSource: "toolbar-back"
            toolTipText: qsTr("Back")
            onClicked: pageStack.pop()
        }
        ToolButtonWithTip {
            iconSource: "toolbar-menu"
            toolTipText: qsTr("Menu")
            onClicked: settingPageMenu.open()
        }
    }

    Menu {
        id: settingPageMenu
        platformInverted: settings.invertedTheme

        MenuLayout {
            MenuItem {
                text: qsTr("Clear cache & database")
                platformInverted: settingPageMenu.platformInverted
                onClicked: internal.createClearCacheDialog()
            }
            MenuItem {
                text: qsTr("Clear thumbnails cache")
                platformInverted: settingPageMenu.platformInverted
                onClicked: internal.createClearThumbnailDialog()
            }
        }
    }

    TabGroup {
        id: settingTabGroup
        anchors { left: parent.left; right: parent.right; top: settingTabBarLayout.bottom; bottom: parent.bottom }

        SettingGeneralTab { id: generalTab }
        SettingRefreshTab { id: refreshTab }
        AccountTab { id: accountTab }
        MuteTab { id: muteTab }
    }

    TabBarLayout {
        id: settingTabBarLayout
        anchors { left: parent.left; right: parent.right; top: parent.top }
        TabButton { tab: generalTab; text: qsTr("General") }
        TabButton { tab: refreshTab; text: qsTr("Update") }
        TabButton { tab: accountTab; text: qsTr("Account") }
        TabButton { tab: muteTab; text: qsTr("Mute") }
    }

    QtObject {
        id: infoText

        property string twitLonger: qsTr("TwitLonger is a third-party service that allows you to post tweets \
longer than 140 characters.<br>\
More info about TwitLonger:<br>\
<a href=\"http://www.twitlonger.com/about\">www.twitlonger.com/about</a><br>\
By enabling this service, you agree to the TwitLonger privacy policy:<br>\
<a href=\"http://www.twitlonger.com/privacy\">www.twitlonger.com/privacy</a>")

        property string pocket: qsTr("Pocket is a third-party service for saving web page links \
so you can read them later.<br>\
More about Pocket:<br>\
<a href=\"http://getpocket.com/about\">http://getpocket.com/about</a><br>\
By signing in, you agree to Pocket privacy policy:<br>\
<a href=\"http://getpocket.com/privacy\">http://getpocket.com/privacy</a>")

        property string instapaper: qsTr("More about Instapaper:<br>\
<a href=\"http://www.instapaper.com/\">http://www.instapaper.com/</a><br>\
By signing in, you agree to Instapaper privacy policy:<br>\
<a href=\"http://www.instapaper.com/privacy-policy\">http://www.instapaper.com/privacy-policy</a>")

        property string mute: qsTr("Mute allow you to mute tweets from your timeline with some specific keywords. \
Separate the keywords by space to mute tweet when ALL of the keywords are matched or separate by newline \
to mute tweet when ANY of the keywords are matched.\n\
Keywords format: @user, #hashtag, source:Tweet_Button or plain words.")

        property string streaming: qsTr("Streaming enables Tweetian to deliver real-time updates of timeline, mentions \
and direct messages without the needs of refreshing periodically. Auto refresh and manual refresh will be disabled \
when streaming is connected. It is not recommended to enable streaming when you are on a weak internet connection \
(eg. mobile data).")
    }

    QtObject {
        id: internal

        function createClearCacheDialog() {
            var icon = settings.invertedTheme ? "image://theme/toolbar-delete_inverse"
                                              : "image://theme/toolbar-delete"
            var message = qsTr("This action will clear the temporary cache and database. \
Twitter credential and app settings will not be reset. Continue?")
            dialog.createQueryDialog(qsTr("Clear Cache & Database"), icon, message, function() {
                Database.clearTable("Timeline");
                Database.clearTable("Mentions");
                Database.clearTable("DM");
                Database.clearTable("ScreenNames");
                cache.clearAll()
                infoBanner.showText(qsTr("Cache and database cleared"))
            })
        }

        function createClearThumbnailDialog() {
            var icon = settings.invertedTheme ? "image://theme/toolbar-delete_inverse"
                                              : "image://theme/toolbar-delete"
            var message = qsTr("Delete all cached thumbnails?")
            dialog.createQueryDialog(qsTr("Clear Thumbnails Cache"), icon, message, function() {
                var deleteCount = thumbnailCacher.clearAll()
                infoBanner.showText(qsTr("%1 thumbnails deleted").arg(deleteCount))
            })
        }
    }
}
