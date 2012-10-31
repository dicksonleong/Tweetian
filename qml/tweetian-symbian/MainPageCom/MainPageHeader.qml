import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"

Item{
    id: mainPageHeader
    anchors { top: parent.top; left: parent.left; right: parent.right }
    height: constant.headerHeight

    Image {
        id: background
        anchors.fill: parent
        source: "../Image/header.png"
    }

    Image{
        anchors { top: parent.top; left: parent.left }
        source: "../Image/meegoTLCorner.png"
    }

    Image{
        anchors { top: parent.top; right: parent.right }
        source: "../Image/meegoTRCorner.png"
    }

    Row{
        anchors.fill: parent

        Repeater{
            id: sectionRepeater
            model: mainView.count
            delegate: Item{
                width: mainPageHeader.width / sectionRepeater.count
                height: mainPageHeader.height

                Image {
                    id: icon
                    anchors.centerIn: parent
                    source: index == 0 ? "../Image/home.svg" : index == 1 ? "../Image/mail.svg" : "../Image/inbox.svg"
                    sourceSize.height: constant.graphicSizeSmall
                    sourceSize.width: constant.graphicSizeSmall
                }

                CountBubble{
                    anchors {
                        left: icon.right
                        leftMargin: -constant.paddingMedium
                        top: parent.top
                        topMargin: constant.paddingSmall
                    }
                    visible: value > 0
                    value: mainView.model.children[index].unreadCount
                }

                Loader{
                    anchors.fill: parent
                    sourceComponent: mainView.model.children[index].busy
                                     ? busyIndicator : (sectionMouseArea.pressed ? pressingIndicator : undefined)
                    Component{
                        id: busyIndicator

                        Rectangle{
                            anchors.fill: parent
                            color: "black"
                            opacity: 0

                            Behavior on opacity { NumberAnimation { duration: 250 } }

                            BusyIndicator{
                                opacity: 1
                                anchors.centerIn: parent
                                running: true
                            }

                            Component.onCompleted: opacity = 0.75
                        }
                    }

                    Component{
                        id: pressingIndicator

                        Rectangle{
                            anchors.fill: parent
                            color: "black"
                            opacity: 0.5
                        }
                    }
                }

                MouseArea{
                    id: sectionMouseArea
                    anchors.fill: parent
                    onClicked: mainView.currentIndex === index ? mainView.currentItem.positionAtTop()
                                                               : mainView.moveToColumn(index)
                    onPressed: basicHapticEffect.play()
                    onReleased: basicHapticEffect.play()
                }
            }
        }
    }

    Rectangle{
        id: currentSectionIndicator
        anchors.bottom: parent.bottom
        color: "white"
        height: constant.paddingSmall
        width: mainView.visibleArea.widthRatio * parent.width
        x: mainView.visibleArea.xPosition * parent.width
    }
}
