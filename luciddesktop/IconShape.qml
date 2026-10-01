import QtQuick
import QtQuick.Shapes

// one of Material 3's expressive shapes, drawn rather than shipped: a circle
// with soft lobes (cookie, clover, scallop) or a squircle. depth and spin can
// be animated, so a shape can breathe and turn under the pointer
Shape {
    id: sh

    // "lobed" or "squircle"
    property string form: "lobed"
    property int lobes: 8
    // how far the dips between lobes reach in, as a share of the radius
    property real depth: 0.08
    // degrees
    property real spin: 0
    property color fill: "white"
    property color stroke: "transparent"
    property real strokeWidth: 0
    readonly property var points: {
        var out = [];
        var n = 120;
        var R = Math.min(sh.width, sh.height) / 2 - sh.strokeWidth / 2;
        var cx = sh.width / 2;
        var cy = sh.height / 2;
        var a0 = sh.spin * Math.PI / 180;
        for (var i = 0; i <= n; i++) {
            var t = i / n * Math.PI * 2;
            var r = R;
            if (sh.form === "squircle") {
                // |x|^4 + |y|^4 = 1, the curve app icons are cut to
                var c = Math.abs(Math.cos(t));
                var s = Math.abs(Math.sin(t));
                r = R / Math.pow(Math.pow(c, 4) + Math.pow(s, 4), 0.25) * 0.86;
            } else {
                r = R * (1 - sh.depth * (1 - Math.cos(sh.lobes * t)) / 2);
            }
            out.push(Qt.point(cx + r * Math.cos(t + a0), cy + r * Math.sin(t + a0)));
        }
        return out;
    }

    preferredRendererType: Shape.CurveRenderer

    ShapePath {
        fillColor: sh.fill
        strokeColor: sh.stroke
        strokeWidth: sh.strokeWidth

        PathPolyline {
            path: sh.points
        }

    }

}
