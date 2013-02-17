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
        ToolButton {
            platformInverted: settings.invertedTheme
            text: qsTr("Search")
            onClicked: pageStack.push(Qt.resolvedUrl("SearchPage.qml"), {searchString: __contructQuery()})
        }
        ToolButton {
            platformInverted: settings.invertedTheme
            text: qsTr("Cancel")
            onClicked: pageStack.pop()
        }
    }

    Flickable {
        id: advSearchFlickable
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
                id: languageListItem
                platformInverted: settings.invertedTheme
                height: textColumn.height + 2 * constant.paddingLarge

                Column {
                    id: textColumn
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.paddingItem.left
                        right: choiceListIcon.left; rightMargin: constant.paddingMedium
                    }
                    height: childrenRect.height

                    ListItemText {
                        platformInverted: languageListItem.platformInverted
                        text: qsTr("Language")
                        mode: languageListItem.mode
                        role: "Title"
                    }

                    ListItemText {
                        platformInverted: languageListItem.platformInverted
                        text: languageSelectionDialog.model.get(languageSelectionDialog.selectedIndex).name
                        mode: languageListItem.mode
                        role: "SubTitle"
                    }
                }

                Image {
                    id: choiceListIcon
                    anchors { verticalCenter: parent.verticalCenter; right: parent.paddingItem.right }
                    source: languageListItem.platformInverted ? "image://theme/qtg_graf_choice_list_indicator_inverse"
                                                              : "image://theme/qtg_graf_choice_list_indicator"
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
                placeHolderText: qsTr("eg. %1").arg("Tweetian_for_Symbian")
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

    ScrollDecorator { platformInverted: settings.invertedTheme; flickableItem: advSearchFlickable }

    PageHeader {
        id: header
        headerIcon: "image://theme/toolbar-search"
        headerText: qsTr("Advanced Search")
        onClicked: advSearchFlickable.contentY = 0
    }

    SelectionDialog {
        id: languageSelectionDialog
        platformInverted: settings.invertedTheme
        titleText: qsTr("Language")
        model: languageModel
        selectedIndex: 0
        delegate: MenuItem {
            platformInverted: languageSelectionDialog.platformInverted
            text: model.name
            onClicked: {
                selectedIndex = index
                languageSelectionDialog.accept()
            }

            Image {
                anchors {
                    right: parent.right; rightMargin: constant.paddingMedium
                    verticalCenter: parent.verticalCenter
                }
                sourceSize { height: constant.graphicSizeSmall; width: constant.graphicSizeSmall }
                source: selectedIndex === index ? (platformInverted ? "Image/selection_indicator_inverse.svg"
                                                                    : "Image/selection_indicator.svg") : ""
            }
        }
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
