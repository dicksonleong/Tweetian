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

#ifndef HARMATTANNOTIFICATION_H
#define HARMATTANNOTIFICATION_H

#include <QTimer>

class HarmattanNotification : public QObject
{
    Q_OBJECT
public:
    explicit HarmattanNotification(QObject *parent = 0);

    Q_INVOKABLE void publish(const QString &eventType, const QString &summary, const QString &body, const int count);
    Q_INVOKABLE void clear(const QString &eventType);

private:
    QTimer *colddown;
};

#endif // HARMATTANNOTIFICATION_H
