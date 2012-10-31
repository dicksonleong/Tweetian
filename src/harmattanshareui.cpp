#include "harmattanshareui.h"

#ifdef Q_OS_HARMATTAN
#include <MDataUri>
#include <maemo-meegotouch-interfaces/shareuiinterface.h>
#endif

HarmattanShareUI::HarmattanShareUI(QObject *parent) :
    QObject(parent)
{
}

void HarmattanShareUI::shareLink(const QString &link, const QString &title)
{
#ifdef Q_OS_HARMATTAN
    MDataUri uri;
    uri.setMimeType("text/x-url");
    uri.setTextData(link);

    if(!title.isEmpty()){
        uri.setAttribute("title", title);
    }

    if(!uri.isValid()){
        qCritical("Invalid URI");
        return;
    }

    ShareUiInterface shareIf("com.nokia.ShareUi");

    if(!shareIf.isValid()){
        qCritical("Invalid Share UI interface");
        return;
    }

    shareIf.share(QStringList() << uri.toString());
#else
    Q_UNUSED(title)
    Q_UNUSED(link)
#endif
}
