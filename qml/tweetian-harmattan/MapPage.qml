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
import QtMobility.location 1.2
import "Dialog"
import "Utils/Calculations.js" as Calculate

Page {
    id: mapPage

    property double latitude: 0
    property double longitude: 0

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            onClicked: menu.open()
        }
    }

    Menu {
        id: menu

        MenuLayout {
            MenuItem {
                text: qsTr("View coordinates")
                onClicked: coordinateDialogComponent.createObject(mapPage)
            }
            MenuItem {
                text: qsTr("Open in Nokia Maps")
                onClicked: Qt.openUrlExternally("geo:" + latitude + "," + longitude)
            }
        }
    }

    Coordinate {
        id: tweetCoordinates
        latitude: mapPage.latitude
        longitude: mapPage.longitude
    }

    Map {
        id: map
        anchors.fill: parent
        size.width: parent.width
        size.height: parent.height
        zoomLevel: 10
        center: tweetCoordinates
        plugin: Plugin {
            name: "nokia"
            parameters: [
                PluginParameter { name: "app_id"; value: constant.nokiaMapsAppId },
                PluginParameter { name: "app_code"; value: constant.nokiaMapsAppToken }
            ]
        }

        MapImage {
            coordinate: tweetCoordinates
            source: "Image/location_mark_blue.png"
            offset.x: -24
            offset.y: -48
        }
    }

    PinchArea {
        id: pincharea

        //! Holds previous zoom level value
        property double __oldZoom

        anchors.fill: parent

        //! Calculate zoom level
        function calcZoomDelta(zoom, percent) {
            return zoom + Math.log(percent)/Math.log(2)
        }

        //! Save previous zoom level when pinch gesture started
        onPinchStarted: {
            __oldZoom = map.zoomLevel
        }

        //! Update map's zoom level when pinch is updating
        onPinchUpdated: {
            map.zoomLevel = calcZoomDelta(__oldZoom, pinch.scale)
        }

        //! Update map's zoom level when pinch is finished
        onPinchFinished: {
            map.zoomLevel = calcZoomDelta(__oldZoom, pinch.scale)
        }
    }

    //! Map's mouse area for implementation of panning in the map
    MouseArea {
        id: mousearea

        //! Property used to indicate if panning the map
        property bool __isPanning: false

        //! Last pressed X and Y position
        property int __lastX: -1
        property int __lastY: -1

        anchors.fill : parent

        //! When pressed, indicate that panning has been started and update saved X and Y values
        onPressed: {
            __isPanning = true
            __lastX = mouse.x
            __lastY = mouse.y
        }

        //! When released, indicate that panning has finished
        onReleased: {
            __isPanning = false
        }

        //! Move the map when panning
        onPositionChanged: {
            if (__isPanning) {
                var dx = mouse.x - __lastX
                var dy = mouse.y - __lastY
                map.pan(-dx, -dy)
                __lastX = mouse.x
                __lastY = mouse.y
            }
        }

        //! When canceled, indicate that panning has finished
        onCanceled: {
            __isPanning = false;
        }
    }

    Slider {
        id: zoomSlider
        anchors { right: parent.right; rightMargin: constant.paddingMedium; verticalCenter: parent.verticalCenter }
        height: parent.height / 2
        maximumValue: map.maximumZoomLevel
        minimumValue: map.minimumZoomLevel
        stepSize: 1
        orientation: Qt.Vertical
        valueIndicatorVisible: true
        onValueChanged: if (pressed) map.zoomLevel = value

        // Create binding of slider value to zoomLevel when not sliding
        Binding {
            when: !zoomSlider.pressed
            target: zoomSlider
            property: "value"
            value: map.zoomLevel
        }
    }

    Component {
        id: coordinateDialogComponent

        CommonDialog {
            id: coordinateDialog
            property bool __isClosing: false
            titleText: qsTr("Location Coordinates")
            titleIcon: "image://theme/icon-l-location-test"
            buttonTexts: [qsTr("Copy"), qsTr("Close")]
            content: Column {
                anchors {
                    top: parent.top; topMargin: coordinateDialog.platformStyle.contentMargin
                    left: parent.left
                    right: parent.right
                    margins: constant.paddingMedium
                }
                height: childrenRect.height + 2 * anchors.topMargin
                spacing: constant.paddingMedium

                ButtonRow {
                    anchors { left: parent.left; right: parent.right }
                    Button {
                        id: degree
                        text: qsTr("Degrees")
                    }
                    Button {
                        id: decimal
                        text: qsTr("Decimal")
                    }
                }
                TextField {
                    id: coordinateTextField
                    anchors { left: parent.left; right: parent.right }
                    readOnly: true
                    text: degree.checked ? Calculate.toDegree(latitude, longitude) : latitude + ", " + longitude
                }
            }
            onButtonClicked: {
                if (index === 0) {
                    QMLUtils.copyToClipboard(coordinateTextField.text)
                    infoBanner.showText(qsTr("Coordinates copied to clipboard"))
                }
            }
            Component.onCompleted: open()
            onStatusChanged: {
                if (status === DialogStatus.Closing) __isClosing = true
                else if (status === DialogStatus.Closed && __isClosing) coordinateDialog.destroy(250)
            }
        }
    }
}
