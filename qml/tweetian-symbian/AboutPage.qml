import QtQuick 1.1
import com.nokia.symbian 1.1
import "twitter.js" as Twitter
import "Component"

Page{
    id: aboutPage
    tools: ToolBarLayout{
        ToolButtonWithTip{
            id: backButton
            iconSource: "toolbar-back"
            toolTipText: "Back"
            onClicked: pageStack.pop()
        }
    }

    Flickable{
        id: aboutPageFlickable
        anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        contentHeight: aboutColumn.height

        Column{
            id: aboutColumn
            width: parent.width
            height: childrenRect.height

            SectionHeader{ text: "About Tweetian" }

            Item{
                width: parent.width
                height: aboutText.height + 2 * constant.paddingMedium

                Text{
                    id: aboutText
                    anchors{ left: parent.left; right: parent.right; top: parent.top; margins: constant.paddingMedium }
                    wrapMode: Text.Wrap
                    font.pixelSize: constant.fontSizeMedium
                    color: constant.colorLight
                    text: "Tweetian is a feature-rich Twitter app for smartphones, powered by Qt and QML. \
It has a simple, native and easy-to-use UI that will surely make you enjoy the Twitter experience on your \
smartphone. Tweetian is open source and licensed under GPL v3."
                }
            }

            SectionHeader{ text: "Version" }

            Item{
                width: parent.width
                height: versionText.height + 2 * constant.paddingMedium

                Text{
                    id: versionText
                    anchors{ left: parent.left; right: parent.right; top: parent.top; margins: constant.paddingMedium }
                    font.pixelSize: constant.fontSizeMedium
                    color: constant.colorLight
                    wrapMode: Text.Wrap
                    text: appVersion + " <i>[This is a pre-release version and only use for debug, \
you are trying at your own risk]</i>"
                }
            }

            SectionHeader{ text: "Developed By" }

            AboutPageItem{
                imageSource: "Image/DicksonBetaDP.png"
                text: "@DicksonBeta"
                onClicked: pageStack.push(Qt.resolvedUrl("UserPage.qml"), {screenName: "DicksonBeta"})
            }

            SectionHeader{ text: "Special Thanks" }

            AboutPageItem{
                imageSource: "Image/knobtvikerDP.jpg"
                text: "@knobtviker"
                onClicked: pageStack.push(Qt.resolvedUrl("UserPage.qml"), {screenName: "knobtviker"})
            }

            AboutPageItem{
                imageSource: "Image/Mandeep_ThemesDP.png"
                text: "@Mandeep_Themes"
                onClicked: pageStack.push(Qt.resolvedUrl("UserPage.qml"), {screenName: "Mandeep_Themes"})
            }

            SectionHeader{ text: "Powered By" }

            AboutPageItem{
                imageSource: "Image/twitter-bird-white-on-blue.png"
                text: "Twitter"
                onClicked: pageStack.push(Qt.resolvedUrl("UserPage.qml"), {screenName: "twitter"})
            }

            AboutPageItem{
                imageSource: "Image/nokia_icon.png"
                text: "Nokia"
                onClicked: pageStack.push(Qt.resolvedUrl("UserPage.qml"), {screenName: "nokia"})
            }

            AboutPageItem{
                imageSource: "Image/qt_icon.png"
                text: "Qt"
                onClicked: pageStack.push(Qt.resolvedUrl("UserPage.qml"), {screenName: "qtproject"})
            }

            SectionHeader{ text: "Legal" }

            AboutPageItem{
                id: privacyButton
                imageSource: "Image/twitter-bird-white-on-blue.png"
                text: "Twitter Privacy Policy"
                onClicked: {
                    Twitter.getPrivacyPolicy(callback.privacyOnSuccess, callback.onFailure)
                    loadingRect.visible = true
                }
            }

            AboutPageItem{
                id: tosButton
                imageSource: "Image/twitter-bird-white-on-blue.png"
                text: "Twitter Terms of Service"
                onClicked: {
                    Twitter.getTermsOfService(callback.tosOnSuccess, callback.onFailure)
                    loadingRect.visible = true
                }
            }
        }
    }

    ScrollDecorator{ platformInverted: settings.invertedTheme; flickableItem: aboutPageFlickable }

    PageHeader{
        id: header
        headerIcon: "Image/information_userguide.svg"
        headerText: "About Tweetian"
        onClicked: aboutPageFlickable.contentY = 0
    }

    QtObject{
        id: callback

        function privacyOnSuccess(data){
            var param = {text: data.privacy, headerText: privacyButton.text, headerIcon: privacyButton.imageSource}
            pageStack.push(Qt.resolvedUrl("TextPage.qml"), param)
            loadingRect.visible = false
        }

        function tosOnSuccess(data){
            var param = {text: data.tos, headerText: tosButton.text, headerIcon: tosButton.imageSource}
            pageStack.push(Qt.resolvedUrl("TextPage.qml"), param)
            loadingRect.visible = false
        }

        function onFailure(status, statusText){
            if(status === 0) infoBanner.alert("Connection error.")
            else infoBanner.alert("Error:" + status + " " + statusText)
            loadingRect.visible = false
        }
    }
}
