#ifndef HARMATTANNOTIFICATION_H
#define HARMATTANNOTIFICATION_H

#include <QTimer>

class HarmattanNotification : public QObject
{
    Q_OBJECT
public:
    explicit HarmattanNotification(QObject *parent = 0);

    Q_INVOKABLE void publish(const QString &eventType, const QString &summary, const QString &body, const int count);
    Q_INVOKABLE void clear(const QString &eventType);

private:
    QTimer *colddown;
};

#endif // HARMATTANNOTIFICATION_H
