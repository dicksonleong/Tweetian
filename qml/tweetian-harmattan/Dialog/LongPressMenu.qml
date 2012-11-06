import QtQuick 1.1
import com.nokia.meego 1.0
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

    content: MenuLayout{
        MenuItem{
            text: qsTr("Reply")
            onClicked: {
                var prop = {type: "Reply", tweetId: model.tweetId, placedText: "@"+model.screenName+" "+getAllHashtags(model.displayTweetText)}
                pageStack.push(Qt.resolvedUrl("../NewTweetPage.qml"), prop)
            }
        }
        MenuItem{
            text: qsTr("Retweet")
            onClicked: {
                var text = model.retweetId == model.tweetId ? "RT @"+model.screenName+": "+model.tweetText
                                                : "RT @"+model.screenName+": RT @"+model.displayScreenName+": "+model.tweetText
                pageStack.push(Qt.resolvedUrl("../NewTweetPage.qml"), {type: "RT", placedText: text, tweetId: model.retweetId})
            }
        }
        MenuItem{
            text: qsTr("%1 Profile").arg("<font color=\"LightSeaGreen\">@" + model.screenName + "</font>")
            onClicked: pageStack.push(Qt.resolvedUrl("../UserPage.qml"), {screenName: model.screenName})
            platformStyle: MenuItemStyle{ position: rtScreenName.visible ? "vertical-center" : "vertical-bottom" }
        }
        MenuItem{
            id: rtScreenName
            text: qsTr("%1 Profile").arg("<font color=\"LightSeaGreen\">@" + model.displayScreenName + "</font>")
            visible: model.displayScreenName != model.screenName
            onClicked: pageStack.push(Qt.resolvedUrl("../UserPage.qml"), {screenName: model.displayScreenName})
        }
    }

    Component.onCompleted: {
        open()
        basicHapticEffect.play()
    }

    onStatusChanged: {
        if(status === DialogStatus.Closing) __isClosing = true
        else if(status === DialogStatus.Closed && __isClosing) root.destroy(250)
    }
}
