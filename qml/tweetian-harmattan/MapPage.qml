import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.location 1.2
import "Dialog"
import "Utils/Calculations.js" as Calculate
import "Services/Global.js" as G

Page{
    id: mapPage

    property double latitude: 0
    property double longitude: 0

    tools: ToolBarLayout{
        ToolIcon{
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolIcon{
            platformIconId: "toolbar-view-menu"
            onClicked: menu.open()
        }
    }

    Menu{
        id: menu

        MenuLayout{
            MenuItem{
                text: "View coordinate"
                onClicked: coordinateDialogComponent.createObject(mapPage)
            }
            MenuItem{
                text: "Open in Nokia Maps"
                onClicked: Qt.openUrlExternally("geo:" + latitude + "," + longitude)
            }
        }
    }

    Coordinate{
        id: tweetCoordinates
        latitude: mapPage.latitude
        longitude: mapPage.longitude
    }

    Map{
        id: map
        plugin: Plugin{
            name: "nokia"
            parameters: [
                PluginParameter{ name: "app_id"; value: G.Global.NokiaMaps.APP_ID },
                PluginParameter{ name: "app_code"; value: G.Global.NokiaMaps.APP_TOKEN }
            ]
        }
        anchors.fill: parent
        size.width: parent.width
        size.height: parent.height
        zoomLevel: 10
        center: tweetCoordinates

        MapImage{
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

    Slider{
        id: zoomSlider
        anchors{ right: parent.right; rightMargin: constant.paddingMedium; verticalCenter: parent.verticalCenter }
        height: parent.height / 2
        maximumValue: map.maximumZoomLevel
        minimumValue: map.minimumZoomLevel
        stepSize: 1
        orientation: Qt.Vertical
        valueIndicatorVisible: true
        onValueChanged: if(pressed) map.zoomLevel = value
    }

    // Create binding of slider value to zoomLevel when not sliding
    Binding{
        when: !zoomSlider.pressed
        target: zoomSlider
        property: "value"
        value: map.zoomLevel
    }

    Component{
        id: coordinateDialogComponent

        CommonDialog{
            id: coordinateDialog
            property bool __isClosing: false
            titleText: "Location Coordinate"
            titleIcon: "image://theme/icon-l-location-test"
            buttonTexts: ["Copy", "Close"]
            content: Column{
                anchors{ left: parent.left; right: parent.right; top: parent.top; margins: constant.paddingMedium}
                anchors.topMargin: coordinateDialog.platformStyle.contentMargin
                height: childrenRect.height + 2 * anchors.topMargin
                spacing: constant.paddingMedium

                ButtonRow{
                    width: parent.width
                    Button{
                        id: degree
                        text: "Degree"
                    }
                    Button{
                        id: decimal
                        text: "Decimal"
                    }
                }
                TextField{
                    id: coordinateTextField
                    width: parent.width
                    readOnly: true
                    text: degree.checked ? Calculate.toDegree(latitude, longitude) : latitude + ", " + longitude
                }
            }
            onButtonClicked: {
                if(index == 0){
                    clipboard.setText(coordinateTextField.text)
                    infoBanner.alert("Coordinate copied to clipboard.")
                }
            }
            Component.onCompleted: open()
            onStatusChanged: {
                if(status === DialogStatus.Closing) __isClosing = true
                else if(status === DialogStatus.Closed && __isClosing) coordinateDialog.destroy(250)
            }
        }
    }
}
