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
import "Delegate"
import "Services/Translation.js" as Translation
import "Services/Flickr.js" as Flickr
import "Services/Pocket.js" as Pocket
import "Services/Instapaper.js" as Instapaper
import "Services/TwitLonger.js" as TwitLonger
import "Services/NokiaMaps.js" as Maps
import "Services/Youtube.js" as YouTube
import "TweetPageJS.js" as JS

Page {
    id: tweetPage

    property variant tweet
    property bool favouritedTweet: false

    property ListModel ancestorModel: ListModel {}
    property ListModel descendantModel: ListModel {}

    Component.onCompleted: {
        favouritedTweet = tweet.isFavourited
        JS.createPicThumb()
        JS.createMapThumb()
        if (networkMonitor.online) {
            JS.createYoutubeThumb()
            JS.expandTwitLonger()
        }
        JS.getConversationFromTimelineAndMentions()
    }

    tools: ToolBarLayout {
        ToolIcon {
            id: backButton
            platformIconId: "toolbar-back" + (enabled ? "" : "-dimmed")
            onClicked: pageStack.pop()
        }
        ToolIcon {
            id: replyButton
            platformIconId: "toolbar-reply"
            onClicked: {
                var prop = { type: "Reply", placedText: JS.contructReplyText(), tweetId: tweet.id }
                pageStack.push(Qt.resolvedUrl("NewTweetPage.qml"), prop)
            }
        }
        ToolIcon {
            iconSource: settings.invertedTheme ? "Image/retweet_inverse.png" : "Image/retweet.png"
            onClicked: {
                var prop = { type: "RT", placedText: JS.contructRetweetText(), tweetId: tweet.id }
                pageStack.push(Qt.resolvedUrl("NewTweetPage.qml"), prop)
            }
        }
        ToolIcon {
            platformIconId: favouritedTweet ? "toolbar-favorite-unmark" : "toolbar-favorite-mark"
            onClicked: {
                if (favouritedTweet)
                    Twitter.postUnfavourite(tweet.id, JS.favouriteOnSuccess, JS.commonOnFailure)
                else Twitter.postFavourite(tweet.id, JS.favouriteOnSuccess, JS.commonOnFailure)
                header.busy = true
            }
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            onClicked: tweetMenu.open()
        }
    }

    Menu {
        id: tweetMenu

        MenuLayout {
            MenuItem {
                text: qsTr("Copy tweet")
                onClicked: {
                    QMLUtils.copyToClipboard("@" + tweet.screenName + ": " + tweet.plainText)
                    infoBanner.showText(qsTr("Tweet copied to clipboard"))
                }
            }
            MenuItem {
                text: translatedTweetLoader.sourceComponent ? qsTr("Hide translated tweet") : qsTr("Translate tweet")
                onClicked: {
                    if (translatedTweetLoader.sourceComponent) translatedTweetLoader.sourceComponent = undefined
                    else if (cache.isTranslationTokenValid()) {
                        Translation.translate(constant, cache.translationToken, tweet.plainText,
                                              settings.translateLangCode, JS.translateOnSuccess, JS.commonOnFailure)
                        header.busy = true
                    }
                    else {
                        Translation.requestToken(constant, JS.translateTokenOnSuccess, JS.commonOnFailure)
                        header.busy = true
                    }
                }
            }
            MenuItem {
                text: qsTr("Tweet permalink")
                onClicked: {
                    var permalink = "http://twitter.com/" + tweet.retweetScreenName + "/status/" + tweet.id
                    dialog.createOpenLinkDialog(permalink)
                }
                platformStyle: MenuItemStyle { position: deleteTweetButton.visible ? "vertical-center" : "vertical-bottom" }
            }
            MenuItem {
                id: deleteTweetButton
                text: qsTr("Delete tweet")
                visible: tweet.retweetScreenName === settings.userScreenName
                onClicked: JS.createDeleteTweetDialog()
            }
        }
    }

    Flickable {
        id: tweetPageFlickable
        anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        contentHeight: mainColumn.height

        Column {
            id: mainColumn
            anchors { left: parent.left; right: parent.right }
            height: childrenRect.height

            Column {
                id: ancestorColumn
                anchors { left: parent.left; right: parent.right }
                height: childrenRect.height

                Repeater { id: ancestorRepeater; TweetDelegate { width: ancestorColumn.width } }
            }

            Loader { sourceComponent: ancestorRepeater.count > 0 ? inReplyToHeading : undefined }

            Column {
                id: mainTweetColumn
                anchors { left: parent.left; right: parent.right }
                height: childrenRect.height + constant.paddingMedium
                spacing: constant.paddingMedium

                ListItem {
                    id: userItem
                    anchors { left: parent.left; right: parent.right }
                    height: usernameColumn.height + 2 * usernameColumn.anchors.margins
                    subItemIndicator: true
                    onClicked: pageStack.push(Qt.resolvedUrl("UserPage.qml"), {screenName: tweet.screenName})
                    Component.onCompleted: {
                        imageSource = thumbnailCacher.get(tweet.profileImageUrl)
                                || (networkMonitor.online ? tweet.profileImageUrl : constant.twitterBirdIcon)
                    }

                    Column {
                        id: usernameColumn
                        anchors { top: parent.top; left: userItem.imageItem.right; margins: constant.paddingMedium }
                        height: childrenRect.height

                        Text {
                            font.pixelSize: constant.fontSizeMedium
                            color: constant.colorLight
                            font.bold: true
                            text: tweet.name
                        }

                        Text {
                            font.pixelSize: constant.fontSizeSmall
                            color: userItem.highlighted ? constant.colorHighlighted : constant.colorMid
                            text: "@" + tweet.screenName
                        }
                    }
                }

                Text {
                    id: tweetTextText
                    anchors { left: parent.left; right: parent.right }
                    font.pixelSize: settings.largeFontSize ? constant.fontSizeXLarge : constant.fontSizeLarge
                    color: constant.colorLight
                    textFormat: Text.RichText
                    wrapMode: Text.Wrap
                    text: tweet.richText
                    onLinkActivated: {
                        basicHapticEffect.play()
                        if (link.indexOf("@") === 0)
                            pageStack.push(Qt.resolvedUrl("UserPage.qml"), {screenName: link.substring(1)})
                        else if (link.indexOf("http") === 0)
                            dialog.createOpenLinkDialog(link, JS.addToPocket, JS.addToInstapaper)
                        else
                            pageStack.push(Qt.resolvedUrl("SearchPage.qml"), {searchString: link})
                    }
                }

                Text {
                    anchors { left: parent.left; right: parent.right }
                    visible: tweet.isRetweet
                    font.pixelSize: settings.largeFontSize ? constant.fontSizeLarge : constant.fontSizeMedium
                    color: constant.colorMid
                    text: qsTr("Retweeted by %1").arg("@" + tweet.retweetScreenName)
                }

                Item {
                    anchors { left: parent.left; right: parent.right }
                    height: timeAndSourceText.height

                    Loader {
                        id: iconLoader
                        anchors.left: parent.left
                        width: sourceComponent ? item.sourceSize.width : 0
                        sourceComponent: favouritedTweet ? favouriteIcon : undefined

                        Component {
                            id: favouriteIcon

                            Image {
                                sourceSize { height: timeAndSourceText.height; width: timeAndSourceText.height }
                                source: settings.invertedTheme ? "image://theme/icon-m-common-favorite-mark"
                                                               : "image://theme/icon-m-common-favorite-mark-inverse"
                            }
                        }
                    }

                    Text {
                        id: timeAndSourceText
                        anchors { left: iconLoader.right; leftMargin: constant.paddingSmall; right: parent.right }
                        font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
                        horizontalAlignment: Text.AlignRight
                        color: constant.colorMid
                        text: tweet.source + " | " + Qt.formatDateTime(tweet.createdAt, "h:mm AP d MMM yy")
                        elide: Text.ElideRight
                    }
                }

                Flow {
                    anchors { left: parent.left; right: parent.right }
                    spacing: constant.paddingMedium

                    Repeater {
                        model: ListModel { id: thumbnailModel }

                        ThumbnailItem {
                            imageSource: model.thumb
                            iconSource: {
                                switch (model.type) {
                                case "image":
                                    return settings.invertedTheme ? "Image/photos_inverse.svg" : "Image/photos.svg"
                                case "map":
                                    return settings.invertedTheme ? "Image/location_mark_inverse.svg" : "Image/location_mark.svg"
                                case "video":
                                    return settings.invertedTheme ? "Image/video_inverse.svg" : "Image/video.svg"
                                default:
                                    console.log("Invalid type: " + model.type); return ""
                                }
                            }
                            onClicked: {
                                if (model.type === "image")
                                    pageStack.push(Qt.resolvedUrl("TweetImage.qml"), {"imageLink": model.link,"imageUrl": model.full})
                                else if (model.type === "map")
                                    pageStack.push(Qt.resolvedUrl("MapPage.qml"), {latitude: tweet.latitude, longitude: tweet.longitude})
                                else {
                                    if (model.link) {
                                        var success = Qt.openUrlExternally(model.link)
                                        if (!success) infoBanner.showText(qsTr("Error opening link: %1").arg(model.link))
                                    }
                                    else infoBanner.showText(qsTr("Streaming link is not available"))
                                }
                            }
                        }
                    }
                }
            }

            Loader { id: translatedTweetLoader; height: sourceComponent ? undefined : 0 }

            Loader { sourceComponent: descendantRepeater.count > 0 ? replyHeading : undefined }

            Column {
                id: descendantColumn
                anchors { left: parent.left; right: parent.right }
                height: childrenRect.height

                Repeater { id: descendantRepeater; TweetDelegate { width: descendantColumn.width } }
            }
        }
    }

    ScrollDecorator { flickableItem: tweetPageFlickable }

    PageHeader {
        id: header
        headerIcon: "Image/chat.png"
        headerText: qsTr("Tweet")
        onClicked: tweetPageFlickable.contentY = 0
    }

    WorkerScript {
        id: conversationParser
        source: "WorkerScript/ConversationParser.js"
        onMessage: {
            backButton.enabled = true
            header.busy = false
            ancestorRepeater.model = ancestorModel
            descendantRepeater.model = descendantModel
        }
    }

    Component {
        id: inReplyToHeading

        SectionHeader { width: mainColumn.width; text: qsTr("In-reply-to") }
    }

    Component {
        id: replyHeading

        SectionHeader { width: mainColumn.width; text: qsTr("Reply") }
    }

    Component {
        id: translatedTweetComponent

        Column {
            property string translatedText

            width: mainColumn.width
            height: childrenRect.height + constant.paddingMedium
            spacing: constant.paddingMedium

            SectionHeader { text: qsTr("Translated Tweet") }

            Text {
                anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                font.pixelSize: constant.fontSizeLarge
                color: constant.colorLight
                text: translatedText
                wrapMode: Text.Wrap
            }
        }
    }
}
