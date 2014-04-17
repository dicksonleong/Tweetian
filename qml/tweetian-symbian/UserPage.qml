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
import "Services/Twitter.js" as Twitter
import "Component"
import "Utils/Calculations.js" as Calculate
import "Utils/Parser.js" as Parser

Page {
    id: userPage

    property string screenName
    property variant user: ({})
    property bool isFollowing: false

    // QQC 1.1.0 Compatibility
    property bool componentCompleted: false

    onScreenNameChanged: {
        if (!componentCompleted) return;

        if (user.hasOwnProperty("screenName"))
            internal.showUserData();
        else if (screenName === settings.userScreenName && cache.userInfo) {
            user = cache.userInfo;
            internal.showUserData();
        }
        else internal.refresh();
    }

    Component.onCompleted: {
        componentCompleted = true;
        if (!screenName) return;

        if (user.hasOwnProperty("screenName"))
            internal.showUserData();
        else if (screenName === settings.userScreenName && cache.userInfo) {
            user = cache.userInfo;
            internal.showUserData();
        }
        else internal.refresh();
    }

    tools: ToolBarLayout {
        ToolButtonWithTip {
            iconSource: "toolbar-back"
            toolTipText: qsTr("Back")
            onClicked: pageStack.pop()
        }
        ToolButtonWithTip {
            iconSource: platformInverted ? "Image/mail_inverse.svg" : "Image/mail.svg"
            enabled: screenName !== settings.userScreenName
            toolTipText: qsTr("Mentions")
            onClicked: pageStack.push(Qt.resolvedUrl("NewTweetPage.qml"), {type: "New", placedText: "@"+screenName+" "})
        }
        ToolButtonWithTip {
            iconSource: platformInverted ? "Image/create_message_inverse.svg" : "Image/create_message.svg"
            enabled: screenName !== settings.userScreenName
            toolTipText: qsTr("Direct Messages")
            onClicked: pageStack.push(Qt.resolvedUrl("NewTweetPage.qml"), {type: "DM", screenName: screenName})
        }
        ToolButtonWithTip {
            iconSource: "toolbar-refresh"
            enabled: !loadingRect.visible
            toolTipText: qsTr("Refresh")
            onClicked: internal.refresh()
        }
        ToolButtonWithTip {
            iconSource: "toolbar-menu"
            toolTipText: qsTr("Menu")
            onClicked: userPageMenu.open()
        }
    }

    Menu {
        id: userPageMenu
        platformInverted: settings.invertedTheme

        MenuLayout {
            MenuItem {
                text: isFollowing ? qsTr("Unfollow %1").arg("@" + screenName)
                                  : qsTr("Follow %1").arg("@" + screenName)
                enabled: screenName !== settings.userScreenName
                platformInverted: userPageMenu.platformInverted
                onClicked: internal.createFollowUserDialog()
            }
            MenuItem {
                text: qsTr("Block user")
                enabled: screenName !== settings.userScreenName
                platformInverted: userPageMenu.platformInverted
                onClicked: internal.createBlockUserDialog()
            }
            MenuItem {
                text: qsTr("Report user as spammer")
                enabled: screenName !== settings.userScreenName
                platformInverted: userPageMenu.platformInverted
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
                    maximumLineCount: inPortrait ? 4 : 3 // TODO: remove hardcoded value
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
                color: constant.colorMarginLine
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
                    height: Math.max(listItemColumn.height + 2 * constant.paddingLarge, implicitHeight)
                    subItemIndicator: model.clickedString
                    enabled: (!subItemIndicator || title === "Website")
                             || !user.isProtected
                             || isFollowing
                             || userPage.screenName === settings.userScreenName
                    platformInverted: settings.invertedTheme
                    onClicked: if (model.clickedString) eval(model.clickedString)
                    // TODO: Remove eval() if possible

                    Column {
                        id: listItemColumn
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.paddingItem.left
                            right: parent.paddingItem.right
                        }
                        height: childrenRect.height

                        ListItemText {
                            id: titleText
                            anchors { left: parent.left; right: parent.right }
                            mode: listItem.mode
                            role: "Title"
                            text: title
                            wrapMode: Text.Wrap
                            platformInverted: listItem.platformInverted
                        }
                        ListItemText {
                            id: subTitleText
                            anchors { left: parent.left; right: parent.right }
                            role: "SubTitle"
                            mode: listItem.mode
                            text: subtitle
                            visible: text !== ""
                            wrapMode: Text.Wrap
                            elide: Text.ElideNone
                            font.pixelSize: constant.fontSizeMedium
                            platformInverted: listItem.platformInverted
                        }
                    }
                }
            }
        }
    }

    ScrollDecorator { platformInverted: settings.invertedTheme; flickableItem: userFlickable }

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
