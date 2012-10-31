import QtQuick 1.1
import com.nokia.meego 1.0

AbstractDelegate{
    id: root
    height: Math.max(textColumn.height, profileImage.height) + 2 * constant.paddingMedium
    sideRectColor: {
        switch(settings.userScreenName){
        case inReplyToScreenName: return constant.colorTextSelection
        case screenName: return constant.colorLight
        default: return ""
        }
    }

    Column{
        id: textColumn
        anchors{ top: parent.top; left: profileImage.right;  right: parent.right }
        anchors.leftMargin: constant.paddingSmall
        anchors.margins: constant.paddingMedium
        height: childrenRect.height

        Item{
            id: titleContainer
            width: parent.width
            height: userNameText.height

            // FIXME: After changing font size from small to large the username will become elided
            // for the loaded delegate
            Text{
                id: userNameText
                anchors.left: parent.left
                width: Math.min(parent.width, implicitWidth)
                font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
                font.bold: true
                color: highlighted ? constant.colorHighlighted : constant.colorLight
                elide: Text.ElideRight
                text: userName
            }

            Text{
                anchors{ left: userNameText.right; right: favouriteIconLoader.left; margins: constant.paddingMedium }
                text: "@" + displayScreenName
                font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
                color: highlighted ? constant.colorHighlighted : constant.colorMid
                elide: Text.ElideRight
            }

            Loader{
                id: favouriteIconLoader
                anchors.right: parent.right
                width: sourceComponent ? item.sourceSize.height : 0
                sourceComponent: favourited ? favouriteIcon : undefined
            }
        }

        Text{
            width: parent.width
            text: displayTweetText
            textFormat: Text.RichText
            font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
            wrapMode: Text.Wrap
            color: highlighted ? constant.colorHighlighted : constant.colorLight
        }

        Loader{
            id: retweetLoader
            sourceComponent: retweetId == tweetId ? undefined : retweetText
        }

        Text{
            width: parent.width
            horizontalAlignment: Text.AlignRight
            text: source + " | " + timeDiff
            font.pixelSize: settings.largeFontSize ? constant.fontSizeSmall : constant.fontSizeXSmall
            color: highlighted ? constant.colorHighlighted : constant.colorMid
            elide: Text.ElideRight
        }
    }

    Component{
        id: retweetText

        Text{
            width: parent.width
            text: "Retweeted by @"+screenName
            font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
            wrapMode: Text.Wrap
            color: highlighted ? constant.colorHighlighted : constant.colorMid
        }
    }

    Component{
        id: favouriteIcon

        Image{
            sourceSize.height: titleContainer.height
            sourceSize.width: titleContainer.height
            source: settings.invertedTheme ? "image://theme/icon-m-common-favorite-mark"
                                           : "image://theme/icon-m-common-favorite-mark-inverse"
        }
    }

    onClicked: pageStack.push(Qt.resolvedUrl("../TweetPage.qml"), {currentTweet: model})
    onPressAndHold: dialog.createTweetLongPressMenu(model)
}
