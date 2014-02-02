Tweetian
========

Tweetian is a feature-rich Twitter app for smartphones, developed using Qt/QML.
The backend of Tweetian is mostly written in JavaScript (database handling, API calls, parsing JSON)
but I hope to move the backend to C++ for better performance & less buggy. The UI is written purely in QML
and use a lot of components from Qt Quick Component for Symbian/MeeGo to provide native UI for each platform.

Tweetian support Symbian^3 and MeeGo Harmattan (Qt 4.7.4 and Qt 4.8.0).

Build for testing
-----------------

If you wanna build Tweetian from source, please make sure you filled in the API key/secret
for respective service in __qml/tweetian-{platform}/Constant.qml__. A default Twitter
OAuth comsumer key/secret is provided for testing.

Downloads
---------

Latest stable release for Symbian/Harmattan: https://github.com/dicksonleong/Tweetian/releases

License
-------

Tweetian license:

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

OAuth library for JavaScript license (qml/tweetian-*/lib/oauth.js):

    Copyright 2008 Netflix, Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

SHA-1 library for JavaScript license (qml/tweetian-*/lib/sha1.js):

    Version 2.2 Copyright Paul Johnston 2000 - 2009.
    Other contributors: Greg Holt, Andrew Kepert, Ydnar, Lostinet
    Distributed under the BSD License
    See http://pajhome.org.uk/crypt/md5 for details.
