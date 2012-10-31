import QtQuick 1.1
import com.nokia.symbian 1.1

ToolButton{
    id: root

    property string toolTipText: ""

    opacity: enabled ? 1 : 0.25
    platformInverted: settings.invertedTheme
    onPlatformPressAndHold: {
        toolTip.target = root
        toolTip.text = toolTipText
        toolTip.show()
    }
    onPlatformReleased: toolTip.hide()
}
