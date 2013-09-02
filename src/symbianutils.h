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

#ifndef SYMBIANUTILS_H
#define SYMBIANUTILS_H

#include <QtCore/QObject>

class QDeclarativeView;
class QUrl;

class SymbianUtils : public QObject
{
    Q_OBJECT
public:
    explicit SymbianUtils(QDeclarativeView *view, QObject *parent = 0);

    // Minimize the app
    Q_INVOKABLE void minimizeApp() const;

    // Show a global notification
    Q_INVOKABLE void showNotification(const QString &title, const QString &message) const;

    // Open url with the default browser
    Q_INVOKABLE void openDefaultBrowser(const QUrl &url) const;

private:
    QDeclarativeView *m_view;
};

#endif // SYMBIANUTILS_H
