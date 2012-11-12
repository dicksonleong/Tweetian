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

QtObject{
    id: constant

    // color
    property color colorHighlighted: settings.invertedTheme ? platformStyle.colorHighlightedInverted
                                                            : platformStyle.colorHighlighted
    property color colorLight: settings.invertedTheme ? platformStyle.colorNormalLightInverted
                                                      : platformStyle.colorNormalLight
    property color colorMid: settings.invertedTheme ? platformStyle.colorNormalMidInverted
                                                    : platformStyle.colorNormalMid
    property color colorTextSelection: settings.invertedTheme ? platformStyle.colorTextSelection
                                                              : platformStyle.colorTextSelectionInverted
    property color colorMarginLine: settings.invertedTheme ? platformStyle.colorDisabledLightInverted
                                                           : platformStyle.colorDisabledMid

    // padding size
    property int paddingSmall: platformStyle.paddingSmall
    property int paddingMedium: platformStyle.paddingMedium
    property int paddingLarge: platformStyle.paddingLarge
    property int paddingXLarge: platformStyle.paddingLarge + platformStyle.paddingSmall
    property int paddingXXLarge: platformStyle.paddingLarge + platformStyle.paddingMedium

    // font size
    property int fontSizeXSmall: platformStyle.fontSizeSmall - 2
    property int fontSizeSmall: platformStyle.fontSizeSmall
    property int fontSizeMedium: platformStyle.fontSizeMedium
    property int fontSizeLarge: platformStyle.fontSizeLarge
    property int fontSizeXLarge: platformStyle.fontSizeLarge + 2
    property int fontSizeXXLarge: platformStyle.fontSizeLarge + 6

    // graphic size
    property int graphicSizeTiny: platformStyle.graphicSizeTiny
    property int graphicSizeSmall: platformStyle.graphicSizeSmall
    property int graphicSizeMedium: platformStyle.graphicSizeMedium
    property int graphicSizeLarge: platformStyle.graphicSizeLarge

    property int thumbnailSize: platformStyle.graphicSizeLarge * 1.5

    // other
    property int borderSizeMedium: platformStyle.borderSizeMedium
    property int headerHeight: inPortrait ? 50 : 45

    // --Twitter--
    property int charReservedPerMedia: 22
    property url twitterBirdIcon: platformInverted ? "Image/twitter-bird-light.png" : "Image/twitter-bird-dark.png"
}

/*
    ---Value for Symbian's platformStyle---

    platformStyle.borderSizeMedium: 20
    platformStyle.colorBackground: #000000
    platformStyle.colorBackgroundInverted: #f1f1f1
    platformStyle.colorDisabledLight: #666666
    platformStyle.colorDisabledLightInverted: #a9a9a9
    platformStyle.colorDisabledMid: #444444
    platformStyle.colorDisabledMidInverted: #7f7f7f
    platformStyle.colorHighlighted: #ffffff
    platformStyle.colorHighlightedInverted: #282828
    platformStyle.colorNormalLight: #ffffff
    platformStyle.colorNormalLightInverted: #282828
    platformStyle.colorNormalLink: #4d8ecc
    platformStyle.colorNormalLinkInverted: #4d8ecc
    platformStyle.colorNormalMid: #999999
    platformStyle.colorNormalMidInverted: #666666
    platformStyle.colorTextSelection: #0072b2
    platformStyle.colorTextSelectionInverted: #0072b2
    platformStyle.fontFamilyRegular: Nokia Sans
    platformStyle.fontSizeLarge: 22
    platformStyle.fontSizeMedium: 20
    platformStyle.fontSizeSmall: 18
    platformStyle.graphicSizeLarge: 70
    platformStyle.graphicSizeMedium: 50
    platformStyle.graphicSizeSmall: 30
    platformStyle.graphicSizeTiny: 20
    platformStyle.paddingLarge: 12
    platformStyle.paddingMedium: 8
    platformStyle.paddingSmall: 4
*/
