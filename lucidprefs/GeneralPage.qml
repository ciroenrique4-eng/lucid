import QtQuick
import Quickshell
import qs

Column {
    id: page

    readonly property string home: Quickshell.env("HOME")
    spacing: 26

    SettingCard {
        title: I18n.tr("LANGUAGE")

        SettingRow {
            title: I18n.tr("Language")
            description: I18n.tr("Automatic follows the system language, here %1. Text the translation doesn't cover stays in English.", I18n.autoName)

            M3Segmented {
                width: 360
                current: Prefs.language
                options: [{
                    "key": "auto",
                    "label": I18n.tr("Automatic")
                }].concat(I18n.languages.map((l) => {
                    return {
                        "key": l.code,
                        "label": l.name
                    };
                }))
                onChosen: (key) => {
                    return Prefs.language = key;
                }
            }

        }

    }

    SettingCard {
        title: I18n.tr("SHAPE")

        SettingRow {
            title: I18n.tr("Bar style")
            description: I18n.tr("Islands float free of the screen edge. Notches sit flush against it, squaring off the corners that meet it. Full bar joins every module on one continuous strip across the screen edge the bar sits on.")

            M3Segmented {
                width: 360
                current: Prefs.barStyle
                options: [{
                    "key": "island",
                    "label": I18n.tr("Islands")
                }, {
                    "key": "notch",
                    "label": I18n.tr("Notches")
                }, {
                    "key": "full",
                    "label": I18n.tr("Full bar")
                }]
                onChosen: (key) => {
                    return Prefs.barStyle = key;
                }
            }

        }

        SettingRow {
            title: I18n.tr("OSD style")
            description: I18n.tr("Where volume, brightness and lock-key changes show up. Islands float above the bottom edge; Notches rise out of it.")

            M3Segmented {
                width: 260
                current: Prefs.osdStyle
                options: [{
                    "key": "island",
                    "label": I18n.tr("Islands")
                }, {
                    "key": "notch",
                    "label": I18n.tr("Notches")
                }]
                onChosen: (key) => {
                    return Prefs.osdStyle = key;
                }
            }

        }

        SettingRow {
            title: I18n.tr("OSD width")
            resetKey: "osdNotchWidth"
            description: I18n.tr("How wide the notched OSD is; the volume and brightness track takes up the difference. Caps Lock, Num Lock and the microphone use the same width unless their label needs more room. Dragging shows the OSD at its new size.")
            enabled: Prefs.osdNotch
            disabledReason: I18n.tr("Only the notched OSD has a set size - switch OSD style to Notches above.")
            stacked: true

            M3Slider {
                width: parent.width
                enabled: Prefs.osdNotch
                from: 240
                to: 640
                stepSize: 10
                suffix: " px"
                value: Prefs.osdNotchWidth
                onMoved: (v) => {
                    return Prefs.osdNotchWidth = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("OSD height")
            resetKey: "osdNotchHeight"
            description: I18n.tr("How tall the notched OSD is, from a slim strip to a roomier card.")
            enabled: Prefs.osdNotch
            disabledReason: I18n.tr("Only the notched OSD has a set size - switch OSD style to Notches above.")
            stacked: true

            M3Slider {
                width: parent.width
                enabled: Prefs.osdNotch
                from: 60
                to: 110
                stepSize: 2
                suffix: " px"
                value: Prefs.osdNotchHeight
                onMoved: (v) => {
                    return Prefs.osdNotchHeight = v;
                }
            }

        }


        SettingRow {
            title: I18n.tr("Dock style")
            description: I18n.tr("The same choice for the dock, against the bottom edge.")
            showDivider: false

            M3Segmented {
                width: 260
                current: Prefs.dockStyle
                options: [{
                    "key": "island",
                    "label": I18n.tr("Islands")
                }, {
                    "key": "notch",
                    "label": I18n.tr("Notches")
                }]
                onChosen: (key) => {
                    return Prefs.dockStyle = key;
                }
            }

        }

    }

    SettingCard {
        title: I18n.tr("SURFACES")

        SettingRow {
            title: I18n.tr("Glass")
            description: I18n.tr("How far the desktop shows through the shell, the terminal and your windows now has a page of its own.")

            M3Button {
                text: I18n.tr("Glass…")
                variant: "tonal"
                onClicked: Prefs.settingsRequested("glass")
            }

        }

        SettingRow {
            title: I18n.tr("Accent intensity")
            resetKey: "accentPunch"
            description: I18n.tr("Lifts the accent colour away from the wallpaper-derived original. 1.0 uses it exactly as generated.")
            stacked: true

            M3Slider {
                width: parent.width
                from: 1
                to: 2
                stepSize: 0.05
                decimals: 2
                value: Prefs.accentPunch
                onMoved: (v) => {
                    return Prefs.accentPunch = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Corner rounding")
            resetKey: "radiusScale"
            description: I18n.tr("Scales every rounded corner in the shell at once — pills, panels, the dock, cards and buttons. 100% is the shipped shape; 0% squares everything off. Pills and round buttons stay fully round from 100% up and square off with the rest below it.")
            stacked: true

            M3Slider {
                width: parent.width
                from: 0
                to: 150
                stepSize: 5
                decimals: 0
                suffix: " %"
                value: Math.round(Prefs.radiusScale * 100)
                onMoved: (v) => {
                    return Prefs.radiusScale = v / 100;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Surface darkness")
            resetKey: "surfaceDarkness"
            description: I18n.tr("How far every panel is darkened beneath the theme's own surface colour. Auto follows the theme.")
            stacked: true

            Row {
                spacing: 16
                width: parent.width

                M3Slider {
                    width: parent.width - resetDark.width - 16
                    enabled: Prefs.surfaceDarkness >= 0
                    from: 0
                    to: 0.8
                    stepSize: 0.05
                    decimals: 2
                    value: Prefs.surfaceDarkness >= 0 ? Prefs.surfaceDarkness : 0.45
                    onMoved: (v) => {
                        return Prefs.surfaceDarkness = v;
                    }
                }

                M3Button {
                    id: resetDark

                    anchors.verticalCenter: parent.verticalCenter
                    text: Prefs.surfaceDarkness >= 0 ? I18n.tr("Auto") : I18n.tr("Manual")
                    variant: Prefs.surfaceDarkness >= 0 ? "tonal" : "filled"
                    onClicked: Prefs.surfaceDarkness = Prefs.surfaceDarkness >= 0 ? -1 : 0.45
                }

            }

        }

        SettingRow {
            title: I18n.tr("Accent tint")
            resetKey: "surfaceTint"
            description: I18n.tr("How much of the accent colour is mixed into every panel. A light palette comes out of the generator almost white, so Auto tints it and leaves dark panels flat.")
            showDivider: false
            stacked: true

            Row {
                spacing: 16
                width: parent.width

                M3Slider {
                    width: parent.width - resetTint.width - 16
                    enabled: Prefs.surfaceTint >= 0
                    from: 0
                    to: 1
                    stepSize: 0.05
                    decimals: 2
                    value: Prefs.surfaceTint >= 0 ? Prefs.surfaceTint : (Theme.isLight ? 0.7 : 0)
                    onMoved: (v) => {
                        return Prefs.surfaceTint = v;
                    }
                }

                M3Button {
                    id: resetTint

                    anchors.verticalCenter: parent.verticalCenter
                    text: Prefs.surfaceTint >= 0 ? I18n.tr("Auto") : I18n.tr("Manual")
                    variant: Prefs.surfaceTint >= 0 ? "tonal" : "filled"
                    onClicked: Prefs.surfaceTint = Prefs.surfaceTint >= 0 ? -1 : (Theme.isLight ? 0.7 : 0.2)
                }

            }

        }

    }

    SettingCard {
        title: I18n.tr("MOTION")

        SettingRow {
            title: I18n.tr("Animation speed")
            resetKey: "motionScale"
            description: I18n.tr("Scales every transition in the shell. 1.00x is the shipped speed; drag to 0 for no animation at all.")
            showDivider: false
            stacked: true

            M3Slider {
                width: parent.width
                from: 0
                to: 2
                stepSize: 0.25
                decimals: 2
                suffix: "x"
                value: Prefs.motionScale
                onMoved: (v) => {
                    return Prefs.motionScale = v;
                }
            }

        }

    }

    SettingCard {
        title: I18n.tr("DESKTOP")

        SettingRow {
            title: I18n.tr("Selection box")
            resetKey: "desktopSelection"
            description: Prefs.desktopIcons ? I18n.tr("Drag across empty desktop and a translucent box follows the cursor and selects the icons it touches. Hold Ctrl or Shift to add to what is already selected.") : I18n.tr("Drag across empty desktop and a translucent box follows the cursor, the way it does on Windows and macOS. Without desktop icons it is decoration only \u2014 nothing gets selected, and dragging inside a window or on a widget is untouched.")

            M3Switch {
                checked: Prefs.desktopSelection
                onToggled: (v) => {
                    return Prefs.desktopSelection = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Right-click menu")
            resetKey: "desktopMenu"
            description: I18n.tr("Right-click empty desktop for wallpaper and theme, the widgets you have placed, a screenshot and settings.")
            showDivider: false

            M3Switch {
                checked: Prefs.desktopMenu
                onToggled: (v) => {
                    return Prefs.desktopMenu = v;
                }
            }

        }

    }

    SettingCard {
        title: I18n.tr("DESKTOP ICONS")

        SettingRow {
            title: I18n.tr("Show icons")
            resetKey: "desktopIcons"
            description: I18n.tr("What is in your Desktop folder sits on the wallpaper, sharing it with the widgets. A widget always keeps its space: an icon it covers steps to the nearest free cell, and goes back when the widget moves away. Drag icons around, into a folder, onto the trash or out into any app; drop files from a file manager or a browser to put them here. Right-click the desktop to hide them for a while.")

            M3Switch {
                checked: Prefs.desktopIcons
                onToggled: (v) => {
                    return Prefs.desktopIcons = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Look")
            resetKey: "desktopIconStyle"
            enabled: Prefs.desktopIcons
            disabledReason: I18n.tr("Turn on Show icons first.")
            description: Prefs.desktopIconStyle === "objects" ? I18n.tr("Folders, pages and the bin drawn as things on a desk, in the wallpaper's colours: a folder's flap opens under the pointer, a page wears its type on a tab, the bin's lid lifts for a drop. Pictures are prints, apps keep their own icons, and a card of the widgets' material comes up under the pointer.") : (Prefs.desktopIconStyle === "shapes" ? I18n.tr("Each icon sits on a shape in a colour of the palette \u2014 folders, apps and files apart at a glance \u2014 and tips toward the pointer. Pictures are prints on paper in the wallpaper's hue, set down slightly askew.") : (Prefs.desktopIconStyle === "glass" ? I18n.tr("Every icon on a frosted card of its own, the material the widgets are made of.") : I18n.tr("The icons straight on the wallpaper, their names in white.")))

            M3Segmented {
                width: 340
                current: Prefs.desktopIconStyle
                options: [{
                    "key": "objects",
                    "label": I18n.tr("Objects")
                }, {
                    "key": "shapes",
                    "label": I18n.tr("Shapes")
                }, {
                    "key": "glass",
                    "label": I18n.tr("Glass")
                }, {
                    "key": "classic",
                    "label": I18n.tr("Classic")
                }]
                onChosen: (key) => {
                    return Prefs.desktopIconStyle = key;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Shape")
            resetKey: "desktopIconShape"
            enabled: Prefs.desktopIcons && Prefs.desktopIconStyle === "shapes"
            disabledReason: I18n.tr("For the Shapes look.")
            description: Prefs.desktopIconShape === "expressive" ? I18n.tr("Material's expressive shapes, one per kind: cookies for folders and the trash, the calendar's rounded pentagon for apps, a squircle for files.") : I18n.tr("A square with the shell's own corners, the roundness dial included, that rounds out a little under the pointer.")

            M3Segmented {
                width: 260
                current: Prefs.desktopIconShape
                options: [{
                    "key": "square",
                    "label": I18n.tr("Shell square")
                }, {
                    "key": "expressive",
                    "label": I18n.tr("Expressive")
                }]
                onChosen: (key) => {
                    return Prefs.desktopIconShape = key;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Shell colours")
            resetKey: "desktopIconTint"
            enabled: Prefs.desktopIcons && Prefs.desktopIconStyle !== "objects"
            disabledReason: Prefs.desktopIcons ? I18n.tr("The Objects look draws folders and files in the palette already.") : I18n.tr("Turn on Show icons first.")
            description: I18n.tr("Recolour the icon theme's folders, or its file icons too, in the palette, keeping their light and shade. Apps keep their own colours, and pictures are never touched.")

            M3Segmented {
                width: 420
                current: Prefs.desktopIconTint
                options: [{
                    "key": "off",
                    "label": I18n.tr("Off")
                }, {
                    "key": "folders",
                    "label": I18n.tr("Folders")
                }, {
                    "key": "all",
                    "label": I18n.tr("Folders and files")
                }]
                onChosen: (key) => {
                    return Prefs.desktopIconTint = key;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Names")
            resetKey: "desktopIconNames"
            enabled: Prefs.desktopIcons
            disabledReason: I18n.tr("Turn on Show icons first.")
            description: Prefs.desktopIconNames === "hover" ? I18n.tr("Only the pictures until the pointer comes among them; then the names come out in a wave from the one under it. Selected icons keep theirs.") : I18n.tr("Every name under its icon, on one line; the whole name shows under the pointer. Over a light sky the names turn dark.")

            M3Segmented {
                width: 240
                current: Prefs.desktopIconNames
                options: [{
                    "key": "always",
                    "label": I18n.tr("Always")
                }, {
                    "key": "hover",
                    "label": I18n.tr("On hover")
                }]
                onChosen: (key) => {
                    return Prefs.desktopIconNames = key;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Size")
            resetKey: "desktopIconSize"
            enabled: Prefs.desktopIcons
            disabledReason: I18n.tr("Turn on Show icons first.")

            M3Segmented {
                width: 240
                current: Prefs.desktopIconSize
                options: [{
                    "key": "small",
                    "label": I18n.tr("Small")
                }, {
                    "key": "medium",
                    "label": I18n.tr("Medium")
                }, {
                    "key": "large",
                    "label": I18n.tr("Large")
                }]
                onChosen: (key) => {
                    return Prefs.desktopIconSize = key;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Start from")
            resetKey: "desktopIconsCorner"
            enabled: Prefs.desktopIcons
            disabledReason: I18n.tr("Turn on Show icons first.")
            description: I18n.tr("New icons fill the columns from this side of the screen, top to bottom.")

            M3Segmented {
                width: 180
                current: Prefs.desktopIconsCorner
                options: [{
                    "key": "left",
                    "label": I18n.tr("Left")
                }, {
                    "key": "right",
                    "label": I18n.tr("Right")
                }]
                onChosen: (key) => {
                    return Prefs.desktopIconsCorner = key;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Arrange by")
            resetKey: "desktopIconsSort"
            enabled: Prefs.desktopIcons
            disabledReason: I18n.tr("Turn on Show icons first.")
            description: I18n.tr("The order new icons take, and the one Arrange Icons (right-click the desktop) puts everything back in. Folders come first.")

            M3Segmented {
                width: 260
                current: Prefs.desktopIconsSort
                options: [{
                    "key": "name",
                    "label": I18n.tr("Name")
                }, {
                    "key": "type",
                    "label": I18n.tr("Type")
                }, {
                    "key": "date",
                    "label": I18n.tr("Modified")
                }]
                onChosen: (key) => {
                    Prefs.desktopIconsSort = key;
                    DesktopIcons.arrange();
                }
            }

        }

        SettingRow {
            title: I18n.tr("Open with")
            resetKey: "desktopIconsOpen"
            enabled: Prefs.desktopIcons
            disabledReason: I18n.tr("Turn on Show icons first.")

            M3Segmented {
                width: 240
                current: Prefs.desktopIconsOpen
                options: [{
                    "key": "double",
                    "label": I18n.tr("Double click")
                }, {
                    "key": "single",
                    "label": I18n.tr("Single click")
                }]
                onChosen: (key) => {
                    return Prefs.desktopIconsOpen = key;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Previews")
            resetKey: "desktopIconsThumbs"
            enabled: Prefs.desktopIcons
            disabledReason: I18n.tr("Turn on Show icons first.")
            description: I18n.tr("Pictures show themselves instead of a generic icon, and so do videos and documents a file manager has already made a thumbnail for.")

            M3Switch {
                checked: Prefs.desktopIconsThumbs
                onToggled: (v) => {
                    return Prefs.desktopIconsThumbs = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Hidden files")
            resetKey: "desktopIconsHidden"
            enabled: Prefs.desktopIcons
            disabledReason: I18n.tr("Turn on Show icons first.")
            description: I18n.tr("Files whose name starts with a dot.")

            M3Switch {
                checked: Prefs.desktopIconsHidden
                onToggled: (v) => {
                    return Prefs.desktopIconsHidden = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Home folder")
            resetKey: "desktopIconsHome"
            enabled: Prefs.desktopIcons
            disabledReason: I18n.tr("Turn on Show icons first.")

            M3Switch {
                checked: Prefs.desktopIconsHome
                onToggled: (v) => {
                    return Prefs.desktopIconsHome = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Trash")
            resetKey: "desktopIconsTrash"
            enabled: Prefs.desktopIcons
            disabledReason: I18n.tr("Turn on Show icons first.")
            description: I18n.tr("Drop files on it to throw them away; right-click it to empty it.")

            M3Switch {
                checked: Prefs.desktopIconsTrash
                onToggled: (v) => {
                    return Prefs.desktopIconsTrash = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Add an app")
            enabled: Prefs.desktopIcons
            disabledReason: I18n.tr("Turn on Show icons first.")
            description: I18n.tr("Puts a launcher for it on the desktop. Launchers that arrive any other way ask before they run the first time.")
            showDivider: false

            M3Button {
                text: I18n.tr("Choose\u2026")
                variant: "tonal"
                enabled: Prefs.desktopIcons
                onClicked: Prefs.appPickerRequested("::desktop")
            }

        }

    }

    SettingCard {
        title: I18n.tr("SCREENSHOTS")

        SettingRow {
            title: I18n.tr("After a capture")
            resetKey: "shotPreview"
            description: Prefs.shotPreview === "preview" ? I18n.tr("A card in the corner shows it, to open, mark up, drag into an app, find in its folder or delete. Recordings get one too.") : (Prefs.shotPreview === "notify" ? I18n.tr("A notification says where it went. Screenshots are on the clipboard either way.") : I18n.tr("Nothing shows. Screenshots are still copied to the clipboard."))

            M3Segmented {
                width: 300
                current: Prefs.shotPreview
                options: [{
                    "key": "preview",
                    "label": I18n.tr("Preview")
                }, {
                    "key": "notify",
                    "label": I18n.tr("Notification")
                }, {
                    "key": "none",
                    "label": I18n.tr("Nothing")
                }]
                onChosen: (key) => {
                    return Prefs.shotPreview = key;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Preview stays for")
            resetKey: "shotPreviewSeconds"
            enabled: Prefs.shotPreview === "preview"
            description: I18n.tr("Resting the pointer on the card holds it for as long as you like.")
            showDivider: false
            stacked: true

            M3Slider {
                width: parent.width
                enabled: Prefs.shotPreview === "preview"
                from: 3
                to: 20
                stepSize: 1
                suffix: " s"
                value: Prefs.shotPreviewSeconds
                onMoved: (v) => {
                    return Prefs.shotPreviewSeconds = v;
                }
            }

        }

    }

}
