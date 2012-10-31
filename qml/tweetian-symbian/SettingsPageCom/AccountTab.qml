import QtQuick 1.1
import com.nokia.symbian 1.1
import "../storage.js" as Storage
import "../Services/Pocket.js" as Pocket
import "../Services/Instapaper.js" as Instapaper
import "AccountTabScript.js" as Script

Page{
    id: accountTab

    Column{
        anchors{ left: parent.left; right: parent.right; top: parent.top; topMargin: constant.paddingLarge }
        height: childrenRect.height
        spacing: constant.paddingLarge

        AccountItem{
            accountName: "Twitter"
            signedIn: true
            onButtonClicked: Script.createTwitterSignOutDialog()
        }

        AccountItem{
            accountName: "Pocket"
            signedIn: settings.pocketUsername && settings.pocketPassword
            infoButtonVisible: true
            onInfoClicked: dialog.createMessageDialog("About Pocket", infoText.pocket)
            onButtonClicked: signedIn ? Script.createPocketSignOutDialog() : Script.createPocketSignInDialog()
        }

        AccountItem{
            accountName: "Instapaper"
            signedIn: settings.instapaperToken && settings.instapaperTokenSecret
            infoButtonVisible: true
            onInfoClicked: dialog.createMessageDialog("About Instapaper", infoText.instapaper)
            onButtonClicked: signedIn ? Script.createInstapaperSignOutDialog() : Script.createInstapaperSignInDialog()
        }
    }
}
