/*
    Copyright (C) 2012 Dickson Leong
    This file is part of Tweetian.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"

Item {
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

    function successCallback(data) {
        dataLoaded = true
        dataRecieved(data)
    }

    function failureCallback(status, statusText) {
        infoBanner.showHttpError(status, statusText)
        loadingRect.visible = false
    }

    function sendToWorkerScript(data) {
        workerScript.sendMessage({ type: reloadType, data: data, model: tweetView.model })
    }

    function positionAtTop() {
        tweetView.positionViewAtBeginning()
    }

    onRefresh: loadingRect.visible = true

    PullDownListView {
        id: tweetView
        anchors.fill: parent
        model: ListModel {}
        header: PullToRefreshHeader {
            height: sectionHeader.height
            SectionHeader { id: sectionHeader; text: root.headerText }
        }
        footer: LoadMoreButton {
            visible: tweetView.count > 0 && showLoadMoreButton
            enabled: !loadingRect.visible
            onClicked: refresh("older")
        }
        onPulledDown: refresh("newer")
    }

    Text {
        anchors.centerIn: parent
        font.pixelSize: constant.fontSizeXXLarge
        color: constant.colorMid
        text: root.emptyText
        visible: tweetView.count == 0 && !loadingRect.visible
    }

    ScrollDecorator { platformInverted: settings.invertedTheme; flickableItem: tweetView }

    WorkerScript {
        id: workerScript
        source: root.workerScriptSource
        onMessage: loadingRect.visible = false
    }
}
