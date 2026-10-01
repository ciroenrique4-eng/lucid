import QtQuick
import Quickshell
import Quickshell.Hyprland
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
    readonly property int iconSize: Math.max(16, Math.min(24, root.compactHeight - 14))
    readonly property int slotWidth: root.iconSize + 14

    function inScope(c) {
        return !root.thisWorkspaceOnly || (!!c.workspace && c.workspace.id === root.currentWs);
    }

    // each app once: the pinned first, in the dock's order, then the others in
    // the order their first window opened. windows keeps Hyprland's order, which
    // holds still while the focus moves around
    readonly property var apps: {
        const out = [];
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

                add({
                    "key": key,
                    "appId": p.appId,
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
                const e = root.dockMod ? root.dockMod.entryForClass(c.class) : null;
                app = {
                    "key": key,
                    "appId": c.class,
                    "name": e ? e.name : c.class,
                    "icon": root.dockMod ? root.dockMod.iconForClass(c.class) : "",
                    "command": e ? e.command : "",
                    "pinned": false,
                    "windows": []
                };
                add(app);
            }
            app.windows.push(c);
        }
        return out;
    }

    // the app the panel is about, looked up again as windows come and go
    property string panelKey: ""
    readonly property var panelApp: root.apps.find((a) => {
        return a.key === root.panelKey;
    }) || null

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

    function focusNow(address) {
        if (address)
            Hyprland.dispatch("hl.dsp.focus({ window = \"address:" + address + "\" })");

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
        if (name.indexOf("special:") === 0)
            return "Special · " + name.substring(8);

        return name !== "" ? "Workspace " + name : "";
    }

    // its own row of things to click: hovering must not open the panel over it
    opensOnHover: false
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
    onPanelAppChanged: {
        if (root.expanded && !root.panelApp)
            root.expanded = false;

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
            spacing: 2

            Repeater {
                model: root.apps

                Item {
                    id: tile

                    required property var modelData
                    required property int index

                    readonly property var app: tile.modelData
                    readonly property int count: tile.app.windows.length
                    readonly property bool focused: root.hasFocus(tile.app)
                    readonly property bool hovered: faceArea.hoverIndex === tile.index
                    readonly property bool urgent: tile.count > 0 && Hyprland.toplevels.values.some((t) => {
                        return t.urgent && t.wayland && t.wayland.appId && t.wayland.appId.toLowerCase() === tile.app.key;
                    })

                    width: root.namesFace ? nameText.width + root.iconSize + 26 : root.slotWidth
                    height: root.compactHeight

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        height: Math.max(0, root.compactHeight - 8)
                        radius: Theme.pill(height)
                        color: tile.focused ? Theme.alpha(Theme.accent, faceArea.pressedIndex === tile.index ? 0.26 : 0.16) : Theme.alpha(Theme.text, faceArea.pressedIndex === tile.index ? 0.14 : (tile.hovered ? 0.08 : 0))

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.durShort
                            }

                        }

                    }

                    AppIcon {
                        id: tileIcon

                        app: tile.app
                        size: root.iconSize
                        x: root.namesFace ? 9 : (parent.width - width) / 2
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: tile.count > 0 || tile.hovered ? 1 : 0.72
                    }

                    Text {
                        id: nameText

                        visible: root.namesFace
                        x: tileIcon.x + tileIcon.width + 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: root.namesFace ? Math.min(implicitWidth, Prefs.appsModuleNameWidth) : 0
                        text: tile.app.name
                        color: tile.count > 0 ? Theme.text : Theme.subtext
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontLabelLg
                        font.weight: tile.focused ? Font.DemiBold : Font.Medium
                        elide: Text.ElideRight
                    }

                    // its windows, on the side against the screen edge: a bar for the
                    // app in focus, a dot a window otherwise (up to three)
                    Row {
                        id: marks

                        readonly property int segments: Math.max(1, Math.min(3, tile.count))

                        anchors.horizontalCenter: tileIcon.horizontalCenter
                        y: root.atBottom ? parent.height - 5 : 2
                        spacing: 3
                        visible: tile.count > 0

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
        // one area over the whole face: the pill's own is off, since every click
        // here means something for the app under the pointer
        MouseArea {
            id: faceArea

            property int hoverIndex: -1
            property int pressedIndex: -1

            function indexAt(mx, my) {
                const p = mapToItem(appRow, mx, my);
                const t = appRow.childAt(p.x, appRow.height / 2);
                return t && t.index !== undefined ? t.index : -1;
            }

            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onPositionChanged: (mouse) => {
                return faceArea.hoverIndex = faceArea.indexAt(mouse.x, mouse.y);
            }
            onExited: faceArea.hoverIndex = -1
            onPressed: (mouse) => {
                return faceArea.pressedIndex = faceArea.indexAt(mouse.x, mouse.y);
            }
            onReleased: faceArea.pressedIndex = -1
            onCanceled: faceArea.pressedIndex = -1
            onClicked: (mouse) => {
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
                    model: panelColumn.app ? panelColumn.app.windows : []

                    Rectangle {
                        id: winRow

                        required property var modelData

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
