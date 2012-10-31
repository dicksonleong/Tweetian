import QtQuick 1.1
import com.nokia.symbian 1.1
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
            height: listItemColumn.height + 2 * constant.paddingMedium
            platformInverted: settings.invertedTheme
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
                anchors {top: parent.paddingItem.top; left: parent.paddingItem.left; right: parent.paddingItem.right}
                height: childrenRect.height

                ListItemText{
                    id: titleText
                    width: parent.width
                    platformInverted: listItem.platformInverted
                    role: "Title"
                    mode: listItem.mode
                    text: title
                    wrapMode: Text.Wrap
                    font.bold: true
                }
                ListItemText{
                    id: subTitleText
                    width: parent.width
                    platformInverted: listItem.platformInverted
                    role: "SubTitle"
                    mode: listItem.mode
                    text: subtitle
                    wrapMode: Text.Wrap
                    elide: Text.ElideNone
                    font.pixelSize: constant.fontSizeMedium
                }
            }
        }
    }
}
