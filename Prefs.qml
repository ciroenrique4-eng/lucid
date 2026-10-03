import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property bool loaded: false


    property bool debugRegions: false

    IpcHandler {
        target: "debug"

        function toggle(): void {
            root.debugRegions = !root.debugRegions;
        }

        function on(): void {
            root.debugRegions = true;
        }

        function off(): void {
            root.debugRegions = false;
        }

    }

    readonly property bool barNotch: root.barStyle === "notch"
    readonly property bool barFull: root.barStyle === "full"
    // notches and the full bar both sit flush against the screen edge
    readonly property bool barFlush: root.barNotch || root.barFull
    // the edge the bar lives on; everything that opens off it opens away from it
    readonly property bool barBottom: root.barPosition === "bottom"
    // module backgrounds on the full bar, one behind each run of modules joined
    // in the arrangement (barGroups: "a+b" for each pair of neighbours joined);
    // on notches the same runs share one notch instead
    readonly property bool barNotchGrouping: root.barNotch && root.barNotchGroups
    readonly property bool barGrouping: (root.barFull && root.barModuleBackgrounds) || root.barNotchGrouping
    readonly property var barGroupSet: root.setOfList(root.splitList(root.barGroups))

    function setOfList(list) {
        const out = {};
        for (const k of list)
            out[k] = true;
        return out;
    }

    function barJoined(a, b) {
        return root.barGroupSet[a + "+" + b] === true || root.barGroupSet[b + "+" + a] === true;
    }

    function setBarJoined(a, b, on) {
        const keep = root.splitList(root.barGroups).filter((k) => {
            return k !== a + "+" + b && k !== b + "+" + a;
        });
        if (on)
            keep.push(a + "+" + b);

        root.barGroups = keep.join(",");
    }
    // the dock and a bottom bar would want the same edge, and its reveal strip
    // would sit on the bar: while the bar is down there the dock stays away,
    // and dockEnabled keeps what was chosen for when the bar goes back up
    readonly property bool dockShown: root.dockEnabled && !root.barBottom
    readonly property bool dockNotch: root.dockStyle === "notch"
    readonly property int barPillRadius: Math.round(Math.min(18, Math.round(root.barHeight / 2)) * root.radiusScale)
    readonly property int effectiveBarTopMargin: root.barFlush ? 0 : root.barTopMargin
    readonly property int effectiveDockBottomMargin: root.dockNotch ? 0 : root.dockBottomMargin
    // every bar module, in one place: the id barLayout arranges it by, the
    // show* pref that switches it on, the group it starts in, how Settings
    // names it, the prefs its card on the Bar page sets (options), and where
    // any settings it has elsewhere live (more, page), and, for one that leaves
    // the bar while it has nothing to show, when it is there (when). A module
    // with looks to pick names the pref that holds its bar face (style) and its
    // panel (panelStyle), and the choices, each {key, name, blurb} (styles,
    // panelStyles); BarStyleSample draws a sample of each. a new module is an
    // entry here, a pill in shell.qml and its rows in BarModuleCard
    readonly property var barModules: [{
        "id": "workspaces",
        "key": "showWorkspaces",
        "home": "left",
        "name": "Workspaces",
        "desc": "Workspace pills and the expanded overview",
        "more": "Special workspaces, which it shows as well, have a page of their own.",
        "page": "workspaces",
        "options": ["workspacesShown", "workspacesWheel"],
        "style": "workspacesStyle",
        "styles": [{
            "key": "dots",
            "name": "Dots",
            "blurb": "A dot for each, the numbers on hover"
        }, {
            "key": "numbers",
            "name": "Numbers",
            "blurb": "Each one's number, the empty ones quieter"
        }, {
            "key": "icons",
            "name": "Icons",
            "blurb": "A symbol for each window, side by side, dots for the empty ones"
        }, {
            "key": "track",
            "name": "Track",
            "blurb": "One segmented track, the accent sliding on it"
        }]
    }, {
        "id": "media",
        "key": "showMedia",
        "home": "left",
        "name": "Media",
        "desc": "Now-playing pill and player controls",
        "when": "while something plays",
        "options": ["mediaHideIdle", "mediaArtist", "mediaTitleWidth", "mediaPlayButton", "mediaWheelVolume"],
        "style": "mediaStyle",
        "styles": [{
            "key": "playing",
            "name": "Playing",
            "blurb": "Bars that move with the music, then the track"
        }, {
            "key": "cover",
            "name": "Cover",
            "blurb": "The album's cover, then the track"
        }, {
            "key": "compact",
            "name": "Compact",
            "blurb": "Only the bars and the play button"
        }],
        "panelStyle": "mediaPanelStyle",
        "panelStyles": [{
            "key": "side",
            "name": "Side by side",
            "blurb": "The cover beside the track"
        }, {
            "key": "cover",
            "name": "Large cover",
            "blurb": "The cover across the panel, the track under it"
        }]
    }, {
        "id": "tray",
        "key": "showTray",
        "home": "left",
        "name": "Tray",
        "desc": "Status icons from running applications",
        "when": "while an app has an icon in the tray",
        "options": ["trayHidden", "trayIconColor"],
        "style": "trayStyle",
        "styles": [{
            "key": "collapsed",
            "name": "Collapsed",
            "blurb": "One icon and how many are running"
        }, {
            "key": "icons",
            "name": "Icons",
            "blurb": "Each app's icon in the bar"
        }]
    }, {
        "id": "clock",
        "key": "showClock",
        "home": "center",
        "name": "Clock",
        "desc": "Time, date and the calendar panel",
        "more": "The time format, whether the date shows and the time zone are on the Date & Time page.",
        "page": "datetime",
        "options": ["clockSeconds", "clockBlink", "clockDateFormat", "clockWeather"],
        "style": "clockStyle",
        "styles": [{
            "key": "inline",
            "name": "One line",
            "blurb": "The time, then the date"
        }, {
            "key": "stacked",
            "name": "Two lines",
            "blurb": "The date small under the time"
        }, {
            "key": "accent",
            "name": "Accent",
            "blurb": "The time on a chip in the accent colour"
        }],
        "panelStyle": "clockPanelStyle",
        "panelStyles": [{
            "key": "full",
            "name": "Full",
            "blurb": "The time, the weather, what is next and the calendar"
        }, {
            "key": "calendar",
            "name": "Calendar",
            "blurb": "Only the calendar, in a narrow panel"
        }]
    }, {
        "id": "notifications",
        "key": "showNotifications",
        "home": "right",
        "name": "Notifications",
        "desc": "Toasts and the notification list",
        "when": "while a notification is waiting",
        "more": "Do not disturb is just below; popups, sounds and quiet hours are on the Notifications page.",
        "page": "notifications",
        "options": ["notificationsHideEmpty"],
        "style": "notificationsStyle",
        "styles": [{
            "key": "badge",
            "name": "Count",
            "blurb": "The bell and how many are waiting"
        }, {
            "key": "dot",
            "name": "Dot",
            "blurb": "The bell with a dot while any are waiting"
        }, {
            "key": "chip",
            "name": "Accent",
            "blurb": "Bell and count on the accent while any wait"
        }]
    }, {
        "id": "system",
        "key": "showSystem",
        "home": "right",
        "name": "System",
        "desc": "Battery, volume, brightness and quick settings",
        "more": "Its tiles and the keyboard layout sign are in System module, further down this page.",
        "page": "",
        "options": ["systemIndicators", "systemPanelAvatar"],
        "style": "systemStyle",
        "styles": [{
            "key": "values",
            "name": "Icons and values",
            "blurb": "The volume, microphone and battery read out"
        }, {
            "key": "icons",
            "name": "Icons",
            "blurb": "Only the icons, narrower"
        }],
        "panelStyle": "systemPanelStyle",
        "panelStyles": [{
            "key": "stacked",
            "name": "Stacked",
            "blurb": "One column: tiles, sliders, then the system figures"
        }, {
            "key": "wide",
            "name": "Wide",
            "blurb": "The figures, the tiles and two tall sliders side by side (on screens 820 px or wider)"
        }, {
            "key": "compact",
            "name": "Compact",
            "blurb": "Square tiles, four to a row, and the figures as chips"
        }, {
            "key": "minimal",
            "name": "Minimal",
            "blurb": "Only the square tiles and the sliders"
        }]
    }, {
        "id": "privacy",
        "key": "showPrivacy",
        "home": "right",
        "name": "Privacy",
        "desc": "Shows up only while an app uses the microphone, the camera or the screen, and says which",
        "when": "while an app uses the microphone, the camera or the screen",
        "options": ["privacyWatch", "privacyToast", "privacyAlwaysShown"],
        "style": "privacyStyle",
        "styles": [{
            "key": "marks",
            "name": "Marks",
            "blurb": "A tinted mark for each thing in use"
        }, {
            "key": "dot",
            "name": "Dot",
            "blurb": "One small dot, red while the screen is shared"
        }]
    }, {
        "id": "power",
        "key": "showPower",
        "home": "right",
        "name": "Power",
        "desc": "Lock, suspend, log out, restart or shut down, the ones you pick in the order you pick",
        "options": ["powerModuleActions", "powerModuleConfirm", "powerModuleUptime"],
        "style": "powerModuleStyle",
        "styles": [{
            "key": "icon",
            "name": "Icon",
            "blurb": "The power symbol"
        }, {
            "key": "accent",
            "name": "Accent",
            "blurb": "The symbol on a circle in the accent"
        }],
        "panelStyle": "powerModulePanelStyle",
        "panelStyles": [{
            "key": "list",
            "name": "List",
            "blurb": "One action to a row"
        }, {
            "key": "grid",
            "name": "Grid",
            "blurb": "Three to a row, the name under each"
        }]
    }, {
        "id": "window",
        "key": "showWindow",
        "home": "left",
        "name": "Active window",
        "desc": "The focused window's icon and title; open it to float, pin, fullscreen, move or close it, or switch to another window on the workspace",
        "when": "while a window on this workspace has the focus",
        "options": ["windowModuleText", "windowModuleWidth", "windowModuleScroll", "windowModuleMiddleClose"],
        "style": "windowModuleStyle",
        "styles": [{
            "key": "plain",
            "name": "Plain",
            "blurb": "The icon and the text on the bar"
        }, {
            "key": "chip",
            "name": "Chip",
            "blurb": "The same on a chip tinted with the accent"
        }]
    }, {
        "id": "apps",
        "key": "showApps",
        "home": "left",
        "name": "Apps",
        "desc": "The dock's pinned apps and every open one, an icon each: click to switch to it, middle-click for a new window, right-click for its windows and what to do with them, drag to reorder (or, dropped among the pinned, to pin)",
        "when": "while an app is pinned or open",
        "more": "The pinned apps are the dock's: pin and unpin here or there, and both change.",
        "page": "dock",
        "options": ["appsModulePinned", "appsModuleScope", "appsModuleClick", "appsModuleWheel", "appsModuleBadges", "appsModuleNameWidth", "appsModuleShowRunning", "appsModuleIndicators", "appsModuleTooltips", "appsModuleIconSize", "appsModuleSpacing", "appsModuleHoverEffect", "appsModuleMagnify", "appsModuleIconTiles"],
        "style": "appsModuleStyle",
        "styles": [{
            "key": "icons",
            "name": "Icons",
            "blurb": "Only each app's icon, marked when it has windows"
        }, {
            "key": "names",
            "name": "Names",
            "blurb": "The icon and the app's name beside it"
        }]
    }, {
        "id": "start",
        "key": "showStart",
        "home": "left",
        "first": true,
        "name": "Start",
        "desc": "A button for the launcher, at the start of the bar: a click opens it or puts it away",
        "options": [],
        "style": "startModuleStyle",
        "styles": [{
            "key": "logo",
            "name": "Logo",
            "blurb": "Lucid's mark, as on the dock"
        }, {
            "key": "grid",
            "name": "Grid",
            "blurb": "Nine dots, the middle one in the accent"
        }]
    }, {
        "id": "desktop",
        "key": "showDesktop",
        "home": "right",
        "name": "Show desktop",
        "desc": "A click sends every window on the workspace in view out of sight, and the next brings them back where they were; an app's icon in the apps module brings back just that one",
        "options": [],
        "style": "desktopModuleStyle",
        "styles": [{
            "key": "sliver",
            "name": "Sliver",
            "blurb": "A thin strip at the end of the bar"
        }, {
            "key": "icon",
            "name": "Icon",
            "blurb": "A small empty screen"
        }]
    }]
    readonly property bool anyBarModuleEnabled: root.barModules.some((m) => {
        return root[m.key] === true;
    })
    // whole-bar looks, offered at the top of the Bar page. a preset sets the
    // prefs in its values; "all" takes every one in barPresetKeys as Lucid
    // ships it. barPresetUndo keeps what the last one replaced, so it can be
    // put back
    readonly property var barPresetKeys: ["barPosition", "barStyle", "barLayout", "showWorkspaces", "showMedia", "showTray", "showClock", "showNotifications", "showSystem", "showPrivacy", "showPower", "showWindow", "showApps", "showStart", "showDesktop", "clockStyle", "appsModuleStyle", "startModuleStyle", "desktopModuleStyle", "barModuleBackgrounds", "dockEnabled"]
    readonly property var barPresets: [
        {
            "id": "lucid",
            "name": "Lucid",
            "blurb": "How Lucid ships: islands along the top, the dock below",
            "all": true
        },
        {
            "id": "centred",
            "name": "Centred taskbar",
            "blurb": "At the bottom: Start and your apps in the middle, the system on the right",
            "values": {
                "barPosition": "bottom",
                "barStyle": "full",
                "barLayout": "{\"left\":[\"workspaces\"],\"center\":[\"start\",\"apps\"],\"right\":[\"privacy\",\"tray\",\"system\",\"clock\",\"notifications\",\"desktop\"]}",
                "clockStyle": "stacked",
                "appsModuleStyle": "icons",
                "startModuleStyle": "logo",
                "desktopModuleStyle": "sliver",
                "barModuleBackgrounds": false,
                "showWorkspaces": true,
                "showMedia": false,
                "showTray": true,
                "showClock": true,
                "showNotifications": true,
                "showSystem": true,
                "showPrivacy": true,
                "showPower": false,
                "showWindow": false,
                "showApps": true,
                "showStart": true,
                "showDesktop": true
            }
        },
        {
            "id": "classic",
            "name": "Classic taskbar",
            "blurb": "At the bottom: Start on the left, apps with their names, the clock in the corner",
            "values": {
                "barPosition": "bottom",
                "barStyle": "full",
                "barLayout": "{\"left\":[\"start\",\"workspaces\",\"apps\"],\"center\":[],\"right\":[\"privacy\",\"tray\",\"media\",\"system\",\"clock\",\"notifications\",\"desktop\"]}",
                "clockStyle": "stacked",
                "appsModuleStyle": "names",
                "startModuleStyle": "grid",
                "desktopModuleStyle": "sliver",
                "barModuleBackgrounds": false,
                "showWorkspaces": true,
                "showMedia": true,
                "showTray": true,
                "showClock": true,
                "showNotifications": true,
                "showSystem": true,
                "showPrivacy": true,
                "showPower": false,
                "showWindow": false,
                "showApps": true,
                "showStart": true,
                "showDesktop": true
            }
        },
        {
            "id": "topdock",
            "name": "Top bar and dock",
            "blurb": "A full bar along the top for the system and the window in focus; the dock for apps",
            "values": {
                "barPosition": "top",
                "barStyle": "full",
                "barLayout": "{\"left\":[\"start\",\"workspaces\",\"window\"],\"center\":[\"clock\"],\"right\":[\"privacy\",\"tray\",\"media\",\"system\",\"notifications\",\"power\"]}",
                "clockStyle": "inline",
                "startModuleStyle": "logo",
                "barModuleBackgrounds": false,
                "dockEnabled": true,
                "showWorkspaces": true,
                "showMedia": true,
                "showTray": true,
                "showClock": true,
                "showNotifications": true,
                "showSystem": true,
                "showPrivacy": true,
                "showPower": true,
                "showWindow": true,
                "showApps": false,
                "showStart": true,
                "showDesktop": false
            }
        },
        {
            "id": "minimal",
            "name": "Minimal",
            "blurb": "The workspaces, the time and the system, floating at the top",
            "values": {
                "barPosition": "top",
                "barStyle": "island",
                "barLayout": "{\"left\":[\"workspaces\"],\"center\":[\"clock\"],\"right\":[\"system\"]}",
                "clockStyle": "inline",
                "barModuleBackgrounds": false,
                "showWorkspaces": true,
                "showMedia": false,
                "showTray": false,
                "showClock": true,
                "showNotifications": false,
                "showSystem": true,
                "showPrivacy": false,
                "showPower": false,
                "showWindow": false,
                "showApps": false,
                "showStart": false,
                "showDesktop": false
            }
        }
    ]

    function barPresetById(id) {
        return root.barPresets.find((p) => {
            return p.id === id;
        }) || null;
    }

    function barPresetValues(p) {
        if (!p)
            return ({});

        if (!p.all)
            return p.values;

        const out = {};
        for (const k of root.barPresetKeys)
            out[k] = root.defaults[k];
        return out;
    }

    // the bar as it stands matches the preset: every pref it sets, and the
    // arrangement compared group by group
    function barPresetActive(id) {
        const v = root.barPresetValues(root.barPresetById(id));
        for (const k in v) {
            if (k === "barLayout") {
                if (JSON.stringify(root.parseBarLayout(root.barLayout)) !== JSON.stringify(root.parseBarLayout(v[k])))
                    return false;

            } else if (root[k] !== v[k]) {
                return false;
            }
        }
        return true;
    }

    function applyBarPreset(id) {
        const p = root.barPresetById(id);
        if (!p)
            return ;

        const v = root.barPresetValues(p);
        const before = {};
        for (const k in v)
            before[k] = root[k];
        root.barPresetUndo = JSON.stringify({
            "name": p.name,
            "values": before
        });
        for (const k in v)
            root.set(k, v[k]);
    }

    function undoBarPreset() {
        let u = null;
        try {
            u = JSON.parse(root.barPresetUndo);
        } catch (e) {
        }
        root.barPresetUndo = "";
        if (!u || !u.values)
            return ;

        for (const k in u.values)
            root.set(k, u.values[k]);
    }

    readonly property var barModuleKeys: root.barModules.map((m) => {
        return m.key;
    })
    readonly property var barModuleHome: {
        const out = {};
        for (const m of root.barModules)
            out[m.id] = m.home;
        return out;
    }
    // the module the Bar page opens on, set by a right click on its pill
    property string barModuleFocus: ""
    // the ids of the modules switched on that the bar leaves out right now,
    // having nothing to show (an empty tray); the bar keeps it up to date, and
    // a module's "when" in barModules says when it comes back
    property var barModulesAway: []

    function openBarModule(id) {
        root.barModuleFocus = id;
        root.settingsRequested("bar");
    }

    readonly property var barModuleById: {
        const out = {};
        for (const m of root.barModules)
            out[m.id] = m;
        return out;
    }
    readonly property var barLayoutGroups: root.parseBarLayout(root.barLayout)
    readonly property var widgetKeys: ["widgetsEnabled", "widgetSnap", "widgetLockAll", "widgetHideFullscreen", "widgetOnTop"]
    readonly property var idleKeys: ["idleDim", "idleDimAfter", "idleDimLevel", "idleDimKeyboard", "idleLock", "idleLockAfter", "idleScreenOff", "idleScreenOffAfter", "idleSuspend", "idleSuspendAfter", "idleSuspendOnAc", "idleLockBeforeSleep", "idleWakeAfterSleep", "idleRespectInhibitors", "idleWhileMedia"]
    readonly property var envKeys: ["envCursorTheme", "envCursorSize", "envCursorShadow", "envIconTheme", "envGtkTheme", "envQtStyle", "envQtPlatformTheme", "envColorScheme", "envFontSync", "envAppFont", "envAppFontSize", "envDocumentFont", "envDocumentFontSize", "envMonoFont", "envMonoFontSize", "envApplyGtk", "envApplyQt", "envApplyHypr", "envAdopted"]
    readonly property var specialKeys: ["specialScratchpad", "specialMusic", "specialComms", "specialTodo", "specialSysmon", "specialMusicApps", "specialCommsApps", "specialTodoApps", "specialSysmonApps", "specialKeepApps", "specialHideOnSwitch", "specialDim", "specialBlur", "specialGaps"]
    readonly property var glassKeys: ["glassApps", "glassValues"]
    readonly property var monitorKeys: ["monitorSetups", "monitorShellScreen", "monitorBarScreen", "monitorDockScreen", "monitorWorkspaces"]
    readonly property var notifKeys: ["toastEnabled", "toastTimeout", "toastUseAppTimeout", "toastCriticalSticky", "toastShowBody", "toastShowActions", "toastBodyLines", "notifShowIcons", "notifMaxHistory", "doNotDisturb", "dndAllowCritical", "dndFullscreen", "quietHours", "quietFrom", "quietTo", "notifSound", "notifSoundName", "notifSoundVolume", "notifSoundUrgentOnly", "notifMutedApps", "notifGrouping", "notifTimestamps", "notifProgress", "notifInlineReply", "toastMaxVisible"]

    property alias barStyle: s.barStyle
    property alias barPosition: s.barPosition
    property alias barModuleBackgrounds: s.barModuleBackgrounds
    property alias barGroups: s.barGroups
    property alias barGroupDividers: s.barGroupDividers
    property alias barNotchGroups: s.barNotchGroups
    property alias barPresetUndo: s.barPresetUndo
    property alias dockStyle: s.dockStyle
    property alias accentPunch: s.accentPunch
    property alias surfaceDarkness: s.surfaceDarkness
    property alias radiusScale: s.radiusScale
    property alias surfaceTint: s.surfaceTint
    property alias motionScale: s.motionScale
    property alias fontFamily: s.fontFamily
    property alias fontScale: s.fontScale
    property alias wallpaperFolder: s.wallpaperFolder
    // bracket writes on the adapter are dropped, so this must go through the alias
    property alias themeOrder: s.themeOrder
    // how matugen builds a palette, from the wallpaper or from themeColour: its
    // scheme type, contrast from -1 to 1, and which of the wallpaper's dominant
    // colours to start from (the index holds for matugenSourceImage only; any
    // other wallpaper starts from its most dominant)
    property alias matugenScheme: s.matugenScheme
    property alias matugenContrast: s.matugenContrast
    property alias matugenSourceImage: s.matugenSourceImage
    property alias matugenSourceIndex: s.matugenSourceIndex
    // the one colour the "colour" theme is built from
    property alias themeColour: s.themeColour
    property string currentTheme: "matugen"
    readonly property string wallpaperDir: root.wallpaperDirFor(root.currentTheme)
    // "dark" | "light". kept in ~/.cache/current_mode beside current_theme
    // because set-wallpaper.sh and apply-theme.sh have to agree on it too
    property string colorMode: "dark"

    function setColorMode(mode) {
        if ((mode !== "dark" && mode !== "light") || mode === root.colorMode)
            return;

        // set straight away so the control answers the click; the cache file is
        // what actually confirms it, and the palette lands a moment later
        root.colorMode = mode;
        // a light shell beside dark application chrome reads as broken, so apps
        // follow. the Environment page can still be set back to auto afterwards
        root.envColorScheme = mode;
        // Env owns the theme names and knows what is installed, so the matching
        // GTK and icon variants are swapped there
        root.colorModeApplied(mode);
        Quickshell.execDetached([Quickshell.env("HOME") + "/.config/lucid/set-mode.sh", mode]);
    }

    property alias barEnabled: s.barEnabled
    property alias barPopupMode: s.barPopupMode
    property alias barPopupGap: s.barPopupGap
    property alias barHeight: s.barHeight
    property alias barTopMargin: s.barTopMargin
    property alias barSideMargin: s.barSideMargin
    property alias barSpacing: s.barSpacing
    property alias barHoverGrow: s.barHoverGrow
    property alias barLayout: s.barLayout
    property alias showWorkspaces: s.showWorkspaces
    property alias workspacesStyle: s.workspacesStyle
    property alias workspacesShown: s.workspacesShown
    property alias workspacesWheel: s.workspacesWheel
    property alias showMedia: s.showMedia
    property alias mediaStyle: s.mediaStyle
    property alias mediaPanelStyle: s.mediaPanelStyle
    property alias mediaHideIdle: s.mediaHideIdle
    property alias mediaArtist: s.mediaArtist
    property alias mediaTitleWidth: s.mediaTitleWidth
    property alias mediaPlayButton: s.mediaPlayButton
    property alias mediaWheelVolume: s.mediaWheelVolume
    property alias showTray: s.showTray
    property alias trayStyle: s.trayStyle
    property alias trayHidden: s.trayHidden
    property alias trayIconColor: s.trayIconColor
    property alias showKbLayout: s.showKbLayout
    property alias gameModeOnCmd: s.gameModeOnCmd
    property alias gameModeOffCmd: s.gameModeOffCmd
    property alias gameModeStatusCmd: s.gameModeStatusCmd

    readonly property string gameModeStateFile: {
        const m = /(?:test|\[)\s+-[ef]\s+(\S+)/.exec(root.gameModeStatusCmd || "");
        return m ? m[1].replace(/^['"]|['"]$/g, "") : "";
    }
    property alias showClock: s.showClock
    property alias showNotifications: s.showNotifications
    property alias notificationsStyle: s.notificationsStyle
    property alias notificationsHideEmpty: s.notificationsHideEmpty
    property alias showSystem: s.showSystem
    property alias systemStyle: s.systemStyle
    property alias systemPanelStyle: s.systemPanelStyle
    property alias systemPanelAvatar: s.systemPanelAvatar
    // the screens whose control centre is open on its main view: its sliders
    // already show volume and brightness there, so the OSD stays down
    property var controlCentreOpenOn: []
    readonly property bool controlCentreOpen: root.controlCentreOpenOn.length > 0

    function noteControlCentre(screen, open) {
        const rest = root.controlCentreOpenOn.filter((s) => {
            return s !== screen;
        });
        root.controlCentreOpenOn = open ? rest.concat([screen]) : rest;
    }
    property alias systemIndicators: s.systemIndicators
    property alias showPrivacy: s.showPrivacy
    property alias privacyWatch: s.privacyWatch
    property alias privacyToast: s.privacyToast
    property alias privacyAlwaysShown: s.privacyAlwaysShown
    property alias privacyStyle: s.privacyStyle
    property alias showPower: s.showPower
    property alias powerModuleActions: s.powerModuleActions
    property alias powerModuleConfirm: s.powerModuleConfirm
    property alias powerModuleUptime: s.powerModuleUptime
    property alias powerModuleStyle: s.powerModuleStyle
    property alias powerModulePanelStyle: s.powerModulePanelStyle
    property alias showWindow: s.showWindow
    property alias windowModuleText: s.windowModuleText
    property alias windowModuleWidth: s.windowModuleWidth
    property alias windowModuleScroll: s.windowModuleScroll
    property alias windowModuleMiddleClose: s.windowModuleMiddleClose
    property alias windowModuleStyle: s.windowModuleStyle
    property alias showApps: s.showApps
    property alias appsModuleStyle: s.appsModuleStyle
    property alias appsModulePinned: s.appsModulePinned
    property alias appsModuleScope: s.appsModuleScope
    property alias appsModuleClick: s.appsModuleClick
    property alias appsModuleWheel: s.appsModuleWheel
    property alias appsModuleBadges: s.appsModuleBadges
    property alias showStart: s.showStart
    property alias startModuleStyle: s.startModuleStyle
    property alias showDesktop: s.showDesktop
    property alias desktopModuleStyle: s.desktopModuleStyle
    property alias appsModuleNameWidth: s.appsModuleNameWidth
    property alias appsModuleIconSize: s.appsModuleIconSize
    property alias appsModuleSpacing: s.appsModuleSpacing
    property alias appsModuleHoverEffect: s.appsModuleHoverEffect
    property alias appsModuleMagnify: s.appsModuleMagnify
    property alias appsModuleShowRunning: s.appsModuleShowRunning
    property alias appsModuleIconTiles: s.appsModuleIconTiles
    property alias appsModuleIndicators: s.appsModuleIndicators
    property alias appsModuleTooltips: s.appsModuleTooltips
    property alias clock24h: s.clock24h
    property alias clockShowDate: s.clockShowDate
    property alias clockStyle: s.clockStyle
    property alias clockPanelStyle: s.clockPanelStyle
    property alias clockSeconds: s.clockSeconds
    property alias clockBlink: s.clockBlink
    property alias clockDateFormat: s.clockDateFormat
    property alias clockWeather: s.clockWeather
    property alias gpsEnabled: s.gpsEnabled
    property alias locationName: s.locationName
    property alias locationLabel: s.locationLabel
    property alias locationLat: s.locationLat
    property alias locationLon: s.locationLon
    property alias nightLight: s.nightLight
    property alias nightLightTemp: s.nightLightTemp
    property alias nightLightSchedule: s.nightLightSchedule
    property alias nightLightFrom: s.nightLightFrom
    property alias nightLightTo: s.nightLightTo
    property alias locationTz: s.locationTz
    property alias timeZoneAuto: s.timeZoneAuto
    property alias doNotDisturb: s.doNotDisturb
    readonly property bool osdNotch: root.osdStyle === "notch"
    // caps lock, num lock and the microphone show as a toast instead of on the osd
    readonly property bool osdTogglesToast: root.osdToggles === "toast"

    property alias osdStyle: s.osdStyle
    property alias osdNotchWidth: s.osdNotchWidth
    property alias osdNotchHeight: s.osdNotchHeight
    property alias osdToggles: s.osdToggles
    property alias toastTimeout: s.toastTimeout
    property alias toastOnLayout: s.toastOnLayout
    property alias toastOnGameMode: s.toastOnGameMode
    property alias toastOnBattery: s.toastOnBattery
    property alias toastOnBluetooth: s.toastOnBluetooth
    property alias toastOnWifi: s.toastOnWifi
    property alias toastOnAudio: s.toastOnAudio
    property alias toastOnDisplays: s.toastOnDisplays
    property alias toastOnPower: s.toastOnPower
    property alias toastOnCopy: s.toastOnCopy
    property alias toastEnabled: s.toastEnabled
    property alias toastUseAppTimeout: s.toastUseAppTimeout
    property alias toastCriticalSticky: s.toastCriticalSticky
    property alias toastShowBody: s.toastShowBody
    property alias toastShowActions: s.toastShowActions
    property alias toastBodyLines: s.toastBodyLines
    property alias notifShowIcons: s.notifShowIcons
    property alias notifMaxHistory: s.notifMaxHistory
    property alias dndAllowCritical: s.dndAllowCritical
    property alias dndFullscreen: s.dndFullscreen
    property alias quietHours: s.quietHours
    property alias quietFrom: s.quietFrom
    property alias quietTo: s.quietTo
    property alias notifSound: s.notifSound
    property alias notifSoundName: s.notifSoundName
    property alias notifSoundVolume: s.notifSoundVolume
    property alias notifSoundUrgentOnly: s.notifSoundUrgentOnly
    // comma-joined; bracket writes on the adapter are dropped, so both go through the alias
    property alias notifMutedApps: s.notifMutedApps
    property alias notifSeenApps: s.notifSeenApps
    property alias notifGrouping: s.notifGrouping
    property alias notifTimestamps: s.notifTimestamps
    property alias notifProgress: s.notifProgress
    property alias notifInlineReply: s.notifInlineReply
    property alias toastMaxVisible: s.toastMaxVisible

    property alias dockEnabled: s.dockEnabled
    property alias dockIconSize: s.dockIconSize
    property alias dockSpacing: s.dockSpacing
    property alias dockBottomMargin: s.dockBottomMargin
    property alias dockMagnify: s.dockMagnify
    property alias dockHoverEffect: s.dockHoverEffect
    property alias barMotionScale: s.barMotionScale
    property alias barNotchFlare: s.barNotchFlare
    // the concave corners the full bar hangs against the screen sides
    property alias barFullCorner: s.barFullCorner
    property alias barHoverOpen: s.barHoverOpen
    property alias barAutoHide: s.barAutoHide
    property alias dockNotchFlare: s.dockNotchFlare
    property alias dockAutoHide: s.dockAutoHide
    property alias dockShowIndicators: s.dockShowIndicators
    property alias dockShowTooltips: s.dockShowTooltips
    property alias dockShowRunning: s.dockShowRunning
    property alias dockIconTiles: s.dockIconTiles
    property alias launcherWidth: s.launcherWidth
    property alias launcherMaxRows: s.launcherMaxRows
    property alias launcherAppDescriptions: s.launcherAppDescriptions
    property alias launcherWindows: s.launcherWindows
    property alias launcherPowerChips: s.launcherPowerChips
    property alias launcherPowerButtons: s.launcherPowerButtons
    property alias launcherPowerSearch: s.launcherPowerSearch
    property alias launcherWebSearch: s.launcherWebSearch
    property alias launcherSearchUrl: s.launcherSearchUrl
    property alias launcherFavApps: s.launcherFavApps
    property alias launcherHiddenApps: s.launcherHiddenApps
    property alias clipboardEnabled: s.clipboardEnabled

    property alias widgetsEnabled: s.widgetsEnabled
    property alias widgetSnap: s.widgetSnap
    property alias widgetLockAll: s.widgetLockAll
    property alias widgetHideFullscreen: s.widgetHideFullscreen
    property alias widgetOnTop: s.widgetOnTop

    property alias btScanOnOpen: s.btScanOnOpen
    property alias btShowUnnamed: s.btShowUnnamed
    property alias btReceive: s.btReceive
    property alias btReceiveFolder: s.btReceiveFolder
    property alias btReceiveAutoPaired: s.btReceiveAutoPaired
    property alias audioMoveStreams: s.audioMoveStreams
    property alias soundVolumeFeedback: s.soundVolumeFeedback
    property alias soundVolumeStyle: s.soundVolumeStyle
    property alias soundBrightness: s.soundBrightness
    property alias soundBrightnessStyle: s.soundBrightnessStyle
    property alias soundPlug: s.soundPlug
    property alias soundPlugStyle: s.soundPlugStyle
    property alias soundLock: s.soundLock
    property alias soundLockStyle: s.soundLockStyle
    property alias soundTrash: s.soundTrash
    property alias soundTrashStyle: s.soundTrashStyle
    property alias soundCapture: s.soundCapture
    property alias soundCaptureStyle: s.soundCaptureStyle
    property alias soundCustomVolume: s.soundCustomVolume
    property alias soundCustomBrightness: s.soundCustomBrightness
    property alias soundCustomPlugIn: s.soundCustomPlugIn
    property alias soundCustomPlugOut: s.soundCustomPlugOut
    property alias soundCustomLock: s.soundCustomLock
    property alias soundCustomUnlock: s.soundCustomUnlock
    property alias soundCustomTrash: s.soundCustomTrash
    property alias soundCustomCapture: s.soundCustomCapture
    property alias soundFeedbackVolume: s.soundFeedbackVolume
    property alias kdeConnectEnabled: s.kdeConnectEnabled
    property alias updateCheck: s.updateCheck

    property alias specialScratchpad: s.specialScratchpad
    property alias specialMusic: s.specialMusic
    property alias specialComms: s.specialComms
    property alias specialTodo: s.specialTodo
    property alias specialSysmon: s.specialSysmon
    // comma-joined app ids, or "auto" for the first one installed
    property alias specialMusicApps: s.specialMusicApps
    property alias specialCommsApps: s.specialCommsApps
    property alias specialTodoApps: s.specialTodoApps
    property alias specialSysmonApps: s.specialSysmonApps
    property alias specialKeepApps: s.specialKeepApps
    property alias specialHideOnSwitch: s.specialHideOnSwitch
    property alias specialDim: s.specialDim
    property alias specialBlur: s.specialBlur
    property alias specialGaps: s.specialGaps
    // the workspaces you made, a JSON list of { key, label, glyph, on, apps }
    property alias specialCustom: s.specialCustom
    // Hyprland options set from Settings > Windows, as JSON { "general.gaps_in": 8, ... }
    property alias hyprOptions: s.hyprOptions
    property alias pinBorder: s.pinBorder
    property alias pinBadge: s.pinBadge
    property alias pinPulse: s.pinPulse
    property alias urgentBadge: s.urgentBadge
    property alias urgentPulse: s.urgentPulse

    property alias glassApps: s.glassApps
    property alias glassValues: s.glassValues

    // per-output display config, JSON keyed by hyprland monitor selector
    property alias monitorSetups: s.monitorSetups
    property alias monitorShellScreen: s.monitorShellScreen
    // empty means the bar or dock goes wherever the shell went
    property alias monitorBarScreen: s.monitorBarScreen
    property alias monitorDockScreen: s.monitorDockScreen
    property alias monitorWorkspaces: s.monitorWorkspaces

    property alias idleEnabled: s.idleEnabled
    property alias idleAutostart: s.idleAutostart
    property alias idleKeepAwake: s.idleKeepAwake
    // one-shot: the hand-written hypridle.conf is read into these keys once
    property alias idleAdopted: s.idleAdopted
    property alias idleDim: s.idleDim
    property alias idleDimAfter: s.idleDimAfter
    property alias idleDimLevel: s.idleDimLevel
    property alias idleDimKeyboard: s.idleDimKeyboard
    property alias idleLock: s.idleLock
    property alias idleLockAfter: s.idleLockAfter
    property alias idleScreenOff: s.idleScreenOff
    property alias idleScreenOffAfter: s.idleScreenOffAfter
    property alias idleSuspend: s.idleSuspend
    property alias idleSuspendAfter: s.idleSuspendAfter
    property alias idleSuspendOnAc: s.idleSuspendOnAc
    property alias idleLockBeforeSleep: s.idleLockBeforeSleep
    property alias idleWakeAfterSleep: s.idleWakeAfterSleep
    property alias idleRespectInhibitors: s.idleRespectInhibitors
    property alias idleWhileMedia: s.idleWhileMedia

    property alias desktopSelection: s.desktopSelection
    property alias desktopMenu: s.desktopMenu
    property alias desktopIcons: s.desktopIcons
    property alias desktopIconSize: s.desktopIconSize
    property alias desktopIconsCorner: s.desktopIconsCorner
    property alias desktopIconsSort: s.desktopIconsSort
    property alias desktopIconsOpen: s.desktopIconsOpen
    property alias desktopIconsThumbs: s.desktopIconsThumbs
    property alias desktopIconsHidden: s.desktopIconsHidden
    property alias desktopIconsHome: s.desktopIconsHome
    property alias desktopIconsTrash: s.desktopIconsTrash
    property alias desktopIconStyle: s.desktopIconStyle
    property alias desktopIconTint: s.desktopIconTint
    property alias desktopIconsShown: s.desktopIconsShown
    property alias desktopIconShape: s.desktopIconShape
    property alias desktopIconNames: s.desktopIconNames
    property alias shotPreview: s.shotPreview
    property alias shotPreviewSeconds: s.shotPreviewSeconds

    // one-shot: the machine's own gtk/qt/cursor settings are read in once
    property alias envAdopted: s.envAdopted
    property alias envCursorTheme: s.envCursorTheme
    property alias envCursorSize: s.envCursorSize
    property alias envCursorShadow: s.envCursorShadow
    property alias envIconTheme: s.envIconTheme
    property alias envGtkTheme: s.envGtkTheme
    property alias envQtStyle: s.envQtStyle
    property alias envQtPlatformTheme: s.envQtPlatformTheme
    property alias envColorScheme: s.envColorScheme
    property alias envFontSync: s.envFontSync
    property alias envAppFont: s.envAppFont
    property alias envAppFontSize: s.envAppFontSize
    property alias envDocumentFont: s.envDocumentFont
    property alias envDocumentFontSize: s.envDocumentFontSize
    property alias envMonoFont: s.envMonoFont
    property alias envMonoFontSize: s.envMonoFontSize
    property alias envApplyGtk: s.envApplyGtk
    property alias envApplyQt: s.envApplyQt
    property alias envApplyHypr: s.envApplyHypr

    readonly property var builtinThemes: [
        { "id": "matugen", "name": "Matugen", "desc": "Colors generated from your wallpaper", "swatchBg": "#12171a", "swatchAccent": "#8ad0ee" },
        { "id": "pywal", "name": "Pywal", "desc": "Wallpaper colors via pywal's classic palette", "swatchBg": "#1a1e24", "swatchAccent": "#c9a1a9" },
        { "id": "catppuccin-mocha", "name": "Catppuccin Mocha", "desc": "Soothing pastel dark theme", "swatchBg": "#1e1e2e", "swatchAccent": "#89b4fa" },
        { "id": "gruvbox", "name": "Gruvbox", "desc": "Retro groove warm palette", "swatchBg": "#282828", "swatchAccent": "#83a598" },
        { "id": "nightfox", "name": "Nightfox", "desc": "Deep navy with muted blue accents", "swatchBg": "#192330", "swatchAccent": "#719cd6" },
        { "id": "nord", "name": "Nord", "desc": "Arctic blue-grey palette", "swatchBg": "#232831", "swatchAccent": "#88c0d0" },
        { "id": "tokyo-night", "name": "Tokyo Night", "desc": "Dark blues and violets", "swatchBg": "#1a1b26", "swatchAccent": "#7aa2f7" },
        { "id": "colour", "name": "Your colour", "desc": "A palette built from one colour you pick", "swatchBg": "#14121a", "swatchAccent": root.themeColour }
    ]
    // themes imported from a scheme repo, read back from their meta.json
    property var userThemes: []
    // the order the user dragged them into; anything it does not name keeps its
    // natural place at the end, so a freshly imported theme still shows up
    readonly property var themeCatalogue: {
        var all = root.builtinThemes.concat(root.userThemes);
        var order = root.themeOrder.split(",").filter((x) => {
            return x !== "";
        });
        if (order.length === 0)
            return all;

        var left = {};
        for (var i = 0; i < all.length; i++) left[all[i].id] = all[i];
        var out = [];
        for (var j = 0; j < order.length; j++) {
            if (left[order[j]]) {
                out.push(left[order[j]]);
                delete left[order[j]];
            }
        }
        for (var k = 0; k < all.length; k++) {
            if (left[all[k].id])
                out.push(all[k]);

        }
        return out;
    }

    function setThemeOrder(ids) {
        root.themeOrder = ids.join(",");
    }

    readonly property var defaults: ({
        "barStyle": "island",
        "barPosition": "top",
        "barModuleBackgrounds": false,
        "barGroups": "",
        "barGroupDividers": true,
        "barNotchGroups": false,
        "dockStyle": "island",
        "accentPunch": 1,
        "surfaceDarkness": -1,
        "radiusScale": 1,
        "surfaceTint": -1,
        "motionScale": 1,
        "fontFamily": "Google Sans",
        "fontScale": 1,
        "wallpaperFolder": "",
        "themeOrder": "",
        "matugenScheme": "scheme-tonal-spot",
        "matugenContrast": 0,
        "matugenSourceImage": "",
        "matugenSourceIndex": 0,
        "themeColour": "#6750a4",
        "barEnabled": true,
        "barPopupMode": false,
        "barPopupGap": 10,
        "barHeight": 35,
        "barTopMargin": 22,
        "barSideMargin": 17,
        "barSpacing": 8,
        "barHoverGrow": 3,
        "barLayout": "{\"left\":[\"workspaces\",\"media\",\"tray\"],\"center\":[\"clock\"],\"right\":[\"notifications\",\"system\"]}",
        "showWorkspaces": true,
        "workspacesStyle": "dots",
        "workspacesShown": 6,
        "workspacesWheel": true,
        "showMedia": true,
        "mediaStyle": "playing",
        "mediaPanelStyle": "side",
        "mediaHideIdle": false,
        "mediaArtist": true,
        "mediaTitleWidth": 160,
        "mediaPlayButton": true,
        "mediaWheelVolume": true,
        "showTray": true,
        "trayStyle": "collapsed",
        "trayHidden": "",
        "trayIconColor": "original",
        "showKbLayout": true,
        "gameModeOnCmd": "",
        "gameModeOffCmd": "",
        "gameModeStatusCmd": "",
        "showClock": true,
        "showNotifications": true,
        "notificationsStyle": "badge",
        "notificationsHideEmpty": false,
        "showSystem": true,
        "systemStyle": "values",
        "systemPanelStyle": "stacked",
        "systemPanelAvatar": true,
        "systemIndicators": "wifi,bluetooth,volume,mic,battery",
        "showPrivacy": false,
        "privacyWatch": "mic,camera,screen",
        "privacyToast": true,
        "privacyAlwaysShown": false,
        "privacyStyle": "marks",
        "showPower": false,
        "powerModuleActions": "lock,suspend,hibernate,logout,reboot,shutdown",
        "powerModuleConfirm": true,
        "powerModuleUptime": true,
        "powerModuleStyle": "icon",
        "powerModulePanelStyle": "list",
        "showWindow": false,
        "windowModuleText": "title",
        "windowModuleWidth": 260,
        "windowModuleScroll": true,
        "windowModuleMiddleClose": false,
        "windowModuleStyle": "plain",
        "showApps": false,
        "appsModuleStyle": "icons",
        "appsModulePinned": true,
        "appsModuleScope": "all",
        "appsModuleClick": "list",
        "appsModuleWheel": true,
        "appsModuleBadges": true,
        "showStart": false,
        "startModuleStyle": "logo",
        "showDesktop": false,
        "desktopModuleStyle": "sliver",
        "appsModuleNameWidth": 120,
        "appsModuleIconSize": 24,
        "appsModuleSpacing": 2,
        "appsModuleHoverEffect": 1,
        "appsModuleMagnify": false,
        "appsModuleShowRunning": true,
        "appsModuleIconTiles": false,
        "appsModuleIndicators": true,
        "appsModuleTooltips": true,
        "clock24h": false,
        "clockShowDate": true,
        "clockStyle": "inline",
        "clockPanelStyle": "full",
        "clockSeconds": false,
        "clockBlink": true,
        "clockDateFormat": "short",
        "clockWeather": false,
        "gpsEnabled": false,
        "locationName": "",
        "locationLabel": "",
        "locationLat": 52.4083,
        "locationLon": 16.9336,
        "nightLight": false,
        "nightLightTemp": 4000,
        "nightLightSchedule": "off",
        "nightLightFrom": 1260,
        "nightLightTo": 420,
        "locationTz": "",
        "timeZoneAuto": true,
        "doNotDisturb": false,
        "osdStyle": "island",
        "osdNotchWidth": 354,
        "osdNotchHeight": 76,
        "osdToggles": "osd",
        "toastTimeout": 5,
        "toastOnLayout": true,
        "toastOnGameMode": true,
        "toastOnBattery": true,
        "toastOnBluetooth": true,
        "toastOnWifi": true,
        "toastOnAudio": true,
        "toastOnDisplays": true,
        "toastOnPower": true,
        "toastOnCopy": true,
        "toastEnabled": true,
        "toastUseAppTimeout": true,
        "toastCriticalSticky": true,
        "toastShowBody": true,
        "toastShowActions": true,
        "toastBodyLines": 4,
        "notifShowIcons": true,
        "notifMaxHistory": 50,
        "dndAllowCritical": true,
        "dndFullscreen": false,
        "quietHours": false,
        "quietFrom": 1320,
        "quietTo": 420,
        "notifSound": false,
        "notifSoundName": "message",
        "notifSoundVolume": 0.6,
        "notifSoundUrgentOnly": false,
        "notifMutedApps": "",
        "notifSeenApps": "",
        "notifGrouping": true,
        "notifTimestamps": true,
        "notifProgress": true,
        "notifInlineReply": true,
        "toastMaxVisible": 3,
        "dockEnabled": true,
        "dockIconSize": 41,
        "dockSpacing": 10,
        "dockBottomMargin": 20,
        "dockMagnify": true,
        "dockHoverEffect": 1,
        "barMotionScale": 1.35,
        "barNotchFlare": 14,
        "barFullCorner": 18,
        "barHoverOpen": false,
        "barAutoHide": false,
        "dockNotchFlare": 14,
        "dockAutoHide": false,
        "dockShowIndicators": true,
        "dockShowTooltips": true,
        "dockShowRunning": true,
        "dockIconTiles": false,
        "launcherWidth": 560,
        "launcherMaxRows": 8,
        "launcherAppDescriptions": true,
        "launcherWindows": true,
        "launcherPowerChips": true,
        "launcherPowerButtons": "lock,suspend,reboot,shutdown",
        "launcherPowerSearch": true,
        "launcherWebSearch": true,
        "launcherSearchUrl": "https://duckduckgo.com/?q=%s",
        "launcherFavApps": "",
        "launcherHiddenApps": "",
        "clipboardEnabled": true,
        "widgetsEnabled": true,
        "widgetSnap": true,
        "widgetLockAll": false,
        "widgetHideFullscreen": true,
        "widgetOnTop": false,
        "btScanOnOpen": true,
        "btShowUnnamed": false,
        "btReceive": true,
        "btReceiveFolder": "",
        "btReceiveAutoPaired": false,
        "audioMoveStreams": true,
        "soundVolumeFeedback": false,
        "soundVolumeStyle": "snap",
        "soundBrightness": false,
        "soundBrightnessStyle": "high",
        "soundPlug": false,
        "soundPlugStyle": "pips",
        "soundLock": false,
        "soundLockStyle": "latch",
        "soundTrash": false,
        "soundTrashStyle": "crunch",
        "soundCapture": false,
        "soundCaptureStyle": "pop",
        "soundCustomVolume": "",
        "soundCustomBrightness": "",
        "soundCustomPlugIn": "",
        "soundCustomPlugOut": "",
        "soundCustomLock": "",
        "soundCustomUnlock": "",
        "soundCustomTrash": "",
        "soundCustomCapture": "",
        "soundFeedbackVolume": 1.0,
        "kdeConnectEnabled": true,
        "updateCheck": true,
        "idleEnabled": false,
        "idleAutostart": true,
        "idleKeepAwake": false,
        "idleAdopted": false,
        "idleDim": true,
        "idleDimAfter": 120,
        "idleDimLevel": 10,
        "idleDimKeyboard": true,
        "idleLock": true,
        "idleLockAfter": 600,
        "idleScreenOff": true,
        "idleScreenOffAfter": 900,
        "idleSuspend": false,
        "idleSuspendAfter": 1800,
        "idleSuspendOnAc": false,
        "idleLockBeforeSleep": true,
        "idleWakeAfterSleep": true,
        "idleRespectInhibitors": true,
        "idleWhileMedia": true,
        "desktopSelection": true,
        "desktopMenu": true,
        "desktopIcons": false,
        "desktopIconSize": "medium",
        "desktopIconsCorner": "left",
        "desktopIconsSort": "name",
        "desktopIconsOpen": "double",
        "desktopIconsThumbs": true,
        "desktopIconsHidden": false,
        "desktopIconsHome": false,
        "desktopIconsTrash": false,
        "desktopIconStyle": "objects",
        "desktopIconTint": "folders",
        "desktopIconsShown": true,
        "desktopIconShape": "square",
        "desktopIconNames": "always",
        "shotPreview": "preview",
        "shotPreviewSeconds": 6,
        "envAdopted": false,
        "envCursorTheme": "",
        "envCursorSize": 24,
        "envCursorShadow": true,
        "envIconTheme": "",
        "envGtkTheme": "",
        "envQtStyle": "Fusion",
        "envQtPlatformTheme": "",
        "envColorScheme": "auto",
        "envFontSync": false,
        "envAppFont": "",
        "envAppFontSize": 11,
        "envDocumentFont": "",
        "envDocumentFontSize": 11,
        "envMonoFont": "",
        "envMonoFontSize": 10,
        "envApplyGtk": true,
        "envApplyQt": true,
        "envApplyHypr": true,
        "specialScratchpad": true,
        "specialMusic": true,
        "specialComms": true,
        "specialTodo": true,
        "specialSysmon": true,
        "specialMusicApps": "auto",
        "specialCommsApps": "auto",
        "specialTodoApps": "auto",
        "specialSysmonApps": "auto",
        "specialKeepApps": true,
        "specialHideOnSwitch": false,
        "specialDim": 0.2,
        "specialBlur": false,
        "specialGaps": 0,
        "specialCustom": "[]",
        "hyprOptions": "{}",
        "pinBorder": "tertiary",
        "pinBadge": "top-right",
        "pinPulse": true,
        "urgentBadge": "top-left",
        "urgentPulse": true,
        "glassApps": "vscodium",
        "glassValues": "vscodium=0.9",
        "monitorSetups": "{}",
        "monitorShellScreen": "",
        "monitorBarScreen": "",
        "monitorDockScreen": "",
        "monitorWorkspaces": "{}"
    })

    // what the bar module is holding right now, so the settings page can offer
    // to clear it; not persisted
    property int liveNotifCount: 0

    signal notificationsClearRequested()

    signal pinnedResetRequested()
    signal settingsRequested(string page)
    signal resetConfirmRequested(string title, string body, string confirmLabel, string action)
    signal wallpaperDeleteRequested(string path)
    signal desktopActionRequested(string action)
    signal wallpapersChanged()

    readonly property string resetAllToken: "__all__"
    readonly property string resetDockToken: "__dock__"
    readonly property string resetBlurToken: "__blur__"
    readonly property string clearWidgetsToken: "__widgets__"
    readonly property string clearClipboardToken: "__clipboard__"
    readonly property string resetIdleToken: "__idle__"
    readonly property string resetEnvToken: "__env__"
    readonly property string resetSpecialsToken: "__specials__"
    readonly property string resetGlassToken: "__glass__"
    readonly property string resetMonitorsToken: "__monitors__"

    signal themeChangeRequested(string id)

    // a deliberate light/dark flip, as opposed to the cache file merely loading
    signal colorModeApplied(string mode)

    signal themeDeleteRequested(string id)

    signal fontPickerRequested()

    // "cursor" | "icon" | "gtk" | "qtStyle" | "appFont" | "docFont" | "monoFont"
    signal envPickerRequested(string kind)

    signal timeZonePickerRequested()

    signal keyboardRequested()

    // which special workspace the app being picked is going into
    signal appPickerRequested(string workspace)

    onAnyBarModuleEnabledChanged: {
        if (!root.anyBarModuleEnabled && root.barEnabled)
            root.barEnabled = false;

    }

    // barLayout is JSON: {"left": [...], "center": [...], "right": [...]}, each
    // list in order from the screen's left edge. a module it leaves out (a hand
    // edit, a module added later) goes back to the end of its home group and an
    // unknown or repeated id is skipped, so every module always has a place
    function parseBarLayout(text) {
        let parsed = null;
        try {
            parsed = JSON.parse(text);
        } catch (e) {
        }
        const out = {
            "left": [],
            "center": [],
            "right": []
        };
        const seen = {};
        for (const side of ["left", "center", "right"]) {
            const ids = parsed && Array.isArray(parsed[side]) ? parsed[side] : [];
            for (const id of ids) {
                if (root.barModuleHome[id] === undefined || seen[id])
                    continue;

                seen[id] = true;
                out[side].push(id);
            }
        }
        // one new to the arrangement goes to its home group: at the end, or at
        // the start for one that belongs there (the start button)
        for (const m of root.barModules) {
            if (seen[m.id])
                continue;

            if (m.first)
                out[m.home].unshift(m.id);
            else
                out[m.home].push(m.id);
        }
        return out;
    }

    function setBarLayout(groups) {
        root.barLayout = JSON.stringify({
            "left": groups.left,
            "center": groups.center,
            "right": groups.right
        });
    }

    // on means the modules that ship switched on; one that ships off stays off
    function setAllBarModules(v) {
        for (const m of root.barModules)
            root[m.key] = v && root.defaults[m.key] === true;
    }

    function setSurface(key, v) {
        if (key === "barEnabled") {
            if (v && !root.anyBarModuleEnabled)
                root.setAllBarModules(true);

            root.barEnabled = v;
        } else if (key === "dockEnabled") {
            root.dockEnabled = v;
        } else if (key === "widgetsEnabled") {
            root.widgetsEnabled = v;
        } else if (key === "kdeConnectEnabled") {
            root.kdeConnectEnabled = v;
        } else if (key === "showNotifications") {
            root.showNotifications = v;
        } else if (key === "idleEnabled") {
            root.idleEnabled = v;
        }
    }

    function askReset(title, body, action) {
        root.resetConfirmRequested(title, body, "Reset", action);
    }

    // same dialog, different verb
    function askConfirm(title, body, confirmLabel, action) {
        root.resetConfirmRequested(title, body, confirmLabel, action);
    }

    function isModified(key) {
        return root.defaults[key] !== undefined && root[key] !== root.defaults[key];
    }

    function resetAll() {
        for (var k in root.defaults) root.set(k, root.defaults[k])
    }

    function resetKeys(keys) {
        for (var i = 0; i < keys.length; i++) root.set(keys[i], root.defaults[keys[i]])
    }

    // a custom folder overrides every theme's own
    function wallpaperDirFor(themeId) {
        return root.wallpaperFolder !== "" ? root.wallpaperFolder : (Quickshell.env("HOME") + "/Pictures/wallpapers/" + themeId);
    }

    // must write through the alias — a bracket write on the adapter is dropped
    function set(key, value) {
        if (root.defaults[key] !== undefined && root[key] !== value)
            root[key] = value;
    }

    // quiet hours, evaluated against a clock the caller owns so Prefs need not
    // depend on Loc, which already depends on Prefs
    function inQuietWindow(d) {
        if (!root.quietHours)
            return false;

        if (root.quietFrom === root.quietTo)
            return false;

        var m = d.getHours() * 60 + d.getMinutes();
        return root.quietFrom < root.quietTo ? (m >= root.quietFrom && m < root.quietTo) : (m >= root.quietFrom || m < root.quietTo);
    }

    function minutesText(m) {
        return String(Math.floor(m / 60)).padStart(2, "0") + ":" + String(m % 60).padStart(2, "0");
    }

    // "22:00", "22.00", "2200" and "9" all land somewhere sensible
    function parseMinutes(t) {
        var m = String(t).trim().match(/^(\d{1,2})\s*[:.h]?\s*(\d{2})?$/);
        if (!m)
            return -1;

        var h = parseInt(m[1], 10);
        var mi = m[2] === undefined ? 0 : parseInt(m[2], 10);
        if (h > 23 || mi > 59)
            return -1;

        return h * 60 + mi;
    }

    // the freedesktop set spreads ~17 dB between its own files, so each carries a
    // trim that lands its peak in roughly the same place. click is the volume
    // feedback's own, shipped with the shell rather than the sound theme
    readonly property var notifSounds: [
        { "key": "message", "label": "Message", "gain": 1.24 },
        { "key": "bell", "label": "Bell", "gain": 2.11 },
        { "key": "complete", "label": "Chime", "gain": 0.9 },
        { "key": "suspend-error", "label": "Alert", "gain": 0.71 },
        { "key": "click", "label": "Click", "gain": 1.15, "file": Qt.resolvedUrl("assets/volume-click.wav").toString().replace("file://", "") }
    ]

    function notifSoundEntry(name) {
        for (var i = 0; i < root.notifSounds.length; i++) {
            if (root.notifSounds[i].key === name)
                return root.notifSounds[i];

        }
        return root.notifSounds[0];
    }

    readonly property string notifSoundPath: {
        var e = root.notifSoundEntry(root.notifSoundName);
        return e.file || "/usr/share/sounds/freedesktop/stereo/" + e.key + ".oga";
    }
    // paplay's --volume rides PulseAudio's cubic scale, so a bare 0.6 is a 13 dB
    // cut rather than six tenths of the loudness; cube-root it back
    readonly property int notifSoundPaVolume: {
        var g = Math.max(0, Math.min(2.5, root.notifSoundVolume * root.notifSoundEntry(root.notifSoundName).gain));
        return Math.round(65536 * Math.cbrt(g));
    }

    function splitList(v) {
        return v.split(",").filter((x) => {
            return x !== "";
        });
    }

    // which power buttons sit beside the launcher's search field, by runPowerAction id
    readonly property var powerButtonList: root.splitList(root.launcherPowerButtons)

    function setPowerButton(id, on) {
        var list = root.powerButtonList.filter((x) => {
            return x !== id;
        });
        if (on)
            list.push(id);

        root.launcherPowerButtons = list.join(",");
    }

    readonly property var mutedApps: root.splitList(root.notifMutedApps)
    // every app that has sent a notification since the list was last cleared, so
    // the settings page can offer them instead of asking you to type a name
    readonly property var seenApps: root.splitList(root.notifSeenApps)

    function isMuted(app) {
        return app !== "" && root.mutedApps.indexOf(app) !== -1;
    }

    function setMuted(app, on) {
        if (app === "")
            return ;

        var list = root.mutedApps.filter((x) => {
            return x !== app;
        });
        if (on)
            list.push(app);

        root.notifMutedApps = list.join(",");
    }

    function noteApp(app) {
        var name = String(app).replace(/,/g, " ").trim();
        if (name === "" || root.seenApps.indexOf(name) !== -1)
            return ;

        var list = root.seenApps.concat([name]).sort((a, b) => {
            return a.toLowerCase().localeCompare(b.toLowerCase());
        });
        root.notifSeenApps = list.slice(0, 60).join(",");
    }

    // imported themes live beside the shipped ones, so the catalogue is the
    // built-in list plus whatever meta.json files are on disk
    Process {
        id: userThemeScan

        command: ["python3", "-c", "import json,glob,os;print(json.dumps([json.load(open(f)) for f in sorted(glob.glob(os.path.expanduser('~/.config/lucid/themes/*/meta.json')))]))"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.userThemes = JSON.parse(text.trim() || "[]");
                } catch (e) {
                    root.userThemes = [];
                }
            }
        }

    }

    function rescanThemes() {
        userThemeScan.running = false;
        userThemeScan.running = true;
    }

    Component.onCompleted: root.rescanThemes()

    FileView {
        path: Quickshell.env("HOME") + "/.cache/current_theme"
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.currentTheme = text().trim() || "matugen"
    }

    FileView {
        path: Quickshell.env("HOME") + "/.cache/current_mode"
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.colorMode = text().trim() === "light" ? "light" : "dark"
    }

    Timer {
        id: writeDebounce

        interval: 120
        repeat: false
        onTriggered: prefsFile.writeAdapter()
    }

    FileView {
        id: prefsFile

        path: Quickshell.env("HOME") + "/.config/quickshell/lucidprefs/prefs.json"
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeDebounce.restart()
        onLoaded: root.loaded = true
        onLoadFailed: root.loaded = true

        adapter: JsonAdapter {
            id: s

            property string barStyle: "island"
            property string barPosition: "top"
            property bool barModuleBackgrounds: false
            property string barGroups: ""
            property bool barGroupDividers: true
            property bool barNotchGroups: false
            property string barPresetUndo: ""
            property string dockStyle: "island"
            property real accentPunch: 1
            property real surfaceDarkness: -1
            property real radiusScale: 1
            property real surfaceTint: -1
            property real motionScale: 1
            property string fontFamily: "Google Sans"
            property real fontScale: 1
            property string wallpaperFolder: ""
            property string themeOrder: ""
            property string matugenScheme: "scheme-tonal-spot"
            property real matugenContrast: 0
            property string matugenSourceImage: ""
            property int matugenSourceIndex: 0
            property string themeColour: "#6750a4"
            property bool barEnabled: true
            property bool barPopupMode: false
            property int barPopupGap: 10
            property int barHeight: 35
            property int barTopMargin: 22
            property int barSideMargin: 17
            property int barSpacing: 8
            property int barHoverGrow: 3
            property string barLayout: "{\"left\":[\"workspaces\",\"media\",\"tray\"],\"center\":[\"clock\"],\"right\":[\"notifications\",\"system\"]}"
            property bool showWorkspaces: true
            property string workspacesStyle: "dots"
            property int workspacesShown: 6
            property bool workspacesWheel: true
            property bool showMedia: true
            property string mediaStyle: "playing"
            property string mediaPanelStyle: "side"
            property bool mediaHideIdle: false
            property bool mediaArtist: true
            property int mediaTitleWidth: 160
            property bool mediaPlayButton: true
            property bool mediaWheelVolume: true
            property bool showTray: true
            property string trayStyle: "collapsed"
            property string trayHidden: ""
            property string trayIconColor: "original"
            property bool showKbLayout: true
            property string gameModeOnCmd: ""
            property string gameModeOffCmd: ""
            property string gameModeStatusCmd: ""
            property bool showClock: true
            property bool showNotifications: true
            property string notificationsStyle: "badge"
            property bool notificationsHideEmpty: false
            property bool showSystem: true
            property string systemStyle: "values"
            property string systemPanelStyle: "stacked"
            property bool systemPanelAvatar: true
            property string systemIndicators: "wifi,bluetooth,volume,mic,battery"
            property bool showPrivacy: false
            property string privacyWatch: "mic,camera,screen"
            property bool privacyToast: true
            property bool privacyAlwaysShown: false
            property string privacyStyle: "marks"
            property bool showPower: false
            property string powerModuleActions: "lock,suspend,hibernate,logout,reboot,shutdown"
            property bool powerModuleConfirm: true
            property bool powerModuleUptime: true
            property string powerModuleStyle: "icon"
            property string powerModulePanelStyle: "list"
            property bool showWindow: false
            property string windowModuleText: "title"
            property int windowModuleWidth: 260
            property bool windowModuleScroll: true
            property bool windowModuleMiddleClose: false
            property string windowModuleStyle: "plain"
            property bool showApps: false
            property string appsModuleStyle: "icons"
            property bool appsModulePinned: true
            property string appsModuleScope: "all"
            property string appsModuleClick: "list"
            property bool appsModuleWheel: true
            property bool appsModuleBadges: true
            property bool showStart: false
            property string startModuleStyle: "logo"
            property bool showDesktop: false
            property string desktopModuleStyle: "sliver"
            property int appsModuleNameWidth: 120
            property int appsModuleIconSize: 24
            property int appsModuleSpacing: 2
            property real appsModuleHoverEffect: 1
            property bool appsModuleMagnify: false
            property bool appsModuleShowRunning: true
            property bool appsModuleIconTiles: false
            property bool appsModuleIndicators: true
            property bool appsModuleTooltips: true
            property bool clock24h: false
            property bool clockShowDate: true
            property string clockStyle: "inline"
            property string clockPanelStyle: "full"
            property bool clockSeconds: false
            property bool clockBlink: true
            property string clockDateFormat: "short"
            property bool clockWeather: false
            property bool gpsEnabled: false
            property string locationName: ""
            property string locationLabel: ""
            property real locationLat: 52.4083
            property real locationLon: 16.9336
            property bool nightLight: false
            property int nightLightTemp: 4000
            property string nightLightSchedule: "off"
            property int nightLightFrom: 1260
            property int nightLightTo: 420
            property string locationTz: ""
            property bool timeZoneAuto: true
            property bool doNotDisturb: false
            property string osdStyle: "island"
            property int osdNotchWidth: 354
            property int osdNotchHeight: 76
            property string osdToggles: "osd"
            property int toastTimeout: 5
            property bool toastOnLayout: true
            property bool toastOnGameMode: true
            property bool toastOnBattery: true
            property bool toastOnBluetooth: true
            property bool toastOnWifi: true
            property bool toastOnAudio: true
            property bool toastOnDisplays: true
            property bool toastOnPower: true
            property bool toastOnCopy: true
            property bool toastEnabled: true
            property bool toastUseAppTimeout: true
            property bool toastCriticalSticky: true
            property bool toastShowBody: true
            property bool toastShowActions: true
            property int toastBodyLines: 4
            property bool notifShowIcons: true
            property int notifMaxHistory: 50
            property bool dndAllowCritical: true
            property bool dndFullscreen: false
            property bool quietHours: false
            property int quietFrom: 1320
            property int quietTo: 420
            property bool notifSound: false
            property string notifSoundName: "message"
            property real notifSoundVolume: 0.6
            property bool notifSoundUrgentOnly: false
            property string notifMutedApps: ""
            property string notifSeenApps: ""
            property bool notifGrouping: true
            property bool notifTimestamps: true
            property bool notifProgress: true
            property bool notifInlineReply: true
            property int toastMaxVisible: 3
            property bool dockEnabled: true
            property int dockIconSize: 41
            property int dockSpacing: 10
            property int dockBottomMargin: 20
            property bool dockMagnify: true
            property real dockHoverEffect: 1
            property real barMotionScale: 1.35
            property int barNotchFlare: 14
            property int barFullCorner: 18
            property bool barHoverOpen: false
            property bool barAutoHide: false
            property int dockNotchFlare: 14
            property bool dockAutoHide: false
            property bool dockShowIndicators: true
            property bool dockShowTooltips: true
            property bool dockShowRunning: true
            property bool dockIconTiles: false
            property int launcherWidth: 560
            property int launcherMaxRows: 8
            property bool launcherAppDescriptions: true
            property bool launcherWindows: true
            property bool launcherPowerChips: true
            property string launcherPowerButtons: "lock,suspend,reboot,shutdown"
            property bool launcherPowerSearch: true
            property bool launcherWebSearch: true
            property string launcherSearchUrl: "https://duckduckgo.com/?q=%s"
            // desktop entry ids, comma separated; see Apps
            property string launcherFavApps: ""
            property string launcherHiddenApps: ""
            property bool clipboardEnabled: true
            property bool widgetsEnabled: true
            property bool widgetSnap: true
            property bool widgetLockAll: false
            property bool widgetHideFullscreen: true
            property bool widgetOnTop: false
            property bool btScanOnOpen: true
            property bool btShowUnnamed: false
            property bool btReceive: true
            property string btReceiveFolder: ""
            property bool btReceiveAutoPaired: false
            property bool audioMoveStreams: true
            property bool soundVolumeFeedback: false
            property string soundVolumeStyle: "snap"
            property bool soundBrightness: false
            property string soundBrightnessStyle: "high"
            property bool soundPlug: false
            property string soundPlugStyle: "pips"
            property bool soundLock: false
            property string soundLockStyle: "latch"
            property bool soundTrash: false
            property string soundTrashStyle: "crunch"
            property bool soundCapture: false
            property string soundCaptureStyle: "pop"
            property string soundCustomVolume: ""
            property string soundCustomBrightness: ""
            property string soundCustomPlugIn: ""
            property string soundCustomPlugOut: ""
            property string soundCustomLock: ""
            property string soundCustomUnlock: ""
            property string soundCustomTrash: ""
            property string soundCustomCapture: ""
            property real soundFeedbackVolume: 1.0
            property bool kdeConnectEnabled: true
            property bool updateCheck: true
            property bool idleEnabled: false
            property bool idleAutostart: true
            property bool idleKeepAwake: false
            property bool idleAdopted: false
            property bool idleDim: true
            property int idleDimAfter: 120
            property int idleDimLevel: 10
            property bool idleDimKeyboard: true
            property bool idleLock: true
            property int idleLockAfter: 600
            property bool idleScreenOff: true
            property int idleScreenOffAfter: 900
            property bool idleSuspend: false
            property int idleSuspendAfter: 1800
            property bool idleSuspendOnAc: false
            property bool idleLockBeforeSleep: true
            property bool idleWakeAfterSleep: true
            property bool idleRespectInhibitors: true
            property bool idleWhileMedia: true
            property bool desktopSelection: true
            property bool desktopMenu: true
            property bool desktopIcons: false
            property string desktopIconSize: "medium"
            property string desktopIconsCorner: "left"
            property string desktopIconsSort: "name"
            property string desktopIconsOpen: "double"
            property bool desktopIconsThumbs: true
            property bool desktopIconsHidden: false
            property bool desktopIconsHome: false
            property bool desktopIconsTrash: false
            property string desktopIconStyle: "objects"
            property string desktopIconTint: "folders"
            property bool desktopIconsShown: true
            property string desktopIconShape: "square"
            property string desktopIconNames: "always"
            property string shotPreview: "preview"
            property int shotPreviewSeconds: 6
            property bool envAdopted: false
            property string envCursorTheme: ""
            property int envCursorSize: 24
            property bool envCursorShadow: true
            property string envIconTheme: ""
            property string envGtkTheme: ""
            property string envQtStyle: "Fusion"
            property string envQtPlatformTheme: ""
            property string envColorScheme: "auto"
            property bool envFontSync: false
            property string envAppFont: ""
            property int envAppFontSize: 11
            property string envDocumentFont: ""
            property int envDocumentFontSize: 11
            property string envMonoFont: ""
            property int envMonoFontSize: 10
            property bool envApplyGtk: true
            property bool envApplyQt: true
            property bool envApplyHypr: true
            property bool specialScratchpad: true
            property bool specialMusic: true
            property bool specialComms: true
            property bool specialTodo: true
            property bool specialSysmon: true
            property string specialMusicApps: "auto"
            property string specialCommsApps: "auto"
            property string specialTodoApps: "auto"
            property string specialSysmonApps: "auto"
            property bool specialKeepApps: true
            property bool specialHideOnSwitch: false
            property real specialDim: 0.2
            property bool specialBlur: false
            property int specialGaps: 0
            property string specialCustom: "[]"
            property string hyprOptions: "{}"
            property string pinBorder: "tertiary"
            property string pinBadge: "top-right"
            property bool pinPulse: true
            property string urgentBadge: "top-left"
            property bool urgentPulse: true
            // the apps on the Glass page, and the ones given their own value
            property string glassApps: "vscodium"
            property string glassValues: "vscodium=0.9"
            // what Settings > Displays gave each output, and which one the shell sits on
            property string monitorSetups: "{}"
            property string monitorShellScreen: ""
            property string monitorBarScreen: ""
            property string monitorDockScreen: ""
            property string monitorWorkspaces: "{}"
        }

    }

}
