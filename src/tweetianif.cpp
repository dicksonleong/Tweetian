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
