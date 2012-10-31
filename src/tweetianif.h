#ifndef TWEETIANIF_H
#define TWEETIANIF_H

#include <QApplication>
#include <QDeclarativeView>
#include <QDeclarativeItem>
#include <QtDBus/QDBusAbstractAdaptor>

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
    QDeclarativeView *mView;
    QDeclarativeItem *qmlMainView;
};

#endif // TWEETIANIF_H
