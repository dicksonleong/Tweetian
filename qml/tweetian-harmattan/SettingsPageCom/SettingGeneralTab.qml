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
import com.nokia.meego 1.0
import "../Component"
import "../Services/Translation.js" as Translation

Page {

    Flickable {
        anchors.fill: parent
        contentHeight: switchColumn.height + 2 * switchColumn.anchors.topMargin

        Column {
            id: switchColumn
            anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: constant.paddingMedium }
            height: childrenRect.height
            spacing: constant.paddingLarge

            Text {
                anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                font.pixelSize: constant.fontSizeLarge
                color: constant.colorLight
                text: qsTr("Theme")
            }

            ButtonRow {
                anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                onVisibleChanged: {
                    if (visible) checkedButton = settings.invertedTheme ?  lightThemeButton : darkThemeButton
                }

                Button {
                    id: darkThemeButton
                    text: qsTr("Dark")
                    onClicked: settings.invertedTheme = false
                }

                Button {
                    id: lightThemeButton
                    text: qsTr("Light")
                    onClicked: settings.invertedTheme = true
                }
            }

            Text {
                anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                font.pixelSize: constant.fontSizeLarge
                color: constant.colorLight
                text: qsTr("Font size")
            }

            ButtonRow {
                anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                onVisibleChanged: {
                    if (visible) checkedButton = settings.largeFontSize ? largeFontSizeButton : smallFontSizeButton
                }

                Button {
                    id: smallFontSizeButton
                    text: qsTr("Small")
                    onClicked: settings.largeFontSize = false
                }

                Button {
                    id: largeFontSizeButton
                    text: qsTr("Large")
                    onClicked: settings.largeFontSize = true
                }
            }

            SettingSwitch {
                id: enableTwitLongerSwitch
                text: qsTr("Enable TwitLonger")
                checked: settings.enableTwitLonger
                infoButtonVisible: true
                onInfoClicked: dialog.createMessageDialog(qsTr("About TwitLonger"), infoText.twitLonger)
                onCheckedChanged: settings.enableTwitLonger = checked
            }

            Item {
                anchors { left: parent.left; right: parent.right }
                height: chooseServiceButton.height + 2 * constant.paddingMedium

                Text {
                    anchors {
                        left: parent.left; right: chooseServiceButton.left; margins: constant.paddingMedium
                        verticalCenter: parent.verticalCenter
                    }
                    font.pixelSize: constant.fontSizeLarge
                    color: constant.colorLight
                    wrapMode: Text.Wrap
                    elide: Text.ElideLeft
                    maximumLineCount: 2
                    text: qsTr("Image upload service")
                }

                Button {
                    id: chooseServiceButton
                    anchors {
                        right: parent.right; rightMargin: constant.paddingMedium
                        verticalCenter: parent.verticalCenter
                    }
                    width: parent.width * 0.4
                    text: imageUploadServiceModel.get(settings.imageUploadService).name
                    onClicked: chooseServiceDialogComponent.createObject(settingPage)
                }
            }

            Item {
                anchors { left: parent.left; right: parent.right }
                height: chooseLangButton.height + 2 * constant.paddingMedium

                Text {
                    anchors {
                        left: parent.left; right: chooseLangButton.left; margins: constant.paddingMedium
                        verticalCenter: parent.verticalCenter
                    }
                    font.pixelSize: constant.fontSizeLarge
                    color: constant.colorLight
                    wrapMode: Text.Wrap
                    elide: Text.ElideLeft
                    maximumLineCount: 2
                    text: qsTr("Tweet translation language")
                }

                Button {
                    id: chooseLangButton
                    anchors {
                        right: parent.right; rightMargin: constant.paddingMedium
                        verticalCenter: parent.verticalCenter
                    }
                    width: parent.width * 0.4
                    enabled: !loadingRect.visible
                    text: settings.translateLangName
                    onClicked: internal.createTranslationLangDialog()
                }
            }
        }
    }

    QtObject {
        id: internal

        property variant languagesCodesArray
        property ListModel languageNamesModel: ListModel {}

        function createTranslationLangDialog() {
            if (!languagesCodesArray || languageNamesModel.count <= 0) __getAvailableLanguages()
            else translationLangDialog.createObject(settingPage)
        }

        function __getAvailableLanguages() {
            if (!cache.isTranslationTokenValid())
                Translation.requestToken(constant, __getTokenOnSuccess, __onFailure)
            else
                Translation.getLanguagesForTranslate(constant, cache.translationToken, __getLangCodesOnSuccess,
                                                     __onFailure)
            loadingRect.visible = true
        }

        function __getTokenOnSuccess(token) {
            cache.translationToken = token
            Translation.getLanguagesForTranslate(constant, cache.translationToken, __getLangCodesOnSuccess,
                                                 __onFailure)
        }

        function __getLangCodesOnSuccess(langCodesArray) {
            if (!Array.isArray(langCodesArray)) {
                infoBanner.showText("Error: " + langCodesArray)
                loadingRect.visible = false
                return
            }
            languagesCodesArray = langCodesArray
            Translation.getLanguageNames(constant, cache.translationToken, JSON.stringify(languagesCodesArray),
                                         __getLangNamesOnSuccess, __onFailure)

        }

        function __getLangNamesOnSuccess(langNamesArray) {
            if (!Array.isArray(langNamesArray)) {
                infoBanner.showText("Error: " + langNamesArray)
                loadingRect.visible = false
                return
            }
            for (var i=0; i<langNamesArray.length; i++) {
                languageNamesModel.append({ name: langNamesArray[i] })
            }
            translationLangDialog.createObject(settingPage)
            loadingRect.visible = false
        }

        function __onFailure(status, statusCode) {
            infoBanner.showHttpError(status, statusCode)
            loadingRect.visible = false
        }
    }

    Component {
        id: translationLangDialog

        SelectionDialog {
            id: dialog
            property bool __isClosing: false
            titleText: qsTr("Translate to")
            model: internal.languageNamesModel
            onAccepted: {
                settings.translateLangName = internal.languageNamesModel.get(selectedIndex).name
                settings.translateLangCode = internal.languagesCodesArray[selectedIndex]
            }
            Component.onCompleted: {
                for (var i=0; i<internal.languagesCodesArray.length; i++) {
                    if (internal.languagesCodesArray[i] === settings.translateLangCode) {
                        selectedIndex = i
                        break
                    }
                }
                open()
            }
            onStatusChanged: {
                if (status === DialogStatus.Closing) __isClosing = true
                else if (status === DialogStatus.Closed && __isClosing) dialog.destroy(250)
            }
        }
    }

    Component {
        id: chooseServiceDialogComponent

        SelectionDialog {
            id: chooseServiceDialog
            property bool __isClosing: false
            titleText: qsTr("Image Upload Service")
            model: imageUploadServiceModel
            selectedIndex: settings.imageUploadService
            onSelectedIndexChanged: settings.imageUploadService = selectedIndex
            Component.onCompleted: open()
            onStatusChanged: {
                if (status === DialogStatus.Closing) __isClosing = true
                else if (status === DialogStatus.Closed && __isClosing) chooseServiceDialog.destroy(250)
            }
        }
    }

    ListModel {
        id: imageUploadServiceModel
        ListElement { name: "Twitter" }
        ListElement { name: "TwitPic" }
        ListElement { name: "MobyPicture" }
        ListElement { name: "img.ly" }
    }
}
