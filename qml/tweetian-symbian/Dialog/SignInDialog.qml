import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog{
    id: root

    property bool __isClosing: false

    signal signIn(string username, string password)

    platformInverted: settings.invertedTheme
    buttonTexts: [qsTr("Sign In"), qsTr("Cancel")]
    content: Item{
        id: contentItem
        anchors { left: parent.left; right: parent.right; top: parent.top }
        height: textFieldColumn.height + textFieldColumn.anchors.margins * 2

        Column{
            id: textFieldColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: constant.paddingMedium
            }
            spacing: constant.paddingLarge
            height: childrenRect.height

            TextField{
                id: usernameTextField
                width: parent.width
                platformInverted: root.platformInverted
                placeholderText: qsTr("Username")
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
            }

            TextField{
                id: passwordTextField
                width: parent.width
                platformInverted: root.platformInverted
                placeholderText: qsTr("Password")
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                echoMode: TextInput.Password
            }
        }
    }
    onButtonClicked: index === 0 ? root.signIn(usernameTextField.text, passwordTextField.text) : close()

    Component.onCompleted: open()

    onStatusChanged: {
        if(status === DialogStatus.Closing) __isClosing = true
        else if(status === DialogStatus.Closed && __isClosing) root.destroy()
    }
}
