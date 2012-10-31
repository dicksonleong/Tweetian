import QtQuick 1.1
import com.nokia.meego 1.0

Dialog{
    id: root

    property string titleText: ""
    property alias titleIcon: iconImage.source
    property variant buttonTexts: []
    signal buttonClicked(int index)

    objectName: "commonDialog"
    platformStyle: DialogStyle{
        property int contentMargin: 21
        leftMargin: constant.paddingLarge
        rightMargin: constant.paddingLarge
    }
    title: Item {
        id: titleField
        width: parent.width
        height: titleText == "" ? titleBarIconField.height :
                    titleBarIconField.height + titleTextText.height + titleFieldCol.spacing
        Column {
            id: titleFieldCol
            spacing: 17

            anchors.left:  parent.left
            anchors.right:  parent.right
            anchors.top:  parent.top

            Item {
                id: titleBarIconField
                height: iconImage.height
                width: parent.width
                Image {
                    id: iconImage
                    anchors.horizontalCenter: titleBarIconField.horizontalCenter
                    source: ""
                }

            }

            Item {
                id: titleBarTextField
                height: titleTextText.height
                width: parent.width

                Text {
                    id: titleTextText
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment:   Text.AlignVCenter
                    font.pixelSize: constant.fontSizeXXLarge
                    font.bold: true
                    color: "white"
                    elide: root.platformStyle.titleElideMode
                    wrapMode: elide == Text.ElideNone ? Text.Wrap : Text.NoWrap
                    text: root.titleText
                }
            }
        }
    }

    buttons: Item{
        anchors.left: parent.left
        anchors.right: parent.right
        height: buttonCol.height + buttonCol.anchors.topMargin

        Column {
            id: buttonCol
            anchors.top: parent.top
            anchors.topMargin: root.platformStyle.buttonsTopMargin
            spacing: root.platformStyle.buttonsColumnSpacing
            height: childrenRect.height
            anchors.horizontalCenter: parent.horizontalCenter

            Repeater{
                model: buttonTexts

                Button {
                    text: modelData
                    onClicked: {
                        buttonClicked(index)
                        if(index === 0) accept()
                        else reject()
                    }
                    platformStyle: ButtonStyle{
                        inverted: true
                        background: index === 0 ? "image://theme/meegotouch-dialog-button-positive"
                                                : "image://theme/meegotouch-dialog-button-negative"
                        pressedBackground: index === 0 ? "image://theme/meegotouch-dialog-button-positive-pressed"
                                                       : "image://theme/meegotouch-dialog-button-negative-pressed"
                    }
                }
            }
        }
    }
}
