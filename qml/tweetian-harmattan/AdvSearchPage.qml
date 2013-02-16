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
import "Component"
import "SettingsPageCom"

Page {
    id: advSearchPage

    function __contructQuery() {
        var query = ""

        if (allOfTheseWordsField.textFieldText && allOfTheseWordsField.acceptableInput)
            query += allOfTheseWordsField.textFieldText + " "
        if (exactPhraseField.textFieldText && exactPhraseField.acceptableInput)
            query += "\"" + exactPhraseField.textFieldText + "\" "
        if (anyOfTheseWordsField.textFieldText && anyOfTheseWordsField.acceptableInput)
            query += anyOfTheseWordsField.textFieldText.replace(/ /g, " OR ") + " "
        if (noneOfTheseWordsField.textFieldText && noneOfTheseWordsField.acceptableInput)
            query += "-" + noneOfTheseWordsField.textFieldText.replace(/ /g, " -") + " "
        if (languageSelectionDialog.model.get(languageSelectionDialog.selectedIndex).code)
            query += "lang:" + languageSelectionDialog.model.get(languageSelectionDialog.selectedIndex).code + " "
        if (fromTheseUsersField.textFieldText && fromTheseUsersField.acceptableInput)
            query += "from:" + fromTheseUsersField.textFieldText.replace(/@/g, "").replace(/ /g, " OR from:") + " "
        if (toTheseUsersField.textFieldText && toTheseUsersField.acceptableInput)
            query += "to:" + toTheseUsersField.textFieldText.replace(/@/g, "").replace(/ /g, " OR to:") + " "
        if (mentioningTheseUsersField.textFieldText && mentioningTheseUsersField.acceptableInput)
            query += "@" + mentioningTheseUsersField.textFieldText.replace(/@/g, "").replace(/ /g, " OR @") + " "
        if (tweetSourceField.textFieldText && tweetSourceField.acceptableInput)
            query += "source:" + tweetSourceField.textFieldText.replace(/ /g, " OR source:") + " "
        if (linkFilterSwitch.checked)
            query += "filter:links "
        if (imageFilterSwitch.checked)
            query += "filter:images "
        if (videoFilterSwitch.checked)
            query += "filter:videos "
        if (positiveAttitudeSwitch.checked)
            query += ":) "
        if (negativeAttitudeSwitch.checked)
            query += ":( "
        if (questionSwitch.checked)
            query += "? "
        if (includeRetweetsSwitch.checked) query += "include:retweets"
        else query += "exclude:retweets"

        return query
    }

    tools: ToolBarLayout {
        Item { width: 80; height: 64 }
        ButtonRow {
            exclusive: false
            spacing: constant.paddingMedium

            ToolButton {
                text: qsTr("Search")
                onClicked: pageStack.push(Qt.resolvedUrl("SearchPage.qml"), {searchString: __contructQuery()})
            }
            ToolButton {
                text: qsTr("Cancel")
                onClicked: pageStack.pop()
            }
        }
        Item { width: 80; height: 64 }
    }

    Flickable {
        id: mainFlickable
        anchors { left: parent.left; right: parent.right; top: header.bottom; bottom: parent.bottom }
        contentHeight: mainColumn.height
        flickableDirection: Flickable.VerticalFlick

        Column {
            id: mainColumn
            anchors { left: parent.left; right: parent.right }
            height: childrenRect.height
            spacing: constant.paddingLarge

            SectionHeader { text: qsTr("Words") }

            SettingTextField {
                id: allOfTheseWordsField
                settingText: qsTr("All of these words")
                validator: RegExpValidator { regExp: /(^$|^\S$|^\S.*\S$)/ }
                placeHolderText: qsTr("eg. %1").arg("Tweetian Symbian Harmattan")
            }

            SettingTextField {
                id: exactPhraseField
                settingText: qsTr("Exact phrase")
                validator: RegExpValidator { regExp: /(^$|^\S$|^\S.*\S$)/ }
                placeHolderText: qsTr("eg. %1").arg("Tweetian is amazing")
            }

            SettingTextField {
                id: anyOfTheseWordsField
                settingText: qsTr("Any of these words")
                validator: RegExpValidator { regExp: /(^$|^\S$|^\S.*\S$)/ }
                placeHolderText: qsTr("eg. %1").arg("Symbian Harmattan")
            }

            SettingTextField {
                id: noneOfTheseWordsField
                settingText: qsTr("None of these words")
                validator: RegExpValidator { regExp: /(^$|^\S$|^\S.*\S$)/ }
                placeHolderText: qsTr("eg. %1").arg("iPhone Android")
            }

            ListItem {
                marginLineVisible: false
                height: textColumn.height + 2 * textColumn.anchors.margins

                Column {
                    id: textColumn
                    height: childrenRect.height
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left; right: parent.right
                        margins: constant.paddingLarge
                    }

                    Text {
                        text: qsTr("Language")
                        font.pixelSize: constant.fontSizeMedium
                        color: constant.colorLight
                    }

                    Text {
                        text: languageSelectionDialog.model.get(languageSelectionDialog.selectedIndex).name
                        color: constant.colorMid
                        font.pixelSize: constant.fontSizeSmall
                    }
                }

                Image {
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right; rightMargin: constant.paddingMedium
                    }
                    sourceSize { width: 40; height: 40 }
                    source: settings.invertedTheme ? "Image/choice_list_indicator_inverse.svg"
                                                   : "Image/choice_list_indicator.svg"
                }
                onClicked: languageSelectionDialog.open()
            }

            SectionHeader { text: qsTr("Users") }

            SettingTextField {
                id: fromTheseUsersField
                settingText: qsTr("From any of these users")
                validator: RegExpValidator { regExp: /(^$|^\S$|^\S.*\S$)/ }
                placeHolderText: qsTr("eg. %1").arg("user1 user2 user3")
            }

            SettingTextField {
                id: toTheseUsersField
                settingText: qsTr("To any of these users")
                validator: RegExpValidator { regExp: /(^$|^\S$|^\S.*\S$)/ }
                placeHolderText: qsTr("eg. %1").arg("user1 user2 user3")
            }

            SettingTextField {
                id: mentioningTheseUsersField
                settingText: qsTr("Mentioning any of these users")
                validator: RegExpValidator { regExp: /(^$|^\S$|^\S.*\S$)/ }
                placeHolderText: qsTr("eg. %1").arg("user1 user2 user3")
            }

            SectionHeader { text: qsTr("Filters") }

            SettingSwitch {
                id: linkFilterSwitch
                text: qsTr("Contain links")
            }

            SettingSwitch {
                id: imageFilterSwitch
                text: qsTr("Contain images")
            }

            SettingSwitch {
                id: videoFilterSwitch
                text: qsTr("Contain videos")
            }

            SectionHeader { text: qsTr("Other") }

            SettingTextField {
                id: tweetSourceField
                settingText: qsTr("From any of these sources")
                validator: RegExpValidator { regExp: /(^$|^\S$|^\S.*\S$)/ }
                placeHolderText: qsTr("eg. %1").arg("Tweetian_for_Harmattan")
            }

            SettingSwitch {
                id: positiveAttitudeSwitch
                text: qsTr("Positive attitude :)")
            }

            SettingSwitch {
                id: negativeAttitudeSwitch
                text: qsTr("Negative attitude :(")
            }

            SettingSwitch {
                id: questionSwitch
                text: qsTr("Question ?")
            }

            SettingSwitch {
                id: includeRetweetsSwitch
                text: qsTr("Include retweets")
            }
        }
    }

    ScrollDecorator { flickableItem: mainFlickable }

    PageHeader {
        id: header
        headerIcon: "image://theme/icon-m-toolbar-search-white-selected"
        headerText: qsTr("Advanced Search")
        onClicked: mainFlickable.contentY = 0
    }

    SelectionDialog {
        id: languageSelectionDialog
        titleText: qsTr("Language")
        model: languageModel
        selectedIndex: 0
    }

    ListModel {
        id: languageModel
        ListElement { name: "Any Language"; code: "" }
        ListElement { name: "Amharic"; code: "am" }
        ListElement { name: "Arabic"; code: "ar" }
        ListElement { name: "Armenian"; code: "hy" }
        ListElement { name: "Bengali"; code: "bn" }
        ListElement { name: "Bulgarian"; code: "bg" }
        ListElement { name: "Cherokee"; code: "chr" }
        ListElement { name: "Chinese"; code: "zh" }
        ListElement { name: "Danish"; code: "da" }
        ListElement { name: "Dutch"; code: "nl" }
        ListElement { name: "English"; code: "en" }
        ListElement { name: "Finnish"; code: "fi" }
        ListElement { name: "French"; code: "fr" }
        ListElement { name: "Georgian"; code: "ka" }
        ListElement { name: "German"; code: "de" }
        ListElement { name: "Greek"; code: "el" }
        ListElement { name: "Gujarati"; code: "gu" }
        ListElement { name: "Hebrew"; code: "iw" }
        ListElement { name: "Hindi"; code: "hi" }
        ListElement { name: "Hungarian"; code: "hu" }
        ListElement { name: "Icelandic"; code: "is" }
        ListElement { name: "Indonesian"; code: "in" }
        ListElement { name: "Inuktitut"; code: "iu" }
        ListElement { name: "Italian"; code: "it" }
        ListElement { name: "Japanese"; code: "ja" }
        ListElement { name: "Kannada"; code: "kn" }
        ListElement { name: "Khmer"; code: "km" }
        ListElement { name: "Korean"; code: "ko" }
        ListElement { name: "Lao"; code: "lo" }
        ListElement { name: "Lithuanian"; code: "lt" }
        ListElement { name: "Malayalam"; code: "ml" }
        ListElement { name: "Maldivian"; code: "dv" }
        ListElement { name: "Myanmar"; code: "my" }
        ListElement { name: "Nepali"; code: "ne" }
        ListElement { name: "Norwegian"; code: "no" }
        ListElement { name: "Oriya"; code: "or" }
        ListElement { name: "Panjabi"; code: "pa" }
        ListElement { name: "Persian"; code: "fa" }
        ListElement { name: "Polish"; code: "pl" }
        ListElement { name: "Portuguese"; code: "pt" }
        ListElement { name: "Russian"; code: "ru" }
        ListElement { name: "Sinhala"; code: "si" }
        ListElement { name: "Spanish"; code: "es" }
        ListElement { name: "Swedish"; code: "sv" }
        ListElement { name: "Tamil"; code: "ta" }
        ListElement { name: "Telugu"; code: "te" }
        ListElement { name: "Thai"; code: "th" }
        ListElement { name: "Tibetan"; code: "bo" }
        ListElement { name: "Turkish"; code: "tr" }
        ListElement { name: "Urdu"; code: "ur" }
        ListElement { name: "Vietnamese"; code: "vi" }
    }
}
