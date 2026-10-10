import QtQuick
import qs
import "MonitorLayout.js" as Layout

// the outputs laid out the way hyprland sees them, drag one to move it. the
// box follows the pointer while an outline shows where it will land: always
// against a neighbour, never on top of one, so there are no gaps to leave the
// pointer stranded in. nothing is applied until it is let go
Item {
    id: map

    // how close an edge has to come to line up with another, in map pixels
    readonly property int snapPx: 14
    // how far a press has to travel before it is a drag rather than a click
    readonly property int dragPx: 4
    // a lone display has nothing to line up with, and the view re-centres on it
    // under the pointer, so a drag would only run away with its position
    readonly property bool movable: Monitors.liveCount > 1
    property string held: ""
    property bool dragging: false
    // where the held box is under the pointer, and where it would land
    property point dragPos: Qt.point(0, 0)
    property point landPos: Qt.point(0, 0)
    property bool canLand: false
    // what had the keyboard before a drag took it for Escape
    property Item keysBefore: null
    // the display the page is pointed at
    property string selected: ""

    signal picked(string key)

    // the outputs that take a place in the layout; a mirror sits wherever its
    // source does, so it is neither moved nor in the way
    readonly property var placed: Monitors.keys.filter((k) => {
        return Monitors.output(k) !== null && Monitors.isOn(k) && Monitors.mirrorOf(k) === "";
    })

    function rectOf(key) {
        const p = Monitors.posOf(key);
        const s = Monitors.layoutSize(key);
        return {
            "x": p.x,
            "y": p.y,
            "w": s.w,
            "h": s.h
        };
    }

    // the whole layout in hyprland's own coordinates, with room around it for
    // a display to be put on any side of the others. nothing is written while
    // a box is held, so this holds still under the pointer until it is let go
    readonly property var bounds: {
        let x0 = 0;
        let y0 = 0;
        let x1 = 0;
        let y1 = 0;
        let first = true;
        for (const key of Monitors.keys) {
            if (!Monitors.isOn(key))
                continue;

            const r = map.rectOf(key);
            if (first) {
                x0 = r.x;
                y0 = r.y;
                x1 = r.x + r.w;
                y1 = r.y + r.h;
                first = false;
            } else {
                x0 = Math.min(x0, r.x);
                y0 = Math.min(y0, r.y);
                x1 = Math.max(x1, r.x + r.w);
                y1 = Math.max(y1, r.y + r.h);
            }
        }
        if (first)
            return {
                "x": 0,
                "y": 0,
                "w": 1920,
                "h": 1080
            };

        let bigW = 0;
        let bigH = 0;
        for (const key of map.placed) {
            const s = Monitors.layoutSize(key);
            bigW = Math.max(bigW, s.w);
            bigH = Math.max(bigH, s.h);
        }
        const padX = Math.max(160, map.movable ? bigW * 0.6 : (x1 - x0) * 0.1);
        const padY = Math.max(160, map.movable ? bigH * 0.6 : (y1 - y0) * 0.1);
        return {
            "x": x0 - padX,
            "y": y0 - padY,
            "w": (x1 - x0) + padX * 2,
            "h": (y1 - y0) + padY * 2
        };
    }
    readonly property real fit: Math.min((frame.width - 20) / map.bounds.w, (frame.height - 20) / map.bounds.h)
    readonly property real offX: frame.width / 2 - (map.bounds.x + map.bounds.w / 2) * map.fit
    readonly property real offY: frame.height / 2 - (map.bounds.y + map.bounds.h / 2) * map.fit

    function begin(key) {
        map.dragging = true;
        const r = map.rectOf(key);
        map.dragPos = Qt.point(r.x, r.y);
        map.landPos = Qt.point(r.x, r.y);
        map.canLand = true;
        map.keysBefore = map.Window.activeFocusItem;
        map.forceActiveFocus();
    }

    // the held box under the pointer (at least half of it kept in view), and
    // where it would land
    function follow(key, wantX, wantY) {
        const s = Monitors.layoutSize(key);
        const x = Math.max(map.bounds.x - s.w / 2, Math.min(map.bounds.x + map.bounds.w - s.w / 2, wantX));
        const y = Math.max(map.bounds.y - s.h / 2, Math.min(map.bounds.y + map.bounds.h - s.h / 2, wantY));
        map.dragPos = Qt.point(x, y);
        const others = map.placed.filter((k) => {
            return k !== key;
        }).map((k) => {
            return map.rectOf(k);
        });
        const spot = Layout.land(s, {
            "x": x,
            "y": y
        }, others, map.snapPx / map.fit);
        map.canLand = spot !== null;
        if (spot)
            map.landPos = Qt.point(spot.x, spot.y);

    }

    function finish() {
        map.dragging = false;
        map.held = "";
        if (map.keysBefore)
            map.keysBefore.forceActiveFocus();
        else
            map.focus = false;
        map.keysBefore = null;
    }

    // the whole layout written at once, its corner at 0,0, so the drop is one
    // apply; a box let go where it started changes nothing
    function commit(key) {
        const from = map.rectOf(key);
        if (map.canLand && (map.landPos.x !== from.x || map.landPos.y !== from.y)) {
            const positions = {};
            for (const k of map.placed) {
                const r = map.rectOf(k);
                positions[k] = k === key ? {
                    "x": map.landPos.x,
                    "y": map.landPos.y
                } : {
                    "x": r.x,
                    "y": r.y
                };
            }
            Monitors.place(Layout.normalise(positions));
        }
        map.finish();
    }

    implicitHeight: Math.max(180, Math.min(420, map.width * map.bounds.h / map.bounds.w))
    // Escape puts the box back; with no drag it is the window's to close on
    Keys.onEscapePressed: (event) => {
        event.accepted = map.dragging;
        if (map.dragging)
            map.finish();

    }

    Rectangle {
        id: frame

        anchors.fill: parent
        radius: Theme.radiusXl
        color: Theme.bgSunken
        clip: true

        // where the held display will go when it is let go
        Rectangle {
            readonly property var size: map.held !== "" ? Monitors.layoutSize(map.held) : ({
                "w": 0,
                "h": 0
            })

            visible: map.dragging && map.canLand
            x: map.offX + map.landPos.x * map.fit
            y: map.offY + map.landPos.y * map.fit
            width: Math.max(34, size.w * map.fit)
            height: Math.max(26, size.h * map.fit)
            radius: Theme.shapeSm
            color: Theme.alpha(Theme.accent, 0.14)
            border.width: 2
            border.color: Theme.accent
            z: 1.5
        }

        Repeater {
            model: Monitors.keys

            Rectangle {
                id: plate

                required property string modelData
                readonly property var out: Monitors.output(plate.modelData)
                readonly property var size: Monitors.layoutSize(plate.modelData)
                readonly property var pos: Monitors.posOf(plate.modelData)
                readonly property bool lifted: map.dragging && map.held === plate.modelData
                readonly property bool lit: drag.containsMouse || map.held === plate.modelData
                readonly property bool chosen: map.selected === plate.modelData

                visible: plate.out !== null && Monitors.isOn(plate.modelData)
                width: Math.max(34, plate.size.w * map.fit)
                height: Math.max(26, plate.size.h * map.fit)
                x: map.offX + (plate.lifted ? map.dragPos.x : plate.pos.x) * map.fit
                y: map.offY + (plate.lifted ? map.dragPos.y : plate.pos.y) * map.fit
                radius: Theme.shapeSm
                color: plate.lit ? Theme.accent : Theme.bgActive
                opacity: plate.lifted ? 0.85 : 1
                border.width: plate.chosen && !plate.lit ? 2 : 0
                border.color: Theme.accent
                z: plate.lit ? 2 : 1

                Text {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.margins: 6
                    visible: plate.height > 44
                    text: Monitors.numberFor(plate.modelData)
                    color: plate.lit ? Theme.fgAccent : Theme.subtextDim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontLabel
                    font.weight: Font.DemiBold
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 1

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: plate.out ? plate.out.name : ""
                        color: plate.lit ? Theme.fgAccent : Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontLabelLg
                        font.weight: Font.DemiBold
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: plate.size.w + " × " + plate.size.h
                        color: plate.lit ? Theme.fgAccent : Theme.subtextDim
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontLabel
                        visible: plate.height > 44
                    }

                }

                MouseArea {
                    id: drag

                    // the press point in the box, so the box does not jump to
                    // the pointer as the drag starts
                    property real pressX: 0
                    property real pressY: 0

                    anchors.fill: parent
                    hoverEnabled: true
                    // the settings pane scrolls, and would take a vertical drag
                    preventStealing: true
                    cursorShape: !map.movable ? Qt.PointingHandCursor : (plate.lifted ? Qt.ClosedHandCursor : Qt.OpenHandCursor)
                    onPressed: (mouse) => {
                        map.held = plate.modelData;
                        drag.pressX = mouse.x;
                        drag.pressY = mouse.y;
                    }
                    onPositionChanged: (mouse) => {
                        if (map.held !== plate.modelData || !map.movable)
                            return ;

                        if (!map.dragging) {
                            if (Math.hypot(mouse.x - drag.pressX, mouse.y - drag.pressY) < map.dragPx)
                                return ;

                            map.begin(plate.modelData);
                        }
                        // the pointer in the frame, back into the layout
                        const fx = plate.x + mouse.x - drag.pressX;
                        const fy = plate.y + mouse.y - drag.pressY;
                        map.follow(plate.modelData, (fx - map.offX) / map.fit, (fy - map.offY) / map.fit);
                    }
                    // Escape already let go of it, so this release is no pick
                    onReleased: {
                        if (map.held !== plate.modelData)
                            return ;

                        if (map.dragging)
                            map.commit(plate.modelData);
                        else {
                            map.held = "";
                            map.picked(plate.modelData);
                        }
                    }
                    onCanceled: {
                        if (map.held === plate.modelData)
                            map.finish();

                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.durShort
                    }

                }

                Behavior on x {
                    enabled: !plate.lifted

                    NumberAnimation {
                        duration: Theme.durShort
                        easing.type: Theme.easeStandard
                    }

                }

                Behavior on y {
                    enabled: !plate.lifted

                    NumberAnimation {
                        duration: Theme.durShort
                        easing.type: Theme.easeStandard
                    }

                }

                Behavior on width {
                    NumberAnimation {
                        duration: Theme.durShort
                        easing.type: Theme.easeStandard
                    }

                }

                Behavior on height {
                    NumberAnimation {
                        duration: Theme.durShort
                        easing.type: Theme.easeStandard
                    }

                }

            }

        }

    }

}
