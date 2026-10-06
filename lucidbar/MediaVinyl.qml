import QtQuick
import QtQuick.Shapes
import Quickshell.Widgets
import qs

// the Vinyl panel's turntable: a plinth with the record on the left and the
// tonearm on the right. the record (the cover as its label) turns while the
// music plays and stops where it is on pause; the arm lowers its needle to play
// and lifts it, its shadow drifting off as it rises. depth comes from light:
// gradients on the plinth, the vinyl, the metal and the arm, a sheen that
// stays put while the record turns under it, and shadows under what sits up
Item {
    id: vinyl

    property string source: ""
    // the record turns only while the panel shows and the music plays
    property bool spinning: false
    // the needle is down whenever the music plays
    property bool playing: false

    readonly property real plinthW: Math.min(vinyl.width, vinyl.height * 1.6)
    readonly property real plinthX: (vinyl.width - vinyl.plinthW) / 2
    readonly property real disc: vinyl.height - 30
    readonly property real r: vinyl.disc / 2
    readonly property real cx: vinyl.plinthX + 15 + vinyl.r + 4
    readonly property real cy: vinyl.height / 2
    // the arm's pivot, up and to the right of the record
    readonly property real px: vinyl.plinthX + vinyl.plinthW - vinyl.r * 0.42
    readonly property real py: vinyl.cy - vinyl.r * 0.62
    readonly property real armLength: vinyl.r * 1.62
    // where it hangs: on the grooves to play, beside the record at rest
    readonly property real armAngle: vinyl.playing ? 58 : 22
    readonly property color metal: "#9a9a9a"

    signal clicked()

    // ── the plinth ──
    Rectangle {
        x: vinyl.plinthX
        width: vinyl.plinthW
        height: vinyl.height
        radius: Theme.rad(18)
        border.width: 1
        border.color: Theme.alpha("white", 0.07)

        gradient: Gradient {
            GradientStop {
                position: 0
                color: Qt.lighter(Theme.bgHigh, 1.18)
            }

            GradientStop {
                position: 1
                color: Theme.bgActive
            }

        }

        // a lit top edge
        Rectangle {
            x: parent.radius
            y: 1
            width: parent.width - parent.radius * 2
            height: 1
            color: Theme.alpha("white", 0.12)
        }

    }

    // power light, glowing while it plays
    Rectangle {
        x: vinyl.plinthX + vinyl.plinthW - 26
        y: vinyl.height - 22
        width: 14
        height: 14
        radius: 7
        color: Theme.alpha(Theme.accent, vinyl.playing ? 0.3 : 0)

        Behavior on color {
            ColorAnimation {
                duration: 400
            }

        }

        Rectangle {
            anchors.centerIn: parent
            width: 6
            height: 6
            radius: 3
            color: vinyl.playing ? Theme.accent : Theme.alpha(Theme.text, 0.25)

            Behavior on color {
                ColorAnimation {
                    duration: 400
                }

            }

        }

    }

    // speed selector
    Row {
        x: vinyl.plinthX + vinyl.plinthW - 26 - width - 10
        y: vinyl.height - 15 - height / 2 - 1
        spacing: 6

        Text {
            text: "33"
            color: Theme.accent
            font.family: Theme.fontFamily
            font.bold: true
            font.pixelSize: Theme.fs(9)
        }

        Text {
            text: "45"
            color: Theme.alpha(Theme.text, 0.35)
            font.family: Theme.fontFamily
            font.bold: true
            font.pixelSize: Theme.fs(9)
        }

    }

    // ── the platter: brushed metal, a little past the record ──
    Rectangle {
        x: vinyl.cx - width / 2
        y: vinyl.cy - height / 2 + 2
        width: vinyl.disc + 12
        height: width
        radius: width / 2
        color: Theme.alpha("black", 0.4)
    }

    Shape {
        x: vinyl.cx - vinyl.r - 5
        y: vinyl.cy - vinyl.r - 5
        width: vinyl.disc + 10
        height: vinyl.disc + 10
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: 1
            strokeColor: Theme.alpha("white", 0.15)

            fillGradient: ConicalGradient {
                centerX: vinyl.r + 5
                centerY: vinyl.r + 5
                angle: 60

                GradientStop {
                    position: 0
                    color: "#5b5b5b"
                }

                GradientStop {
                    position: 0.25
                    color: "#2b2b2b"
                }

                GradientStop {
                    position: 0.5
                    color: "#4d4d4d"
                }

                GradientStop {
                    position: 0.75
                    color: "#262626"
                }

                GradientStop {
                    position: 1
                    color: "#5b5b5b"
                }

            }

            PathAngleArc {
                centerX: vinyl.r + 5
                centerY: vinyl.r + 5
                radiusX: vinyl.r + 4.5
                radiusY: vinyl.r + 4.5
                startAngle: 0
                sweepAngle: 360
            }

        }

    }

    // ── the record ──
    Item {
        id: record

        x: vinyl.cx - vinyl.r
        y: vinyl.cy - vinyl.r
        width: vinyl.disc
        height: vinyl.disc

        // vinyl: darkest at the rim
        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeWidth: 0
                strokeColor: "transparent"

                fillGradient: RadialGradient {
                    centerX: vinyl.r
                    centerY: vinyl.r
                    centerRadius: vinyl.r
                    focalX: vinyl.r
                    focalY: vinyl.r

                    GradientStop {
                        position: 0.3
                        color: "#232323"
                    }

                    GradientStop {
                        position: 0.85
                        color: "#141414"
                    }

                    GradientStop {
                        position: 1
                        color: "#0a0a0a"
                    }

                }

                PathAngleArc {
                    centerX: vinyl.r
                    centerY: vinyl.r
                    radiusX: vinyl.r
                    radiusY: vinyl.r
                    startAngle: 0
                    sweepAngle: 360
                }

            }

        }

        // grooves: fine rings, with darker gaps between the tracks
        Repeater {
            model: 26

            Rectangle {
                required property int index
                readonly property bool gap: index === 6 || index === 13 || index === 19

                anchors.centerIn: parent
                width: vinyl.disc * (0.95 - index * 0.0205)
                height: width
                radius: width / 2
                color: "transparent"
                border.width: gap ? 1.5 : 1
                border.color: gap ? Theme.alpha("black", 0.6) : Theme.alpha("white", index % 2 === 0 ? 0.045 : 0.02)
            }

        }

        // the label sits up a little: its shadow, an accent rim, the cover
        Rectangle {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 1.5
            width: vinyl.disc * 0.4 + 3
            height: width
            radius: width / 2
            color: Theme.alpha("black", 0.5)
        }

        Rectangle {
            anchors.centerIn: parent
            width: vinyl.disc * 0.4
            height: width
            radius: width / 2
            color: Theme.accent
        }

        ClippingRectangle {
            anchors.centerIn: parent
            width: vinyl.disc * 0.36
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

    }

    // ── light that stays put while the record turns under it ──
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
                angle: 40

                GradientStop {
                    position: 0
                    color: Theme.alpha("white", 0)
                }

                GradientStop {
                    position: 0.06
                    color: Theme.alpha("white", 0.16)
                }

                GradientStop {
                    position: 0.13
                    color: Theme.alpha("white", 0)
                }

                GradientStop {
                    position: 0.3
                    color: Theme.alpha(Theme.accent, 0)
                }

                GradientStop {
                    position: 0.36
                    color: Theme.alpha(Theme.accent, 0.07)
                }

                GradientStop {
                    position: 0.42
                    color: Theme.alpha(Theme.accent, 0)
                }

                GradientStop {
                    position: 0.5
                    color: Theme.alpha("white", 0)
                }

                GradientStop {
                    position: 0.56
                    color: Theme.alpha("white", 0.12)
                }

                GradientStop {
                    position: 0.63
                    color: Theme.alpha("white", 0)
                }

                GradientStop {
                    position: 1
                    color: Theme.alpha("white", 0)
                }

            }

            // a ring: from the record's edge in to the label
            PathAngleArc {
                centerX: vinyl.r
                centerY: vinyl.r
                radiusX: vinyl.r - 1
                radiusY: vinyl.r - 1
                startAngle: 0
                sweepAngle: 360
            }

            PathMove {
                x: vinyl.r + vinyl.disc * 0.2
                y: vinyl.r
            }

            PathAngleArc {
                centerX: vinyl.r
                centerY: vinyl.r
                radiusX: vinyl.disc * 0.2
                radiusY: vinyl.disc * 0.2
                startAngle: 0
                sweepAngle: -360
            }

        }

    }

    // a gloss across the label, top left
    Shape {
        x: vinyl.cx - vinyl.disc * 0.18
        y: vinyl.cy - vinyl.disc * 0.18
        width: vinyl.disc * 0.36
        height: width
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: 0
            strokeColor: "transparent"

            fillGradient: LinearGradient {
                x1: 0
                y1: 0
                x2: vinyl.disc * 0.36
                y2: vinyl.disc * 0.36

                GradientStop {
                    position: 0
                    color: Theme.alpha("white", 0.22)
                }

                GradientStop {
                    position: 0.45
                    color: Theme.alpha("white", 0)
                }

            }

            PathAngleArc {
                centerX: vinyl.disc * 0.18
                centerY: vinyl.disc * 0.18
                radiusX: vinyl.disc * 0.18
                radiusY: vinyl.disc * 0.18
                startAngle: 0
                sweepAngle: 360
            }

        }

    }

    // the spindle, polished
    Rectangle {
        x: vinyl.cx - width / 2
        y: vinyl.cy - height / 2
        width: Math.max(8, vinyl.disc * 0.05)
        height: width
        radius: width / 2
        border.width: 1
        border.color: Theme.alpha("black", 0.5)

        gradient: Gradient {
            GradientStop {
                position: 0
                color: "#f2f2f2"
            }

            GradientStop {
                position: 1
                color: "#7a7a7a"
            }

        }

    }

    // ── the tonearm: its shadow first, falling further off as it lifts ──
    Arm {
        x: vinyl.px + (vinyl.playing ? 4 : 9)
        y: vinyl.py + (vinyl.playing ? 6 : 13)
        rotation: vinyl.armAngle
        r: vinyl.r
        length: vinyl.armLength
        shadow: true

        Behavior on x {
            NumberAnimation {
                duration: 700
                easing.type: Easing.InOutCubic
            }

        }

        Behavior on y {
            NumberAnimation {
                duration: 700
                easing.type: Easing.InOutCubic
            }

        }

        Behavior on rotation {
            NumberAnimation {
                duration: 700
                easing.type: Easing.InOutCubic
            }

        }

    }

    Arm {
        x: vinyl.px
        y: vinyl.py
        rotation: vinyl.armAngle
        r: vinyl.r
        length: vinyl.armLength

        Behavior on rotation {
            NumberAnimation {
                duration: 700
                easing.type: Easing.InOutCubic
            }

        }

    }

    // the arm rest, where the arm lies when it's lifted
    Rectangle {
        x: vinyl.px - vinyl.armLength * Math.sin(22 * Math.PI / 180) * 0.62 - width / 2
        y: vinyl.py + vinyl.armLength * Math.cos(22 * Math.PI / 180) * 0.62 - height / 2 + 6
        width: 10
        height: 6
        radius: 2
        color: Theme.alpha("black", 0.35)
        z: -1
    }

    // the pivot: a metal turret with a ring and a cap
    Rectangle {
        x: vinyl.px - width / 2 + 2
        y: vinyl.py - height / 2 + 3
        width: vinyl.r * 0.34
        height: width
        radius: width / 2
        color: Theme.alpha("black", 0.4)
    }

    Rectangle {
        x: vinyl.px - width / 2
        y: vinyl.py - height / 2
        width: vinyl.r * 0.34
        height: width
        radius: width / 2
        border.width: 1
        border.color: Theme.alpha("white", 0.2)

        gradient: Gradient {
            GradientStop {
                position: 0
                color: "#5a5a5a"
            }

            GradientStop {
                position: 1
                color: "#262626"
            }

        }

        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.5
            height: width
            radius: width / 2

            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: "#e6e6e6"
                }

                GradientStop {
                    position: 1
                    color: "#6c6c6c"
                }

            }

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

    // the arm hangs from (0, 0), its pivot: a counterweight behind, a tube
    // lit down one side, a headshell turned in, the needle in the accent.
    // shadow: the same shape, flat and dark, to drop on what's below
    component Arm: Item {
        id: armShape

        property bool shadow: false
        property real r: 80
        property real length: 120
        readonly property real tube: Math.max(3.5, armShape.r * 0.045)
        readonly property color shade: Theme.alpha("black", 0.35)

        // counterweight
        Rectangle {
            x: -width / 2
            y: -armShape.r * 0.36
            width: Math.max(12, armShape.r * 0.17)
            height: armShape.r * 0.22
            radius: Theme.rad(4)
            color: armShape.shadow ? armShape.shade : "transparent"

            gradient: armShape.shadow ? null : weightGradient

            Gradient {
                id: weightGradient

                orientation: Gradient.Horizontal

                GradientStop {
                    position: 0
                    color: "#d8d8d8"
                }

                GradientStop {
                    position: 1
                    color: "#5e5e5e"
                }

            }

        }

        // the tube
        Rectangle {
            x: -width / 2
            y: 0
            width: armShape.tube
            height: armShape.length - headshell.height + 3
            radius: width / 2
            color: armShape.shadow ? armShape.shade : "transparent"

            gradient: armShape.shadow ? null : tubeGradient

            Gradient {
                id: tubeGradient

                orientation: Gradient.Horizontal

                GradientStop {
                    position: 0
                    color: "#f4f4f4"
                }

                GradientStop {
                    position: 0.45
                    color: "#bdbdbd"
                }

                GradientStop {
                    position: 1
                    color: "#6a6a6a"
                }

            }

        }

        // headshell and needle
        Rectangle {
            id: headshell

            x: -width / 2 - 1
            y: armShape.length - height
            width: Math.max(9, armShape.r * 0.12)
            height: Math.max(16, armShape.r * 0.21)
            radius: Theme.rad(3)
            rotation: 24
            color: armShape.shadow ? armShape.shade : "transparent"

            gradient: armShape.shadow ? null : headGradient

            Gradient {
                id: headGradient

                orientation: Gradient.Horizontal

                GradientStop {
                    position: 0
                    color: "#e9e9e9"
                }

                GradientStop {
                    position: 1
                    color: "#7d7d7d"
                }

            }

            Rectangle {
                visible: !armShape.shadow
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.bottom
                anchors.topMargin: -2
                width: 2.5
                height: 5
                radius: 1
                color: Theme.accent
            }

        }

    }

}
