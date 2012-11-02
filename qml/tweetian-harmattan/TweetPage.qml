import QtQuick 1.1
import com.nokia.meego 1.0
import "twitter.js" as Twitter
import "Component"
import "Delegate"
import "Services/Translation.js" as Translate
import "Services/Flickr.js" as Flickr
import "Services/Pocket.js" as Pocket
import "Services/Instapaper.js" as Instapaper
import "Services/TwitLonger.js" as TwitLonger
import "Services/NokiaMaps.js" as Maps
import "Services/Youtube.js" as YouTube
import "TweetPageJS.js" as JS

Page{
    id: tweetPage

    property variant currentTweet: {
                "createdAt": "",
                "displayScreenName": "",
                "displayTweetText": "",
                "favourited": false,
                "inReplyToScreenName": "",
                "inReplyToStatusId": "",
                "latitude": "",
                "longitude": "",
                "mediaExpandedUrl": "",
                "mediaViewUrl": "",
                "mediaThumbnail": "",
                "profileImageUrl": "",
                "retweetId": "",
                "screenName": "",
                "source": "",
                "tweetId": "",
                "tweetText": "",
                "userName": ""
    }
    property bool favouritedTweet: false

    property ListModel ancestorModel: ListModel{}
    property ListModel descendantModel: ListModel{}

    Component.onCompleted: {
        favouritedTweet = currentTweet.favourited
        // Process image thumbnail
        if(currentTweet.mediaViewUrl){
            if(currentTweet.mediaViewUrl == "flickr"){
                Flickr.getSizes(currentTweet.mediaExpandedUrl.substring(17), function(full, thumb){
                                    thumbnailModel.append({"type": "image", "thumb": thumb,"full": full, "link": currentTweet.mediaExpandedUrl})
                                })
            }
            else thumbnailModel.append({"type": "image", "thumb": currentTweet.mediaThumbnail,"full": currentTweet.mediaViewUrl,
                                           "link": currentTweet.mediaExpandedUrl})
        }
        // Process location thumbnail
        if(currentTweet.latitude && currentTweet.longitude){
            var thumbnailURL = Maps.getMaps(currentTweet.latitude, currentTweet.longitude, constant.graphicSizeXXLarge, constant.graphicSizeXXLarge)
            thumbnailModel.append({"type": "map", "thumb": thumbnailURL, "full": "", "link": ""})
        }
        // Process Youtube thumbnail
        var youtubeLink = currentTweet.displayTweetText.match(/https?:\/\/(youtu.be\/[\w-]{11,}|www.youtube.com\/watch\?[\w-=&]{11,})/)
        if(youtubeLink != null){
            YouTube.getVideoThumbnailAndLink(JS.getYouTubeVideoId(youtubeLink[0]), function(thumb, rstpLink){
                                          thumbnailModel.append({type: "video", thumb: thumb, full: "", link: rstpLink})
                                      })
        }
        // Load conversation
        if(currentTweet.inReplyToStatusId){
            backButton.enabled = false
            header.busy = true
            conversationParser.sendMessage({'ancestorModel': ancestorModel, 'descendantModel': descendantModel,
                                               'timelineModel': mainPage.timeline.model,
                                               'mentionsModel': mainPage.mentions.model,
                                               'inReplyToStatusId': currentTweet.inReplyToStatusId})
        }
        // check for TwitLonger
        var twitLongerLink = currentTweet.displayTweetText.match(/http:\/\/tl.gd\/\w+/)
        if(twitLongerLink != null){
            TwitLonger.getFullTweet(twitLongerLink[0], JS.getTwitLongerTextOnSuccess, JS.commonOnFailure)
            header.busy = true
        }

    }

    tools: ToolBarLayout{
        ToolIcon{
            id: backButton
            platformIconId: "toolbar-back" + (enabled ? "" : "-dimmed")
            onClicked: pageStack.pop()
        }
        ToolIcon{
            id: replyButton
            platformIconId: "toolbar-reply"
            onClicked: {
                var prop = {
                    type: "Reply",
                    placedText: JS.getAllMentions(currentTweet.displayTweetText)
                                + JS.getAllHashtags(currentTweet.displayTweetText),
                    tweetId: currentTweet.tweetId
                }
                pageStack.push(Qt.resolvedUrl("NewTweetPage.qml"), prop)
            }
        }
        ToolIcon{
            iconSource: settings.invertedTheme ? "Image/retweet_inverse.png" : "Image/retweet.png"
            onClicked: {
                var text
                if(currentTweet.retweetId === currentTweet.tweetId)
                    text = "RT @"+currentTweet.screenName + ": " + currentTweet.tweetText
                else
                    text = "RT @"+currentTweet.screenName+": RT @"+currentTweet.displayScreenName+": "+currentTweet.tweetText
                pageStack.push(Qt.resolvedUrl("NewTweetPage.qml"), {type: "RT", placedText: text, tweetId: currentTweet.retweetId})
            }
        }
        ToolIcon{
            platformIconId: favouritedTweet ? "toolbar-favorite-unmark" : "toolbar-favorite-mark"
            onClicked: {
                if(favouritedTweet) Twitter.postUnfavourite(currentTweet.tweetId, JS.favouriteOnSuccess, JS.commonOnFailure)
                else Twitter.postFavourite(currentTweet.tweetId, JS.favouriteOnSuccess, JS.commonOnFailure)
                header.busy = true
            }
        }
        ToolIcon{
            platformIconId: "toolbar-view-menu"
            onClicked: tweetMenu.open()
        }
    }

    Menu{
        id: tweetMenu

        MenuLayout{
            MenuItem{
                text: "Copy tweet"
                onClicked: {
                    clipboard.setText("@" + currentTweet.screenName + ": " + currentTweet.tweetText)
                    infoBanner.alert("Tweet copied to clipboard.")
                }
            }
            MenuItem{
                text: translatedTweetLoader.sourceComponent ? "Hide translated tweet" : "Translate tweet"
                onClicked: {
                    if(translatedTweetLoader.sourceComponent) translatedTweetLoader.sourceComponent = undefined
                    else if(cache.translationToken && JS.checkExpire(cache.translationToken)){
                        Translate.translate(cache.translationToken, currentTweet.tweetText, JS.translateOnSuccess, JS.translateOnFailure)
                        header.busy = true
                    }
                    else{
                        Translate.requestToken(JS.translateTokenOnSuccess, JS.translateOnFailure)
                        header.busy = true
                    }
                }
            }
            MenuItem{
                text: "Tweet permalink"
                onClicked: {
                    var permalink = "http://twitter.com/" + currentTweet.screenName + "/status/" + currentTweet.tweetId
                    dialog.createOpenLinkDialog(permalink)
                }
                platformStyle: MenuItemStyle{ position: deleteTweetButton.visible ? "vertical-center" : "vertical-bottom" }
            }
            MenuItem{
                id: deleteTweetButton
                text: "Delete tweet"
                visible: currentTweet.screenName === settings.userScreenName
                onClicked: JS.createDeleteTweetDialog()
            }
        }
    }

    Flickable{
        id: tweetPageFlickable
        anchors{ top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        contentHeight: mainColumn.height

        Column{
            id: mainColumn
            width: parent.width
            height: childrenRect.height

            Column{
                id: ancestorColumn
                width: parent.width
                height: childrenRect.height

                Repeater{
                    id: ancestorRepeater

                    TweetDelegate{ width: ancestorColumn.width }
                }
            }

            Loader{ sourceComponent: ancestorRepeater.count > 0 ? inReplyToHeading : undefined }

            Column{
                id: mainTweetColumn
                height: childrenRect.height + constant.paddingMedium
                width: parent.width
                spacing: constant.paddingMedium

                ListItem{
                    id: userItem
                    height: usernameColumn.height + 2 * usernameColumn.anchors.margins
                    width: parent.width
                    subItemIndicator: true
                    imageAnchorAtCenter: true
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("UserPage.qml"), {screenName: currentTweet.displayScreenName})
                    }
                    Component.onCompleted: {
                        imageSource = thumbnailCacher.get(currentTweet.profileImageUrl)
                                || (networkMonitor.online ? currentTweet.profileImageUrl : constant.twitterBirdIcon)
                    }

                    Column{
                        id: usernameColumn
                        anchors.left: userItem.imageItem.right
                        anchors.top: parent.top
                        anchors.margins: constant.paddingMedium
                        height: childrenRect.height

                        Text{
                            text: currentTweet.userName
                            font.pixelSize: constant.fontSizeMedium
                            color: constant.colorLight
                            font.bold: true
                        }

                        Text{
                            text: "@" + currentTweet.displayScreenName
                            font.pixelSize: constant.fontSizeSmall
                            color: userItem.highlighted ? constant.colorHighlighted : constant.colorMid
                        }
                    }
                }

                Text{
                    id: tweetTextText
                    font.pixelSize: settings.largeFontSize ? constant.fontSizeXLarge : constant.fontSizeLarge
                    color: constant.colorLight
                    textFormat: Text.RichText
                    width: parent.width
                    wrapMode: Text.Wrap
                    text: currentTweet.displayTweetText
                    onLinkActivated: {
                        basicHapticEffect.play()
                        if(link.indexOf("@") === 0)
                            pageStack.push(Qt.resolvedUrl("UserPage.qml"), {screenName: link.substring(1)})
                        else if(link.indexOf("#") === 0)
                            pageStack.push(Qt.resolvedUrl("SearchPage.qml"), {searchName: link})
                        else if(link.indexOf("http") === 0)
                            dialog.createOpenLinkDialog(link, JS.addToPocket, JS.addToInstapaper)
                    }
                }

                Text{
                    width: parent.width
                    font.pixelSize: settings.largeFontSize ? constant.fontSizeLarge : constant.fontSizeMedium
                    color: constant.colorMid
                    text: "Retweeted by @" + currentTweet.screenName
                    visible: currentTweet.retweetId !== currentTweet.tweetId
                }

                Item{
                    height: timeAndSourceText.height
                    width: parent.width

                    Loader{
                        id: iconLoader
                        anchors.left: parent.left
                        width: sourceComponent ? item.sourceSize.width : 0
                        sourceComponent: favouritedTweet ? favouriteIcon : undefined

                        Component{
                            id: favouriteIcon

                            Image{
                                source: settings.invertedTheme ? "image://theme/icon-m-common-favorite-mark"
                                                               : "image://theme/icon-m-common-favorite-mark-inverse"
                                sourceSize.height: timeAndSourceText.height
                                sourceSize.width: timeAndSourceText.height
                            }
                        }
                    }

                    Text{
                        id: timeAndSourceText
                        anchors { left: iconLoader.right; leftMargin: constant.paddingSmall; right: parent.right }
                        font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
                        horizontalAlignment: Text.AlignRight
                        color: constant.colorMid
                        text: currentTweet.source + " | " + Qt.formatDateTime(currentTweet.createdAt, "h:mm AP d MMM yy")
                        elide: Text.ElideRight
                    }
                }

                Row{
                    id: thumbnailRow
                    height: childrenRect.height
                    width: parent.width
                    spacing: constant.paddingMedium

                    Repeater{
                        model: ListModel{ id: thumbnailModel }

                        ThumbnailItem{
                            imageSource: model.thumb
                            iconSource: {
                                if(model.type === "image")
                                    return settings.invertedTheme ? "Image/photos_inverse.svg" : "Image/photos.svg"
                                else if(model.type === "map")
                                    return settings.invertedTheme ? "Image/location_mark_inverse.svg" : "Image/location_mark.svg"
                                else
                                    return settings.invertedTheme ? "Image/video_inverse.svg" : "Image/video.svg"
                            }
                            onClicked: {
                                if(model.type === "image")
                                    pageStack.push(Qt.resolvedUrl("TweetImage.qml"), {"imageLink": model.link,"imageUrl": model.full})
                                else if(model.type === "map")
                                    pageStack.push(Qt.resolvedUrl("MapPage.qml"), {latitude: currentTweet.latitude, longitude: currentTweet.longitude})
                                else {
                                    if(model.link){
                                        var success = Qt.openUrlExternally(model.link)
                                        if(!success) infoBanner.alert("Error opening link: " + model.link)
                                    }
                                    else infoBanner.alert("Streaming link is not available.")
                                }
                            }
                        }
                    }
                }
            }

            Loader{ id: translatedTweetLoader; height: sourceComponent ? undefined : 0 }

            Loader{ sourceComponent: descendantRepeater.count > 0 ? replyHeading : undefined }

            Column{
                id: descendantColumn
                width: parent.width
                height: childrenRect.height

                Repeater{
                    id: descendantRepeater

                    TweetDelegate{ width: descendantColumn.width }
                }
            }
        }
    }

    ScrollDecorator{ flickableItem: tweetPageFlickable }

    PageHeader{
        id: header
        headerIcon: "Image/chat.png"
        headerText: "Tweet"
        onClicked: tweetPageFlickable.contentY = 0
    }

    WorkerScript{
        id: conversationParser
        source: "WorkerScript/ConversationParser.js"
        onMessage: {
            backButton.enabled = true
            if(messageObject.action === "callAPI"){
                ancestorRepeater.model = ancestorModel
                descendantRepeater.model = descendantModel
                if(networkMonitor.online){
                    Twitter.getConversation(currentTweet.tweetId, JS.conversationOnSuccess, JS.conversationOnFailure)
                    header.busy = true
                }
            }
            else header.busy = false
        }
    }

    Component{
        id: inReplyToHeading

        SectionHeader{
            width: mainColumn.width
            text: "In-reply-to ↑"
        }
    }

    Component{
        id: replyHeading

        SectionHeader{
            width: mainColumn.width
            text: "Reply ↓"
        }
    }

    Component{
        id: translatedTweet
        Item{
            id: root
            width: mainColumn.width
            height: childrenRect.height + constant.paddingMedium
            property string text

            SectionHeader{
                id: translateHeader
                text: "Translated Tweet"
            }

            Text{
                anchors { left: parent.left; right: parent.right; top: translateHeader.bottom; margins: constant.paddingMedium }
                font.pixelSize: constant.fontSizeLarge
                color: constant.colorLight
                text: root.text
                wrapMode: Text.Wrap
            }
        }
    }
}
