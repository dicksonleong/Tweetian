import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "SettingsPageCom"

Page{
    id: advSearchPage

    property string searchQuery: ""

    function __contructQuery(){
        var query = ""

        if(allOfTheseWordsField.textFieldText && allOfTheseWordsField.acceptableInput)
            query += allOfTheseWordsField.textFieldText + " "
        if(exactPhraseField.textFieldText && exactPhraseField.acceptableInput)
            query += "\"" + exactPhraseField.textFieldText + "\" "
        if(anyOfTheseWordsField.textFieldText && anyOfTheseWordsField.acceptableInput)
            query += anyOfTheseWordsField.textFieldText.replace(/ /g, " OR ") + " "
        if(noneOfTheseWordsField.textFieldText && noneOfTheseWordsField.acceptableInput)
            query += "-" + noneOfTheseWordsField.textFieldText.replace(/ /g, " -") + " "
        if(languageSelectionDialog.model.get(languageSelectionDialog.selectedIndex).code)
            query += "lang:" + languageSelectionDialog.model.get(languageSelectionDialog.selectedIndex).code + " "
        if(fromTheseUsersField.textFieldText && fromTheseUsersField.acceptableInput)
            query += "from:" + fromTheseUsersField.textFieldText.replace(/@/g, "").replace(/ /g, " OR from:") + " "
        if(toTheseUsersField.textFieldText && toTheseUsersField.acceptableInput)
            query += "to:" + toTheseUsersField.textFieldText.replace(/@/g, "").replace(/ /g, " OR to:") + " "
        if(mentioningTheseUsersField.textFieldText && mentioningTheseUsersField.acceptableInput)
            query += "@" + mentioningTheseUsersField.textFieldText.replace(/@/g, "").replace(/ /g, " OR @") + " "
        if(tweetSourceField.textFieldText && tweetSourceField.acceptableInput)
            query += "source:" + tweetSourceField.textFieldText.replace(/ /g, " OR source:") + " "
        if(linkFilterSwitch.checked)
            query += "filter:links "
        if(imageFilterSwitch.checked)
            query += "filter:images "
        if(videoFilterSwitch.checked)
            query += "filter:videos "
        if(positiveAttitudeSwitch.checked)
            query += ":) "
        if(negativeAttitudeSwitch.checked)
            query += ":( "
        if(questionSwitch.checked)
            query += "? "
        if(includeRetweetsSwitch.checked) query += "include:retweets"
        else query += "exclude:retweets"

        return query
    }

    tools: ToolBarLayout{
        ToolButton{
            platformInverted: settings.invertedTheme
            text: "Search"
            onClicked: pageStack.push(Qt.resolvedUrl("SearchPage.qml"), {searchName: __contructQuery()})
        }
        ToolButton{
            platformInverted: settings.invertedTheme
            text: "Cancel"
            onClicked: pageStack.pop()
        }
    }

    Flickable{
        id: advSearchFlickable
        anchors { left: parent.left; right: parent.right; top: header.bottom; bottom: parent.bottom }
        contentHeight: mainColumn.height
        flickableDirection: Flickable.VerticalFlick

        Column{
            id: mainColumn
            anchors{ left: parent.left; right: parent.right }
            height: childrenRect.height
            spacing: constant.paddingLarge

            SectionHeader{ text: "Words" }

            SettingTextField{
                id: allOfTheseWordsField
                settingText: "All of these words"
                textFieldText: searchQuery
                validator: RegExpValidator{ regExp: /(^$|^\S$|^\S.*\S$)/ }
                placeHolderText: "eg. Tweetian Symbian MeeGo"
            }

            SettingTextField{
                id: exactPhraseField
                settingText: "Exact phrase"
                validator: RegExpValidator{ regExp: /(^$|^\S$|^\S.*\S$)/ }
                placeHolderText: "eg. Tweetian is amazing"
            }

            SettingTextField{
                id: anyOfTheseWordsField
                settingText: "Any of these words"
                validator: RegExpValidator{ regExp: /(^$|^\S$|^\S.*\S$)/ }
                placeHolderText: "eg. Symbian MeeGo"
            }

            SettingTextField{
                id: noneOfTheseWordsField
                settingText: "None of these words"
                validator: RegExpValidator{ regExp: /(^$|^\S$|^\S.*\S$)/ }
                placeHolderText: "eg. iPhone Android"
            }

            ListItem{
                id: languageListItem
                platformInverted: settings.invertedTheme
                height: textColumn.height + 2 * textColumn.anchors.margins

                Column{
                    id: textColumn
                    height: childrenRect.height
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: constant.paddingLarge }

                    ListItemText{
                        platformInverted: languageListItem.platformInverted
                        text: "Language"
                        mode: languageListItem.mode
                        role: "Title"
                    }

                    ListItemText{
                        platformInverted: languageListItem.platformInverted
                        text: languageSelectionDialog.model.get(languageSelectionDialog.selectedIndex).name
                        mode: languageListItem.mode
                        role: "SubTitle"
                    }
                }

                Image{
                    anchors{
                        right: parent.right
                        rightMargin: constant.paddingMedium
                        verticalCenter: parent.verticalCenter
                    }
                    source: languageListItem.platformInverted ? "image://theme/qtg_graf_choice_list_indicator_inverse"
                                                              : "image://theme/qtg_graf_choice_list_indicator"
                }
                onClicked: languageSelectionDialog.open()
            }

            SectionHeader{ text: "Users" }

            SettingTextField{
                id: fromTheseUsersField
                settingText: "From any of these users"
                validator: RegExpValidator{ regExp: /(^$|^\S$|^\S.*\S$)/ }
                placeHolderText: "eg. user1 user2 user3"
            }

            SettingTextField{
                id: toTheseUsersField
                settingText: "To any of these users"
                validator: RegExpValidator{ regExp: /(^$|^\S$|^\S.*\S$)/ }
                placeHolderText: "eg. user1 user2 user3"
            }

            SettingTextField{
                id: mentioningTheseUsersField
                settingText: "Mentioning any of these users"
                validator: RegExpValidator{ regExp: /(^$|^\S$|^\S.*\S$)/ }
                placeHolderText: "eg. user1 user2 user3"
            }

            SectionHeader{ text: "Filters" }

            SettingSwitch{
                id: linkFilterSwitch
                text: "Contain links"
            }

            SettingSwitch{
                id: imageFilterSwitch
                text: "Contain images"
            }

            SettingSwitch{
                id: videoFilterSwitch
                text: "Contain videos"
            }

            SectionHeader{ text: "Other" }

            SettingTextField{
                id: tweetSourceField
                settingText: "From any of these sources"
                validator: RegExpValidator{ regExp: /(^$|^\S$|^\S.*\S$)/ }
                placeHolderText: "eg. Tweetian Tweet_Button"
            }

            SettingSwitch{
                id: positiveAttitudeSwitch
                text: "Position attitude :)"
            }

            SettingSwitch{
                id: negativeAttitudeSwitch
                text: "Negative attitude :("
            }

            SettingSwitch{
                id: questionSwitch
                text: "Question ?"
            }

            SettingSwitch{
                id: includeRetweetsSwitch
                text: "Include retweets"
            }
        }
    }

    ScrollDecorator { platformInverted: settings.invertedTheme; flickableItem: advSearchFlickable }

    PageHeader{
        id: header
        headerIcon: "image://theme/toolbar-search"
        headerText: "Advanced Search"
        onClicked: advSearchFlickable.contentY = 0
    }

    SelectionDialog{
        id: languageSelectionDialog
        platformInverted: settings.invertedTheme
        titleText: "Language"
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
                anchors{
                    right: parent.right
                    rightMargin: constant.paddingMedium
                    verticalCenter: parent.verticalCenter
                }
                source: selectedIndex === index ? (platformInverted ? "Image/selection_indicator_inverse.svg"
                                                                    : "Image/selection_indicator.svg") : ""
                sourceSize.height: constant.graphicSizeSmall
                sourceSize.width: constant.graphicSizeSmall
            }
        }
    }

    ListModel{
        id: languageModel
        ListElement{ name: "Any Language"; code: "" }
        ListElement{ name: "Amharic"; code: "am" }
        ListElement{ name: "Arabic"; code: "ar" }
        ListElement{ name: "Armenian"; code: "hy" }
        ListElement{ name: "Bengali"; code: "bn" }
        ListElement{ name: "Bulgarian"; code: "bg" }
        ListElement{ name: "Cherokee"; code: "chr" }
        ListElement{ name: "Chinese"; code: "zh" }
        ListElement{ name: "Danish"; code: "da" }
        ListElement{ name: "Dutch"; code: "nl" }
        ListElement{ name: "English"; code: "en" }
        ListElement{ name: "Finnish"; code: "fi" }
        ListElement{ name: "French"; code: "fr" }
        ListElement{ name: "Georgian"; code: "ka" }
        ListElement{ name: "German"; code: "de" }
        ListElement{ name: "Greek"; code: "el" }
        ListElement{ name: "Gujarati"; code: "gu" }
        ListElement{ name: "Hebrew"; code: "iw" }
        ListElement{ name: "Hindi"; code: "hi" }
        ListElement{ name: "Hungarian"; code: "hu" }
        ListElement{ name: "Icelandic"; code: "is" }
        ListElement{ name: "Indonesian"; code: "in" }
        ListElement{ name: "Inuktitut"; code: "iu" }
        ListElement{ name: "Italian"; code: "it" }
        ListElement{ name: "Japanese"; code: "ja" }
        ListElement{ name: "Kannada"; code: "kn" }
        ListElement{ name: "Khmer"; code: "km" }
        ListElement{ name: "Korean"; code: "ko" }
        ListElement{ name: "Lao"; code: "lo" }
        ListElement{ name: "Lithuanian"; code: "lt" }
        ListElement{ name: "Malayalam"; code: "ml" }
        ListElement{ name: "Maldivian"; code: "dv" }
        ListElement{ name: "Myanmar"; code: "my" }
        ListElement{ name: "Nepali"; code: "ne" }
        ListElement{ name: "Norwegian"; code: "no" }
        ListElement{ name: "Oriya"; code: "or" }
        ListElement{ name: "Panjabi"; code: "pa" }
        ListElement{ name: "Persian"; code: "fa" }
        ListElement{ name: "Polish"; code: "pl" }
        ListElement{ name: "Portuguese"; code: "pt" }
        ListElement{ name: "Russian"; code: "ru" }
        ListElement{ name: "Sinhala"; code: "si" }
        ListElement{ name: "Spanish"; code: "es" }
        ListElement{ name: "Swedish"; code: "sv" }
        ListElement{ name: "Tamil"; code: "ta" }
        ListElement{ name: "Telugu"; code: "te" }
        ListElement{ name: "Thai"; code: "th" }
        ListElement{ name: "Tibetan"; code: "bo" }
        ListElement{ name: "Turkish"; code: "tr" }
        ListElement{ name: "Urdu"; code: "ur" }
        ListElement{ name: "Vietnamese"; code: "vi" }
    }
}
