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
import com.nokia.meego 1.0 // for Style

Style {

    // Font
    property int fontPixelSize: 68
    property bool fontBoldProperty: true

    // Color
    property color textColor: inverted?"#000":"#fff"

    property string handleImage: "image://theme/meegotouch-fast-scroll-handle"+__invertedString
    property string magnifierImage: "image://theme/meegotouch-fast-scroll-magnifier"+__invertedString
    property string railImage: "image://theme/meegotouch-fast-scroll-rail"+__invertedString
}
