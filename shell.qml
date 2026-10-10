//@ pragma AppId lucid
import "./lucidbar"
import "./luciddesktop"
import "./luciddocks"
import "./lucidkeys"
import "./lucidlock"
import "./lucidmoji"
import "./lucidnotif"
import "./lucidosd"
import "./lucidpolkit"
import "./lucidprefs"
import "./lucidshot"
import "./lucidwidgets"
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    // singletons are made lazily, and these have to be up before anything
    // asks: the KDE Connect bridge and its ipc target, the bluez extras, the
    // idle daemon, which owns hypridle.conf, the environment, which owns
    // the gtk and qt appearance files, and the special workspaces, which own
    // lucid-specials.lua, the glass mirror, which owns kitty's opacity file,
    // the displays, which own lucid-monitors.lua, the Hyprland options,
    // which own lucid-settings.lua and follow the palette in border colours,
    // the bluetooth file receiver, which has to be listening before anyone
    // sends something,
    // the desktop shown before a restart, whose windows go back home,
    // the update check, which runs whether or not the settings app is
    // ever opened, the clipboard, which owns the wl-paste watchers and so
    // has to be up long before the launcher is first opened, and night
    // light, whose schedule runs whether or not the System pill is shown, and
    // the feedback sounds, whose ipc has to answer before anything has played
    Component.onCompleted: {
        void KdeConnect.installed;
        void Bt.present;
        void BtReceive.status;
        void Net.connectivity;
        void Idle.probed;
        void Env.probed;
        void Specials.moduleProbed;
        void Glass.probed;
        void Monitors.probed;
        void HyprConfig.moduleProbed;
        void Updates.current;
        void Notifs.count;
        void Clip.probed;
        void Users.probed;
        void Polkit.registered;
        void NightLight.active;
        void Sounds.choosing;
        void WallTransitions.active;
        void ShowDesktop.active;
    }

    // one bar, or one on every display when Settings > Displays asks for it
    Variants {
        id: bars

        model: Monitors.barEverywhere ? Quickshell.screens : [""]

        PanelWindow {
            id: bar

            required property var modelData
            readonly property var workspacesModule: workspacesMod
            readonly property var mprisModule: mprisMod

            visible: Prefs.loaded && Prefs.barEnabled && Monitors.surfacesUp
            property bool laidOut: false
            readonly property bool anyModuleShown: bar.leftGroupWidth + bar.centerGroupWidth + bar.rightGroupWidth > 0.5
            // in a shared notch, a module and the next one shown sit flush when
            // the chain between them holds (one switched off or away keeps it)
            function joinedToNext(ids, widths, i) {
                if (!Prefs.barNotchGrouping)
                    return false;

                for (let k = i + 1; k < ids.length; k++) {
                    if (!Prefs.barJoined(ids[k - 1], ids[k]))
                        return false;

                    if (widths[k] > 0.5)
                        return true;

                }
                return false;
            }

            function placeGroup(ids, widths, originX) {
                const gap = Prefs.barSpacing;
                const out = [];
                let x = originX;
                let any = false;
                for (let i = 0; i < widths.length; i++) {
                    out.push(x);
                    const w = widths[i];
                    if (w > 0.5) {
                        x += w + (gap > 0 && !bar.joinedToNext(ids, widths, i) ? gap * Math.min(1, w / gap) : 0);
                        any = true;
                    }
                }
                out.push(any ? Math.max(originX, x - Prefs.barSpacing) : originX);
                return out;
            }

            property real wsCollapse: (workspacesMod.expanded && !Prefs.barPopupMode) ? 0 : 1
            // the pill for each id in Prefs.barModules
            readonly property var moduleById: ({
                "workspaces": workspacesMod,
                "media": mprisMod,
                "tray": sysTrayMod,
                "clock": clockMod,
                "notifications": notifMod,
                "system": systemMod,
                "privacy": privacyMod,
                "power": powerMod,
                "window": windowMod,
                "apps": appsMod,
                "start": startMod,
                "desktop": desktopMod
            })
            readonly property var modules: Prefs.barModules.map((m) => {
                return bar.moduleById[m.id];
            })

            // which modules switched on have left the bar for now, for the Bar
            // page's arrangement
            Binding {
                target: Prefs
                property: "barModulesAway"
                value: Prefs.barModules.filter((m) => {
                    const mod = bar.moduleById[m.id];
                    return Prefs[m.key] === true && mod && !mod.shown;
                }).map((m) => {
                    return m.id;
                })
            }

            // the least room kept between the centre group and either side group
            readonly property int centerGap: 28
            // every module's x and each group's width, worked out in one pass from
            // the pref and the pills' own widths, so a new layout never meets the
            // places of the old one halfway through
            readonly property var placement: {
                const g = Prefs.barLayoutGroups;
                const lw = g.left.map((id) => {
                    return bar.widthOf(id);
                });
                const cw = g.center.map((id) => {
                    return bar.widthOf(id);
                });
                const rw = g.right.map((id) => {
                    return bar.widthOf(id);
                });
                const left = bar.placeGroup(g.left, lw, 0)[lw.length];
                const center = bar.placeGroup(g.center, cw, 0)[cw.length];
                const right = bar.placeGroup(g.right, rw, 0)[rw.length];
                // centred on the screen, but kept clear of the side groups
                const centerX = Math.min(Math.max((bar.width - center) / 2, bar.sideMargin + left + bar.centerGap), bar.width - right - bar.sideMargin - center - bar.centerGap);
                const out = {
                    "left": left,
                    "center": center,
                    "right": right,
                    "x": {}
                };
                const put = (ids, places) => {
                    for (let i = 0; i < ids.length; i++) out.x[ids[i]] = places[i]
                };
                put(g.left, bar.placeGroup(g.left, lw, bar.sideMargin));
                put(g.center, bar.placeGroup(g.center, cw, centerX));
                put(g.right, bar.placeGroup(g.right, rw, bar.width - right - bar.sideMargin));
                return out;
            }
            readonly property real leftGroupWidth: bar.placement.left
            readonly property real centerGroupWidth: bar.placement.center
            readonly property real rightGroupWidth: bar.placement.right

            // the workspaces pill folds out of its group while the overview is open
            function widthOf(id) {
                const mod = bar.moduleById[id];
                return mod === workspacesMod ? mod.width * bar.wsCollapse : mod.width;
            }

            function xOf(id) {
                return bar.placement.x[id];
            }

            // a pop-up opens away from the edge its group sits against
            function alignOf(id) {
                const g = Prefs.barLayoutGroups;
                if (g.left.indexOf(id) >= 0)
                    return "left";

                return g.center.indexOf(id) >= 0 ? "center" : "right";
            }

            Behavior on wsCollapse {
                NumberAnimation {
                    duration: Theme.barMs(380)
                    easing.type: Easing.OutCubic
                }

            }
            readonly property real sideMargin: Prefs.barSideMargin
            readonly property bool atBottom: Prefs.barBottom

            // the y of something h tall resting against the bar's edge: the top of
            // the window, or its bottom on a bottom bar, less the auto-hide slide
            function edgeY(h) {
                return bar.atBottom ? bar.height - h - bar.hiddenOffset : bar.hiddenOffset;
            }

            // busy: a panel is open somewhere on the bar, so it stays out
            // regardless of the pointer. held: the pointer is on the reveal
            // strip or already on a module - either keeps it from hiding
            // every module in Prefs.barModules counts, so a new one needs no entry here
            readonly property bool barBusy: bar.modules.some((m) => {
                return m && (m === workspacesMod ? m.expanded : m.anyOpen);
            })
            // its pills hold off opening on hover while the launcher is up
            readonly property bool launcherOpen: dock.menuOpen
            // a panel the user opened, not one a hover or a popup brought out:
            // it and the launcher take turns
            readonly property bool panelChosen: bar.modules.some((m) => {
                return m && m.expanded === true && m.hoverOpen !== true;
            })
            onPanelChosenChanged: {
                if (bar.panelChosen)
                    dock.menuOpen = false;

            }
            // what is open on this bar, as {x, w, top, bottom} in screen pixels,
            // for the OSD to slide clear of. the same pieces the mask takes in
            readonly property var openRects: {
                const originY = bar.atBottom ? (bar.screen ? bar.screen.height : bar.height) - Prefs.effectiveBarTopMargin - bar.height : Prefs.effectiveBarTopMargin;
                const out = [];
                for (const m of bar.modules) {
                    if (!m || !(m === workspacesMod ? m.expanded : m.anyOpen))
                        continue;

                    let x0 = m.x + (m.surfaceX !== undefined ? m.surfaceX : 0);
                    let y0 = m.y + (m.surfaceY !== undefined ? m.surfaceY : 0);
                    let x1 = x0 + (m.surfaceWidth !== undefined ? m.surfaceWidth : m.width);
                    let y1 = y0 + (m.surfaceHeight !== undefined ? m.surfaceHeight : m.height);
                    const take = (x, y, w, h) => {
                        x0 = Math.min(x0, x);
                        y0 = Math.min(y0, y);
                        x1 = Math.max(x1, x + w);
                        y1 = Math.max(y1, y + h);
                    };
                    if (m.popupOpen && m.popupItem)
                        take(m.x + m.popupItem.x, m.y + m.popupItem.y, m.popupItem.width, m.popupItem.height);

                    if (m.overlayOpen && m.overlayItem)
                        take(m.x + m.overlayItem.x, m.y + (m.overlayY !== undefined ? m.overlayY : 0) + m.overlayItem.y, m.overlayItem.width, m.overlayItem.height);

                    out.push({
                        "x": x0,
                        "w": x1 - x0,
                        "top": originY + y0,
                        "bottom": originY + y1
                    });
                }
                return out;
            }
            property bool slidingAway: false
            readonly property bool heldByPointer: revealArea.containsMouse || (!bar.slidingAway && bar.modules.some((m) => {
                return m && (m === workspacesMod ? m.compactHovered : m.surfaceHovered);
            }))
            readonly property bool barRevealed: !Prefs.barAutoHide || bar.barBusy || bar.heldByPointer
            // how far the compact content sits off its resting place while
            // hidden - past the window's own edge, so it clips away for free
            property real hiddenOffset: bar.barRevealed ? 0 : -(Prefs.barHeight + Prefs.effectiveBarTopMargin + 4)

            Behavior on hiddenOffset {
                NumberAnimation {
                    duration: Theme.durLong
                    easing.type: Easing.Bezier
                    easing.bezierCurve: Theme.easeEmphasizedDecel
                }

            }

            onBarRevealedChanged: {
                if (bar.barRevealed) {
                    bar.slidingAway = false;
                    slideAwayTimer.stop();
                } else {
                    bar.slidingAway = true;
                    slideAwayTimer.restart();
                }
            }

            Timer {
                id: slideAwayTimer

                interval: Theme.durLong
                onTriggered: bar.slidingAway = false
            }

            Component.onCompleted: laidOutTimer.start()

            Timer {
                id: laidOutTimer

                interval: 120
                onTriggered: bar.laidOut = true
            }

            color: "transparent"
            implicitHeight: bar.screen ? bar.screen.height - Prefs.effectiveBarTopMargin : 800
            exclusiveZone: (Prefs.barEnabled && bar.anyModuleShown && !Prefs.barAutoHide) ? Prefs.barHeight : 0

            anchors {
                top: !bar.atBottom
                bottom: bar.atBottom
                left: true
                right: true
            }

            margins {
                top: bar.atBottom ? 0 : Prefs.effectiveBarTopMargin
                bottom: bar.atBottom ? Prefs.effectiveBarTopMargin : 0
            }

            // full bar: one strip across the whole edge, under every module
            Rectangle {
                id: fullStrip

                visible: Prefs.barFull && bar.anyModuleShown
                x: 0
                y: bar.edgeY(Prefs.barHeight)
                z: -2
                width: bar.width
                height: Prefs.barHeight
                color: Theme.bg

                Behavior on color {
                    enabled: bar.laidOut

                    ColorAnimation {
                        duration: Theme.barMs(260)
                        easing.type: Easing.OutCubic
                    }

                }

            }

            // rounded corners hanging off the strip where it meets the screen sides
            // (standing on it, on a bottom bar)
            BarFlare {
                visible: fullStrip.visible && size > 0
                mirrored: true
                flipped: bar.atBottom
                size: Prefs.barFullCorner
                x: 0
                y: bar.atBottom ? fullStrip.y - height : fullStrip.y + Prefs.barHeight
                z: -2
            }

            BarFlare {
                visible: fullStrip.visible && size > 0
                flipped: bar.atBottom
                size: Prefs.barFullCorner
                x: bar.width - width
                y: bar.atBottom ? fullStrip.y - height : fullStrip.y + Prefs.barHeight
                z: -2
            }

            // module backgrounds on the full bar, or shared notches: the modules
            // of each group, in the arrangement's order, split wherever two
            // neighbours are not joined; one switched off or away keeps a chain
            // through it
            readonly property var clusters: {
                if (!Prefs.barGrouping)
                    return [];

                const g = Prefs.barLayoutGroups;
                const out = [];
                for (const side of ["left", "center", "right"]) {
                    const ids = g[side];
                    let run = [];
                    const flush = () => {
                        // by the room each keeps in the bar: the workspaces
                        // leave it while the overview is open
                        const shown = run.filter((id) => {
                            const m = bar.moduleById[id];
                            return m && m.visible && bar.widthOf(id) > 0.5;
                        });
                        if (shown.length > 0)
                            out.push(shown);

                        run = [];
                    };
                    for (let i = 0; i < ids.length; i++) {
                        if (i > 0 && !Prefs.barJoined(ids[i - 1], ids[i]))
                            flush();

                        run.push(ids[i]);
                    }
                    flush();
                }
                return out;
            }
            // the modules sharing a notch with another, by id: whether each ends
            // it on the left and on the right. A notch of its own is the pill's
            readonly property var sharedNotch: {
                const out = {};
                if (!Prefs.barNotchGrouping)
                    return out;

                for (const run of bar.clusters) {
                    if (run.length < 2)
                        continue;

                    for (let i = 0; i < run.length; i++) out[run[i]] = {
                        "first": i === 0,
                        "last": i === run.length - 1
                    }
                }
                return out;
            }

            function sharesNotch(id) {
                return bar.sharedNotch[id] !== undefined;
            }

            // as tall as the apps module's own highlights, so they line up; and
            // short of each end, so two groups stay apart with no bar spacing.
            // a shared notch is the whole notch, flush with the edge
            readonly property int groupInset: Prefs.barNotchGrouping ? 0 : 4
            readonly property int groupEndInset: Prefs.barNotchGrouping ? 0 : 3

            // repeated by count: the list is rebuilt as the pills change width
            Repeater {
                model: bar.clusters.length

                Item {
                    id: group

                    required property int index

                    readonly property var ids: bar.clusters[group.index] || []
                    readonly property var mods: group.ids.map((id) => {
                        return bar.moduleById[id];
                    })
                    // a notch of one is drawn by its own pill
                    readonly property bool drawn: !Prefs.barNotchGrouping || group.mods.length > 1
                    // from the places the modules keep in the bar, not where
                    // they are: the workspaces go elsewhere for the overview
                    readonly property real x0: group.ids.length > 0 ? Math.min.apply(null, group.ids.map((id) => {
                        return bar.xOf(id);
                    })) + bar.groupEndInset : 0
                    readonly property real x1: group.ids.length > 0 ? Math.max.apply(null, group.ids.map((id) => {
                        return bar.xOf(id) + bar.widthOf(id);
                    })) - bar.groupEndInset : 0
                    readonly property real y0: bar.edgeY(Prefs.barHeight) + bar.groupInset
                    readonly property real tall: Math.max(0, Prefs.barHeight - bar.groupInset * 2)
                    // the notch's corners away from the edge, as a pill's own
                    readonly property int notchRadius: Prefs.barPillRadius

                    anchors.fill: parent
                    z: -1
                    visible: group.drawn

                    Rectangle {
                        x: group.x0
                        y: group.y0
                        width: Math.max(0, group.x1 - group.x0)
                        height: group.tall
                        radius: Prefs.barNotchGrouping ? group.notchRadius : Theme.pill(height)
                        topLeftRadius: Prefs.barNotchGrouping && !bar.atBottom ? 0 : radius
                        topRightRadius: Prefs.barNotchGrouping && !bar.atBottom ? 0 : radius
                        bottomLeftRadius: Prefs.barNotchGrouping && bar.atBottom ? 0 : radius
                        bottomRightRadius: Prefs.barNotchGrouping && bar.atBottom ? 0 : radius
                        color: Prefs.barNotchGrouping ? Theme.bg : Theme.alpha(Theme.text, 0.07)

                        Behavior on color {
                            enabled: bar.laidOut && Prefs.barNotchGrouping

                            ColorAnimation {
                                duration: Theme.barMs(260)
                                easing.type: Easing.OutCubic
                            }

                        }

                    }

                    // each module's hover, to the background's shape: on a shared
                    // notch, a slice of it, rounded where it ends the notch
                    Repeater {
                        model: group.mods.length

                        Rectangle {
                            id: lift

                            required property int index

                            readonly property var mod: group.mods[index]
                            readonly property string id: group.ids[index] || ""
                            readonly property bool lit: !!mod && (mod.compactHovered === true) && mod.tintsOnHover !== false && !(mod.anyOpen === true)
                            readonly property bool endsLeft: lift.index === 0
                            readonly property bool endsRight: lift.index === group.mods.length - 1

                            x: mod ? Math.max(bar.xOf(lift.id), group.x0) : 0
                            y: group.y0
                            width: mod ? Math.max(0, Math.min(bar.xOf(lift.id) + bar.widthOf(lift.id), group.x1) - x) : 0
                            height: group.tall
                            radius: Prefs.barNotchGrouping ? group.notchRadius : Theme.pill(height)
                            topLeftRadius: Prefs.barNotchGrouping ? (bar.atBottom && lift.endsLeft ? radius : 0) : radius
                            topRightRadius: Prefs.barNotchGrouping ? (bar.atBottom && lift.endsRight ? radius : 0) : radius
                            bottomLeftRadius: Prefs.barNotchGrouping ? (!bar.atBottom && lift.endsLeft ? radius : 0) : radius
                            bottomRightRadius: Prefs.barNotchGrouping ? (!bar.atBottom && lift.endsRight ? radius : 0) : radius
                            color: Theme.alpha(Theme.text, lit ? (Prefs.barNotchGrouping ? 0.08 : 0.07) : 0)

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.barMs(150)
                                }

                            }

                        }

                    }

                    // a line between joined neighbours
                    Repeater {
                        model: Prefs.barGroupDividers ? Math.max(0, group.mods.length - 1) : 0

                        Rectangle {
                            required property int index

                            readonly property var a: group.mods[index]
                            readonly property var b: group.mods[index + 1]

                            // not across a panel opening out of either
                            visible: !(a.surfaceOpen === true || b.surfaceOpen === true)
                            x: Math.round(((bar.xOf(group.ids[index]) + bar.widthOf(group.ids[index])) + bar.xOf(group.ids[index + 1])) / 2)
                            y: Math.round(group.y0 + group.tall * 0.25)
                            width: 1
                            height: Math.round(group.tall * 0.5)
                            color: Theme.alpha(Theme.text, 0.22)
                        }

                    }

                }

            }

            // shared notch: a panel opening out of one of its modules hangs off
            // the notch's inner edge, so round the concave corners where its sides
            // meet it - but not at the notch's own ends, which hang off the edge
            Repeater {
                model: (Prefs.barNotchGrouping && !Prefs.barPopupMode) ? bar.modules.filter((m) => {
                    return m && m !== workspacesMod;
                }) : []

                Item {
                    id: notchPanelFlares

                    required property var modelData

                    readonly property var place: bar.sharedNotch[notchPanelFlares.modelData.moduleId()]
                    readonly property real reach: (notchPanelFlares.place && notchPanelFlares.modelData.visible && notchPanelFlares.modelData.surfaceOpen === true) ? notchPanelFlares.modelData.height - Prefs.barHeight : 0

                    // short of the notch's own rounded corner at that end
                    function sizeFor(toTheLeft) {
                        const p = notchPanelFlares.place;
                        if (!p || (toTheLeft ? p.first : p.last))
                            return 0;

                        const m = notchPanelFlares.modelData;
                        const run = bar.clusters.find((r) => {
                            return r.indexOf(m.moduleId()) >= 0;
                        }) || [];
                        const end = toTheLeft ? Math.min.apply(null, run.map((id) => {
                            return bar.xOf(id);
                        })) : Math.max.apply(null, run.map((id) => {
                            return bar.xOf(id) + bar.widthOf(id);
                        }));
                        const room = (toTheLeft ? m.x - end : end - m.x - m.width) - Prefs.barPillRadius;
                        return Math.max(0, Math.floor(Math.min(Prefs.barNotchFlare, notchPanelFlares.reach, room)));
                    }

                    anchors.fill: parent
                    z: -1

                    BarFlare {
                        flipped: bar.atBottom
                        size: notchPanelFlares.sizeFor(true)
                        x: notchPanelFlares.modelData.x - width + 0.5
                        y: bar.atBottom ? bar.edgeY(Prefs.barHeight) - height : bar.edgeY(Prefs.barHeight) + Prefs.barHeight
                    }

                    BarFlare {
                        mirrored: true
                        flipped: bar.atBottom
                        size: notchPanelFlares.sizeFor(false)
                        x: notchPanelFlares.modelData.x + notchPanelFlares.modelData.width - 0.5
                        y: bar.atBottom ? bar.edgeY(Prefs.barHeight) - height : bar.edgeY(Prefs.barHeight) + Prefs.barHeight
                    }

                }

            }

            // full bar: an open panel hangs off the strip, so round the two concave
            // corners where its sides meet the strip's inner edge. They grow with
            // the panel's height, so a folding panel takes them with it
            Repeater {
                model: (Prefs.barFull && !Prefs.barPopupMode) ? [mprisMod, sysTrayMod, clockMod, notifMod, systemMod, appsMod] : []

                Item {
                    id: panelFlares

                    required property var modelData

                    // surfaceOpen, not the height alone: a pill that is only
                    // resizing its compact face is see-through on the full bar
                    readonly property real reach: (panelFlares.modelData.visible && panelFlares.modelData.surfaceOpen === true) ? panelFlares.modelData.height - Prefs.barHeight : 0

                    // never past the screen edge, and never into the screen corner
                    // that already rounds that side
                    function sizeFor(toTheLeft) {
                        var m = panelFlares.modelData;
                        var toEdge = toTheLeft ? m.x : bar.width - m.x - m.width;
                        var room = toEdge - (toEdge < Prefs.barFullCorner * 2 ? Prefs.barFullCorner : 0);
                        return Math.max(0, Math.floor(Math.min(Prefs.barFullCorner, panelFlares.reach, room)));
                    }

                    anchors.fill: parent
                    z: -1

                    BarFlare {
                        flipped: bar.atBottom
                        size: panelFlares.sizeFor(true)
                        x: panelFlares.modelData.x - width + 0.5
                        y: bar.atBottom ? bar.height - Prefs.barHeight - height : Prefs.barHeight
                    }

                    BarFlare {
                        mirrored: true
                        flipped: bar.atBottom
                        size: panelFlares.sizeFor(false)
                        x: panelFlares.modelData.x + panelFlares.modelData.width - 0.5
                        y: bar.atBottom ? bar.height - Prefs.barHeight - height : Prefs.barHeight
                    }

                }

            }

            Mpris {
                id: mprisMod

                popupAlign: bar.alignOf("media")

                hostWindow: bar
                x: bar.xOf("media")
                y: bar.edgeY(mprisMod.height)

            }

            SysTray {
                id: sysTrayMod

                popupAlign: bar.alignOf("tray")

                hostWindow: bar
                x: bar.xOf("tray")
                y: bar.edgeY(sysTrayMod.height)

            }

            Clock {
                id: clockMod

                popupAlign: bar.alignOf("clock")

                hostWindow: bar
                y: bar.edgeY(clockMod.height)
                x: bar.xOf("clock")

            }

            Notifications {
                id: notifMod

                popupAlign: bar.alignOf("notifications")
                showsPopups: !Monitors.barEverywhere || bar.screen === Monitors.popupScreen

                hostWindow: bar
                x: bar.xOf("notifications")
                y: bar.edgeY(notifMod.height)

            }

            System {
                id: systemMod

                popupAlign: bar.alignOf("system")

                hostWindow: bar
                mprisMod: mprisMod
                x: bar.xOf("system")
                y: bar.edgeY(systemMod.height)

            }

            Privacy {
                id: privacyMod

                popupAlign: bar.alignOf("privacy")

                hostWindow: bar
                toast: toastMod
                recorder: snapMod
                x: bar.xOf("privacy")
                y: bar.edgeY(privacyMod.height)

            }

            SessionMenu {
                id: powerMod

                popupAlign: bar.alignOf("power")

                hostWindow: bar
                x: bar.xOf("power")
                y: bar.edgeY(powerMod.height)

            }

            AppStrip {
                id: appsMod

                popupAlign: bar.alignOf("apps")

                hostWindow: bar
                dockMod: dock
                x: bar.xOf("apps")
                y: bar.edgeY(appsMod.height)

            }

            StartButton {
                id: startMod

                popupAlign: bar.alignOf("start")

                hostWindow: bar
                dockMod: dock
                x: bar.xOf("start")
                y: bar.edgeY(startMod.height)

            }

            DesktopButton {
                id: desktopMod

                popupAlign: bar.alignOf("desktop")

                hostWindow: bar
                x: bar.xOf("desktop")
                y: bar.edgeY(desktopMod.height)

            }

            ActiveWindow {
                id: windowMod

                popupAlign: bar.alignOf("window")

                hostWindow: bar
                x: bar.xOf("window")
                y: bar.edgeY(windowMod.height)

            }

            Repeater {
                model: Prefs.barNotch ? bar.modules : []

                Item {
                    id: flares

                    required property var modelData

                    readonly property bool present: flares.modelData && flares.modelData.width > 0.5 && flares.modelData.visible
                    readonly property bool modHovered: flares.modelData ? (flares.modelData.compactHovered === true && flares.modelData !== workspacesMod) : false

                    // in a shared notch only its two ends hang off the edge
                    readonly property var place: flares.modelData ? bar.sharedNotch[flares.modelData === workspacesMod ? "workspaces" : flares.modelData.moduleId()] : undefined

                    function flareFor(toTheLeft) {
                        if (!flares.present)
                            return 0;

                        if (flares.place && !(toTheLeft ? flares.place.first : flares.place.last))
                            return 0;

                        var mods = bar.modules;
                        var edge = toTheLeft ? flares.modelData.x : flares.modelData.x + flares.modelData.width;
                        var toEdge = toTheLeft ? edge : bar.width - edge;
                        var toNeighbour = 100000;
                        for (var i = 0; i < mods.length; i++) {
                            var o = mods[i];
                            if (!o || o === flares.modelData || o.width <= 0.5 || !o.visible)
                                continue;

                            var d = toTheLeft ? edge - (o.x + o.width) : o.x - edge;
                            if (d >= 0)
                                toNeighbour = Math.min(toNeighbour, d);

                        }
                        return Math.max(0, Math.min(Prefs.barNotchFlare, Math.floor(toNeighbour / 2), Math.floor(toEdge)));
                    }

                    anchors.fill: parent
                    z: -1
                    visible: Prefs.barNotch && flares.present

                    readonly property real bite: 0.5

                    BarFlare {
                        hovered: flares.modHovered
                        flipped: bar.atBottom
                        size: flares.flareFor(true)
                        x: flares.modelData ? flares.modelData.x - width + flares.bite : 0
                        y: bar.edgeY(height)
                    }

                    BarFlare {
                        hovered: flares.modHovered
                        mirrored: true
                        flipped: bar.atBottom
                        size: flares.flareFor(false)
                        x: flares.modelData ? flares.modelData.x + flares.modelData.width - flares.bite : 0
                        y: bar.edgeY(height)
                    }

                }

            }

            Workspaces {
                id: workspacesMod

                hostWindow: bar
                dockMod: dock
                restX: bar.xOf("workspaces")
                restY: bar.edgeY(workspacesMod.height)

            }

            // a bar of its own display when there is one on each; otherwise the one
            // bar goes where Settings > Displays puts it. unset must leave the
            // choice to hyprland, which null would not, so it is gated
            Binding {
                target: bar
                property: "screen"
                value: bar.modelData !== "" ? bar.modelData : Monitors.barPlacement
                when: bar.modelData !== "" || Monitors.barPlacement !== null
            }

            Connections {
                function onExpandedChanged() {
                    if (workspacesMod.expanded)
                        dock.menuOpen = false;

                }

                target: workspacesMod
            }

            mask: Region {

                ModuleRegion {
                    mod: workspacesMod
                }

                ModuleRegion {
                    mod: mprisMod
                }

                ModuleRegion {
                    mod: sysTrayMod
                }

                ModuleRegion {
                    mod: clockMod
                }

                ModuleRegion {
                    mod: notifMod
                }

                ModuleRegion {
                    mod: systemMod
                }

                ModuleRegion {
                    mod: privacyMod
                }

                ModuleRegion {
                    mod: powerMod
                }

                ModuleRegion {
                    mod: windowMod
                }

                ModuleRegion {
                    mod: appsMod
                }

                ModuleRegion {
                    mod: startMod
                }

                ModuleRegion {
                    mod: desktopMod
                }

                Region {
                    item: Prefs.barAutoHide ? revealArea : null
                }

            }

            // touching this strip reveals the bar
            MouseArea {
                id: revealArea

                x: 0
                y: bar.atBottom ? bar.height - height : 0
                width: bar.width
                height: 4
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                enabled: Prefs.barAutoHide
                visible: Prefs.barAutoHide
            }

            BackgroundEffect.blurRegion: (Theme.blurAmount > 0 && bar.laidOut) ? barBlurRegion : null

            Region {
                id: barBlurRegion

                Region {
                    x: 0
                    y: fullStrip.visible ? fullStrip.y : 0
                    width: fullStrip.visible ? Math.round(bar.width) : 0
                    height: fullStrip.visible ? Prefs.barHeight : 0
                }

                ModuleRegion {
                    blur: true
                    mod: workspacesMod
                }

                ModuleRegion {
                    blur: true
                    mod: mprisMod
                }

                ModuleRegion {
                    blur: true
                    mod: sysTrayMod
                }

                ModuleRegion {
                    blur: true
                    mod: clockMod
                }

                ModuleRegion {
                    blur: true
                    mod: notifMod
                }

                ModuleRegion {
                    blur: true
                    mod: systemMod
                }

                ModuleRegion {
                    blur: true
                    mod: privacyMod
                }

                ModuleRegion {
                    blur: true
                    mod: powerMod
                }

                ModuleRegion {
                    blur: true
                    mod: windowMod
                }

                ModuleRegion {
                    blur: true
                    mod: appsMod
                }

                ModuleRegion {
                    blur: true
                    mod: startMod
                }

                ModuleRegion {
                    blur: true
                    mod: desktopMod
                }

            }

        }

    }

    Dock {
        id: dock
    }

    Screenshot {
        id: screenshotMod

        shotPreview: shotPreviewMod
        onCaptured: snapMod.open = false
        onSaved: (file, kind) => {
            return shotPreviewMod.show(file, kind, screenshotMod.screen);
        }
        onTextResult: (status) => {
            snapMod.finishTextRead();
            if (status === "copied")
                toastMod.popup("copy", I18n.tr("Text copied"), false);
            else if (status === "notool")
                toastMod.popup("alert", I18n.tr("Install tesseract to copy text"), true);
            else
                toastMod.popup("alert", I18n.tr("No text found"), true);
        }
        onColorResult: (value, hex, status) => {
            if (status === "notool") {
                toastMod.popup("alert", I18n.tr("Install hyprpicker to pick colours"), true);
            } else if (status === "ok") {
                snapMod.open = false;
                if (hex === "")
                    toastMod.popup("copy", value, false);
                else
                    toastMod.popupSwatch(hex, value);
            }
        }
    }

    SnapOverlay {
        id: snapMod

        shotPreview: shotPreviewMod
        onFullscreenRequested: screenshotMod.captureFull(false, snapMod.freezePath)
        onRegionRequested: (x, y, w, h) => {
            return screenshotMod.captureRegion(x, y, w, h, false, snapMod.freezePath, snapMod.freezeScale);
        }
        onTextRequested: (x, y, w, h) => {
            return screenshotMod.copyText(x, y, w, h, snapMod.freezePath, snapMod.freezeScale);
        }
        onColorPickRequested: (format) => screenshotMod.pickColor(format)
        onRecordingSaved: (file) => {
            return screenshotMod.announce(file, "video");
        }
    }

    ShotPreview {
        id: shotPreviewMod
    }

    WidgetLayer {
        id: widgetLayer
    }

    WidgetIpc {
    }

    MonitorIpc {
    }

    Desktop {
    }

    IconRename {
    }

    Osd {
        id: osdMod

        obstacles: {
            const out = [];
            for (const b of bars.instances) {
                if (root.sameScreen(b.screen, osdMod.screen))
                    out.push(...b.openRects);

            }
            // the launcher is centred on the edge, in the dock's window
            if (dock.menuOpen && root.sameScreen(dock.screen, osdMod.screen))
                out.push({
                "x": (osdMod.width - dock.menuWidth) / 2,
                "w": dock.menuWidth,
                "top": (osdMod.screen ? osdMod.screen.height : dock.height) - dock.height,
                "bottom": osdMod.screen ? osdMod.screen.height : dock.height
            });

            return out;
        }
        // the card sits above what the bar and dock reserve along the bottom,
        // unless it already goes down past a covered bar
        bottomReserve: {
            if (Monitors.barCoveredOn(osdMod.screen))
                return 0;

            let r = 0;
            for (const b of bars.instances) {
                if (b.visible && b.atBottom && b.exclusiveZone > 0 && root.sameScreen(b.screen, osdMod.screen))
                    r += b.exclusiveZone + b.margins.bottom;

            }
            if (dock.visible && dock.exclusiveZone > 0 && root.sameScreen(dock.screen, osdMod.screen))
                r += dock.exclusiveZone;

            return r;
        }
    }

    PinnedWindows {
    }

    UrgentWindows {
    }

    Toast {
        id: toastMod
    }

    ToastEvents {
        toast: toastMod
        osd: osdMod
    }

    Lock {
        id: lockMod
    }

    Moji {
        id: mojiMod
    }

    Keyboard {
        id: keyboardMod
    }

    KeybindSheet {
        id: keybindSheetMod
    }

    Settings {
        id: settingsMod
    }

    // the numbers the Displays page puts on every screen
    DisplayIdentify {
    }

    // "keep these display settings?" on every screen while a change is on trial
    DisplayTrial {
    }

    // the map on the Displays page marks the displays these sit on
    Binding {
        target: Monitors
        property: "barWindows"
        value: bars.instances
    }

    Auth {
        id: polkitMod
    }

    Connections {
        function onSettingsRequested() {
            settingsMod.show("notifications");
        }

        target: Notifs
    }

    PanelWindow {
        id: clickCatcher

        // gone while an app is dragged out of the launcher, or it would take
        // the drop meant for the desktop under it
        visible: dock.menuOpen && !dock.appDragging && Monitors.surfacesUp
        color: "transparent"
        exclusiveZone: 0
        WlrLayershell.layer: WlrLayer.Top

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: dock.menuOpen = false
        }

    }

    // every surface there is one of, on the display Settings > Displays picks —
    // the dock can be sent to one of its own, the rest follow the shell.
    // gated, because unset must leave the choice to hyprland, which null would not.
    // emoji and screenshot act on the window you are in, so they follow the focus,
    // and so does the launcher while the dock is off (Dock.launcherPlacement)
    Instantiator {
        model: [dock, clickCatcher]

        Binding {
            required property var modelData

            target: modelData
            property: "screen"
            value: dock.launcherPlacement || Monitors.dockPlacement
            when: (dock.launcherPlacement || Monitors.dockPlacement) !== null
        }

    }

    Instantiator {
        model: [toastMod, keyboardMod, polkitMod, keybindSheetMod]

        Binding {
            required property var modelData

            target: modelData
            property: "screen"
            value: Monitors.shellPlacement
            when: Monitors.shellPlacement !== null
        }

    }

    // the osd follows the shell too, unless no display is picked for it: then
    // it shows on the one being worked on, as the launcher does (Osd.placement)
    Binding {
        target: osdMod
        property: "screen"
        value: osdMod.placement || Monitors.shellPlacement
        when: (osdMod.placement || Monitors.shellPlacement) !== null
    }

    Connections {
        function onKeyboardRequested() {
            keyboardMod.show();
        }

        target: Prefs
    }

    Connections {
        function onDesktopActionRequested(action) {
            if (action === "wallpaper")
                dock.openLauncher(">wallpaper");
            else if (action === "theme")
                dock.openLauncher(">theme");
            else if (action === "screenshot")
                snapMod.beginOpen();

        }

        target: Prefs
    }

    Connections {
        function onMenuOpenChanged() {
            if (!dock.menuOpen)
                return ;

            // every panel the bar has open, not just the overview: the launcher
            // covers them. popups (alt) are left to come and go on their own
            for (const b of bars.instances) {
                for (const m of b.modules) {
                    if (m && m.expanded === true)
                        m.expanded = false;

                }
            }
        }

        target: dock
    }

    // unset (hyprland's choice) is taken as the same display
    function sameScreen(a, b) {
        return !a || !b || a.name === b.name;
    }

    // the bar on the display being worked on, for ipc aimed at "the" bar
    function focusedBar() {
        const list = bars.instances;
        const scr = Monitors.focusedScreen;
        for (const b of list) {
            if (scr && b.screen && b.screen.name === scr.name)
                return b;

        }
        return list.length > 0 ? list[0] : null;
    }

    // here rather than in the modules, which there can be one of per display
    IpcHandler {
        target: "workspaces"

        function toggle(): void {
            const b = root.focusedBar();
            if (b)
                b.workspacesModule.expanded = !b.workspacesModule.expanded;

        }

        function open(): void {
            const b = root.focusedBar();
            if (b)
                b.workspacesModule.expanded = true;

        }

        function close(): void {
            const b = root.focusedBar();
            if (b)
                b.workspacesModule.expanded = false;

        }

    }

    IpcHandler {
        target: "media"

        function toggle(): void {
            const b = root.focusedBar();
            if (!b)
                return ;

            if (b.mprisModule.expanded)
                b.mprisModule.expanded = false;
            else
                b.mprisModule.openPanel("player");
        }

        function open(): void {
            const b = root.focusedBar();
            if (b)
                b.mprisModule.openPanel("player");

        }

        function close(): void {
            const b = root.focusedBar();
            if (b)
                b.mprisModule.expanded = false;

        }

        function identify(): void {
            const b = root.focusedBar();
            if (!b)
                return ;

            b.mprisModule.openPanel("shazam");
            b.mprisModule.startListening();
        }

        function playPause(): void {
            const b = root.focusedBar();
            if (b)
                b.mprisModule.togglePlay();

        }

        function next(): void {
            const b = root.focusedBar();
            if (b)
                b.mprisModule.skip(1);

        }

        function previous(): void {
            const b = root.focusedBar();
            if (b)
                b.mprisModule.skip(-1);

        }

    }

}
