import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"

Item{
    id: root

    // Required to set explicitly
    property url workerScriptSource: ""
    property string headerText: ""
    property string emptyText: ""
    property alias delegate: tweetView.delegate
    signal refresh(string type)
    signal dataRecieved(variant data)

    property string reloadType: "all"
    property bool showLoadMoreButton: true
    property bool refreshTimeStamp: true

    // read-only
    property ListModel model: tweetView.model
    property bool dataLoaded: false

    function successCallback(data){
        dataLoaded = true
        dataRecieved(data)
    }

    function failureCallback(status, statusText){
        if(status === 0) infoBanner.alert("Connection error.")
        else infoBanner.alert("Error: " + status + " " + statusText)
        loadingRect.visible = false
    }

    function sendToWorkerScript(data){
        workerScript.sendMessage({data: data, reloadType: reloadType, model: tweetView.model})
    }

    function positionAtTop(){
        tweetView.positionViewAtBeginning()
    }

    onRefresh: loadingRect.visible = true

    AbstractListView{
        id: tweetView
        anchors.fill: parent
        model: ListModel{}
        header: PullToRefreshHeader{
            height: sectionHeader.height
            SectionHeader {
                id: sectionHeader
                text: root.headerText
            }
        }
        footer: LoadMoreButton{
            visible: tweetView.count > 0 && showLoadMoreButton
            enabled: !loadingRect.visible
            onClicked: refresh("older")
        }
        onPullDownRefresh: refresh("newer")
    }

    Text{
        anchors.centerIn: parent
        font.pixelSize: constant.fontSizeXXLarge
        color: constant.colorMid
        text: root.emptyText
        visible: tweetView.count == 0 && !loadingRect.visible
    }

    ScrollDecorator { platformInverted: settings.invertedTheme; flickableItem: tweetView }

    WorkerScript{
        id: workerScript
        source: root.workerScriptSource
        onMessage: loadingRect.visible = false
    }
}
