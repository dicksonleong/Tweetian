import QtQuick 1.1
import com.nokia.meego 1.0

CommonDialog{
    id: root

    property bool __isClosing: false

    signal signIn(string username, string password)

    buttonTexts: [qsTr("Sign In"), qsTr("Cancel")]
    content: Item{
        id: contentItem
        anchors { left: parent.left; right: parent.right; top: parent.top }
        anchors.topMargin: root.platformStyle.contentMargin
        height: textFieldColumn.height + anchors.topMargin * 2

        Column{
            id: textFieldColumn
            anchors {
                left: parent.left
                right: parent.right
                margins: constant.paddingMedium
            }
            spacing: constant.paddingLarge
            height: childrenRect.height

            TextField{
                id: usernameTextField
                width: parent.width
                placeholderText: qsTr("Username")
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                platformSipAttributes: SipAttributes {
                    actionKeyEnabled: usernameTextField.text.length > 0
                    actionKeyHighlighted: true
                    actionKeyLabel: qsTr("Next")
                }
                Keys.onReturnPressed: passwordTextField.forceActiveFocus()
            }

            TextField{
                id: passwordTextField
                width: parent.width
                placeholderText: qsTr("Password")
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                echoMode: TextInput.Password
                platformSipAttributes: SipAttributes {
                    actionKeyEnabled: passwordTextField.text.length > 0
                    actionKeyHighlighted: true
                    actionKeyLabel: qsTr("Sign In")
                }
                Keys.onReturnPressed: {
                    passwordTextField.platformCloseSoftwareInputPanel()
                    root.accept()
                }
            }
        }
    }

    onAccepted: root.signIn(usernameTextField.text, passwordTextField.text)

    Component.onCompleted:open()

    onStatusChanged: {
        if(status === DialogStatus.Closing) __isClosing = true
        else if(status === DialogStatus.Closed && __isClosing) root.destroy(250)
    }
}
