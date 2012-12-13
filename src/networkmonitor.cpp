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

#include <QtNetwork/QNetworkConfigurationManager>

NetworkMonitor::NetworkMonitor(QObject *parent) :
    QObject(parent), networkManager(new QNetworkConfigurationManager(this)), m_online(false)
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
    return m_online;
#endif
}

void NetworkMonitor::checkIsOnline()
{
    bool online = networkManager->isOnline();
    if (m_online != online) {
        m_online = online;
        emit onlineChanged();
    }
}

void NetworkMonitor::setToOnline()
{
    if (m_online == false) {
        m_online = true;
        emit onlineChanged();
    }
}
