import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
pragma Singleton

// show the desktop: the windows on the workspace in view go to a hidden
// special workspace, and come back to where they were on the second click.
// the bar's desktop button drives it; the apps module brings a window back
// from there when it is clicked. the list is kept in the runtime dir, so a
// shell that restarts while they are away puts them back
Singleton {
    id: root

    readonly property string stash: "special:lucid-desktop"
    // the windows sent away: [{ address, ws }]
    property var away: []
    readonly property bool active: root.away.length > 0

    function address(t) {
        const a = t ? String(t.address || "") : "";
        return a === "" ? "" : (a.indexOf("0x") === 0 ? a : "0x" + a);
    }

    function move(address, ws) {
        Hyprland.dispatch("hl.dsp.window.move({ window = \"address:" + address + "\", workspace = \"" + ws + "\", follow = false })");
    }

    function toggle() {
        if (root.active)
            root.restore();
        else
            root.show();
    }

    function show() {
        const ws = Hyprland.focusedWorkspace;
        if (!ws || String(ws.name).indexOf("special:") === 0)
            return ;

        const out = [];
        for (const t of ws.toplevels.values) {
            const o = t.lastIpcObject || {};
            // a pinned window is on every workspace: it stays
            if (o.pinned === true)
                continue;

            const a = root.address(t);
            if (a !== "")
                out.push({
                "address": a,
                "ws": ws.id
            });

        }
        if (out.length === 0)
            return ;

        for (const w of out)
            root.move(w.address, root.stash);
        root.away = out;
        root.save();
    }

    function restore() {
        for (const w of root.away)
            root.move(w.address, w.ws);
        root.away = [];
        root.save();
    }

    function holds(address) {
        return root.away.some((w) => {
            return w.address === address;
        });
    }

    // one window back on its own, the rest stay away
    function bringBack(address) {
        const w = root.away.find((x) => {
            return x.address === address;
        });
        if (!w)
            return ;

        root.move(w.address, w.ws);
        root.away = root.away.filter((x) => {
            return x !== w;
        });
        root.save();
    }

    function save() {
        state.setText(JSON.stringify(root.away));
    }

    // windows closed while away drop out of the list
    Connections {
        function onRawEvent(event) {
            if (event.name !== "closewindow" || !root.active)
                return ;

            const a = "0x" + String(event.data).split(",")[0];
            if (root.holds(a)) {
                root.away = root.away.filter((x) => {
                    return x.address !== a;
                });
                root.save();
            }
        }

        target: Hyprland
    }

    FileView {
        id: state

        path: Quickshell.env("XDG_RUNTIME_DIR") + "/lucid-show-desktop.json"
        blockLoading: true
        printErrors: false
        property bool checked: false

        // a shell that went away mid-show: what is still stashed goes home.
        // the first read only, at start; later ones follow our own writes
        onLoadFailed: state.checked = true
        onLoaded: {
            if (state.checked)
                return ;

            state.checked = true;
            let list = [];
            try {
                list = JSON.parse(state.text() || "[]");
            } catch (e) {
            }
            if (Array.isArray(list) && list.length > 0) {
                root.away = list;
                root.restore();
            }
        }
    }

}
