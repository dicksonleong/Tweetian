import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "twitter.js" as Twitter

Page{
    id: userCategoryPage

    Component.onCompleted: script.refresh()

    tools: ToolBarLayout{
        ToolButtonWithTip{
            iconSource: "toolbar-back"
            toolTipText: "Back"
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

    ScrollDecorator{ platformInverted: settings.invertedTheme; flickableItem: userCategoryView }

    PageHeader{
        id: header
        headerText: "Suggested User Categories"
        headerIcon: "Image/people.svg"
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
            if(status === 0) infoBanner.alert("Connection error.")
            else infoBanner.alert("Error: " + status + " " + statusText)
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
            platformInverted: settings.invertedTheme
            width: ListView.view.width
            height: categoryText.height + categoryText.anchors.topMargin * 2
            subItemIndicator: true

            Text{
                id: categoryText
                anchors{
                    left: userCategoryItem.left
                    top: userCategoryItem.top
                    right: countBubble.left
                    topMargin: constant.paddingXLarge
                    leftMargin: constant.paddingMedium
                }
                elide: Text.ElideRight
                text: model.name
                font.pixelSize: constant.fontSizeLarge
                color: constant.colorLight
            }

            CountBubble{
                id: countBubble
                anchors.right: paddingItem.right
                anchors.verticalCenter: parent.verticalCenter
                value: model.size
            }

            onClicked: pageStack.push(Qt.resolvedUrl("SuggestedUserPage.qml"), {slug: model.slug})
        }
    }
}
