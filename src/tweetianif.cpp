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
    qmlMainView->setProperty("currentIndex", 1);
}

void TweetianIf::message()
{
    mView->activateWindow();
    if(!qmlMainView)
        qmlMainView = mView->rootObject()->findChild<QDeclarativeItem*>("mainView");
    qmlMainView->setProperty("currentIndex", 2);
}
