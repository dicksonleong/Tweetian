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
import QtWebKit 1.0
import com.nokia.meego 1.0
import "Services/Twitter.js" as Twitter
import "Component"

Page{
    id: signInPage

    property string tokenTempo: ""
    property string tokenSecretTempo: ""

    tools: ToolBarLayout{
        ToolIcon{
            platformIconId: "toolbar-back-dimmed"
            enabled: false
        }
        ToolIcon{
            platformIconId: "toolbar-refresh"
            onClicked: {
                Twitter.postRequestToken(script.requestTokenOnSuccess, script.onFailure)
                header.busy = true
            }
        }
    }

    Component.onCompleted: {
        Twitter.postRequestToken(script.requestTokenOnSuccess, script.onFailure)
        header.busy = true
    }

    onStatusChanged: if(status === PageStatus.Deactivating) settings.settingsLoaded()

    Flickable{
        id: webViewFlickable
        anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        contentHeight: signInWebView.height
        contentWidth: signInWebView.width

        WebView{
            id: signInWebView
            preferredHeight: webViewFlickable.height
            preferredWidth: webViewFlickable.width
            onUrlChanged: {
                var index = (url.toString()).indexOf("oauth_verifier=")
                if(index !== -1){
                    var oauthVerifier = (url.toString()).substring(index + 15, url.length)
                    Twitter.postAccessToken(tokenTempo, tokenSecretTempo, oauthVerifier,
                                            script.accessTokenOnSuccess, script.onFailure)
                    stop.trigger()
                }
            }
            onLoadStarted: header.busy = true
            onLoadFinished: header.busy = false
            onLoadFailed: header.busy = false
        }
    }

    ScrollDecorator{ flickableItem: webViewFlickable }

    PageHeader{
        id: header
        headerText: qsTr("Sign In to Twitter")
        headerIcon: "Image/sign_in.svg"
    }

    QtObject{
        id: script

        function requestTokenOnSuccess(token, tokenSecret){
            tokenTempo = token
            tokenSecretTempo = tokenSecret
            signInWebView.url = "https://api.twitter.com/oauth/authorize?oauth_token=" + tokenTempo
        }

        function accessTokenOnSuccess(token, tokenSecret, screenName){
            settings.oauthToken = token
            settings.oauthTokenSecret = tokenSecret
            settings.userScreenName = screenName
            infoBanner.alert(qsTr("Signed in successfully"))
            pageStack.pop(null)
        }

        function onFailure(status, statusText){
            if(status === 0)
                infoBanner.alert(qsTr("Server or connection error. Click the refresh button to try again."))
            else
                infoBanner.alert(qsTr("Error: %1. Make sure the time/date of your phone is set correctly.").arg(statusText + "(" + status + ")"))
            header.busy = false
        }
    }
}
