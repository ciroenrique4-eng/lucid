.pragma library

// which face the System module draws in the bar, and how full each indicator's
// ring is in the Rings look. kept apart from System.qml so it can be tested

var faces = ["values", "icons", "rings", "accent", "battery"];

// the Battery look needs a battery to show; without one it reads as Icons
function face(style, batteryShown) {
    if (faces.indexOf(style) === -1)
        return "values";
    if (style === "battery" && !batteryShown)
        return "icons";
    return style;
}

function clamp01(v) {
    return Math.max(0, Math.min(1, v));
}

// s: { connected, strength } for wifi, { muted, percent } for volume,
// { muted } for mic, { percent } for battery
function level(kind, s) {
    switch (kind) {
    case "wifi":
        return s.connected ? clamp01(s.strength / 100) : 0;
    case "volume":
        return s.muted ? 0 : clamp01(s.percent / 100);
    case "mic":
        return s.muted ? 0 : 1;
    case "battery":
        return clamp01(s.percent / 100);
    }
    return 0;
}
