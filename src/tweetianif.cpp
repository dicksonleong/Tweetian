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

#include "tweetianif.h"

TweetianIf::TweetianIf(QApplication *parent, QDeclarativeView *view) :
    QDBusAbstractAdaptor(parent), mView(view)
{
}

void TweetianIf::mention()
{
    mView->activateWindow();
    if(!qmlMainView)
        qmlMainView = mView->rootObject()->findChild<QDeclarativeItem*>("mainView");
    QMetaObject::invokeMethod(qmlMainView, "moveToColumn", Q_ARG(QVariant, 1));
}

void TweetianIf::message()
{
    mView->activateWindow();
    if(!qmlMainView)
        qmlMainView = mView->rootObject()->findChild<QDeclarativeItem*>("mainView");
    QMetaObject::invokeMethod(qmlMainView, "moveToColumn", Q_ARG(QVariant, 2));
}
