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

#include "symbianutils.h"

#include <QtDeclarative/QDeclarativeView>

#ifdef Q_OS_SYMBIAN
#include <akndiscreetpopup.h>
#include <avkon.hrh>
#endif

SymbianUtils::SymbianUtils(QDeclarativeView *view, QObject *parent) :
    QObject(parent), m_view(view)
{
}

void SymbianUtils::minimizeApp() const
{
    m_view->lower();
}

void SymbianUtils::showNotification(const QString &title, const QString &message) const
{
#ifdef Q_OS_SYMBIAN
    TPtrC16 sTitle(static_cast<const TUint16 *>(title.utf16()), title.length());
    TPtrC16 sMessage(static_cast<const TUint16 *>(message.utf16()), message.length());
    TRAP_IGNORE(CAknDiscreetPopup::ShowGlobalPopupL(sTitle, sMessage, KAknsIIDNone, KNullDesC,
                                                    0, 0, KAknDiscreetPopupDurationLong, 0, NULL, {0x2005e90a}));
#else
    qWarning("SymbianUtils::showNotification() called with title=\"%s\" message=\"%s\" but not handled",
             qPrintable(title), qPrintable(message));
#endif
}
