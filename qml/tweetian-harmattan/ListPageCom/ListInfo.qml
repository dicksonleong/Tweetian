import QtQuick 1.1
import com.nokia.meego 1.0
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
            width: ListView.view.width
            height: listItemColumn.height + 2 * constant.paddingMedium
            subItemIndicator: model.clickedString
            onClicked: if(model.clickedString) eval(model.clickedString)

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
