import QtQuick 1.1
import com.nokia.meego 1.0
import "twitter.js" as Twitter
import "Component"
import "Utils/Calculations.js" as Calculate

Page{
    id: userPage

    property string screenName
    property variant userInfoRawData

    QtObject{
        id: userInfoData

        property url profileImageUrl: ""
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
        ToolIcon{
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolIcon{
            platformIconId: "toolbar-send-email"
            enabled: screenName !== settings.userScreenName
            opacity: enabled ? 1 : 0.25
            onClicked: pageStack.push(Qt.resolvedUrl("NewTweetPage.qml"), {type: "New", placedText: "@"+screenName+" "})
        }
        ToolIcon{
            platformIconId: "toolbar-send-sms"
            enabled: screenName !== settings.userScreenName
            opacity: enabled ? 1 : 0.25
            onClicked: pageStack.push(Qt.resolvedUrl("NewTweetPage.qml"), {type: "DM", screenName: screenName})
        }
        ToolIcon{
            platformIconId: "toolbar-view-menu"
            onClicked: userPageMenu.open()
        }
    }

    Menu{
        id: userPageMenu

        MenuLayout{
            MenuItem{
                text: userInfoData.following ? "Unfollow @" + screenName : "Follow @" + screenName
                enabled: screenName !== settings.userScreenName
                onClicked: internal.createFollowUserDialog()
            }
            MenuItem{
                text: "Report user as spammer"
                enabled: screenName !== settings.userScreenName
                onClicked: internal.createReportSpamDialog()
            }
        }
    }

    AbstractListView{
        id: userPageListView
        anchors{ top: pageHeader.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
        model: ListModel{}
        clip: true
        delegate: ListItem{
            id: listItem
            subItemIndicator: (/(Website|Tweets|Following|Followers|Favourites|Subscribed Lists|Listed)/).test(title)
            enabled: (!subItemIndicator || title === "Website")
                     || !userInfoData.protectedUser
                     || userInfoData.following
                     || userPage.screenName === settings.userScreenName
            width: ListView.view.width
            height: Math.max(listItemColumn.height + 2 * constant.paddingMedium, 80)
            onClicked: {
                switch(title){
                case "Website": dialog.createOpenLinkDialog(subtitle); break;
                case "Tweets": internal.pushUserPage("UserPageCom/UserTweetsPage.qml"); break;
                case "Following": internal.pushUserPage("UserPageCom/UserFollowingPage.qml"); break;
                case "Followers": internal.pushUserPage("UserPageCom/UserFollowersPage.qml"); break;
                case "Favourites": internal.pushUserPage("UserPageCom/UserFavouritesPage.qml"); break;
                case "Subscribed Lists": internal.pushUserPage("UserPageCom/UserSubscribedListsPage.qml"); break;
                case "Listed": internal.pushUserPage("UserPageCom/UserListedPage.qml"); break;
                }
            }

            Column{
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

                Text{
                    id: titleText
                    text: title
                    width: parent.width
                    wrapMode: Text.Wrap
                    font.bold: true
                    font.pixelSize: constant.fontSizeMedium
                    color: listItem.enabled ? constant.colorLight : constant.colorDisabled
                }
                Text{
                    id: subTitleText
                    text: subtitle
                    visible: subtitle !== ""
                    width: parent.width
                    wrapMode: Text.Wrap
                    font.pixelSize: constant.fontSizeMedium
                    color: listItem.enabled ? constant.colorMid : constant.colorDisabled
                }
            }
        }
        onPullDownRefresh: internal.refresh()
    }

    ScrollDecorator{ flickableItem: userPageListView }

    LargePageHeader{
        id: pageHeader
        primaryText: userInfoData.userName
        secondaryText: userInfoData.screenName ? "@" + userInfoData.screenName : ""
        imageSource: userInfoData.profileImageUrl
        showProtectedIcon: userInfoData.protectedUser
        onClicked: userPageListView.positionViewAtBeginning()
    }

    QtObject{
        id: internal

        function refresh(){
            userPageListView.model.clear()
            Twitter.getUserInfo(userPage.screenName, userInfoOnSuccess, userInfoOnFailure)
            loadingRect.visible = true
        }

        function userInfoOnSuccess(data){
            if(userPage.screenName === settings.userScreenName) cache.userInfo = data
            userInfoRawData = data
            userInfoData.setData()
            if(data.description) userPageListView.model.append({"title": "Bio", "subtitle": data.description})
            if(data.url) userPageListView.model.append({"title": "Website", "subtitle": data.url})
            if(data.location) userPageListView.model.append({"title": "Location", "subtitle": data.location})
            userPageListView.model.append({"title": "Joined", "subtitle": Qt.formatDateTime(new Date(data.created_at), "d MMMM yyyy")})
            userPageListView.model.append({"title": "Tweets", "subtitle": data.statuses_count + " | " + Calculate.tweetsFrequency(data.created_at,data.statuses_count)})
            userPageListView.model.append({"title": "Following", "subtitle": data.friends_count})
            userPageListView.model.append({"title": "Followers", "subtitle": data.followers_count})
            userPageListView.model.append({"title": "Favourites", "subtitle": data.favourites_count})
            userPageListView.model.append({"title": "Subscribed Lists", "subtitle": ""})
            userPageListView.model.append({"title": "Listed", "subtitle": data.listed_count})
            loadingRect.visible = false
        }

        function userInfoOnFailure(status, statusText){
            if(status === 0) infoBanner.alert("Connection error.")
            else if(status === 404) infoBanner.alert("The user @" + userPage.screenName + " does not exist.")
            else infoBanner.alert("Error: " + status + " " + statusText)
            loadingRect.visible = false
        }

        function followOnSuccess(data, isFollowing){
            userInfoData.following = isFollowing
            if(isFollowing) infoBanner.alert("Followed the user @" + data.screen_name + ".")
            else infoBanner.alert("Unfollowed the user @" + data.screen_name + ".")
            loadingRect.visible = false
        }

        function followOnFailure(status, statusText){
            if(status === 0) infoBanner.alert("Connection error.")
            else infoBanner.alert("Error: " + status + " " + statusText)
            loadingRect.visible = false
        }

        function reportSpamOnSuccess(data){
            infoBanner.alert("Reported and blocked the user @" + data.screen_name +".")
            loadingRect.visible = false
        }

        function reportSpamOnFailure(status, statusText){
            if(status === 0) infoBanner.alert("Connection error.")
            else infoBanner.alert("Error: " + status + " " + statusText)
            loadingRect.visible = false
        }

        function createReportSpamDialog(){
            var message = "Do you want to report and block the user @"+ screenName + "?"
            dialog.createQueryDialog("Report Spammer", "", message, function(){
                Twitter.postReportSpam(screenName, reportSpamOnSuccess, reportSpamOnFailure)
                loadingRect.visible = true
            })
        }

        function createFollowUserDialog(){
            var title = userInfoData.following ? "Unfollow user" : "Follow user"
            var message = userInfoData.following ? "Do you want to unfollow the user @"+ screenName + "?"
                                                 : "Do you want to follow the user @"+ screenName + "?"
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
