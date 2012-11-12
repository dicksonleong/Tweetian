import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import "Component"
import "Services/Twitter.js" as Twitter

Page{
    id: userCategoryPage

    Component.onCompleted: script.refresh()

    tools: ToolBarLayout{
        ToolIcon{
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
    }

    AbstractListView{
        id: userCategoryView
        anchors{ top: header.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
        delegate: userCategoryDelegate
        model: ListModel{}
        onPullDownRefresh: script.refresh()
    }

    ScrollDecorator{ flickableItem: userCategoryView }

    PageHeader{
        id: header
        headerText: qsTr("Suggested User Categories")
        headerIcon: "image://theme/icon-m-toolbar-people-white-selected"
        onClicked: userCategoryView.positionViewAtBeginning()
    }

    QtObject{
        id: script

        function onSuccess(data){
            for(var i=0; i<data.length; i++){
                userCategoryView.model.append(data[i])
            }
            header.busy = false
        }

        function onFailure(status, statusText){
            infoBanner.showHttpError(status, statusText)
            header.busy = false
        }

        function refresh(){
            userCategoryView.model.clear()
            Twitter.getSuggestedUserCategories(onSuccess, onFailure)
            header.busy = true
        }
    }

    Component{
        id: userCategoryDelegate

        ListItem{
            id: userCategoryItem
            width: ListView.view.width
            height: categoryText.height + categoryText.anchors.topMargin * 2
            subItemIndicator: true
            marginLineVisible: false

            Text{
                id: categoryText
                anchors{
                    left: userCategoryItem.left
                    top: userCategoryItem.top
                    right: countBubble.left
                    topMargin: constant.paddingXXLarge
                    leftMargin: constant.paddingMedium
                }
                elide: Text.ElideRight
                text: model.name
                font.pixelSize: constant.fontSizeLarge
                color: constant.colorLight
            }

            CountBubble{
                id: countBubble
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: constant.paddingMedium + listItemRightMargin
                largeSized: true
                value: model.size
            }

            onClicked: pageStack.push(Qt.resolvedUrl("SuggestedUserPage.qml"), {slug: model.slug})
        }
    }
}
