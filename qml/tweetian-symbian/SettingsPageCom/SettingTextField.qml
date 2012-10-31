import QtQuick 1.1
import com.nokia.symbian 1.1

Item{
    id: root

    property string settingText: ""
    property alias textFieldText: textField.text
    property alias placeHolderText: textField.placeholderText
    property alias validator: textField.validator

    property alias acceptableInput: textField.acceptableInput

    implicitHeight: column.height
    implicitWidth: parent.width

    Column{
        id: column
        anchors{
            left: parent.left
            right: parent.right
            leftMargin: constant.paddingMedium
            rightMargin: constant.paddingLarge // for scroll bar
        }
        height: childrenRect.height
        spacing: constant.paddingMedium

        Text{
            anchors{ left: parent.left; right: parent.right }
            font.pixelSize: constant.fontSizeMedium
            color: constant.colorLight
            text: settingText
        }

        TextField{
            id: textField
            anchors{ left: parent.left; right: parent.right }
            platformInverted: settings.invertedTheme
        }
    }
}
