import QtQuick 1.1

Item{
    id: root

    property int value: 0

    height: valueText.paintedHeight + 2 * constant.paddingSmall
    width: Math.max(height, valueText.paintedWidth + 2 * constant.paddingMedium)

    BorderImage{
        anchors.fill: parent
        source: "../Image/countbubble.png"
        border { left: 10; right: 10; top: 10; bottom: 10 }
    }

    Text{
        id: valueText
        color: "white"
        font.pixelSize: constant.fontSizeSmall
        text: root.value
        anchors.centerIn: parent
    }
}
