#ifndef HARMATTANMUSIC_H
#define HARMATTANMUSIC_H

#include <QObject>

class HarmattanMusic : public QObject
{
    Q_OBJECT
public:
    explicit HarmattanMusic(QObject *parent = 0);

    Q_INVOKABLE void requestCurrentMedia();
signals:
    void mediaReceived(const QString mediaName);

private slots:
    void processMediaChanged(const QStringList &media);
private:
    bool isMusicSuiteRunning();
};

#endif // HARMATTANMUSIC_H
