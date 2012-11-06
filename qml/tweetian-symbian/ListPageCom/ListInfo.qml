import QtQuick 1.1
import com.nokia.symbian 1.1
import "../twitter.js" as Twitter
import "../Component"

Item{
    id: listInfo
    width: listPageListView.width
    height: listPageListView.height

    function initialize(){

        function addToListInfo(title, subtitle, clickedString){
            var item = { title: title, subtitle: subtitle, clickedString: clickedString || "" }
            listInfoListView.model.append(item)
        }

        addToListInfo(qsTr("List Name"), listName)
        addToListInfo(qsTr("List Owner"), "@" + ownerScreenName,
                      "pageStack.push(Qt.resolvedUrl(\"../UserPage.qml\"), {screenName: subtitle.substring(1)})")
        if(listDescription) addToListInfo(qsTr("Description"), listDescription)
        addToListInfo(qsTr("Member"), memberCount, "listPageListView.currentIndex = 2")
        addToListInfo(qsTr("Subscriber"), subscriberCount, "listPageListView.currentIndex = 3")
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
            text: qsTr("List Info")
        }
        delegate: ListItem{
            id: listItem
            height: listItemColumn.height + 2 * constant.paddingMedium
            platformInverted: settings.invertedTheme
            subItemIndicator: model.clickedString
            onClicked: if(model.clickedString) eval(model.clickedString)

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
