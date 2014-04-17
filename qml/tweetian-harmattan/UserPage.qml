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
import "Utils/Parser.js" as Parser

Page {
    id: userPage

    property string screenName
    property variant user: ({})
    property bool isFollowing: false

    Component.onCompleted: {
        if (user.hasOwnProperty("screenName"))
            internal.showUserData();
        else if (screenName === settings.userScreenName && cache.userInfo) {
            user = cache.userInfo;
            internal.showUserData();
        }
        else internal.refresh();
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
                text: isFollowing ? qsTr("Unfollow %1").arg("@" + screenName)
                                  : qsTr("Follow %1").arg("@" + screenName)
                enabled: screenName !== settings.userScreenName
                onClicked: internal.createFollowUserDialog()
            }
            MenuItem {
                text: qsTr("Block user")
                enabled: screenName !== settings.userScreenName
                onClicked: internal.createBlockUserDialog();
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
                        if (user.profileBannerUrl)
                            return user.profileBannerUrl.concat(inPortrait ? "/web" : "/mobile_retina")
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
                            source: user.profileImageUrl ? user.profileImageUrl.replace("_normal", "_bigger") : ""
                        }

                        MouseArea {
                            id: profileImageMouseArea
                            anchors.fill: parent
                            onClicked: {
                                var prop = { imageUrl: user.profileImageUrl.replace("_normal", "") }
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
                        text: user.name || ""
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
                        text: user.screenName ? "@" + user.screenName : ""
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
                    text: user.description || ""
                }
            }

            Rectangle {
                anchors { left: parent.left; right: parent.right }
                height: 1
                color: constant.colorDisabled
            }

            Repeater {
                id: userInfoRepeater

                function append(title, subtitle, clickedString) {
                    var item = {
                        title: title,
                        subtitle: subtitle,
                        clickedString: clickedString || ""
                    }
                    model.append(item)
                }

                anchors { left: parent.left; right: parent.right }
                model: ListModel {}
                delegate: ListItem {
                    id: listItem
                    parent: userInfoRepeater
                    height: Math.max(listItemColumn.height + 2 * constant.paddingLarge, 80)
                    subItemIndicator: model.clickedString
                    enabled: (!subItemIndicator || title === "Website")
                             || !user.isProtected
                             || isFollowing
                             || userPage.screenName === settings.userScreenName
                    onClicked: if (model.clickedString) eval(model.clickedString)
                    // TODO: Remove eval() if possible

                    Column {
                        id: listItemColumn
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left; leftMargin: constant.paddingLarge
                            right: parent.right
                            rightMargin: listItem.listItemRightMargin + constant.paddingMedium
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

        function showUserData() {
            if (user.url) userInfoRepeater.append(qsTr("Website"), user.url, "dialog.createOpenLinkDialog(subtitle)")
            if (user.location) userInfoRepeater.append(qsTr("Location"), user.location)
            userInfoRepeater.append(qsTr("Joined"), Qt.formatDate(new Date(user.createdAt), Qt.SystemLocaleShortDate))
            userInfoRepeater.append(qsTr("Tweets"), user.tweetsCount + " | " +
                                    Calculate.tweetsFrequency(user.createdAt, user.tweetsCount),
                                    "internal.pushUserPage(\"UserPageCom/UserTweetsPage.qml\")")
            userInfoRepeater.append(qsTr("Following"), user.followingCount,
                                    "internal.pushUserPage(\"UserPageCom/UserFollowingPage.qml\")")
            userInfoRepeater.append(qsTr("Followers"), user.followersCount,
                                    "internal.pushUserPage(\"UserPageCom/UserFollowersPage.qml\")")
            userInfoRepeater.append(qsTr("Favourites"), user.favouritesCount,
                                    "internal.pushUserPage(\"UserPageCom/UserFavouritesPage.qml\")")
            userInfoRepeater.append(qsTr("Subscribed List"), "",
                                    "internal.pushUserPage(\"UserPageCom/UserSubscribedListsPage.qml\")")
            userInfoRepeater.append(qsTr("Listed"), user.listedCount,
                                    "internal.pushUserPage(\"UserPageCom/UserListedPage.qml\")")
            isFollowing = user.isFollowing;
        }

        function userInfoOnSuccess(data) {
            user = Parser.parseUser(data);
            if (userPage.screenName === settings.userScreenName)
                cache.userInfo = user;
            showUserData();
            loadingRect.visible = false
        }

        function userInfoOnFailure(status, statusText) {
            if (status === 404) infoBanner.showText(qsTr("The user %1 does not exist").arg("@" + userPage.screenName))
            else infoBanner.showHttpError(status, statusText)
            loadingRect.visible = false
        }

        function followOnSuccess(data, following) {
            isFollowing = following;
            if (isFollowing) infoBanner.showText(qsTr("Followed the user %1 successfully").arg("@" + data.screen_name))
            else infoBanner.showText(qsTr("Unfollowed the user %1 successfully").arg("@" + data.screen_name))
            loadingRect.visible = false
        }

        function followOnFailure(status, statusText) {
            infoBanner.showHttpError(status, statusText)
            loadingRect.visible = false
        }

        function reportBlockOnSuccess(data) {
            infoBanner.showText(qsTr("Blocked %1").arg("@" + data.screen_name))
            loadingRect.visible = false
        }

        function createBlockUserDialog() {
            var message = qsTr("Do you want to block %1?").arg("@" + screenName)
            dialog.createQueryDialog(qsTr("Block User"), "", message, function() {
                Twitter.postBlockUser(screenName, reportBlockOnSuccess, reportSpamOnFailure)
                loadingRect.visible = true
            })
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
            var message = qsTr("Do you want to report and block the user %1?").arg("@" + screenName)
            dialog.createQueryDialog(qsTr("Report Spammer"), "", message, function() {
                Twitter.postReportSpam(screenName, reportSpamOnSuccess, reportSpamOnFailure)
                loadingRect.visible = true
            })
        }

        function createFollowUserDialog() {
            var title = isFollowing ? qsTr("Unfollow user") : qsTr("Follow user")
            var message = isFollowing ? qsTr("Do you want to unfollow the user %1?").arg("@" + screenName)
                                                 : qsTr("Do you want to follow the user %1?").arg("@" + screenName)
            dialog.createQueryDialog(title, "", message, function() {
                if (isFollowing)
                    Twitter.postUnfollow(screenName, followOnSuccess, followOnFailure)
                else
                    Twitter.postFollow(screenName, followOnSuccess, followOnFailure)
                loadingRect.visible = true
            })
        }

        function pushUserPage(pageString) {
            pageStack.push(Qt.resolvedUrl(pageString), { user: user })
        }
    }
}
