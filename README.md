Tweetian
========

Tweetian is a feature-rich Twitter app for smartphones, developed using Qt/QML.
The backend of Tweetian is mostly written in JavaScript (database handling, API calls, parsing JSON)
but I hope to move the backend to C++ for better performance & less buggy. The UI is written purely in QML
and use a lot of components from Qt Quick Component for Symbian/MeeGo to provide native UI for each platform.

Tweetian currently support Symbian^3 and MeeGo Harmattan (Qt 4.7.4 or higher).

ToDo
----

* Migrate to Twitter API v1.1 (before March 2013)
* Port to Nemo/Jolla
* Move the whole app backend to C++
* Harmattan: event feed integration
* Internationalization support (You can contribute by translating Tweetian to your native language in
[Transifex](https://www.transifex.com/projects/p/tweetian/))

Build for testing
-----------------

If you wanna build Tweetian from source, please make sure you filled in the API key/secret
for respective service in __qml/tweetian-{platform}/Services/Global.js__. A default Twitter
OAuth comsumer key/secret is provided for testing.

Downloads
---------

Latest stable release for Symbian/Harmattan: [Nokia Store](http://store.ovi.com/content/280255)

License
-------

    Tweetian - A feature-rich Twitter app for smartphones developed using Qt/QML
    Copyright (C) 2012 Dickson Leong

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
