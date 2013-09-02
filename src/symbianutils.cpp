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

#include <QtCore/QUrl>
#include <QtDeclarative/QDeclarativeView>

#ifdef Q_OS_SYMBIAN
#include <akndiscreetpopup.h> // CAknDiscreetPopup
#include <avkon.hrh> // KAknDiscreetPopupDurationLong

#include <eikenv.h> // CEikonEnv
#include <apgcli.h> // RApaLsSession
#include <apgtask.h> // TApaTaskList, TApaTask

_LIT(KBrowserPrefix, "4 " );
static const TUid KUidBrowser = { 0x10008D39 };
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

void SymbianUtils::openDefaultBrowser(const QUrl &url) const
{
#ifdef Q_OS_SYMBIAN
    // convert url to encoded version of QString
    QString encUrl(QString::fromUtf8(url.toEncoded()));
    // using qt_QString2TPtrC() based on
    // <http://qt.gitorious.org/qt/qt/blobs/4.7/src/corelib/kernel/qcore_symbian_p.h#line102>
    TPtrC tUrl(TPtrC16(static_cast<const TUint16*>(encUrl.utf16()), encUrl.length()));

    // Following code based on
    // <http://www.developer.nokia.com/Community/Wiki/Launch_default_web_browser_using_Symbian_C%2B%2B>

    // create a session with apparc server
    RApaLsSession appArcSession;
    User::LeaveIfError(appArcSession.Connect());
    CleanupClosePushL<RApaLsSession>(appArcSession);

    // get the default application uid for application/x-web-browse
    TDataType mimeDatatype(_L8("application/x-web-browse"));
    TUid handlerUID;
    appArcSession.AppForDataType(mimeDatatype, handlerUID);

    // if UiD not found, use the native browser
    if (handlerUID.iUid == 0 || handlerUID.iUid == -1)
        handlerUID = KUidBrowser;

    // Following code based on
    // <http://qt.gitorious.org/qt/qt/blobs/4.7/src/gui/util/qdesktopservices_s60.cpp#line213>

    HBufC* buf16 = HBufC::NewLC(tUrl.Length() + KBrowserPrefix.iTypeLength);
    buf16->Des().Copy(KBrowserPrefix); // Prefix used to launch correct browser view
    buf16->Des().Append(tUrl);

    TApaTaskList taskList(CEikonEnv::Static()->WsSession());
    TApaTask task = taskList.FindApp(handlerUID);
    if (task.Exists()) {
        // Switch to existing browser instance
        task.BringToForeground();
        HBufC8* param8 = HBufC8::NewLC(buf16->Length());
        param8->Des().Append(buf16->Des());
        task.SendMessage(TUid::Uid( 0 ), *param8); // Uid is not used
        CleanupStack::PopAndDestroy(param8);
    } else {
        // Start a new browser instance
        TThreadId id;
        appArcSession.StartDocument(*buf16, handlerUID, id);
    }

    CleanupStack::PopAndDestroy(buf16);
    CleanupStack::PopAndDestroy(&appArcSession);
#else
    qWarning("SymbianUtils::openDefaultBrowser() call with url=\"%s\" but not handled",
             qPrintable(url.toString()));
#endif
}
