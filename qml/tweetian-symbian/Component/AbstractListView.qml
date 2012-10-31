import QtQuick 1.1
import com.nokia.symbian 1.1

ListView{

    property string lastUpdate: ""
    signal pullDownRefresh()

    // Private
    property bool __wasAtYBeginning: false
    property int __initialContentY: 0
    property bool __toBeRefresh: false

    flickableDirection: Flickable.VerticalFlick
    header: PullToRefreshHeader{}
    onMovementStarted: {
        __wasAtYBeginning = atYBeginning
        __initialContentY = contentY
        __toBeRefresh = false
    }
    onMovementEnded: if(__toBeRefresh) pullDownRefresh()
    onContentYChanged: detectPullDownTimer.running = true

    Timer{
        id: detectPullDownTimer
        interval: 250
        repeat: false
        onTriggered: if(__wasAtYBeginning && __initialContentY - contentY > 100) __toBeRefresh = true
    }
}
