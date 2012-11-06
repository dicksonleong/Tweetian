import QtQuick 1.1
import com.nokia.meego 1.0

AbstractDelegate{
    id: root
    height: Math.max(textColumn.height, profileImage.height) + 2 * constant.paddingMedium

    Column{
        id: textColumn
        anchors{ top: parent.top; left: profileImage.right; right: parent.right }
        anchors.leftMargin: constant.paddingSmall
        anchors.margins: constant.paddingMedium
        height: childrenRect.height

        Item{
            id: titleContainer
            width: parent.width
            height: listNameText.height

            Text{
                id: listNameText
                anchors.left: parent.left
                width: Math.min(parent.width, implicitWidth)
                font.bold: true
                font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
                color: highlighted ? constant.colorHighlighted : constant.colorLight
                text: listName
                elide: Text.ElideRight
            }

            Text{
                anchors{ left: listNameText.right; leftMargin: constant.paddingMedium; right: parent.right }
                font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
                color: highlighted ? constant.colorHighlighted : constant.colorMid
                text: qsTr("By %1").arg(ownerUserName)
                elide: Text.ElideRight
            }
        }

        Text{
            width: parent.width
            visible: text != ""
            wrapMode: Text.Wrap
            font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
            color: highlighted ? constant.colorHighlighted : constant.colorLight
            text: listDescription
        }

        Text{
            width: parent.width
            font.pixelSize: settings.largeFontSize ? constant.fontSizeMedium : constant.fontSizeSmall
            color: highlighted ? constant.colorHighlighted : constant.colorMid
            text: qsTr("%1 members | %2 subscribers").arg(memberCount).arg(subscriberCount)
        }
    }

    onClicked: {
        var parameters = {
            listName: listName,
            listId: listId,
            listDescription: listDescription,
            ownerScreenName: ownerScreenName,
            memberCount: memberCount,
            subscriberCount: subscriberCount,
            protectedList: protectedList,
            followingList: following,
            ownerProfileImageUrl: profileImageUrl
        }
        window.pageStack.push(Qt.resolvedUrl("../ListPage.qml"), parameters)
    }
}
