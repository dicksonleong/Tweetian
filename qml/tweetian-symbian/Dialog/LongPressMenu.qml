import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"

ContextMenu{
    id: root

    property variant model
    property bool __isClosing: false

    function getAllHashtags(text){
        if(!settings.hashtagsInReply)
            return ""

        var hashtags = ""
        var hashtagsArray = text.match(/href="#[^"\s]+/g)
        if(hashtagsArray != null)
            for(var i=0; i<hashtagsArray.length; i++) hashtags += hashtagsArray[i].substring(6) + " "

        return hashtags
    }

    platformInverted: settings.invertedTheme

    MenuLayout{
        MenuItemWithIcon{
            iconSource: platformInverted ? "../Image/reply_inverse.png" : "../Image/reply.png"
            text: "Reply"
            platformInverted: root.platformInverted
            onClicked: {
                var prop = {type: "Reply", tweetId: model.tweetId, placedText: "@"+model.screenName+" "+getAllHashtags(model.displayTweetText)}
                pageStack.push(Qt.resolvedUrl("../NewTweetPage.qml"), prop)
            }
        }
        MenuItemWithIcon{
            iconSource: platformInverted ? "../Image/retweet_inverse.png" : "../Image/retweet.png"
            text: "Retweet"
            platformInverted: root.platformInverted
            onClicked: {
                var text = model.retweetId == model.tweetId ? "RT @"+model.screenName+": "+model.tweetText
                                                : "RT @"+model.screenName+": RT @"+model.displayScreenName+": "+model.tweetText
                pageStack.push(Qt.resolvedUrl("../NewTweetPage.qml"), {type: "RT", placedText: text, tweetId: model.retweetId})
            }
        }
        MenuItemWithIcon{
            iconSource: platformInverted ? "../Image/contacts_inverse.svg" : "../Image/contacts.svg"
            text: "<font color=\"LightSeaGreen\">@"+ model.screenName + "</font> Profile"
            platformInverted: root.platformInverted
            onClicked: pageStack.push(Qt.resolvedUrl("../UserPage.qml"), {screenName: model.screenName})
        }
        MenuItemWithIcon{
            iconSource: platformInverted ? "../Image/contacts_inverse.svg" : "../Image/contacts.svg"
            text: "<font color=\"LightSeaGreen\">@"+ model.displayScreenName + "</font> Profile"
            visible: model.displayScreenName != model.screenName
            platformInverted: root.platformInverted
            onClicked: pageStack.push(Qt.resolvedUrl("../UserPage.qml"), {screenName: model.displayScreenName})
        }
    }

    Component.onCompleted: open()

    onStatusChanged: {
        if(status === DialogStatus.Closing) __isClosing = true
        else if(status === DialogStatus.Closed && __isClosing) root.destroy()
    }
}
