// stand-in for the shell's Monitors singleton, for tst_monitormap.qml
pragma Singleton
import QtQuick
QtObject {
    id: root
    property var outputs: [{ "key": "A", "name": "eDP-1", "x": 0, "y": 0, "width": 1920, "height": 1080 },
                           { "key": "B", "name": "HDMI-A-1", "x": 1920, "y": 0, "width": 1920, "height": 1080 }]
    property var setups: ({})
    property var placed: null
    property int placeCalls: 0
    readonly property var keys: outputs.map(o => o.key)
    readonly property int liveCount: outputs.length
    function output(k) { return outputs.find(o => o.key === k) || null }
    function isOn(k) { return true }
    function mirrorOf(k) { return "" }
    function posOf(k) { const s = setups[k]; if (s) return { "x": s.x, "y": s.y }; const o = output(k); return { "x": o.x, "y": o.y } }
    function layoutSize(k) { const o = output(k); return { "w": o.width, "h": o.height } }
    function numberFor(k) { return k === "A" ? "1" : "2" }
    function place(p) { placed = p; placeCalls++; const n = {}; for (const k in p) n[k] = p[k]; setups = n }
    function reset() { setups = {}; placed = null; placeCalls = 0 }
}
