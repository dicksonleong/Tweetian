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

#ifndef NETWORKMONITOR_H
#define NETWORKMONITOR_H

#include <QtCore/QObject>

class QNetworkConfigurationManager;

class NetworkMonitor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool online READ isOnline NOTIFY onlineChanged)
public:
    explicit NetworkMonitor(QObject *parent = 0);

    // Force set the online status to true. This is only used for workaround of a bug in Symbian.
    Q_INVOKABLE void setToOnline();

    bool isOnline() const;
signals:
    void onlineChanged();

private slots:
    void checkIsOnline();

private:
    Q_DISABLE_COPY(NetworkMonitor)

    QNetworkConfigurationManager *networkManager;
    bool m_online;
};

#endif // NETWORKMONITOR_H
