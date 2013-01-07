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
import com.nokia.symbian 1.1
import "../Utils/Database.js" as Database
import "../Services/Pocket.js" as Pocket
import "../Services/Instapaper.js" as Instapaper
import "AccountTabScript.js" as Script

Page {
    id: accountTab

    Column {
        anchors { top: parent.top; topMargin: constant.paddingMedium; left: parent.left; right: parent.right }
        height: childrenRect.height
        spacing: constant.paddingLarge

        AccountItem {
            accountName: "Twitter"
            signedIn: true
            onButtonClicked: Script.createTwitterSignOutDialog()
        }

        AccountItem {
            accountName: "Pocket"
            signedIn: settings.pocketUsername && settings.pocketPassword
            infoButtonVisible: true
            onInfoClicked: dialog.createMessageDialog(qsTr("About Pocket"), infoText.pocket)
            onButtonClicked: signedIn ? Script.createPocketSignOutDialog() : Script.createPocketSignInDialog()
        }

        AccountItem {
            accountName: "Instapaper"
            signedIn: settings.instapaperToken && settings.instapaperTokenSecret
            infoButtonVisible: true
            onInfoClicked: dialog.createMessageDialog(qsTr("About Instapaper"), infoText.instapaper)
            onButtonClicked: signedIn ? Script.createInstapaperSignOutDialog() : Script.createInstapaperSignInDialog()
        }
    }
}
