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
import QtMobility.location 1.2
import "Services/Twitter.js" as Twitter
import "Services/TwitLonger.js" as TwitLonger
import "Component"
import Uploader 1.0

Page {
    id: newTweetPage

    property string type: "New" //"New","Reply", "RT" or "DM"
    property string tweetId //for "Reply", "RT"
    property string screenName //for "DM"
    property string placedText: ""
    property double latitude: 0
    property double longitude: 0

    property string imageUrl: ""
    property string imagePath: ""

    onStatusChanged: if (status === PageStatus.Activating) preventTouch.enabled = false

    tools: ToolBarLayout {
        enabled: !preventTouch.enabled
        ToolButton {
            id: tweetButton
            text: {
                switch (type) {
                case "New": return qsTr("Tweet")
                case "Reply": return qsTr("Reply")
                case "RT": return qsTr("Retweet")
                case "DM": return qsTr("DM")
                }
            }
            enabled: (tweetTextArea.text.length != 0 || addImageButton.checked)
                     && ((settings.enableTwitLonger && !addImageButton.checked) || !tweetTextArea.errorHighlight)
                     && !header.busy
            platformInverted: settings.invertedTheme
            onClicked: {
                // remove focus on text field for force commit pre-edit text
                tweetTextArea.parent.focus = true;
                if (type == "New" || type == "Reply") {
                    if (addImageButton.checked) imageUploader.run()
                    else {
                        if (tweetTextArea.errorHighlight) internal.createUseTwitLongerDialog()
                        else {
                            Twitter.postStatus(tweetTextArea.text, tweetId ,latitude, longitude,
                                               internal.postStatusOnSuccess, internal.commonOnFailure)
                            header.busy = true
                        }
                    }
                }
                else if (type == "RT") {
                    Twitter.postRetweet(tweetId, internal.postStatusOnSuccess, internal.commonOnFailure)
                    header.busy = true
                }
                else if (type == "DM") {
                    Twitter.postDirectMsg(tweetTextArea.text, screenName,
                                          internal.postStatusOnSuccess, internal.commonOnFailure)
                    header.busy = true
                }
            }
        }
        ToolButton {
            id: cancelButton
            text: qsTr("Cancel")
            platformInverted: settings.invertedTheme
            onClicked: pageStack.pop()
        }
    }

    TextArea {
        id: tweetTextArea
        anchors {
            top: header.bottom; left: parent.left; right: parent.right
            bottomMargin: autoCompleter.height + 2 * buttonColumn.anchors.margins
            margins: constant.paddingMedium
        }
        platformInverted: settings.invertedTheme
        readOnly: header.busy
        textFormat: Text.PlainText
        errorHighlight: charLeftText.text < 0 && type != "RT"
        font.pixelSize: constant.fontSizeXXLarge
        placeholderText: qsTr("Tap to write...")
        text: placedText
        states: [
            State {
                when: inputContext.visible
                AnchorChanges { target: tweetTextArea; anchors.bottom: newTweetPage.bottom }
            },
            State {
                when: !inputContext.visible
                PropertyChanges { target: tweetTextArea; height: Math.max(implicitHeight, 120) }
            }
        ]
        onTextChanged: internal.updateAutoCompleter()

        Text {
            id: charLeftText

            property string shortenText: tweetTextArea.text.replace(/https?:\/\/\S+/g, __replaceLink)

            function __replaceLink(w) {
                if (w.indexOf("https://") === 0)
                    return "https://t.co/xxxxxxxxxx" // Length: 23
                else return "http://t.co/xxxxxxxxxx" // Length: 22
            }

            anchors { right: parent.right; bottom: parent.bottom; margins: constant.paddingMedium }
            font.pixelSize: constant.fontSizeLarge
            color: constant.colorMid
            text: 140 - shortenText.length - (addImageButton.checked ? constant.charReservedPerMedia : 0)
        }
    }

    Loader {
        anchors.fill: tweetTextArea
        sourceComponent: type == "RT" ? rtCoverComponent : undefined

        Component {
            id: rtCoverComponent

            Rectangle {
                color: "white"
                opacity: 0.9
                radius: constant.paddingMedium

                Text {
                    anchors.centerIn: parent
                    color: "black"
                    font.pixelSize: tweetTextArea.font.pixelSize * 1.25
                    text: qsTr("Tap to Edit")
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: !header.busy
                    onClicked: {
                        tweetTextArea.forceActiveFocus()
                        type = "New"
                    }
                }
            }
       }
    }

    Column {
        id: buttonColumn
        anchors { left: parent.left; right: parent.right; top: tweetTextArea.bottom; margins: constant.paddingMedium }
        height: childrenRect.height
        spacing: constant.paddingMedium

        ListView {
            id: autoCompleter
            anchors { left: parent.left; right: parent.right }
            height: 42
            model: ListModel {}
            visible: inputContext.visible
            delegate: Button {
                platformInverted: settings.invertedTheme
                height: ListView.view.height
                text: model.completeWord
                onClicked: {
                    var word = model.completeWord
                    var leftIndex = tweetTextArea.text.slice(0, tweetTextArea.cursorPosition).search(/\S+$/)
                    if (leftIndex < 0) leftIndex = tweetTextArea.cursorPosition
                    var rightIndex = tweetTextArea.text.slice(tweetTextArea.cursorPosition).search(/\s/)
                    if (rightIndex < 0) {
                        rightIndex = 0
                        word += " "
                    }
                    tweetTextArea.text = tweetTextArea.text.slice(0, leftIndex) + word
                            + tweetTextArea.text.slice(rightIndex + tweetTextArea.cursorPosition)
                    tweetTextArea.cursorPosition = leftIndex + word.length
                    tweetTextArea.forceActiveFocus()
                    autoCompleter.model.clear()
                }
            }
            orientation: ListView.Horizontal
            spacing: constant.paddingSmall
        }

        Row {
            id: newTweetButtonRow
            anchors { left: parent.left; right: parent.right }
            height: childrenRect.height
            spacing: constant.paddingMedium
            visible: type == "New" || type == "Reply"

            Button {
                id: locationButton
                iconSource: platformInverted ? "Image/add_my_location_inverse.svg" : "Image/add_my_location.svg"
                width: (parent.width - constant.paddingMedium) / 2
                text: qsTr("Add")
                platformInverted: settings.invertedTheme
                enabled: !header.busy
                states: [
                    State {
                        name: "loading"
                        PropertyChanges {
                            target: locationButton
                            text: qsTr("Updating...")
                            checked: false
                        }
                    },
                    State {
                        name: "done"
                        PropertyChanges {
                            target: locationButton
                            text: qsTr("View/Remove")
                            iconSource: platformInverted ? "Image/location_mark_inverse.svg" : "Image/location_mark.svg"
                            checked: true
                        }
                    }
                ]
                onClicked: {
                    if (state == "done") locationDialogComponent.createObject(newTweetPage)
                    else {
                        positionSource.start()
                        state = "loading"
                    }
                }
            }

            Button {
                id: addImageButton
                width: (parent.width - constant.paddingMedium) / 2
                iconSource: platformInverted ? "Image/photos_inverse.svg" : "Image/photos.svg"
                text: checked ? qsTr("View/Remove") : qsTr("Add")
                platformInverted: settings.invertedTheme
                enabled: !header.busy
                checked: imagePath != ""
                onClicked: {
                    if (checked) imageDialogComponent.createObject(newTweetPage)
                    else pageStack.push(Qt.resolvedUrl("SelectImagePage.qml"), {newTweetPage: newTweetPage})
                }
            }
        }
    }

    PageHeader {
        id: header
        headerIcon: type == "DM" ? "Image/create_message.svg" : "Image/edit.svg"
        headerText: {
            if (imageUploader.progress > 0) return qsTr("Uploading...") + Math.round(imageUploader.progress * 100) + "%"

            switch (type) {
            case "New": return qsTr("New Tweet")
            case "Reply": return qsTr("Reply to %1").arg(placedText.substring(0, placedText.indexOf(" ")))
            case "RT": return qsTr("Retweet")
            case "DM": return qsTr("DM to %1").arg("@" + screenName)
            }
        }
        visible: !inputContext.visible
        height: visible ? undefined : 0
    }

    Component {
        id: locationDialogComponent

        ContextMenu {
            id: locationDialog
            property bool __isClosing: false
            platformInverted: settings.invertedTheme

            MenuLayout {
                MenuItemWithIcon {
                    iconSource: platformInverted ? "Image/location_mark_inverse.svg" : "Image/location_mark.svg"
                    text: qsTr("View location")
                    onClicked: {
                        preventTouch.enabled = true
                        pageStack.push(Qt.resolvedUrl("MapPage.qml"), {"latitude": latitude, "longitude": longitude})
                    }
                }
                MenuItemWithIcon {
                    iconSource: platformInverted ? "image://theme/toolbar-delete_inverse" : "image://theme/toolbar-delete"
                    text: qsTr("Remove location")
                    onClicked: {
                        latitude = 0
                        longitude = 0
                        locationButton.state = ""
                    }
                }
            }
            Component.onCompleted: open()
            onStatusChanged: {
                if (status === DialogStatus.Closing) __isClosing = true
                else if (status === DialogStatus.Closed && __isClosing) locationDialog.destroy()
            }
        }
    }

    Component {
        id: imageDialogComponent

        ContextMenu {
            id: imageDialog
            property bool __isClosing: false
            platformInverted: settings.invertedTheme

            MenuLayout {
                MenuItemWithIcon {
                    iconSource: platformInverted ? "Image/photos_inverse.svg" : "Image/photos.svg"
                    text: qsTr("View image")
                    onClicked: Qt.openUrlExternally(imageUrl)
                }
                MenuItemWithIcon {
                    iconSource: platformInverted ? "image://theme/toolbar-delete_inverse" : "image://theme/toolbar-delete"
                    text: qsTr("Remove image")
                    onClicked: {
                        imageUrl = ""
                        imagePath = ""
                    }
                }
            }
            Component.onCompleted: open()
            onStatusChanged: {
                if (status === DialogStatus.Closing) __isClosing = true
                else if (status === DialogStatus.Closed && __isClosing) imageDialog.destroy()
            }
        }
    }

    MouseArea {
        id: preventTouch
        anchors.fill: parent
        z: 1
        enabled: false
    }

    WorkerScript { id: autoCompleterWorkerScript; source: "WorkerScript/AutoCompleter.js" }

    PositionSource {
        id: positionSource
        updateInterval: 1000

        onPositionChanged: {
            latitude = position.coordinate.latitude
            longitude = position.coordinate.longitude
            positionSource.stop()
            locationButton.state = "done"
        }

        Component.onDestruction: stop()
    }

    ImageUploader {
        id: imageUploader
        networkAccessManager: QMLUtils.networkAccessManager()
        service: settings.imageUploadService
        onSuccess: {
            if (service == ImageUploader.Twitter) internal.postStatusOnSuccess(JSON.parse(replyData))
            else {
                var imageLink = ""
                if (service == ImageUploader.TwitPic) imageLink = JSON.parse(replyData).url
                else if (service == ImageUploader.MobyPicture) imageLink = JSON.parse(replyData).media.mediaurl
                else if (service == ImageUploader.Imgly) imageLink = JSON.parse(replyData).url
                Twitter.postStatus(tweetTextArea.text+" "+imageLink, tweetId, latitude, longitude,
                                   internal.postStatusOnSuccess, internal.commonOnFailure)
            }
        }
        onFailure: internal.commonOnFailure(status, statusText)

        function run() {
            imageUploader.setFile(imagePath)
            if (service == ImageUploader.Twitter) {
                imageUploader.setParameter("status", tweetTextArea.text)
                if (tweetId) imageUploader.setParameter("in_reply_to_status_id", tweetId)
                if (latitude != 0 && longitude != 0) {
                    imageUploader.setParameter("lat", latitude.toString())
                    imageUploader.setParameter("long", longitude.toString())
                }
                imageUploader.setAuthorizationHeader(Twitter.getTwitterImageUploadAuthHeader())
            }
            else {
                if (service == ImageUploader.TwitPic) imageUploader.setParameter("key", constant.twitpicAPIKey)
                else if (service == ImageUploader.MobyPicture) imageUploader.setParameter("key", constant.mobypictureAPIKey)
                imageUploader.setParameter("message", tweetTextArea.text)
                imageUploader.setAuthorizationHeader(Twitter.getOAuthEchoAuthHeader())
            }
            header.busy = true
            imageUploader.send()
        }
    }

    QtObject {
        id: internal

        property string twitLongerId: ""

        function updateAutoCompleter() {
            if (newTweetPage.status !== PageStatus.Active || !tweetTextArea.activeFocus) return
            autoCompleter.model.clear()
            var currentWord = getWordAt(tweetTextArea.text, tweetTextArea.cursorPosition)
            if (!/^(@|#)\w*$/.test(currentWord)) {
                tweetTextArea.inputMethodHints = Qt.ImhNone
                return
            }
            var msg = {
                word: currentWord,
                model: autoCompleter.model,
                screenNames: cache.screenNames,
                hashtags: cache.hashtags
            }
            autoCompleterWorkerScript.sendMessage(msg)
            tweetTextArea.inputMethodHints = Qt.ImhNoPredictiveText
        }

        /**
          Extract a word from str at the specificed pos.
          Example:
          var text = "Hello world"
          var word = getWordAt(text, n)

          n = 0; word = ""
          n = 1/2/3/4/5; word = "Hello"
          n = 6; word = ""
          n = 7/8/9/10/11; word = "world"
          n > text.length; unexpected behaviour
        */
        function getWordAt(str, pos) {
            var left = str.slice(0, pos).search(/\S+$/)
            if (left < 0) return ""

            var right = str.slice(pos).search(/\s/)
            if (right < 0) return str.slice(left)

            return str.slice(left, right + pos)
        }

        function postStatusOnSuccess(data) {
            switch (type) {
            case "New": infoBanner.showText(qsTr("Tweet sent successfully")); break;
            case "Reply": infoBanner.showText(qsTr("Reply sent successfully")); break;
            case "DM":infoBanner.showText(qsTr("Direct message sent successfully")); break;
            case "RT": infoBanner.showText(qsTr("Retweet sent successfully")); break;
            }
            pageStack.pop()
        }

        function twitLongerOnSuccess(twitLongerId, shortenTweet) {
            internal.twitLongerId = twitLongerId
            Twitter.postStatus(shortenTweet, tweetId ,latitude, longitude,
                               postTwitLongerStatusOnSuccess, commonOnFailure)
        }

        function postTwitLongerStatusOnSuccess(data) {
            TwitLonger.postIDCallback(constant, twitLongerId, data.id_str)
            switch (type) {
            case "New": infoBanner.showText(qsTr("Tweet sent successfully")); break;
            case "Reply": infoBanner.showText(qsTr("Reply sent successfully")); break;
            }
            pageStack.pop()
        }

        function commonOnFailure(status, statusText) {
            infoBanner.showHttpError(status, statusText)
            header.busy = false
        }

        function createUseTwitLongerDialog() {
            var message = qsTr("Your tweet is more than 140 characters. Do you want to use TwitLonger to post your tweet?\n\
Note: The tweet content will be publicly visible even if your tweet is private.")
            dialog.createQueryDialog(qsTr("Use TwitLonger?"), "", message, function() {
                var replyScreenName = placedText ? placedText.substring(1, placedText.indexOf(" ")) : ""
                TwitLonger.postTweet(constant, settings.userScreenName, tweetTextArea.text, tweetId, replyScreenName,
                                     twitLongerOnSuccess, commonOnFailure)
                header.busy = true
            })
        }
    }
}
