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

#ifndef TWEETIANIF_H
#define TWEETIANIF_H

#include <QtDBus/QDBusAbstractAdaptor>

class QApplication;
class QDeclarativeView;
class QDeclarativeItem;

class TweetianIf : public QDBusAbstractAdaptor
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "com.tweetian")
public:
    explicit TweetianIf(QApplication *parent, QDeclarativeView *view);

public slots:
    void mention();
    void message();

private:
    QDeclarativeView *m_view;
    QDeclarativeItem *qmlMainView;
};

#endif // TWEETIANIF_H
