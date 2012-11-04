import QtQuick 1.1
import com.nokia.meego 1.0
import "../Component"

Page{
    id: root

    property string headerText
    property int headerNumber: 0
    property string emptyText
    property alias delegate: listView.delegate
    property string reloadType: "all"

    property bool backButtonEnabled: true
    property bool loadMoreButtonVisible: true

    property QtObject userInfoData
    property ListView listView: listView

    signal reload

    onStatusChanged: if(status === PageStatus.Deactivating) loadingRect.visible = false
    Component.onCompleted: reload()

    tools: ToolBarLayout{
        ToolIcon{
            platformIconId: "toolbar-back" + (enabled ? "" : "-dimmed")
            enabled: backButtonEnabled
            onClicked: pageStack.pop()
        }
    }

    AbstractListView{
        id: listView
        anchors{ top: header.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
        model: ListModel{}
        footer: LoadMoreButton{
            visible: loadMoreButtonVisible
            enabled: !loadingRect.visible
            onClicked: {
                reloadType = "older"
                reload()
            }
        }
        onPullDownRefresh: {
            reloadType = "all"
            reload()
        }
    }

    Text{
        anchors.centerIn: parent
        font.pixelSize: constant.fontSizeXXLarge
        color: constant.colorMid
        text: root.emptyText
        visible: listView.count == 0 && !loadingRect.visible
    }

    ScrollDecorator{ flickableItem: listView }

    PageHeader{
        id: header
        headerIcon: userInfoData.profileImageUrl
        headerText: "<b>@" + userInfoData.screenName + "</b>: " + root.headerText
        countBubbleVisible: true
        countBubbleValue: root.headerNumber
        onClicked: listView.positionViewAtBeginning()
    }
}
