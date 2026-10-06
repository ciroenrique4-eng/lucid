import QtQuick
import Quickshell.Widgets
import qs

// the Vinyl panel's record: the cover as its label, turning while the music
// plays and stopping where it is when it pauses
Item {
    id: vinyl

    property string source: ""
    property bool spinning: false
    readonly property real disc: Math.min(vinyl.width, vinyl.height)

    signal clicked()

    Item {
        id: record

        anchors.centerIn: parent
        width: vinyl.disc
        height: vinyl.disc

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "#161616"
            border.width: 1
            border.color: Theme.alpha("white", 0.06)
        }

        // grooves
        Repeater {
            model: 4

            Rectangle {
                required property int index

                anchors.centerIn: parent
                width: vinyl.disc * (0.9 - index * 0.11)
                height: width
                radius: width / 2
                color: "transparent"
                border.width: 1
                border.color: Theme.alpha("white", 0.05 + (index % 2) * 0.03)
            }

        }

        // a sheen that turns with it, so the turning shows
        Rectangle {
            anchors.centerIn: parent
            width: vinyl.disc * 0.86
            height: 2
            radius: 1
            color: Theme.alpha("white", 0.07)
        }

        ClippingRectangle {
            anchors.centerIn: parent
            width: vinyl.disc * 0.4
            height: width
            radius: width / 2
            color: Theme.accentContainer

            Image {
                anchors.fill: parent
                source: vinyl.source
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                smooth: true
                sourceSize.width: 256
                sourceSize.height: 256
            }

        }

        Rectangle {
            anchors.centerIn: parent
            width: Math.max(6, vinyl.disc * 0.04)
            height: width
            radius: width / 2
            color: Theme.bgOpaque
        }

    }

    // a turn every four seconds, only while it plays and shows; stopped, it
    // stays at the angle it reached
    FrameAnimation {
        running: vinyl.visible && vinyl.spinning
        onTriggered: record.rotation = (record.rotation + frameTime * 90) % 360
    }

    MouseArea {
        anchors.centerIn: parent
        width: vinyl.disc
        height: vinyl.disc
        cursorShape: Qt.PointingHandCursor
        onClicked: vinyl.clicked()
    }

}
