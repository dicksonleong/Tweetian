#ifndef HARMATTANSHAREUI_H
#define HARMATTANSHAREUI_H

#include <QObject>

class HarmattanShareUI : public QObject
{
    Q_OBJECT
public:
    explicit HarmattanShareUI(QObject *parent = 0);

    Q_INVOKABLE void shareLink(const QString &link, const QString &title = QString());
};

#endif // HARMATTANSHAREUI_H
