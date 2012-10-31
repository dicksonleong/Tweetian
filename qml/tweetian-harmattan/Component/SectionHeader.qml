import QtQuick 1.1

Item{
    id: root
    implicitWidth: parent.width
    implicitHeight: text.height

    property string text: ""

    Rectangle{
        id: line
        anchors{
            left: parent.left
            right: text.left; rightMargin: constant.paddingXLarge
            verticalCenter: parent.verticalCenter
        }
        color: constant.colorMid
        height: 1
    }

    Text{
        id: text
        anchors.right: parent.right
        anchors.rightMargin: constant.paddingXLarge
        text: root.text
        color: constant.colorMid
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignRight
        font.pixelSize: constant.fontSizeXSmall
        font.bold: true
    }
}
