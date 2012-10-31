#ifndef QMLCLIPBOARD_H
#define QMLCLIPBOARD_H

#include <QApplication>
#include <QClipboard>

class QMLClipboard : public QObject
{
    Q_OBJECT
public:
    explicit QMLClipboard(QObject *parent = 0) : QObject(parent) {
        clipboard = QApplication::clipboard();
    }

    Q_INVOKABLE void setText(const QString text){
        clipboard->setText(text, QClipboard::Clipboard);
        clipboard->setText(text, QClipboard::Selection);
    }

private:
    QClipboard *clipboard;
};

#endif // QMLCLIPBOARD_H
