import QtQuick
import QtQuick.Shapes
import qs

// the Vinyl panel's turntable: a plinth with the record on the left and, to
// its right, room for whatever the panel puts there (the track, a small
// visualizer). the record turns while the music plays and stops where it is on
// pause. all of it flat, in the palette's tones: the record one tone with two
// grooves, its label the cover cut to one of Material's cookies, whose lobes
// swell while it plays
Item {
    id: vinyl

    property string source: ""
    // the record turns only while the panel shows and the music plays
    property bool spinning: false
    // the needle is down whenever the music plays
    property bool playing: false

    // what the panel sets beside the record
    default property alias info: infoArea.data

    readonly property real plinthW: vinyl.width
    readonly property real plinthX: 0
    readonly property real disc: vinyl.height - 28
    readonly property real r: vinyl.disc / 2
    readonly property real cx: 14 + vinyl.r
    readonly property real cy: vinyl.height / 2
    // the label's lobes stand out while it plays and soften on pause
    property real cookieDepth: vinyl.playing ? 0.1 : 0.05

    Behavior on cookieDepth {
        NumberAnimation {
            duration: Theme.durMedium
            easing.type: Easing.OutBack
            easing.overshoot: 2
        }

    }

    signal clicked()

    // ── the plinth: one flat tone of the palette ──
    Rectangle {
        x: vinyl.plinthX
        width: vinyl.plinthW
        height: vinyl.height
        radius: Theme.rad(18)
        color: Theme.bgHigh
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

    // ── the record: one flat tone, two grooves, the cover in a cookie ──
    Item {
        id: record

        x: vinyl.cx - vinyl.r
        y: vinyl.cy - vinyl.r
        width: vinyl.disc
        height: vinyl.disc

        // round whatever the corner dial says: it turns, a squircle would
        // wobble. the dial shows in the label's lobes instead
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: Theme.bgSunken
        }

        Repeater {
            model: [0.92, 0.76]

            Rectangle {
                required property real modelData

                anchors.centerIn: parent
                width: vinyl.disc * modelData
                height: width
                radius: width / 2
                color: "transparent"
                border.width: 1
                border.color: Theme.alpha(Theme.text, 0.07)
            }

        }

        // the label: an accent cookie, the cover cut to the same shape inside
        Cookie {
            anchors.centerIn: parent
            width: vinyl.disc * 0.56
            height: width
            depth: vinyl.cookieDepth
            fill: Theme.accent
        }

        Cookie {
            anchors.centerIn: parent
            width: vinyl.disc * 0.56 - 8
            height: width
            depth: vinyl.cookieDepth
            fill: Theme.accentContainer
            cover: vinyl.source
        }

        // the spindle hole
        Rectangle {
            anchors.centerIn: parent
            width: Math.max(8, vinyl.disc * 0.05)
            height: width
            radius: width / 2
            color: Theme.bgHigh
        }

    }

    // beside the record, above the speed selector
    Item {
        id: infoArea

        x: vinyl.cx + vinyl.r + 16
        y: 14
        width: vinyl.width - x - 16
        height: vinyl.height - 14 - 34
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

    // a circle with soft lobes, as the desktop's cookies draw it; filled with a
    // colour or, given a cover, with the cover. the shell's roundness dial
    // scales the lobes: squared off, it is a plain circle
    component Cookie: Shape {
        id: cookie

        property real depth: 0.08
        property int lobes: 12
        property color fill: "white"
        property string cover: ""
        readonly property real d: cookie.depth * Math.min(1.5, Math.max(0, Theme.radiusScale))
        readonly property var points: {
            var R = cookie.width / 2;
            var out = [];
            for (var i = 0; i <= 144; i++) {
                var t = i / 144 * Math.PI * 2;
                var r = R * (1 - cookie.d * (1 - Math.cos(cookie.lobes * t)) / 2);
                out.push(Qt.point(R + r * Math.cos(t), R + r * Math.sin(t)));
            }
            return out;
        }

        preferredRendererType: Shape.CurveRenderer

        Image {
            id: coverImage

            width: cookie.width
            height: cookie.height
            source: cookie.cover
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            smooth: true
            sourceSize.width: 256
            sourceSize.height: 256
        }

        // the cover as drawn, cropped to a square: the Image's own texture is
        // the whole picture, so a wide cover would fill from its corner
        ShaderEffectSource {
            id: coverTexture

            width: cookie.width
            height: cookie.height
            sourceItem: coverImage
            hideSource: true
            visible: false
        }

        ShapePath {
            fillColor: cookie.fill
            fillItem: coverImage.status === Image.Ready ? coverTexture : null
            strokeWidth: 0
            strokeColor: "transparent"

            PathPolyline {
                path: cookie.points
            }

        }

    }

}
