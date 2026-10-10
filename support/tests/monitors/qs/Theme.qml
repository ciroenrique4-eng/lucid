// stand-in for the shell's Theme singleton, for tst_monitormap.qml
pragma Singleton
import QtQuick
QtObject {
    property int radiusXl: 12; property color bgSunken: "#111"; property color accent: "#f80"
    property int shapeSm: 6; property color bgActive: "#333"; property color fgAccent: "#000"
    property color subtextDim: "#888"; property color text: "#fff"; property string fontFamily: "sans"
    property int fontLabel: 11; property int fontLabelLg: 13; property int durShort: 1; property int easeStandard: Easing.Linear
    function alpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }
}
