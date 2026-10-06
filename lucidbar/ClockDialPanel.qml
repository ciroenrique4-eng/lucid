import QtQuick
import qs

// the Dial panel's head: a large clock face and the day under it. the month's
// calendar follows it in Clock.qml
Column {
    id: head

    property var now: new Date()
    property bool seconds: false

    spacing: 8

    AnalogDial {
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(200, head.width - 40)
        height: width
        detail: true
        date: head.now
        seconds: head.seconds
        faceColor: Theme.alpha(Theme.text, 0.06)
        handColor: Theme.text
        tickColor: Theme.subtext
        secondColor: Theme.accent
    }

    Text {
        width: head.width
        horizontalAlignment: Text.AlignHCenter
        text: head.now.toLocaleDateString(I18n.locale, I18n.tr("dddd, MMMM d"))
        color: Theme.subtext
        font.family: Theme.fontFamily
        font.bold: true
        font.pixelSize: Theme.fs(13)
        elide: Text.ElideRight
    }

    Item {
        width: 1
        height: 4
    }

}
