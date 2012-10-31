#ifndef NETWORKMONITOR_H
#define NETWORKMONITOR_H

#include <QNetworkConfigurationManager>

class NetworkMonitor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool online READ isOnline NOTIFY onlineChanged)
public:
    explicit NetworkMonitor(QObject *parent = 0);

    Q_INVOKABLE void appIsOnline();
    bool isOnline() const;
signals:
    void onlineChanged();

private slots:
    void checkIsOnline();

private:
    QNetworkConfigurationManager *networkManager;
    bool online;
};

#endif // NETWORKMONITOR_H
