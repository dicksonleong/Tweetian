import QtQuick 1.1
import com.nokia.meego 1.0
import "../twitter.js" as Twitter
import "../Component"

Item{
    id: listInfo
    width: listPageListView.width
    height: listPageListView.height

    function initialize(){
        listInfoListView.model.append({title: "List Name", subtitle: listName})
        listInfoListView.model.append({title: "List Owner", subtitle: "@" + ownerScreenName})
        if(listDescription) listInfoListView.model.append({title: "Description", subtitle: listDescription})
        listInfoListView.model.append({title: "Member", subtitle: memberCount})
        listInfoListView.model.append({title: "Subscriber", subtitle: subscriberCount})
    }

    function positionAtTop(){
        listInfoListView.positionViewAtBeginning()
    }

    ListView{
        id: listInfoListView
        anchors.fill: parent
        model: ListModel{}
        header: SectionHeader{
            id: sectionHeader
            text: "List Info"
        }
        delegate: ListItem{
            id: listItem
            width: ListView.view.width
            height: listItemColumn.height + 2 * constant.paddingMedium
            subItemIndicator: title === "List Owner" || title === "Member" || title === "Subscriber"
            onClicked: {
                if(title == "List Owner")
                    pageStack.push(Qt.resolvedUrl("../UserPage.qml"), {screenName: subtitle.substring(1)})
                else if(title == "Member")
                    listPageListView.currentIndex = 2
                else if(title == "Subscriber")
                    listPageListView.currentIndex = 3
            }
            Column{
                id: listItemColumn
                anchors {top: parent.top; left: parent.left; right: parent.right; margins: constant.paddingLarge}
                height: childrenRect.height

                Text{
                    id: titleText
                    width: parent.width
                    wrapMode: Text.Wrap
                    font.bold: true
                    font.pixelSize: constant.fontSizeMedium
                    color: listItem.enabled ? constant.colorLight : constant.colorDisabled
                    text: title
                }
                Text{
                    id: subTitleText
                    width: parent.width
                    wrapMode: Text.Wrap
                    font.pixelSize: constant.fontSizeMedium
                    color: listItem.enabled ? constant.colorMid : constant.colorDisabled
                    text: subtitle
                }
            }
        }
    }
}
