import QtQuick
import QtQuick.Shapes

// a level ring: a faint track all the way round and the value as an arc from
// twelve o'clock, clockwise, with round caps. whatever goes inside sits in the
// middle. plain QtQuick (no qs import) so it can be tested on its own; callers
// pass the colours and Theme.barMs() for the duration
Item {
    id: ring

    property real value: 0
    property real thickness: 2.5
    property color trackColor: "#33ffffff"
    property color ringColor: "white"
    property int duration: 300
    readonly property real shownValue: Math.max(0, Math.min(1, ring.animatedValue))
    readonly property real sweep: Math.max(0, Math.min(1, ring.value)) * 360
    readonly property bool arcVisible: ring.sweep > 0
    property real animatedValue: ring.value
    readonly property real radius: Math.max(0, (Math.min(ring.width, ring.height) - ring.thickness) / 2)
    default property alias content: inner.data

    implicitWidth: 22
    implicitHeight: 22

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: "transparent"
            strokeColor: ring.trackColor
            strokeWidth: ring.thickness

            PathAngleArc {
                centerX: ring.width / 2
                centerY: ring.height / 2
                radiusX: ring.radius
                radiusY: ring.radius
                startAngle: 0
                sweepAngle: 360
            }

        }

        ShapePath {
            fillColor: "transparent"
            strokeColor: ring.arcVisible ? ring.ringColor : "transparent"
            strokeWidth: ring.thickness
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: ring.width / 2
                centerY: ring.height / 2
                radiusX: ring.radius
                radiusY: ring.radius
                startAngle: -90
                sweepAngle: ring.shownValue * 360
            }

        }

    }

    Item {
        id: inner

        anchors.centerIn: parent
        width: inner.childrenRect.width
        height: inner.childrenRect.height
    }

    Behavior on animatedValue {
        enabled: ring.duration > 0

        NumberAnimation {
            duration: ring.duration
            easing.type: Easing.OutCubic
        }

    }

}
