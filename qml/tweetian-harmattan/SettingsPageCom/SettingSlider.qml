import QtQuick 1.1
import com.nokia.meego 1.0

Item{
    id: root

    property string text: ""
    property alias maximumValue: slider.maximumValue
    property alias stepSize: slider.stepSize
    property alias value: slider.value
    signal released

    implicitWidth: parent.width
    height: mainText.height + slider.height + 2 * constant.paddingMedium + slider.anchors.margins

    Text{
        id: mainText
        anchors{ top: parent.top; left: parent.left; margins: constant.paddingMedium }
        font.pixelSize: constant.fontSizeLarge
        color: constant.colorLight
        text: root.text
    }

    Slider{
        id: slider
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: mainText.bottom
        anchors.margins: constant.paddingSmall
        enabled: root.enabled
        minimumValue: 0
        valueIndicatorText: value == 0 ? "Off" : value
        valueIndicatorVisible: true
        onPressedChanged: if(!pressed) root.released()
    }
}
