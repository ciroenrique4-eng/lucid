import QtQuick

// a clock face. detail false is the bar's: a filled disc, four dots and two thick
// round hands that still read at 20 px. detail true is the panel's: twelve ticks,
// the quarters longer. plain QtQuick so it can be tested; callers pass colours
Item {
    id: dial

    property var date: new Date()
    property bool detail: false
    property bool seconds: false
    property color faceColor: "#33ffffff"
    property color handColor: "white"
    property color tickColor: "#88ffffff"
    property color secondColor: "orange"

    readonly property real hourAngle: (dial.date.getHours() % 12) * 30 + dial.date.getMinutes() * 0.5
    readonly property real minuteAngle: dial.date.getMinutes() * 6 + dial.date.getSeconds() * 0.1
    readonly property real secondAngle: dial.date.getSeconds() * 6
    readonly property int marks: dial.detail ? 12 : 4
    readonly property real r: Math.min(dial.width, dial.height) / 2

    implicitWidth: 22
    implicitHeight: 22

    Rectangle {
        anchors.centerIn: parent
        width: dial.r * 2
        height: dial.r * 2
        radius: dial.r
        color: dial.faceColor
    }

    Item {
        anchors.centerIn: parent

        Repeater {
            model: dial.marks

            Item {
                id: mark

                required property int index

                readonly property bool major: mark.index % 3 === 0

                rotation: mark.index * (360 / dial.marks)

                Rectangle {
                    x: -width / 2
                    y: -dial.r + (dial.detail ? dial.r * 0.08 : dial.r * 0.18)
                    width: dial.detail ? (mark.major ? dial.r * 0.03 + 1.6 : dial.r * 0.02 + 1.2) : Math.max(1.5, dial.r * 0.16)
                    height: dial.detail ? (mark.major ? dial.r * 0.12 : dial.r * 0.06) : width
                    radius: width / 2
                    color: dial.detail && !mark.major ? Qt.alpha(dial.tickColor, 0.5) : dial.tickColor
                }

            }

        }

        Item {
            rotation: dial.hourAngle

            Rectangle {
                x: -width / 2
                y: -dial.r * 0.5
                width: Math.max(2, dial.r * (dial.detail ? 0.06 : 0.2))
                height: dial.r * 0.5 + width / 2
                radius: width / 2
                color: dial.handColor
            }

        }

        Item {
            rotation: dial.minuteAngle

            Rectangle {
                x: -width / 2
                y: -dial.r * 0.74
                width: Math.max(1.6, dial.r * (dial.detail ? 0.04 : 0.15))
                height: dial.r * 0.74 + width / 2
                radius: width / 2
                color: dial.handColor
            }

        }

        Item {
            visible: dial.seconds
            rotation: dial.secondAngle

            Rectangle {
                x: -width / 2
                y: -dial.r * 0.82
                width: Math.max(1, dial.r * 0.02)
                height: dial.r * 0.95
                color: dial.secondColor
            }

        }

        Rectangle {
            x: -width / 2
            y: -height / 2
            width: Math.max(3, dial.r * (dial.detail ? 0.08 : 0.22))
            height: width
            radius: width / 2
            color: dial.handColor
        }

    }

}
