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

QtObject{
    id: constant

    // color
    property color colorHighlighted: colorLight
    property color colorLight: settings.invertedTheme ? "#191919" : "#ffffff"
    property color colorMid: settings.invertedTheme ? "#666666" : "#8c8c8c"
    property color colorTextSelection: "#4591ff"
    property color colorDisabled: settings.invertedTheme ? "#b2b2b4" : "#444444"

    // padding size
    property int paddingSmall: 4
    property int paddingMedium: 6
    property int paddingLarge: 8
    property int paddingXLarge: 12
    property int paddingXXLarge: 16

    // font size
    property int fontSizeXSmall: 20
    property int fontSizeSmall: 22
    property int fontSizeMedium: 24
    property int fontSizeLarge: 26
    property int fontSizeXLarge: 28
    property int fontSizeXXLarge: 32

    // graphic size
    property int graphicSizeTiny: 24
    property int graphicSizeSmall: 32
    property int graphicSizeMedium: 48
    property int graphicSizeLarge: 72

    property int thumbnailSize: 150

    // other
    property int borderSizeMedium: 20
    property int headerHeight: inPortrait ? 65 : 55

    // --Twitter--
    property int charReservedPerMedia: 22
    property url twitterBirdIcon: settings.invertedTheme ? "Image/twitter-bird-light.png" : "Image/twitter-bird-dark.png"
}
