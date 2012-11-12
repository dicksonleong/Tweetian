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

#include "networkmonitor.h"

NetworkMonitor::NetworkMonitor(QObject *parent) :
    QObject(parent), networkManager(new QNetworkConfigurationManager(this)), online(false)
{
    connect(networkManager, SIGNAL(onlineStateChanged(bool)), this, SLOT(checkIsOnline()));
    connect(networkManager, SIGNAL(updateCompleted()), this, SLOT(checkIsOnline()));
    networkManager->updateConfigurations();
}

bool NetworkMonitor::isOnline() const
{
#ifdef Q_WS_SIMULATOR
    return true;
#else
    return online;
#endif
}

void NetworkMonitor::checkIsOnline()
{
    bool on = networkManager->isOnline();
    if(online != on){
        online = on;
        emit onlineChanged();
    }
}

/*
  In Symbian, networkManager->isOnline() will return false when mobile data is disable
  (or in offline mode) and WLAN already activated before app is started.

  networkManager->isOnline() will only return true when:
  - Mobile network is enabled/connected, or
  - WLAN is activate by the app.

  Following function is to solve this issue. It will be called when Timeline/Mentions return 200 from server.
  The following function should NOT be used in any other situation.
*/
void NetworkMonitor::appIsOnline()
{
    if(online == false){
        online = true;
        emit onlineChanged();
    }
}
