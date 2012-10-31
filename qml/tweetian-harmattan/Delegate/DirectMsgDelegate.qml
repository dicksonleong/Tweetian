import QtQuick 1.1
import com.nokia.meego 1.0

AbstractDelegate{
    id: root
    height: Math.max(textColumn.height, profileImage.height) + 2 * constant.paddingMedium
    imageSource: sentMsg ? settings.userProfileImage : profileImageUrl

    Column{
        id: textColumn
        anchors{ top: parent.top; left: profileImage.right; right: parent.right }
        anchors.leftMargin: constant.paddingSmall
        anchors.margins: constant.paddingMedium
        height: childrenRect.height

        Item{
            width: parent.width
            height: userNameText.height

            Text{
                id: userNameText
                anchors.left: parent.left
                width: Math.min(implicitWidth, parent.width)
                text: sentMsg ? settings.userFullName : userName
                font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
                font.bold: true
                color: highlighted ? constant.colorHighlighted : constant.colorLight
                elide: Text.ElideRight
            }

            Text{
                anchors{ left: userNameText.right; leftMargin: constant.paddingMedium; right: parent.right }
                text: "@" + (sentMsg ? settings.userScreenName : screenName)
                font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
                color: highlighted ? constant.colorHighlighted : constant.colorMid
                elide: Text.ElideRight
            }
        }

        Text{
            width: parent.width
            text: tweetText
            font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
            wrapMode: Text.Wrap
            color: highlighted ? constant.colorHighlighted : constant.colorLight
        }

        Text{
            width: parent.width
            horizontalAlignment: Text.AlignRight
            text: timeDiff
            font.pixelSize: settings.largeFontSize ? constant.fontSizeSmall : constant.fontSizeXSmall
            color: highlighted ? constant.colorHighlighted : constant.colorMid
        }

    }

    onClicked: internal.createDMDialog(model)
}
