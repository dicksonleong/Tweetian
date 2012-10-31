import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog{
    id: root

    property bool __isClosing: false

    platformInverted: settings.invertedTheme
    buttonTexts: ["Search", "Advanced", "Cancel"]
    titleText: "Search Twitter"
    titleIcon: platformInverted ? "image://theme/toolbar-search_inverse"
                                : "image://theme/toolbar-search"
    content: Item{
        id: dialogContent
        anchors{
            top: parent.top
            left: parent.left
            right: parent.right
            margins: constant.paddingMedium
        }
        height: searchTypeRow.height + searchTextField.height + searchTypeRow.anchors.topMargin + 2 * anchors.margins

        TextField{
            id: searchTextField
            anchors{ top: parent.top; left: parent.left; right: parent.right }
            placeholderText: "Enter your search query..."
            font.pixelSize: constant.fontSizeLarge
            platformInverted: root.platformInverted
            inputMethodHints: Qt.ImhNoPredictiveText
        }

        Text{
            id: searchTypeText
            anchors.verticalCenter: searchTypeRow.verticalCenter
            font.pixelSize: constant.fontSizeMedium
            color: constant.colorLight
            text: "Search for:"
        }

        ButtonRow{
            id: searchTypeRow
            anchors{
                left: searchTypeText.right; leftMargin: constant.paddingLarge
                top: searchTextField.bottom; topMargin: constant.paddingLarge
                right: parent.right
            }
            height: childrenRect.height

            Button{
                id: tweetType
                text: "Tweet"
                platformInverted: root.platformInverted
            }
            Button{
                id: userType
                text: "User"
                platformInverted: root.platformInverted
            }
        }
    }
    onButtonClicked: {
        if(index === 0){
            if(tweetType.checked)
                pageStack.push(Qt.resolvedUrl("../SearchPage.qml"), {searchName: searchTextField.text})
            else if(userType.checked)
                pageStack.push(Qt.resolvedUrl("../UserSearchPage.qml"), {userSearchQuery: searchTextField.text})
        }
        else if(index === 1) pageStack.push(Qt.resolvedUrl("../AdvSearchPage.qml"), {searchQuery: searchTextField.text})
    }

    Component.onCompleted: open()

    onStatusChanged: {
        if(status === DialogStatus.Closing) __isClosing = true
        else if(status === DialogStatus.Closed && __isClosing) root.destroy()
    }
}
