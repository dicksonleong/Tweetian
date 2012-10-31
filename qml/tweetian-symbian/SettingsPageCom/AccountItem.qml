import QtQuick 1.1
import com.nokia.symbian 1.1

Item{
    id: root

    property string accountName
    property bool signedIn
    property bool infoButtonVisible: false
    signal buttonClicked
    signal infoClicked

    anchors { left: parent.left; right: parent.right }
    height: accountNameText.height + signedInText.height

    Text{
        id: accountNameText
        anchors {
            left: parent.left
            top: parent.top
            right: infoButtonVisible ? infoIconLoader.left : signInButton.left
            leftMargin: constant.paddingMedium
        }
        color: constant.colorLight
        font.pixelSize: constant.fontSizeLarge
        text: accountName
        elide: Text.ElideRight
    }

    Text{
        id: signedInText
        anchors { left: parent.left; top: accountNameText.bottom; leftMargin: constant.paddingMedium }
        color: signedIn ? "Green" : "Red"
        font.pixelSize: constant.fontSizeSmall
        text: signedIn ? "Signed in" : "Not signed in"
        font.italic: true
    }

    Loader{
        id: infoIconLoader
        anchors.right: signInButton.left
        anchors.rightMargin: constant.paddingMedium
        anchors.verticalCenter: parent.verticalCenter
        sourceComponent: infoButtonVisible ? infoIcon : undefined

        MouseArea{
            anchors.fill: parent
            onClicked: root.infoClicked()
        }
    }

    Component{
        id: infoIcon

        Image{
            source: settings.invertedTheme ? "../Image/info_inverse.png" : "../Image/info.png"
            sourceSize.width: constant.graphicSizeSmall + constant.paddingMedium
            sourceSize.height: constant.graphicSizeSmall + constant.paddingMedium
            cache: false
        }
    }

    Button{
        id: signInButton
        anchors.right: parent.right
        anchors.rightMargin: constant.paddingMedium
        anchors.verticalCenter: parent.verticalCenter
        platformInverted: settings.invertedTheme
        width: parent.width / 3
        text: signedIn ? "Sign Out" : "Sign In"
        onClicked: root.buttonClicked()
    }
}
