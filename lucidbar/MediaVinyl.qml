import QtQuick
import QtQuick.Shapes
import Quickshell.Widgets
import qs

// the Vinyl panel's turntable: the cover as the record's label, turning while
// the music plays and stopping where it is when it pauses, and a tonearm that
// lowers its needle onto the grooves to play and lifts off on pause
Item {
    id: vinyl

    property string source: ""
    // the record turns only while the panel shows and the music plays
    property bool spinning: false
    // the needle is down whenever the music plays
    property bool playing: false
    readonly property real disc: Math.min(vinyl.width, vinyl.height)
    readonly property real r: vinyl.disc / 2
    readonly property real cx: vinyl.width / 2
    readonly property real cy: vinyl.height / 2

    signal clicked()

    // the platter's rim, just past the record's edge
    Rectangle {
        x: vinyl.cx - width / 2
        y: vinyl.cy - height / 2
        width: vinyl.disc + 8
        height: width
        radius: width / 2
        color: Theme.bgHigh
        border.width: 1
        border.color: Theme.alpha(Theme.text, 0.12)
    }

    // a soft shadow under the record
    Rectangle {
        x: vinyl.cx - vinyl.r + 2
        y: vinyl.cy - vinyl.r + 5
        width: vinyl.disc
        height: vinyl.disc
        radius: width / 2
        color: Theme.alpha("black", 0.35)
    }

    Item {
        id: record

        x: vinyl.cx - vinyl.r
        y: vinyl.cy - vinyl.r
        width: vinyl.disc
        height: vinyl.disc

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "#141414"
            border.width: 1
            border.color: Theme.alpha("white", 0.08)
        }

        // grooves, finer toward the label
        Repeater {
            model: 9

            Rectangle {
                required property int index

                anchors.centerIn: parent
                width: vinyl.disc * (0.94 - index * 0.06)
                height: width
                radius: width / 2
                color: "transparent"
                border.width: 1
                border.color: Theme.alpha("white", index % 3 === 0 ? 0.09 : 0.035)
            }

        }

        // a scratch of light that turns with it, so the turning shows
        Rectangle {
            x: vinyl.r - width / 2
            y: vinyl.disc * 0.1
            width: 2
            height: vinyl.disc * 0.26
            radius: 1
            color: Theme.alpha("white", 0.08)
        }

        // the label: the cover, a rim in the accent, the spindle
        Rectangle {
            anchors.centerIn: parent
            width: vinyl.disc * 0.42
            height: width
            radius: width / 2
            color: Theme.accent
        }

        ClippingRectangle {
            anchors.centerIn: parent
            width: vinyl.disc * 0.38
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
            width: Math.max(7, vinyl.disc * 0.045)
            height: width
            radius: width / 2
            color: "#d9d9d9"
            border.width: 1
            border.color: Theme.alpha("black", 0.4)
        }

    }

    // the light on the vinyl stays put while the record turns under it
    Shape {
        x: vinyl.cx - vinyl.r
        y: vinyl.cy - vinyl.r
        width: vinyl.disc
        height: vinyl.disc
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: 0
            strokeColor: "transparent"

            fillGradient: ConicalGradient {
                centerX: vinyl.r
                centerY: vinyl.r
                angle: 35

                GradientStop {
                    position: 0
                    color: Theme.alpha("white", 0)
                }

                GradientStop {
                    position: 0.08
                    color: Theme.alpha("white", 0.09)
                }

                GradientStop {
                    position: 0.16
                    color: Theme.alpha("white", 0)
                }

                GradientStop {
                    position: 0.5
                    color: Theme.alpha("white", 0)
                }

                GradientStop {
                    position: 0.58
                    color: Theme.alpha("white", 0.07)
                }

                GradientStop {
                    position: 0.66
                    color: Theme.alpha("white", 0)
                }

                GradientStop {
                    position: 1
                    color: Theme.alpha("white", 0)
                }

            }

            // a ring: the record's edge out, the label in
            PathAngleArc {
                centerX: vinyl.r
                centerY: vinyl.r
                radiusX: vinyl.r - 1
                radiusY: vinyl.r - 1
                startAngle: 0
                sweepAngle: 360
            }

            PathMove {
                x: vinyl.r + vinyl.disc * 0.21
                y: vinyl.r
            }

            PathAngleArc {
                centerX: vinyl.r
                centerY: vinyl.r
                radiusX: vinyl.disc * 0.21
                radiusY: vinyl.disc * 0.21
                startAngle: 0
                sweepAngle: -360
            }

        }

    }

    // the tonearm: a pivot to the upper right of the record, the arm hanging
    // from it. 20° swings the needle onto the outer grooves, -10° lifts it
    // clear of the record
    Item {
        id: arm

        readonly property real length: vinyl.r * 1.2

        x: vinyl.cx + vinyl.r * 0.95
        y: vinyl.cy - vinyl.r * 0.7
        rotation: vinyl.playing ? 20 : -10

        // counterweight, behind the pivot
        Rectangle {
            x: -width / 2
            y: -vinyl.r * 0.3
            width: Math.max(10, vinyl.r * 0.13)
            height: vinyl.r * 0.18
            radius: Theme.rad(3)
            color: Theme.alpha(Theme.text, 0.55)
        }

        // the arm
        Rectangle {
            x: -width / 2
            y: 0
            width: Math.max(3, vinyl.r * 0.035)
            height: arm.length - headshell.height + 2
            radius: width / 2
            color: Theme.alpha(Theme.text, 0.85)
        }

        // the headshell, angled in a little, and the needle under it
        Rectangle {
            id: headshell

            x: -width / 2 - 1
            y: arm.length - height
            width: Math.max(8, vinyl.r * 0.11)
            height: Math.max(14, vinyl.r * 0.19)
            radius: Theme.rad(3)
            rotation: 18
            color: Theme.alpha(Theme.text, 0.9)

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.bottom
                anchors.topMargin: -1
                width: 2
                height: 4
                radius: 1
                color: Theme.accent
            }

        }

        Behavior on rotation {
            NumberAnimation {
                duration: 700
                easing.type: Easing.InOutCubic
            }

        }

    }

    // the pivot's base, over the arm's end
    Rectangle {
        x: arm.x - width / 2
        y: arm.y - height / 2
        width: Math.max(18, vinyl.r * 0.24)
        height: width
        radius: width / 2
        color: Theme.bgHigh
        border.width: 2
        border.color: Theme.alpha(Theme.text, 0.25)

        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.4
            height: width
            radius: width / 2
            color: Theme.alpha(Theme.text, 0.6)
        }

    }

    // a turn every four seconds, only while it plays and shows; stopped, it
    // stays at the angle it reached
    FrameAnimation {
        running: vinyl.visible && vinyl.spinning
        onTriggered: record.rotation = (record.rotation + frameTime * 90) % 360
    }

    MouseArea {
        x: vinyl.cx - vinyl.r
        y: vinyl.cy - vinyl.r
        width: vinyl.disc
        height: vinyl.disc
        cursorShape: Qt.PointingHandCursor
        onClicked: vinyl.clicked()
    }

}
