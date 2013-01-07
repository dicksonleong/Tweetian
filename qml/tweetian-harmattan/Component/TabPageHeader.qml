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
import com.nokia.extras 1.1

Item {
    id: tabPageHeader

    // listView must have:
    // VisualItemModel as model
    // function - moveToColumn(index)
    // Each children of VisualItemModel must have:
    // properties - busy (bool) and unreadCount (int)
    // method - positionAtTop()
    property ListView listView: null
    property variant iconArray: []

    anchors { top: parent.top; left: parent.left; right: parent.right }
    height: constant.headerHeight

    Image {
        id: background
        anchors.fill: parent
        source: "image://theme/color6-meegotouch-view-header-fixed"
    }

    Row {
        anchors.fill: parent

        Repeater {
            id: sectionRepeater
            model: iconArray
            delegate: Item {
                width: tabPageHeader.width / sectionRepeater.count
                height: tabPageHeader.height

                Image {
                    id: icon
                    anchors.centerIn: parent
                    sourceSize { height: constant.graphicSizeSmall; width: constant.graphicSizeSmall }
                    source: modelData
                }

                CountBubble {
                    anchors {
                        top: parent.top; topMargin: constant.paddingSmall
                        left: icon.right; leftMargin: -constant.paddingMedium
                    }
                    visible: value > 0
                    largeSized: true
                    value: listView.model.children[index].unreadCount
                }

                Loader {
                    anchors.fill: parent
                    sourceComponent: listView.model.children[index].busy
                                     ? busyIndicator : (sectionMouseArea.pressed ? pressingIndicator : undefined)
                    Component {
                        id: busyIndicator

                        Rectangle {
                            anchors.fill: parent
                            color: "black"
                            opacity: 0

                            Behavior on opacity { NumberAnimation { duration: 250 } }

                            BusyIndicator {
                                opacity: 1
                                anchors.centerIn: parent
                                running: true
                                platformStyle: BusyIndicatorStyle { inverted: true }
                            }

                            Component.onCompleted: opacity = 0.75
                        }
                    }

                    Component {
                        id: pressingIndicator

                        Rectangle {
                            anchors.fill: parent
                            color: "black"
                            opacity: 0.5
                        }
                    }
                }

                MouseArea {
                    id: sectionMouseArea
                    anchors.fill: parent
                    onClicked: listView.currentIndex === index ? listView.currentItem.positionAtTop()
                                                               : listView.moveToColumn(index)
                }
            }
        }
    }

    Rectangle {
        id: currentSectionIndicator
        anchors.bottom: parent.bottom
        color: "white"
        height: constant.paddingSmall
        width: listView.visibleArea.widthRatio * parent.width
        x: listView.visibleArea.xPosition * parent.width
    }
}
