import QtQuick 1.1

Item{
    id: paneIndicator

    property ListView listView

    function show(){
        fadeOut.stop()
        opacity = 1
    }

    function hide(){
        fadeOut.start()
    }

    anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: constant.paddingMedium }
    height: constant.paddingXXLarge

    SequentialAnimation{
        id: fadeOut
        PauseAnimation{ duration: 1500 }
        NumberAnimation{
            duration: 400
            target: paneIndicator
            property: "opacity"
            from: 1
            to: 0.5
        }
    }

    Row{
        anchors.centerIn: parent
        spacing: constant.paddingMedium

        Repeater{
            model: listView.count

            Rectangle{
                id: dot
                height: paneIndicator.height
                width: height
                radius: height
                color: listView.currentIndex == index ? border.color : "transparent"
                border.width: 1
                border.color: "lightgrey"
                smooth: true
            }
        }
    }

    Component.onCompleted: hide()
}
