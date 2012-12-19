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
import "Services/Twitter.js" as Twitter
import "Component"
import "Utils/Calculations.js" as Calculate

Page {
    id: userPage

    property string screenName
    property variant userInfoRawData

    QtObject {
        id: userInfoData

        property string profileImageUrl: ""
        property string bannerImageUrl: ""
        property string screenName: ""
        property bool protectedUser: false
        property string userName: ""
        property int statusesCount: 0
        property int friendsCount: 0
        property int followersCount: 0
        property int favouritesCount: 0
        property int listedCount: 0
        property bool following: false

        function setData() {
            profileImageUrl = userInfoRawData.profile_image_url
            if (userInfoRawData.profile_banner_url) bannerImageUrl = userInfoRawData.profile_banner_url
            screenName = userInfoRawData.screen_name
            protectedUser = userInfoRawData.protected
            userName = userInfoRawData.name
            statusesCount = userInfoRawData.statuses_count
            friendsCount = userInfoRawData.friends_count
            followersCount = userInfoRawData.followers_count
            favouritesCount = userInfoRawData.favourites_count
            listedCount = userInfoRawData.listed_count
            if (userInfoRawData.following) following = userInfoRawData.following
            userInfoRawData = undefined
        }
    }

    onScreenNameChanged: {
        if (screenName === settings.userScreenName && cache.userInfo)
            internal.userInfoOnSuccess(cache.userInfo)
        else if (userInfoRawData) internal.userInfoOnSuccess(userInfoRawData)
        else internal.refresh()
    }

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolIcon {
            platformIconId: "toolbar-send-email"
            enabled: screenName !== settings.userScreenName
            opacity: enabled ? 1 : 0.25
            onClicked: pageStack.push(Qt.resolvedUrl("NewTweetPage.qml"), {type: "New", placedText: "@"+screenName+" "})
        }
        ToolIcon {
            platformIconId: "toolbar-send-sms"
            enabled: screenName !== settings.userScreenName
            opacity: enabled ? 1 : 0.25
            onClicked: pageStack.push(Qt.resolvedUrl("NewTweetPage.qml"), {type: "DM", screenName: screenName})
        }
        ToolIcon {
            platformIconId: "toolbar-refresh" + (enabled ? "" : "-dimmed")
            enabled: !loadingRect.visible
            onClicked: internal.refresh()
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            onClicked: userPageMenu.open()
        }
    }

    Menu {
        id: userPageMenu

        MenuLayout {
            MenuItem {
                text: userInfoData.following ? qsTr("Unfollow %1").arg("@" + screenName)
                                             : qsTr("Follow %1").arg("@" + screenName)
                enabled: screenName !== settings.userScreenName
                onClicked: internal.createFollowUserDialog()
            }
            MenuItem {
                text: qsTr("Report user as spammer")
                enabled: screenName !== settings.userScreenName
                onClicked: internal.createReportSpamDialog()
            }
        }
    }

    Flickable {
        id: userFlickable
        anchors.fill: parent
        flickableDirection: Flickable.VerticalFlick
        contentHeight: userColumn.height

        Column {
            id: userColumn
            anchors { left: parent.left; right: parent.right }

            Item {
                id: headerItem
                anchors { left: parent.left; right: parent.right }
                height: inPortrait ? width / 2 : width / 4

                Image {
                    id: headerImage
                    anchors.fill: parent
                    cache: false
                    fillMode: Image.PreserveAspectCrop
                    clip: true
                    source: {
                        if (userInfoData.bannerImageUrl)
                            return userInfoData.bannerImageUrl.concat(inPortrait ? "/web" : "/mobile_retina")
                        else
                            return "Image/banner_empty.jpg"
                    }

                    onStatusChanged: if (status === Image.Error) source = "Image/banner_empty.jpg"
                }

                Item {
                    id: headerTopItem
                    anchors { left: parent.left; right: parent.right }
                    height: childrenRect.height

                    Rectangle {
                        id: profileImageContainer
                        anchors { left: parent.left; top: parent.top; margins: constant.paddingMedium }
                        width: profileImage.width + (border.width / 2); height: width
                        color: "black"
                        border.width: 2
                        border.color: profileImageMouseArea.pressed ? constant.colorTextSelection : constant.colorMid

                        Image {
                            id: profileImage
                            anchors.centerIn: parent
                            height: userNameText.height + screenNameText.height; width: height
                            cache: false
                            fillMode: Image.PreserveAspectCrop
                            source: userInfoData.profileImageUrl.replace("_normal", "_bigger")
                        }

                        MouseArea {
                            id: profileImageMouseArea
                            anchors.fill: parent
                            onClicked: {
                                var prop = { imageUrl: userInfoData.profileImageUrl.replace("_normal", "") }
                                pageStack.push(Qt.resolvedUrl("TweetImage.qml"), prop)
                            }
                        }
                    }

                    Text {
                        id: userNameText
                        anchors {
                            top: parent.top
                            left: profileImageContainer.right
                            right: parent.right
                            margins: constant.paddingMedium
                        }
                        font.bold: true
                        font.pixelSize: constant.fontSizeXLarge
                        color: "white"
                        style: Text.Outline
                        styleColor: "black"
                        text: userInfoData.userName
                    }

                    Text {
                        id: screenNameText
                        anchors {
                            top: userNameText.bottom
                            left: profileImageContainer.right; leftMargin: constant.paddingMedium
                            right: parent.right; rightMargin: constant.paddingMedium
                        }
                        font.pixelSize: constant.fontSizeLarge
                        color: "white"
                        style: Text.Outline
                        styleColor: "black"
                        text: userInfoData.screenName ? "@" + userInfoData.screenName : ""
                    }
                }

                Text {
                    id: descriptionText
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: headerTopItem.bottom
                        bottom: parent.bottom
                        margins: constant.paddingMedium
                    }
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    maximumLineCount: inPortrait ? 5 : 4 // TODO: remove hardcoded value
                    font.pixelSize: constant.fontSizeSmall
                    verticalAlignment: Text.AlignBottom
                    color: "white"
                    style: Text.Outline
                    styleColor: "black"
                }
            }

            Rectangle {
                anchors { left: parent.left; right: parent.right }
                height: 1
                color: constant.colorDisabled
            }

            Repeater {
                id: userInfoRepeater
                anchors { left: parent.left; right: parent.right }
                model: ListModel {}
                delegate: ListItem {
                    id: listItem
                    parent: userInfoRepeater
                    height: Math.max(listItemColumn.height + 2 * constant.paddingMedium, 80)
                    subItemIndicator: model.clickedString
                    enabled: (!subItemIndicator || title === "Website")
                             || !userInfoData.protectedUser
                             || userInfoData.following
                             || userPage.screenName === settings.userScreenName
                    onClicked: if (model.clickedString) eval(model.clickedString)
                    // TODO: Remove eval() if possible

                    Column {
                        id: listItemColumn
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            right: parent.right
                            margins: constant.paddingLarge
                            rightMargin: listItem.subItemIndicator ? constant.graphicSizeSmall + 2 * constant.paddingMedium
                                                                   : anchors.margins
                        }
                        height: childrenRect.height

                        Text {
                            id: titleText
                            anchors { left: parent.left; right: parent.right }
                            wrapMode: Text.Wrap
                            font.bold: true
                            font.pixelSize: constant.fontSizeMedium
                            color: listItem.enabled ? constant.colorLight : constant.colorDisabled
                            text: title
                        }
                        Text {
                            id: subTitleText
                            anchors { left: parent.left; right: parent.right }
                            visible: subtitle !== ""
                            wrapMode: Text.Wrap
                            font.pixelSize: constant.fontSizeMedium
                            color: listItem.enabled ? constant.colorMid : constant.colorDisabled
                            text: subtitle
                        }
                    }
                }
            }
        }
    }

    ScrollDecorator { flickableItem: userFlickable }

    QtObject {
        id: internal

        function refresh() {
            userInfoRepeater.model.clear()
            Twitter.getUserInfo(userPage.screenName, userInfoOnSuccess, userInfoOnFailure)
            loadingRect.visible = true
        }

        function userInfoOnSuccess(data) {
            if (userPage.screenName === settings.userScreenName) cache.userInfo = data
            userInfoRawData = data
            userInfoData.setData()
            if (data.description) descriptionText.text = data.description
            if (data.url) __addToUserInfo(qsTr("Website"), data.url, "dialog.createOpenLinkDialog(subtitle)")
            if (data.location) __addToUserInfo(qsTr("Location"), data.location)
            __addToUserInfo(qsTr("Joined"), Qt.formatDate(new Date(data.created_at), Qt.SystemLocaleShortDate))
            __addToUserInfo(qsTr("Tweets"), data.statuses_count + " | " + Calculate.tweetsFrequency(data.created_at,data.statuses_count),
                            "internal.pushUserPage(\"UserPageCom/UserTweetsPage.qml\")")
            __addToUserInfo(qsTr("Following"), data.friends_count,
                            "internal.pushUserPage(\"UserPageCom/UserFollowingPage.qml\")")
            __addToUserInfo(qsTr("Followers"), data.followers_count,
                            "internal.pushUserPage(\"UserPageCom/UserFollowersPage.qml\")")
            __addToUserInfo(qsTr("Favourites"), data.favourites_count,
                            "internal.pushUserPage(\"UserPageCom/UserFavouritesPage.qml\")")
            __addToUserInfo(qsTr("Subscribed List"), "",
                            "internal.pushUserPage(\"UserPageCom/UserSubscribedListsPage.qml\")")
            __addToUserInfo(qsTr("Listed"), data.listed_count,
                            "internal.pushUserPage(\"UserPageCom/UserListedPage.qml\")")
            loadingRect.visible = false
        }

        function __addToUserInfo(title, subtitle, clickedString) {
            var item = {
                title: title,
                subtitle: subtitle,
                clickedString: clickedString || ""
            }
            userInfoRepeater.model.append(item)
        }

        function userInfoOnFailure(status, statusText) {
            if (status === 404) infoBanner.showText(qsTr("The user %1 does not exist").arg("@" + userPage.screenName))
            else infoBanner.showHttpError(status, statusText)
            loadingRect.visible = false
        }

        function followOnSuccess(data, isFollowing) {
            userInfoData.following = isFollowing
            if (isFollowing) infoBanner.showText(qsTr("Followed the user %1 successfully").arg("@" + data.screen_name))
            else infoBanner.showText(qsTr("Unfollowed the user %1 successfully").arg("@" + data.screen_name))
            loadingRect.visible = false
        }

        function followOnFailure(status, statusText) {
            infoBanner.showHttpError(status, statusText)
            loadingRect.visible = false
        }

        function reportSpamOnSuccess(data) {
            infoBanner.showText(qsTr("Reported and blocked the user %1 successfully").arg("@" + data.screen_name))
            loadingRect.visible = false
        }

        function reportSpamOnFailure(status, statusText) {
            infoBanner.showHttpError(status, statusText)
            loadingRect.visible = false
        }

        function createReportSpamDialog() {
            var message = qsTr("Do you want to report and block the user %1 ?").arg("@" + screenName)
            dialog.createQueryDialog(qsTr("Report Spammer"), "", message, function() {
                Twitter.postReportSpam(screenName, reportSpamOnSuccess, reportSpamOnFailure)
                loadingRect.visible = true
            })
        }

        function createFollowUserDialog() {
            var title = userInfoData.following ? qsTr("Unfollow user") : qsTr("Follow user")
            var message = userInfoData.following ? qsTr("Do you want to unfollow the user %1 ?").arg("@" + screenName)
                                                 : qsTr("Do you want to follow the user %1 ?").arg("@" + screenName)
            dialog.createQueryDialog(title, "", message, function() {
                if (userInfoData.following)
                    Twitter.postUnfollow(screenName, followOnSuccess, followOnFailure)
                else
                    Twitter.postFollow(screenName, followOnSuccess, followOnFailure)
                loadingRect.visible = true
            })
        }

        function pushUserPage(pageString) {
            pageStack.push(Qt.resolvedUrl(pageString), { userInfoData: userInfoData })
        }
    }
}
