import QtQuick 1.1
import com.nokia.symbian 1.1
import "twitter.js" as Twitter
import "Component"
import "Utils/Calculations.js" as Calculate

Page{
    id: userPage

    property string screenName
    property variant userInfoRawData

    QtObject{
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

        function setData(){
            profileImageUrl = userInfoRawData.profile_image_url
            if(userInfoRawData.profile_banner_url) bannerImageUrl = userInfoRawData.profile_banner_url
            screenName = userInfoRawData.screen_name
            protectedUser = userInfoRawData.protected
            userName = userInfoRawData.name
            statusesCount = userInfoRawData.statuses_count
            friendsCount = userInfoRawData.friends_count
            followersCount = userInfoRawData.followers_count
            favouritesCount = userInfoRawData.favourites_count
            listedCount = userInfoRawData.listed_count
            if(userInfoRawData.following) following = userInfoRawData.following
            userInfoRawData = undefined
        }
    }

    onScreenNameChanged: {
        if(screenName === settings.userScreenName && cache.userInfo)
            internal.userInfoOnSuccess(cache.userInfo)
        else if(userInfoRawData) internal.userInfoOnSuccess(userInfoRawData)
        else internal.refresh()
    }

    tools: ToolBarLayout{
        ToolButtonWithTip{
            iconSource: "toolbar-back"
            toolTipText: qsTr("Back")
            onClicked: pageStack.pop()
        }
        ToolButtonWithTip{
            iconSource: platformInverted ? "Image/mail_inverse.svg" : "Image/mail.svg"
            enabled: screenName !== settings.userScreenName
            toolTipText: qsTr("Mentions")
            onClicked: pageStack.push(Qt.resolvedUrl("NewTweetPage.qml"), {type: "New", placedText: "@"+screenName+" "})
        }
        ToolButtonWithTip{
            iconSource: platformInverted ? "Image/create_message_inverse.svg" : "Image/create_message.svg"
            enabled: screenName !== settings.userScreenName
            toolTipText: qsTr("Direct Messages")
            onClicked: pageStack.push(Qt.resolvedUrl("NewTweetPage.qml"), {type: "DM", screenName: screenName})
        }
        ToolButtonWithTip{
            iconSource: "toolbar-refresh"
            enabled: !loadingRect.visible
            toolTipText: qsTr("Refresh")
            onClicked: internal.refresh()
        }
        ToolButtonWithTip{
            iconSource: "toolbar-menu"
            toolTipText: qsTr("Menu")
            onClicked: userPageMenu.open()
        }
    }

    Menu{
        id: userPageMenu
        platformInverted: settings.invertedTheme

        MenuLayout{
            MenuItem{
                text: userInfoData.following ? qsTr("Unfollow %1").arg("@" + screenName)
                                             : qsTr("Follow %1").arg("@" + screenName)
                enabled: screenName !== settings.userScreenName
                platformInverted: userPageMenu.platformInverted
                onClicked: internal.createFollowUserDialog()
            }
            MenuItem{
                text: qsTr("Report user as spammer")
                enabled: screenName !== settings.userScreenName
                platformInverted: userPageMenu.platformInverted
                onClicked: internal.createReportSpamDialog()
            }
        }
    }

    Flickable{
        id: userFlickable
        anchors.fill: parent
        flickableDirection: Flickable.VerticalFlick
        contentHeight: userColumn.height

        Column{
            id: userColumn
            anchors{ left: parent.left; right: parent.right }

            Item{
                id: headerItem
                anchors{ left: parent.left; right: parent.right }
                height: inPortrait ? width / 2 : width / 4

                Image{
                    id: headerImage
                    anchors.fill: parent
                    cache: false
                    fillMode: Image.PreserveAspectCrop
                    clip: true
                    source: {
                        if(userInfoData.bannerImageUrl)
                            return userInfoData.bannerImageUrl.concat(inPortrait ? "/web" : "/mobile_retina")
                        else
                            return "Image/banner_empty.jpg"
                    }

                    onStatusChanged: if(status === Image.Error) source = "Image/banner_empty.jpg"
                }

                Item{
                    id: headerTopItem
                    anchors{ left: parent.left; right: parent.right }
                    height: childrenRect.height

                    Rectangle{
                        id: profileImageContainer
                        anchors{ left: parent.left; top: parent.top; margins: constant.paddingMedium }
                        width: profileImage.width + (border.width / 2); height: width
                        color: "black"
                        border.width: 2
                        border.color: profileImageMouseArea.pressed ? constant.colorTextSelection : constant.colorMid

                        Image{
                            id: profileImage
                            anchors.centerIn: parent
                            height: userNameText.height + screenNameText.height; width: height
                            cache: false
                            fillMode: Image.PreserveAspectCrop
                            source: userInfoData.profileImageUrl.replace("_normal", "_bigger")
                        }

                        MouseArea{
                            id: profileImageMouseArea
                            anchors.fill: parent
                            onClicked: {
                                var prop = { imageUrl: userInfoData.profileImageUrl.replace("_normal", "") }
                                pageStack.push(Qt.resolvedUrl("TweetImage.qml"), prop)
                            }
                        }
                    }

                    Text{
                        id: userNameText
                        anchors{
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

                    Text{
                        id: screenNameText
                        anchors{
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

                Text{
                    id: descriptionText
                    anchors{
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
                }
            }

            Rectangle{
                anchors{ left: parent.left; right: parent.right }
                height: 1
                color: constant.colorMarginLine
            }

            Repeater{
                id: userInfoRepeater
                width: parent.width
                model: ListModel{}
                delegate: ListItem{
                    id: listItem
                    height: Math.max(listItemColumn.height + 2 * constant.paddingMedium, implicitHeight)
                    subItemIndicator: model.clickedString
                    enabled: (!subItemIndicator || title === "Website")
                             || !userInfoData.protectedUser
                             || userInfoData.following
                             || userPage.screenName === settings.userScreenName
                    onClicked: if(model.clickedString) eval(model.clickedString)
                    // TODO: Remove eval() if possible

                    Column{
                        id: listItemColumn
                        anchors{
                            verticalCenter: parent.verticalCenter
                            left: parent.paddingItem.left
                            right: parent.paddingItem.right
                        }
                        height: childrenRect.height

                        ListItemText{
                            id: titleText
                            width: parent.width
                            mode: listItem.mode
                            role: "Title"
                            text: title
                            wrapMode: Text.Wrap
                            platformInverted: listItem.platformInverted
                        }
                        ListItemText{
                            id: subTitleText
                            width: parent.width
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

    ScrollDecorator{ platformInverted: settings.invertedTheme; flickableItem: userFlickable }

    QtObject{
        id: internal

        function refresh(){
            userInfoRepeater.model.clear()
            Twitter.getUserInfo(userPage.screenName, userInfoOnSuccess, userInfoOnFailure)
            loadingRect.visible = true
        }

        function userInfoOnSuccess(data){
            if(userPage.screenName === settings.userScreenName) cache.userInfo = data
            userInfoRawData = data
            userInfoData.setData()
            if(data.description) descriptionText.text = data.description
            if(data.url) __addToUserInfo(qsTr("Website"), data.url, "dialog.createOpenLinkDialog(subtitle)")
            if(data.location) __addToUserInfo(qsTr("Location"), data.location)
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

        function __addToUserInfo(title, subtitle, clickedString){
            var item = {
                title: title,
                subtitle: subtitle,
                clickedString: clickedString || ""
            }
            userInfoRepeater.model.append(item)
        }

        function userInfoOnFailure(status, statusText){
            if(status === 404) infoBanner.alert(qsTr("The user %1 does not exist").arg("@" + userPage.screenName))
            else infoBanner.showHttpError(status, statusText)
            loadingRect.visible = false
        }

        function followOnSuccess(data, isFollowing){
            userInfoData.following = isFollowing
            if(isFollowing) infoBanner.alert(qsTr("Followed the user %1 successfully").arg("@" + data.screen_name))
            else infoBanner.alert(qsTr("Unfollowed the user %1 successfully").arg("@" + data.screen_name))
            loadingRect.visible = false
        }

        function followOnFailure(status, statusText){
            infoBanner.showHttpError(status, statusText)
            loadingRect.visible = false
        }

        function reportSpamOnSuccess(data){
            infoBanner.alert(qsTr("Reported and blocked the user %1 successfully").arg("@" + data.screen_name))
            loadingRect.visible = false
        }

        function reportSpamOnFailure(status, statusText){
            infoBanner.showHttpError(status, statusText)
            loadingRect.visible = false
        }

        function createReportSpamDialog(){
            var message = qsTr("Do you want to report and block the user %1 ?").arg("@" + screenName)
            dialog.createQueryDialog(qsTr("Report Spammer"), "", message, function(){
                Twitter.postReportSpam(screenName, reportSpamOnSuccess, reportSpamOnFailure)
                loadingRect.visible = true
            })
        }

        function createFollowUserDialog(){
            var title = userInfoData.following ? qsTr("Unfollow user") : qsTr("Follow user")
            var message = userInfoData.following ? qsTr("Do you want to unfollow the user %1 ?").arg("@" + screenName)
                                                 : qsTr("Do you want to follow the user %1 ?").arg("@" + screenName)
            dialog.createQueryDialog(title, "", message, function(){
                if(userInfoData.following)
                    Twitter.postUnfollow(screenName, followOnSuccess, followOnFailure)
                else
                    Twitter.postFollow(screenName, followOnSuccess, followOnFailure)
                loadingRect.visible = true
            })
        }

        function pushUserPage(pageString){
            pageStack.push(Qt.resolvedUrl(pageString), { userInfoData: userInfoData })
        }
    }
}
