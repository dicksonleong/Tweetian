import QtQuick 1.1
import com.nokia.symbian 1.1

Item{
    id: root

    property string text: ""
    property alias maximumValue: slider.maximumValue
    property alias stepSize: slider.stepSize
    property alias value: slider.value
    signal released

    implicitWidth: parent.width
    height: label.height + slider.height + 2 * constant.paddingMedium + slider.anchors.margins

    Text{
        id: label
        anchors{ top: parent.top; left: parent.left; margins: constant.paddingMedium }
        font.pixelSize: constant.fontSizeLarge
        color: constant.colorLight
        text: root.text
    }

    Slider{
        id: slider
        anchors{ left: parent.left; right: parent.right; top: label.bottom; margins: constant.paddingSmall }
        platformInverted: settings.invertedTheme
        enabled: root.enabled
        minimumValue: 0
        valueIndicatorText: value == 0 ? "Off" : ""
        valueIndicatorVisible: true
        onPressedChanged: if(!pressed) root.released()
    }
}
