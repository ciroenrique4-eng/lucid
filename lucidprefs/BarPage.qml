import QtQuick
import qs

Column {
    id: page

    readonly property var moduleList: Prefs.barModules
    // the module whose card shows: the one a right click on the bar asked for,
    // or the first
    property string selectedModule: ""

    function paneFlick() {
        let p = page.parent;
        while (p) {
            if (p.contentY !== undefined && p.contentHeight !== undefined)
                return p;

            p = p.parent;
        }
        return null;
    }

    // brings the module's card into view, for a right click on the bar
    function revealModule() {
        const flick = page.paneFlick();
        if (!flick)
            return ;

        const y = moduleCard.mapToItem(flick.contentItem, 0, 0).y;
        flick.contentY = Math.max(0, Math.min(Math.max(0, flick.contentHeight - flick.height), y - 90));
    }

    Component.onCompleted: {
        page.selectedModule = Prefs.barModuleFocus !== "" ? Prefs.barModuleFocus : Prefs.barModules[0].id;
        if (Prefs.barModuleFocus !== "")
            revealLater.start();

    }

    Timer {
        id: revealLater

        interval: 120
        onTriggered: {
            page.revealModule();
            Prefs.barModuleFocus = "";
        }
    }

    // asked again while the page is already up
    Connections {
        function onBarModuleFocusChanged() {
            if (Prefs.barModuleFocus === "")
                return ;

            page.selectedModule = Prefs.barModuleFocus;
            revealLater.restart();
        }

        target: Prefs
    }

    spacing: 26

    BarPreview {
        width: parent.width
    }

    // whole-bar looks: its edge, its style, its modules and where they sit
    SettingCard {
        title: I18n.tr("PRESETS")

        SettingRow {
            title: I18n.tr("Start from a preset")
            description: I18n.tr("Sets the bar's edge, style, modules and their places, and a few looks, in one go; everything stays yours to change afterwards.")
            stacked: true
            showDivider: false

            Flow {
                width: parent.width
                spacing: 10

                Repeater {
                    model: Prefs.barPresets

                    BarPresetTile {
                        required property var modelData

                        presetId: modelData.id
                    }

                }

            }

        }

        SettingRow {
            readonly property var undo: {
                try {
                    return Prefs.barPresetUndo !== "" ? JSON.parse(Prefs.barPresetUndo) : null;
                } catch (e) {
                    return null;
                }
            }

            visible: undo !== null
            title: undo ? I18n.tr("Applied %1", undo.name) : ""
            description: I18n.tr("What it replaced is kept: undo puts the bar back as it was before.")
            showDivider: false

            M3Button {
                text: I18n.tr("Undo")
                variant: "tonal"
                onClicked: Prefs.undoBarPreset()
            }

        }

    }

    SettingCard {
        title: I18n.tr("OPENING BEHAVIOUR")

        SettingRow {
            title: I18n.tr("Auto-hide")
            description: I18n.tr("The bar slides off its edge of the screen and comes back when the pointer reaches that edge, or while one of its panels is open.")

            M3Switch {
                checked: Prefs.barAutoHide
                onToggled: (v) => {
                    return Prefs.barAutoHide = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Open on hover")
            resetKey: "barHoverOpen"
            description: I18n.tr("Rest the pointer on a module and its panel opens by itself, no click needed; move away and it closes again. A panel opened this way leaves the keyboard with whatever window had it — click the panel to take focus, exactly as a clicked-open one does. The workspace overview still needs a click.")

            M3Switch {
                checked: Prefs.barHoverOpen
                onToggled: (v) => {
                    return Prefs.barHoverOpen = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Pop-up mode")
            description: Prefs.barBottom ? I18n.tr("Modules stop morphing their own pill into a panel. The pill stays put in the bar and the panel appears above it as a detached pop-up.") : I18n.tr("Modules stop morphing their own pill into a panel. The pill stays put in the bar and the panel appears below it as a detached pop-up.")

            M3Switch {
                checked: Prefs.barPopupMode
                onToggled: (v) => {
                    return Prefs.barPopupMode = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Pop-up distance")
            resetKey: "barPopupGap"
            description: I18n.tr("The gap between a module's pill and the panel it opens.")
            enabled: Prefs.barPopupMode
            disabledReason: I18n.tr("Only applies in pop-up mode.")
            showDivider: false
            stacked: true

            M3Slider {
                width: parent.width
                enabled: Prefs.barPopupMode
                from: 0
                to: 24
                stepSize: 1
                suffix: " px"
                value: Prefs.barPopupGap
                onMoved: (v) => {
                    return Prefs.barPopupGap = v;
                }
            }

        }

    }

    SettingCard {
        title: I18n.tr("LAYOUT")

        SettingRow {
            title: I18n.tr("Screen edge")
            resetKey: "barPosition"
            description: I18n.tr("Which edge of the screen the bar sits on. At the bottom, every panel, pop-up and menu opens upwards, new notifications stack above it, and the dock steps aside (the launcher stays).")

            M3Segmented {
                width: 220
                current: Prefs.barPosition
                options: [{
                    "key": "top",
                    "label": I18n.tr("Top")
                }, {
                    "key": "bottom",
                    "label": I18n.tr("Bottom")
                }]
                onChosen: (key) => {
                    return Prefs.barPosition = key;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Bar height")
            resetKey: "barHeight"
            description: I18n.tr("How tall each module's resting pill is.")
            stacked: true

            M3Slider {
                width: parent.width
                from: 26
                to: 52
                stepSize: 1
                suffix: " px"
                value: Prefs.barHeight
                onMoved: (v) => {
                    return Prefs.barHeight = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Distance from the edge")
            resetKey: "barTopMargin"
            description: Prefs.barBottom ? I18n.tr("How far the bar floats above the bottom edge of the screen.") : I18n.tr("How far the bar floats below the top edge of the screen.")
            enabled: !Prefs.barFlush
            disabledReason: I18n.tr("Notches and the full bar sit flush against the screen edge by definition - switch back to islands on the General page to float the bar.")
            stacked: true

            M3Slider {
                width: parent.width
                enabled: !Prefs.barFlush
                from: 0
                to: 48
                stepSize: 1
                suffix: " px"
                value: Prefs.barTopMargin
                onMoved: (v) => {
                    return Prefs.barTopMargin = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Side margin")
            resetKey: "barSideMargin"
            description: I18n.tr("Inset from the left and right screen edges.")
            stacked: true

            M3Slider {
                width: parent.width
                from: 0
                to: 60
                stepSize: 1
                suffix: " px"
                value: Prefs.barSideMargin
                onMoved: (v) => {
                    return Prefs.barSideMargin = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Edge blend")
            resetKey: "barNotchFlare"
            description: I18n.tr("How far a notched module's upper corners sweep out into the top of the screen. Only drawn where there is room for it - modules packed close together keep their square corners rather than leaving a spike of wallpaper between them.")
            enabled: Prefs.barNotch
            disabledReason: I18n.tr("Islands float clear of the screen edge, so there is nothing to blend into - switch the bar to Notches on the General page.")
            stacked: true

            M3Slider {
                width: parent.width
                enabled: Prefs.barNotch
                from: 0
                to: 32
                stepSize: 1
                suffix: " px"
                value: Prefs.barNotchFlare
                onMoved: (v) => {
                    return Prefs.barNotchFlare = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Animation speed")
            resetKey: "barMotionScale"
            description: I18n.tr("Scales every transition in the bar - hovers, pills growing and shrinking, modules appearing and leaving - on top of the shell-wide Animation speed on the General page. Above 1.00x the bar moves more slowly than the rest of the shell.")
            stacked: true

            M3Slider {
                width: parent.width
                from: 0
                to: 2.5
                stepSize: 0.05
                decimals: 2
                suffix: "x"
                value: Prefs.barMotionScale
                onMoved: (v) => {
                    return Prefs.barMotionScale = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Screen corners")
            resetKey: "barFullCorner"
            description: I18n.tr("How far the full bar's strip curves into the left and right screen edges. Separate from Edge blend, which is the curve between the strip and an open panel.")
            enabled: Prefs.barFull
            disabledReason: I18n.tr("Only the full bar meets the screen edges - switch bar style to Full bar on the General page.")
            stacked: true

            M3Slider {
                width: parent.width
                enabled: Prefs.barFull
                from: 0
                to: 40
                stepSize: 1
                suffix: " px"
                value: Prefs.barFullCorner
                onMoved: (v) => {
                    return Prefs.barFullCorner = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Module spacing")
            resetKey: "barSpacing"
            description: I18n.tr("The gap between neighbouring pills.")
            stacked: true

            M3Slider {
                width: parent.width
                from: 0
                to: 24
                stepSize: 1
                suffix: " px"
                value: Prefs.barSpacing
                onMoved: (v) => {
                    return Prefs.barSpacing = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Hover growth")
            resetKey: "barHoverGrow"
            description: I18n.tr("How far a pill swells under the pointer to show it opens. Capped at half the module spacing.")
            showDivider: false
            stacked: true

            M3Slider {
                width: parent.width
                from: 0
                to: 6
                stepSize: 1
                suffix: " px"
                value: Prefs.barHoverGrow
                onMoved: (v) => {
                    return Prefs.barHoverGrow = v;
                }
            }

        }

    }

    SettingCard {
        title: I18n.tr("MODULES")

        SettingRow {
            title: I18n.tr("Arrangement")
            resetKey: "barLayout"
            description: I18n.tr("Tap a module to set it up below, or drag it along its group or into another one. Left and right sit against the screen's edges and the centre stays in the middle; a module switched off keeps its place, and an outlined one is on but has nothing to show right now.")
            enabled: Prefs.barEnabled
            disabledReason: I18n.tr("The bar is switched off, so there is nothing to arrange.")
            stacked: true

            BarLayoutEditor {
                width: parent.width
                enabled: Prefs.barEnabled
                selected: page.selectedModule
                onChosen: (id) => {
                    return page.selectedModule = id;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Module backgrounds")
            resetKey: "barModuleBackgrounds"
            description: I18n.tr("A soft background behind each module, so they stand out on the strip. In the arrangement above, the + between two neighbours puts them on one background; the - parts them again.")
            enabled: Prefs.barEnabled && Prefs.barFull
            disabledReason: Prefs.barNotch ? I18n.tr("Only on the full bar. On notches, Shared notches below joins modules instead.") : I18n.tr("Only on the full bar: islands already give every module a shape of its own.")
            showDivider: false

            M3Switch {
                enabled: Prefs.barEnabled && Prefs.barFull
                checked: Prefs.barModuleBackgrounds
                onToggled: (v) => {
                    return Prefs.barModuleBackgrounds = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Shared notches")
            resetKey: "barNotchGroups"
            description: I18n.tr("Modules joined in the arrangement above hang from one notch, as wide as they are together, instead of one notch each. The + between two neighbours joins them; the - parts them again.")
            enabled: Prefs.barEnabled && Prefs.barNotch
            disabledReason: I18n.tr("Only when the bar is notches.")
            showDivider: false

            M3Switch {
                enabled: Prefs.barEnabled && Prefs.barNotch
                checked: Prefs.barNotchGroups
                onToggled: (v) => {
                    return Prefs.barNotchGroups = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Lines between joined modules")
            resetKey: "barGroupDividers"
            description: I18n.tr("A thin line between modules that share a background or a notch.")
            enabled: Prefs.barEnabled && Prefs.barGrouping
            disabledReason: I18n.tr("Turn on module backgrounds on the full bar, or shared notches, first.")
            showDivider: false

            M3Switch {
                enabled: Prefs.barEnabled && Prefs.barGrouping
                checked: Prefs.barGroupDividers
                onToggled: (v) => {
                    return Prefs.barGroupDividers = v;
                }
            }

        }

    }

    BarModuleCard {
        id: moduleCard

        moduleId: page.selectedModule
    }

    SettingCard {
        title: I18n.tr("NOTIFICATIONS")

        SettingRow {
            title: I18n.tr("Do not disturb")
            resetKey: "doNotDisturb"
            description: I18n.tr("Notifications are still collected in the list, but no popup is shown.")

            M3Switch {
                checked: Prefs.doNotDisturb
                onToggled: (v) => {
                    return Prefs.doNotDisturb = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Everything else")
            description: I18n.tr("How long a popup stays, quiet hours, sound and which applications may interrupt you all live on their own page.")
            showDivider: false

            M3Button {
                text: I18n.tr("Notifications…")
                variant: "tonal"
                onClicked: Prefs.settingsRequested("notifications")
            }

        }

    }

    SettingCard {
        title: I18n.tr("SYSTEM MODULE")

        SettingRow {
            title: I18n.tr("Keyboard layout")
            resetKey: "showKbLayout"
            description: I18n.tr("Shows the active keyboard layout next to the network icon. Click it to switch to the next layout.")

            M3Switch {
                checked: Prefs.showKbLayout
                onToggled: (v) => {
                    return Prefs.showKbLayout = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Game mode: turn on")
            resetKey: "gameModeOnCmd"
            description: I18n.tr("Shell command the Game Mode quick toggle runs to switch it on. Runs through bash, so pipes and && work.")
            stacked: true

            M3TextField {
                width: parent.width
                placeholder: I18n.tr("e.g. sudo -n g15-gamemode on")
                text: Prefs.gameModeOnCmd
                onAccepted: (v) => {
                    return Prefs.gameModeOnCmd = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Game mode: turn off")
            resetKey: "gameModeOffCmd"
            description: I18n.tr("Shell command run to switch game mode off again.")
            stacked: true

            M3TextField {
                width: parent.width
                placeholder: I18n.tr("e.g. sudo -n g15-gamemode off")
                text: Prefs.gameModeOffCmd
                onAccepted: (v) => {
                    return Prefs.gameModeOffCmd = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Game mode: status check")
            resetKey: "gameModeStatusCmd"
            description: I18n.tr("Optional. Exits 0 while game mode is on, so the toggle stays right when something else (a keybind, a script) changes it. Checked whenever the panel opens.")
            showDivider: false
            stacked: true

            M3TextField {
                width: parent.width
                placeholder: I18n.tr("e.g. test -f /run/g15-gamemode.state")
                text: Prefs.gameModeStatusCmd
                onAccepted: (v) => {
                    return Prefs.gameModeStatusCmd = v;
                }
            }

        }

    }

}
