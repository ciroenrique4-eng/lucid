import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import qs
import "../luciddocks"

// the dock's pinned apps and every open one, an icon each, for a bar that does
// the dock's job: a click switches to the app, a middle click opens another
// window, a right click lists its windows and what can be done with them. the
// data is the dock's own (its windows, its desktop-entry lookup, its pins), so
// pinning here or there changes both
BarPill {
    id: root

    property var dockMod: null

    readonly property var clients: root.dockMod ? root.dockMod.clientsData : []
    readonly property string focusedAddress: root.dockMod ? root.dockMod.focusedAddress : ""
    readonly property int currentWs: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1
    // the looks and options, from its card on the Bar page
    readonly property bool namesFace: Prefs.appsModuleStyle === "names"
    readonly property bool thisWorkspaceOnly: Prefs.appsModuleScope === "workspace"
    readonly property int iconSize: Math.max(16, Math.min(Prefs.appsModuleIconSize, root.compactHeight - 6))
    readonly property int slotWidth: root.iconSize + 14

    function inScope(c) {
        return !root.thisWorkspaceOnly || (!!c.workspace && c.workspace.id === root.currentWs);
    }

    // where the open (unpinned) apps were dragged to, by key; for this session,
    // since they come and go with their windows
    property var runningOrder: []

    // each app once: the pinned first, in the dock's order, then the others in
    // the order they were dragged to, or else their first window opened.
    // windows keeps Hyprland's order, which holds still while the focus moves
    // around. base is the desktop entry, which notifications name
    readonly property var apps: {
        const out = [];
        const running = [];
        const byKey = {};
        const add = (app) => {
            byKey[app.key] = app;
            out.push(app);
        };
        if (Prefs.appsModulePinned && root.dockMod) {
            for (const p of root.dockMod.pinnedList) {
                const key = String(p.appId || "").toLowerCase();
                if (key === "" || byKey[key])
                    continue;

                const pe = root.dockMod.entryForClass(String(p.appId));
                add({
                    "key": key,
                    "appId": p.appId,
                    "base": pe ? String(pe.base).toLowerCase() : key,
                    "entry": pe ? String(pe.base) : "",
                    "name": p.name || p.appId,
                    "icon": IconTheme.resolve(p.iconName),
                    "command": p.command || "",
                    "pinned": true,
                    "windows": []
                });
            }
        }
        for (const c of root.clients) {
            if (!c.class || !root.inScope(c))
                continue;

            const key = c.class.toLowerCase();
            let app = byKey[key];
            if (!app) {
                // with running apps off, only the pinned ones show
                if (!Prefs.appsModuleShowRunning)
                    continue;

                const e = root.dockMod ? root.dockMod.entryForClass(c.class) : null;
                app = {
                    "key": key,
                    "appId": c.class,
                    "base": e ? String(e.base).toLowerCase() : key,
                    "entry": e ? String(e.base) : "",
                    "name": e ? e.name : c.class,
                    "icon": root.dockMod ? root.dockMod.iconForClass(c.class) : "",
                    "command": e ? e.command : "",
                    "pinned": false,
                    "windows": []
                };
                byKey[key] = app;
                running.push(app);
            }
            app.windows.push(c);
        }
        const rank = (a) => {
            const i = root.runningOrder.indexOf(a.key);
            return i < 0 ? 1e6 : i;
        };
        // a stable sort keeps the undragged ones in their opening order
        const ranked = running.map((a, i) => {
            return {
                "a": a,
                "i": i
            };
        }).sort((x, y) => {
            return rank(x.a) - rank(y.a) || x.i - y.i;
        });
        for (const r of ranked)
            out.push(r.a);
        return out;
    }

    readonly property int pinnedCount: root.apps.filter((a) => {
        return a.pinned;
    }).length

    function dockIndexOf(app) {
        if (!root.dockMod || !app)
            return -1;

        return root.dockMod.pinnedList.findIndex((p) => {
            return String(p.appId || "").toLowerCase() === app.key;
        });
    }

    // a drag along the strip ends: a pin moves among the pins, an open app
    // moves among the open ones, or, dropped among the pins, is pinned there
    function dropApp(from, to) {
        const app = root.apps[from];
        if (!app || from === to)
            return ;

        const pins = root.pinnedCount;
        if (app.pinned) {
            const target = root.apps[Math.min(to, pins - 1)];
            root.dockMod.movePinned(root.dockIndexOf(app), root.dockIndexOf(target));
            return ;
        }
        if (to < pins && app.command !== "" && root.dockMod) {
            root.dockMod.pinRunningApp(app.appId, root.dockIndexOf(root.apps[to]));
            return ;
        }
        const keys = root.apps.slice(pins).map((a) => {
            return a.key;
        }).filter((k) => {
            return k !== app.key;
        });
        keys.splice(Math.max(0, to - pins), 0, app.key);
        root.runningOrder = keys;
    }

    // waiting notifications from an app, by its desktop entry, name or class
    function badgeOf(app) {
        if (!Prefs.appsModuleBadges || !app || app.key === "")
            return 0;

        const c = Notifs.countsByApp;
        return c[app.base] || c[String(app.name).toLowerCase()] || c[app.key] || 0;
    }

    readonly property var noApp: ({
        "key": "",
        "appId": "",
        "base": "",
        "name": "",
        "icon": "",
        "command": "",
        "pinned": false,
        "windows": []
    })

    // the app the panel is about, looked up again as windows come and go
    property string panelKey: ""
    readonly property var panelApp: root.apps.find((a) => {
        return a.key === root.panelKey;
    }) || null

    // the app the pointer rests on: its windows, live, over the bar
    property string previewKey: ""
    // the middle of its icon, in the overlay's coordinates
    property real previewX: 0
    readonly property var previewApp: root.previewKey === "" ? null : (root.apps.find((a) => {
        return a.key === root.previewKey;
    }) || null)
    readonly property bool previewShown: root.previewApp !== null && root.shown && !root.anyOpen

    function tileFor(index) {
        for (const c of appRow.children) {
            if (c.index === index)
                return c;

        }
        return null;
    }

    function showPreview(index) {
        if (!Prefs.appsModuleTooltips)
            return ;

        const app = index >= 0 && index < root.apps.length ? root.apps[index] : null;
        const tileItem = root.tileFor(index);
        if (!app || !tileItem)
            return ;

        root.previewX = tileItem.mapToItem(previewLayer, tileItem.width / 2, 0).x;
        root.previewKey = app.key;
    }

    function hidePreview() {
        previewOpen.stop();
        previewClose.stop();
        root.previewKey = "";
    }

    // the toplevel behind one of an app's windows, for its live picture
    function toplevelAt(address) {
        return Hyprland.toplevels.values.find((t) => {
            return t && t.lastIpcObject && t.lastIpcObject.address === address;
        }) || null;
    }

    function hasFocus(app) {
        return app.windows.some((w) => {
            return w.address === root.focusedAddress;
        });
    }

    // the window used last, for an app none of whose windows has the focus
    function latest(app) {
        let best = null;
        for (const w of app.windows) {
            if (!best || (w.focusHistoryID !== undefined && w.focusHistoryID < best.focusHistoryID))
                best = w;

        }
        return best;
    }

    // the pointer stays where it is: it was on the bar, and Hyprland would
    // otherwise warp it to the window's middle. no_warps goes on for this one
    // focus and back to what it was, in the same call, so nothing else sees it
    function focusNow(address) {
        if (!/^0x[0-9a-fA-F]+$/.test(address || ""))
            return ;

        // put away by show desktop: back where it was first, the rest stay away
        if (ShowDesktop.holds(address))
            ShowDesktop.bringBack(address);

        Quickshell.execDetached(["hyprctl", "eval", "local nw = hl.get_config('cursor.no_warps') " + "hl.config({ cursor = { no_warps = true } }) " + "pcall(function() hl.dispatch(hl.dsp.focus({ window = 'address:" + address + "' })) end) " + "hl.config({ cursor = { no_warps = nw } })"]);
    }

    // from inside the panel: its focus grab hands the focus back as it lets go,
    // so the switch waits for that to be over
    function focusFromPanel(address) {
        root.expanded = false;
        focusLater.address = address;
        focusLater.restart();
    }

    function launch(app) {
        if (app && app.command !== "")
            Quickshell.execDetached(["sh", "-c", app.command]);

    }

    function closeWindow(address) {
        closeGuard.restart();
        Hyprland.dispatch("hl.dsp.window.close({ window = \"address:" + address + "\" })");
        refresh.restart();
    }

    function cycle(app, step) {
        const n = app.windows.length;
        if (n === 0)
            return ;

        const i = app.windows.findIndex((w) => {
            return w.address === root.focusedAddress;
        });
        const next = i < 0 ? root.latest(app) : app.windows[(i + step + n) % n];
        root.focusNow(next.address);
    }

    function openPanel(app) {
        if (root.expanded && root.panelKey === app.key) {
            root.expanded = false;
            return ;
        }
        root.panelKey = app.key;
        Hyprland.refreshToplevels();
        root.expanded = true;
    }

    // a left click: open it, bring its window, or show its windows to pick one
    function primary(app) {
        const n = app.windows.length;
        if (n === 0) {
            root.launch(app);
        } else if (n === 1) {
            root.focusNow(app.windows[0].address);
        } else if (Prefs.appsModuleClick === "cycle") {
            root.cycle(app, 1);
        } else {
            root.openPanel(app);
        }
    }

    function workspaceLabel(c) {
        const name = c.workspace ? String(c.workspace.name || c.workspace.id) : "";
        if (name === ShowDesktop.stash)
            return "Put away · show desktop";

        if (name.indexOf("special:") === 0)
            return "Special · " + name.substring(8);

        return name !== "" ? "Workspace " + name : "";
    }

    // its own row of things to click: hovering must not open the panel over it
    opensOnHover: false
    // each icon lights up on its own
    tintsOnHover: false
    compactInteractive: false
    compactHovered: faceArea.containsMouse
    shown: Prefs.showApps && root.apps.length > 0
    compactWidth: appRow.implicitWidth + 8
    panelWidth: 340
    panelHeight: panelColumn.implicitHeight + 32
    expandedRadius: Theme.shapeXl
    onShownChanged: {
        if (!root.shown)
            root.expanded = false;

    }
    overlayOpen: root.previewShown
    overlayItem: previewCard
    onAnyOpenChanged: {
        if (root.anyOpen)
            root.hidePreview();

    }
    onPreviewAppChanged: {
        if (!root.previewApp)
            root.previewKey = "";

    }
    onPanelAppChanged: {
        if (root.expanded && !root.panelApp)
            root.expanded = false;

    }

    // resting on an icon opens it; once one is up, moving along switches at once
    Timer {
        id: previewOpen

        property int index: -1

        interval: 500
        onTriggered: root.showPreview(previewOpen.index)
    }

    // long enough to cross the gap between the bar and the preview
    Timer {
        id: previewClose

        interval: 280
        onTriggered: {
            if (faceArea.hoverIndex < 0 && !previewHover.hovered)
                root.previewKey = "";

        }
    }

    Timer {
        id: focusLater

        property string address: ""

        interval: 80
        onTriggered: root.focusNow(focusLater.address)
    }

    // the rows close up under the pointer as a window goes, so for a moment a
    // second click must not land on the next window's close button
    Timer {
        id: closeGuard

        interval: 500
    }

    Timer {
        id: refresh

        interval: 150
        onTriggered: Hyprland.refreshToplevels()
    }

    // titles only reach lastIpcObject on a refresh
    Timer {
        interval: 2000
        repeat: true
        running: root.expanded
        onTriggered: Hyprland.refreshToplevels()
    }

    component AppIcon: Item {
        id: appIcon

        property var app: null
        property int size: 20

        width: appIcon.size
        height: appIcon.size

        IconImage {
            anchors.fill: parent
            visible: !!appIcon.app && appIcon.app.icon !== ""
            source: appIcon.app ? appIcon.app.icon : ""
            asynchronous: true
        }

        Rectangle {
            anchors.fill: parent
            visible: !appIcon.app || appIcon.app.icon === ""
            radius: Theme.rad(6)
            color: Theme.bgHigh

            Text {
                anchors.centerIn: parent
                text: appIcon.app && appIcon.app.name ? appIcon.app.name.charAt(0).toUpperCase() : "?"
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: Math.round(appIcon.size * 0.55)
                font.weight: Font.DemiBold
            }

        }

    }

    component ActionButton: Rectangle {
        id: button

        property string label: ""
        property bool danger: false

        signal clicked()

        width: buttonLabel.implicitWidth + 28
        height: 36
        radius: Theme.pill(height)
        color: {
            if (button.danger)
                return buttonArea.containsMouse ? Theme.error : Theme.errorContainer;

            return buttonArea.containsMouse ? Theme.alpha(Theme.secondaryContainer, 0.8) : Theme.secondaryContainer;
        }

        Text {
            id: buttonLabel

            anchors.centerIn: parent
            text: button.label
            color: button.danger ? (buttonArea.containsMouse ? Theme.fgError : Theme.fgErrorContainer) : Theme.fgSecondaryContainer
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontLabelLg
            font.weight: Font.Medium
        }

        MouseArea {
            id: buttonArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }

        Behavior on color {
            ColorAnimation {
                duration: Theme.durShort
            }

        }

    }

    compactContent: [
        Row {
            id: appRow

            anchors.centerIn: parent
            spacing: Prefs.appsModuleSpacing

            // by count, not by the list: the list is rebuilt whenever a window
            // changes title, and a list model would rebuild every icon with it
            Repeater {
                model: root.apps.length

                Item {
                    id: tile

                    required property int index

                    readonly property var app: root.apps[tile.index] || root.noApp
                    readonly property int count: tile.app.windows.length
                    readonly property bool focused: root.hasFocus(tile.app)
                    readonly property bool hovered: faceArea.hoverIndex === tile.index
                    readonly property bool urgent: tile.count > 0 && Hyprland.toplevels.values.some((t) => {
                        return t.urgent && t.wayland && t.wayland.appId && t.wayland.appId.toLowerCase() === tile.app.key;
                    })

                    readonly property int badge: root.badgeOf(tile.app)
                    // the dock's hover: the icon swells and lifts away from the screen
                    // edge under the pointer (an open app overshoots), pressed it sinks
                    // and, with magnify, its neighbours swell in a ripple
                    readonly property bool pressedNow: faceArea.pressedIndex === tile.index
                    readonly property int hoverDist: faceArea.hoverIndex < 0 || faceArea.dragIndex >= 0 ? -1 : Math.abs(tile.index - faceArea.hoverIndex)
                    readonly property real boost: {
                        if (!Prefs.appsModuleMagnify)
                            return 0;

                        if (tile.hoverDist === 1)
                            return 0.06 * Prefs.appsModuleHoverEffect;

                        return tile.hoverDist === 2 ? 0.025 * Prefs.appsModuleHoverEffect : 0;
                    }
                    property real swell: tile.pressedNow ? -0.06 : (tile.hovered ? (tile.count > 0 ? 0.12 : 0.08) * Prefs.appsModuleHoverEffect : tile.boost)
                    property real lift: tile.pressedNow ? 2 : (tile.hovered ? (tile.count > 0 ? 9 : 6) * Prefs.appsModuleHoverEffect : 0)
                    readonly property bool lifted: faceArea.dragIndex === tile.index
                    // while one is dragged: it follows the pointer, and the ones
                    // between where it was and where it would land make room
                    readonly property real shift: {
                        const from = faceArea.dragIndex;
                        const to = faceArea.dropIndex;
                        if (from < 0)
                            return 0;

                        if (tile.lifted)
                            return faceArea.dragDx;

                        const room = faceArea.dragWidth + appRow.spacing;
                        if (from < to && tile.index > from && tile.index <= to)
                            return -room;

                        if (from > to && tile.index >= to && tile.index < from)
                            return room;

                        return 0;
                    }

                    width: root.namesFace ? nameText.width + root.iconSize + 26 : root.slotWidth
                    height: root.compactHeight
                    z: tile.lifted ? 10 : 0
                    transform: Translate {
                        x: tile.shift

                        Behavior on x {
                            enabled: !tile.lifted

                            NumberAnimation {
                                duration: Theme.barMs(160)
                                easing.type: Easing.OutCubic
                            }

                        }

                    }

                    Behavior on swell {
                        NumberAnimation {
                            duration: Theme.durShort
                            easing.type: tile.count > 0 && tile.hovered ? Easing.OutBack : Easing.OutCubic
                            easing.overshoot: 0.6
                        }

                    }

                    Behavior on lift {
                        NumberAnimation {
                            duration: Theme.durShort
                            easing.type: tile.count > 0 && tile.hovered ? Easing.OutBack : Easing.OutCubic
                            easing.overshoot: 0.6
                        }

                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        height: Math.max(0, root.compactHeight - 8)
                        radius: Theme.pill(height)
                        color: tile.lifted ? Theme.alpha(Theme.text, 0.16) : (tile.focused ? Theme.alpha(Theme.accent, faceArea.pressedIndex === tile.index ? 0.26 : 0.16) : Theme.alpha(Theme.text, faceArea.pressedIndex === tile.index ? 0.14 : (tile.hovered ? 0.08 : 0)))

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.durShort
                            }

                        }

                    }

                    // the dock's tile behind the icon
                    Rectangle {
                        visible: Prefs.appsModuleIconTiles
                        x: tileIcon.x - 4
                        anchors.verticalCenter: parent.verticalCenter
                        width: tileIcon.width + 8
                        height: tileIcon.height + 8
                        radius: Theme.rad(8)
                        color: Theme.bgTile
                        scale: 1 + tile.swell
                        transform: Translate {
                            y: root.atBottom ? -tile.lift : tile.lift
                        }
                    }

                    AppIcon {
                        id: tileIcon

                        app: tile.app
                        size: root.iconSize
                        scale: 1 + tile.swell
                        transform: Translate {
                            y: root.atBottom ? -tile.lift : tile.lift
                        }

                        x: root.namesFace ? 9 : (parent.width - width) / 2
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: tile.count > 0 || tile.hovered ? 1 : 0.72
                    }

                    // measured apart: an eliding Text's implicitWidth follows its own
                    // width, which loops when the width is taken from it
                    TextMetrics {
                        id: nameMetrics

                        text: tile.app.name
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontLabelLg
                        font.weight: Font.DemiBold
                    }

                    Text {
                        id: nameText

                        visible: root.namesFace
                        x: tileIcon.x + tileIcon.width + 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: root.namesFace ? Math.min(Math.ceil(nameMetrics.advanceWidth) + 1, Prefs.appsModuleNameWidth) : 0
                        text: tile.app.name
                        color: tile.count > 0 ? Theme.text : Theme.subtext
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontLabelLg
                        font.weight: tile.focused ? Font.DemiBold : Font.Medium
                        elide: Text.ElideRight
                    }

                    // waiting notifications, on the icon's corner away from the edge
                    Rectangle {
                        visible: tile.badge > 0
                        x: tileIcon.x + tileIcon.width - width / 2 - 1
                        y: root.atBottom ? tileIcon.y - height / 2 + 2 : tileIcon.y + tileIcon.height - height / 2 - 2
                        width: Math.max(height, badgeText.implicitWidth + 7)
                        height: 14
                        radius: Theme.pill(height)
                        color: Theme.accent
                        border.width: 1.5
                        border.color: Theme.bg
                        z: 2

                        Text {
                            id: badgeText

                            anchors.centerIn: parent
                            text: tile.badge > 9 ? "9+" : String(tile.badge)
                            color: Theme.fgAccent
                            font.family: Theme.fontFamily
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                        }

                    }

                    // its windows, on the side against the screen edge: a bar for the
                    // app in focus, a dot a window otherwise (up to three)
                    Row {
                        id: marks

                        readonly property int segments: Math.max(1, Math.min(3, tile.count))

                        anchors.horizontalCenter: tileIcon.horizontalCenter
                        y: root.atBottom ? parent.height - 5 : 2
                        spacing: 3
                        visible: tile.count > 0 && Prefs.appsModuleIndicators

                        Repeater {
                            model: tile.focused ? 1 : marks.segments

                            Rectangle {
                                width: tile.focused ? 14 : 4
                                height: 3
                                radius: height / 2
                                color: tile.urgent ? Theme.error : (tile.focused ? Theme.accent : Theme.subtext)

                                Behavior on width {
                                    NumberAnimation {
                                        duration: Theme.durShort
                                        easing.type: Easing.OutCubic
                                    }

                                }

                            }

                        }

                    }

                }

            }

        },
        // what rides under the pointer when an app is pulled off the bar
        Item {
            id: outProxy

            width: 40
            height: 40
            Drag.dragType: Drag.Automatic
            Drag.supportedActions: Qt.CopyAction
            Drag.proposedAction: Qt.CopyAction
            Drag.imageSourceSize: Qt.size(40, 40)
            Drag.hotSpot.x: 20
            Drag.hotSpot.y: 20
            Drag.onDragFinished: (action) => {
                outProxy.Drag.active = false;
            }
        },
        // one area over the whole face: the pill's own is off, since every click
        // here means something for the app under the pointer
        MouseArea {
            id: faceArea

            property int hoverIndex: -1
            property int pressedIndex: -1
            // a drag along the strip: which icon, how far, and where it would land
            property int dragIndex: -1
            property real pressX: 0
            property real dragDx: 0
            property real dragWidth: 0
            property bool dragEnded: false
            readonly property int dropIndex: {
                if (faceArea.dragIndex < 0)
                    return -1;

                const tiles = [];
                for (const c of appRow.children) {
                    if (c.index !== undefined && c.width > 0)
                        tiles.push(c);

                }
                const lifted = tiles.find((t) => {
                    return t.index === faceArea.dragIndex;
                });
                if (!lifted)
                    return faceArea.dragIndex;

                const centre = lifted.x + lifted.width / 2 + faceArea.dragDx;
                let to = 0;
                for (const t of tiles) {
                    if (t !== lifted && t.x + t.width / 2 < centre)
                        to++;

                }
                return to;
            }

            function indexAt(mx, my) {
                const p = mapToItem(appRow, mx, my);
                const t = appRow.childAt(p.x, appRow.height / 2);
                return t && t.index !== undefined ? t.index : -1;
            }

            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            cursorShape: faceArea.dragIndex >= 0 ? Qt.ClosedHandCursor : Qt.PointingHandCursor
            // on entering too: a pointer that lands on an icon in one jump sends
            // no move until it moves again
            function hoverAt(mx, my) {
                const i = faceArea.indexAt(mx, my);
                if (i === faceArea.hoverIndex)
                    return ;

                faceArea.hoverIndex = i;
                if (i < 0) {
                    previewOpen.stop();
                    previewClose.restart();
                } else if (root.previewShown) {
                    previewClose.stop();
                    root.showPreview(i);
                } else {
                    previewOpen.index = i;
                    previewOpen.restart();
                }
            }

            onEntered: faceArea.hoverAt(faceArea.mouseX, faceArea.mouseY)
            onPositionChanged: (mouse) => {
                if (faceArea.pressed && faceArea.pressedIndex >= 0 && (mouse.buttons & Qt.LeftButton)) {
                    // pulled off the bar, an app with a desktop entry becomes a
                    // drag the desktop takes as a launcher
                    const app = root.apps[faceArea.pressedIndex];
                    if ((mouse.y < -20 || mouse.y > faceArea.height + 20) && app && app.entry !== "" && !outProxy.Drag.active) {
                        faceArea.dragIndex = -1;
                        faceArea.dragDx = 0;
                        faceArea.dragEnded = true;
                        // the drag takes the pointer without a word to the bar
                        faceArea.hoverIndex = -1;
                        root.hidePreview();
                        const data = {};
                        data[DesktopIcons.appMime] = app.entry;
                        outProxy.Drag.mimeData = data;
                        outProxy.Drag.imageSource = app.icon;
                        outProxy.Drag.active = true;
                        return ;
                    }
                    const dx = mouse.x - faceArea.pressX;
                    if (faceArea.dragIndex < 0 && Math.abs(dx) > 6) {
                        const t = root.tileFor(faceArea.pressedIndex);
                        faceArea.dragWidth = t ? t.width : root.slotWidth;
                        faceArea.dragIndex = faceArea.pressedIndex;
                        root.hidePreview();
                    }
                    if (faceArea.dragIndex >= 0) {
                        faceArea.dragDx = dx;
                        return ;
                    }
                }
                return faceArea.hoverAt(mouse.x, mouse.y);
            }
            onExited: {
                faceArea.hoverIndex = -1;
                previewOpen.stop();
                previewClose.restart();
            }
            preventStealing: faceArea.dragIndex >= 0
            onPressed: (mouse) => {
                root.hidePreview();
                faceArea.pressX = mouse.x;
                faceArea.dragEnded = false;
                return faceArea.pressedIndex = faceArea.indexAt(mouse.x, mouse.y);
            }
            onReleased: {
                if (faceArea.dragIndex >= 0) {
                    const from = faceArea.dragIndex;
                    const to = faceArea.dropIndex;
                    faceArea.dragIndex = -1;
                    faceArea.dragDx = 0;
                    faceArea.dragEnded = true;
                    root.dropApp(from, to);
                }
                faceArea.pressedIndex = -1;
            }
            onCanceled: {
                faceArea.dragIndex = -1;
                faceArea.dragDx = 0;
                faceArea.pressedIndex = -1;
            }
            onClicked: (mouse) => {
                // the end of a drag is not a click
                if (faceArea.dragEnded) {
                    faceArea.dragEnded = false;
                    return ;
                }
                const i = faceArea.indexAt(mouse.x, mouse.y);
                const app = i >= 0 && i < root.apps.length ? root.apps[i] : null;
                if (!app) {
                    // between the icons, it is the module like any other
                    if (mouse.button === Qt.RightButton)
                        Prefs.openBarModule("apps");

                    return ;
                }
                if (mouse.button === Qt.RightButton)
                    root.openPanel(app);
                else if (mouse.button === Qt.MiddleButton)
                    root.launch(app);
                else
                    root.primary(app);
            }
            onWheel: (wheel) => {
                const i = faceArea.indexAt(wheel.x, wheel.y);
                if (!Prefs.appsModuleWheel || i < 0 || i >= root.apps.length) {
                    wheel.accepted = false;
                    return ;
                }
                root.cycle(root.apps[i], wheel.angleDelta.y < 0 ? 1 : -1);
            }
        }
    ]

    overlayContent: [
        Item {
            id: previewLayer

            anchors.fill: parent

            Rectangle {
                id: previewCard

                readonly property var app: root.previewApp
                readonly property var windows: previewCard.app ? previewCard.app.windows.slice(0, 5) : []
                readonly property int thumbHeight: 112

                // the width a window's picture gets, from its own shape
                function thumbWidth(w) {
                    const size = w && w.size ? w.size : [16, 9];
                    const ratio = size[1] > 0 ? size[0] / size[1] : 16 / 9;
                    return Math.round(Math.max(96, Math.min(220, previewCard.thumbHeight * ratio)));
                }

                width: Math.max(previewHeader.implicitWidth, thumbRow.visible ? thumbRow.implicitWidth : 0, previewHint.visible ? previewHint.implicitWidth : 0) + 24
                height: previewColumn.implicitHeight + 24
                // over its icon, kept on screen
                x: Math.round(Math.max(10 - root.x, Math.min(root.previewX - width / 2, previewLayer.width - width - 10)))
                y: Math.round(root.overlayEdgeY(root.compactHeight + 8, height))
                radius: Theme.shapeLg
                color: Theme.bg
                opacity: root.previewShown ? 1 : 0
                visible: opacity > 0.01

                HoverHandler {
                    id: previewHover

                    onHoveredChanged: {
                        if (previewHover.hovered)
                            previewClose.stop();
                        else
                            previewClose.restart();
                    }
                }

                Column {
                    id: previewColumn

                    x: 12
                    y: 12
                    spacing: 10

                    Row {
                        id: previewHeader

                        spacing: 8

                        AppIcon {
                            app: previewCard.app
                            size: 18
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: previewCard.app ? previewCard.app.name : ""
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontLabelLg
                            font.weight: Font.DemiBold
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            readonly property int extra: previewCard.app ? previewCard.app.windows.length - previewCard.windows.length : 0
                            visible: extra > 0
                            text: "+" + extra + " more"
                            color: Theme.subtext
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontLabel
                        }

                    }

                    Text {
                        id: previewHint

                        visible: previewCard.windows.length === 0
                        text: previewCard.app && previewCard.app.command !== "" ? "Not open · click to open it" : "Not open"
                        color: Theme.subtext
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontLabel
                    }

                    Row {
                        id: thumbRow

                        visible: previewCard.windows.length > 0
                        spacing: 10

                        Repeater {
                            model: previewCard.windows.length

                            Item {
                                id: thumb

                                required property int index
                                readonly property var modelData: previewCard.windows[thumb.index] || ({})

                                readonly property var toplevel: root.toplevelAt(thumb.modelData.address)
                                readonly property bool hovered: thumbHover.hovered
                                readonly property bool isFocused: thumb.modelData.address === root.focusedAddress

                                width: previewCard.thumbWidth(thumb.modelData)
                                height: previewCard.thumbHeight + 26

                                HoverHandler {
                                    id: thumbHover
                                }

                                ClippingRectangle {
                                    id: frame

                                    width: parent.width
                                    height: previewCard.thumbHeight
                                    radius: Theme.shapeMd
                                    color: Theme.bgTile
                                    border.width: thumb.isFocused ? 2 : 0
                                    border.color: Theme.accent

                                    ScreencopyView {
                                        id: picture

                                        anchors.centerIn: parent
                                        constraintSize.width: frame.width
                                        constraintSize.height: frame.height
                                        captureSource: thumb.toplevel ? thumb.toplevel.wayland : null
                                        live: root.previewShown
                                        visible: picture.hasContent
                                    }

                                    AppIcon {
                                        anchors.centerIn: parent
                                        app: previewCard.app
                                        size: 36
                                        visible: !picture.hasContent
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        color: Theme.text
                                        opacity: thumb.hovered ? Theme.stateHover : 0

                                        Behavior on opacity {
                                            NumberAnimation {
                                                duration: Theme.durQuick
                                            }

                                        }

                                    }

                                }

                                Text {
                                    y: previewCard.thumbHeight + 6
                                    width: parent.width
                                    text: thumb.modelData.title || thumb.modelData.class
                                    color: thumb.hovered || thumb.isFocused ? Theme.text : Theme.subtext
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontLabel
                                    font.weight: thumb.isFocused ? Font.DemiBold : Font.Normal
                                    elide: Text.ElideRight
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                                    onClicked: (mouse) => {
                                        // read before the preview goes, which takes this thumb with it
                                        const address = thumb.modelData.address;
                                        if (mouse.button === Qt.MiddleButton) {
                                            if (!closeGuard.running)
                                                root.closeWindow(address);

                                            return ;
                                        }
                                        // the preview goes first: as it does, the pointer is
                                        // over whatever window is under it, and Hyprland hands
                                        // that one the focus, so the switch comes a beat later
                                        // (and last: it takes this thumb, handler and all)
                                        focusLater.address = address;
                                        focusLater.restart();
                                        root.hidePreview();
                                    }
                                }

                                Rectangle {
                                    anchors.right: frame.right
                                    anchors.top: frame.top
                                    anchors.margins: 6
                                    width: 24
                                    height: 24
                                    radius: Theme.pill(height)
                                    visible: thumb.hovered
                                    color: thumbClose.containsMouse ? Theme.error : Theme.alpha(Theme.bg, 0.85)

                                    Text {
                                        anchors.centerIn: parent
                                        text: "✕"
                                        color: thumbClose.containsMouse ? Theme.fgError : Theme.text
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontLabel
                                    }

                                    MouseArea {
                                        id: thumbClose

                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (!closeGuard.running)
                                                root.closeWindow(thumb.modelData.address);

                                        }
                                    }

                                }

                            }

                        }

                    }

                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.barMs(160)
                        easing.type: Easing.OutCubic
                    }

                }

                Behavior on x {
                    enabled: previewCard.visible

                    NumberAnimation {
                        duration: Theme.barMs(180)
                        easing.type: Easing.OutCubic
                    }

                }

            }

        }
    ]

    panelContent: [
        Column {
            id: panelColumn

            readonly property var app: root.panelApp

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 16
            spacing: 12

            Row {
                spacing: 12

                AppIcon {
                    app: panelColumn.app
                    size: 34
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        width: Math.min(implicitWidth, panelColumn.width - 50)
                        text: panelColumn.app ? panelColumn.app.name : ""
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontTitleSm
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }

                    Text {
                        text: {
                            const app = panelColumn.app;
                            if (!app)
                                return "";

                            const n = app.windows.length;
                            const count = n === 0 ? "Not open" : (n === 1 ? "1 window" : n + " windows");
                            return app.pinned ? count + "  ·  pinned" : count;
                        }
                        color: Theme.subtext
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontLabel
                    }

                }

            }

            // its windows: click one to go to it
            Column {
                width: parent.width
                spacing: 4
                visible: !!panelColumn.app && panelColumn.app.windows.length > 0

                Repeater {
                    model: panelColumn.app ? panelColumn.app.windows.length : 0

                    Rectangle {
                        id: winRow

                        required property int index
                        readonly property var modelData: panelColumn.app && panelColumn.app.windows[winRow.index] || ({})

                        readonly property bool isFocused: winRow.modelData.address === root.focusedAddress

                        width: parent.width
                        height: 46
                        radius: Theme.shapeMd
                        color: winArea.containsMouse ? Theme.alpha(Theme.text, 0.08) : (winRow.isFocused ? Theme.alpha(Theme.accent, 0.12) : Theme.alpha(Theme.text, 0.03))

                        MouseArea {
                            id: winArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                            onClicked: (mouse) => {
                                if (mouse.button === Qt.MiddleButton) {
                                    if (!closeGuard.running)
                                        root.closeWindow(winRow.modelData.address);

                                } else {
                                    root.focusFromPanel(winRow.modelData.address);
                                }
                            }
                        }

                        Column {
                            anchors.left: parent.left
                            anchors.right: closeButton.left
                            anchors.leftMargin: 12
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            Text {
                                width: parent.width
                                text: winRow.modelData.title || winRow.modelData.class
                                color: Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontLabelLg
                                font.weight: winRow.isFocused ? Font.DemiBold : Font.Medium
                                elide: Text.ElideRight
                            }

                            Text {
                                width: parent.width
                                text: root.workspaceLabel(winRow.modelData) + (winRow.isFocused ? "  ·  in focus" : "")
                                color: Theme.subtext
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontLabel
                                elide: Text.ElideRight
                            }

                        }

                        Rectangle {
                            id: closeButton

                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            width: 28
                            height: 28
                            radius: Theme.pill(height)
                            color: closeArea.containsMouse ? Theme.errorContainer : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                color: closeArea.containsMouse ? Theme.fgErrorContainer : Theme.subtext
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontLabelLg
                            }

                            MouseArea {
                                id: closeArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (!closeGuard.running)
                                        root.closeWindow(winRow.modelData.address);

                                }
                            }

                        }

                    }

                }

            }

            Flow {
                width: parent.width
                spacing: 8

                ActionButton {
                    visible: !!panelColumn.app && panelColumn.app.command !== ""
                    label: panelColumn.app && panelColumn.app.windows.length === 0 ? "Open" : "New window"
                    onClicked: {
                        const app = panelColumn.app;
                        root.expanded = false;
                        root.launch(app);
                    }
                }

                // an app with no desktop entry has nothing the dock could start it with
                ActionButton {
                    visible: !!panelColumn.app && !!root.dockMod && (panelColumn.app.pinned || panelColumn.app.command !== "")
                    label: panelColumn.app && panelColumn.app.pinned ? "Unpin" : "Pin"
                    onClicked: {
                        const app = panelColumn.app;
                        if (app.pinned)
                            root.dockMod.unpinApp(app.appId);
                        else
                            root.dockMod.pinRunningApp(app.appId);
                    }
                }

                ActionButton {
                    visible: !!panelColumn.app && panelColumn.app.windows.length > 1
                    label: "Close all"
                    danger: true
                    onClicked: {
                        for (const w of panelColumn.app.windows)
                            root.closeWindow(w.address);
                        root.expanded = false;
                    }
                }

            }

        }
    ]
}
