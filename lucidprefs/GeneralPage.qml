import QtQuick
import Quickshell
import qs

Column {
    id: page

    readonly property string home: Quickshell.env("HOME")
    spacing: 26

    SettingCard {
        title: "SHAPE"

        SettingRow {
            title: "Bar style"
            description: "Islands float free of the screen edge. Notches sit flush against it, squaring off the corners that meet it. Full bar joins every module on one continuous strip across the screen edge the bar sits on."

            M3Segmented {
                width: 360
                current: Prefs.barStyle
                options: [{
                    "key": "island",
                    "label": "Islands"
                }, {
                    "key": "notch",
                    "label": "Notches"
                }, {
                    "key": "full",
                    "label": "Full bar"
                }]
                onChosen: (key) => {
                    return Prefs.barStyle = key;
                }
            }

        }

        SettingRow {
            title: "OSD style"
            description: "Where volume, brightness and lock-key changes show up. Islands float above the bottom edge; Notches rise out of it."

            M3Segmented {
                width: 260
                current: Prefs.osdStyle
                options: [{
                    "key": "island",
                    "label": "Islands"
                }, {
                    "key": "notch",
                    "label": "Notches"
                }]
                onChosen: (key) => {
                    return Prefs.osdStyle = key;
                }
            }

        }

        SettingRow {
            title: "OSD width"
            resetKey: "osdNotchWidth"
            description: "How wide the notched OSD is; the volume and brightness track takes up the difference. Caps Lock, Num Lock and the microphone use the same width unless their label needs more room. Dragging shows the OSD at its new size."
            enabled: Prefs.osdNotch
            disabledReason: "Only the notched OSD has a set size - switch OSD style to Notches above."
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
            title: "OSD height"
            resetKey: "osdNotchHeight"
            description: "How tall the notched OSD is, from a slim strip to a roomier card."
            enabled: Prefs.osdNotch
            disabledReason: "Only the notched OSD has a set size - switch OSD style to Notches above."
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
            title: "Dock style"
            description: "The same choice for the dock, against the bottom edge."
            showDivider: false

            M3Segmented {
                width: 260
                current: Prefs.dockStyle
                options: [{
                    "key": "island",
                    "label": "Islands"
                }, {
                    "key": "notch",
                    "label": "Notches"
                }]
                onChosen: (key) => {
                    return Prefs.dockStyle = key;
                }
            }

        }

    }

    SettingCard {
        title: "SURFACES"

        SettingRow {
            title: "Glass"
            description: "How far the desktop shows through the shell, the terminal and your windows now has a page of its own."

            M3Button {
                text: "Glass…"
                variant: "tonal"
                onClicked: Prefs.settingsRequested("glass")
            }

        }

        SettingRow {
            title: "Accent intensity"
            resetKey: "accentPunch"
            description: "Lifts the accent colour away from the wallpaper-derived original. 1.0 uses it exactly as generated."
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
            title: "Corner rounding"
            resetKey: "radiusScale"
            description: "Scales every rounded corner in the shell at once — pills, panels, the dock, cards and buttons. 100% is the shipped shape; 0% squares everything off. Pills and round buttons stay fully round from 100% up and square off with the rest below it."
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
            title: "Surface darkness"
            resetKey: "surfaceDarkness"
            description: "How far every panel is darkened beneath the theme's own surface colour. Auto follows the theme."
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
                    text: Prefs.surfaceDarkness >= 0 ? "Auto" : "Manual"
                    variant: Prefs.surfaceDarkness >= 0 ? "tonal" : "filled"
                    onClicked: Prefs.surfaceDarkness = Prefs.surfaceDarkness >= 0 ? -1 : 0.45
                }

            }

        }

        SettingRow {
            title: "Accent tint"
            resetKey: "surfaceTint"
            description: "How much of the accent colour is mixed into every panel. A light palette comes out of the generator almost white, so Auto tints it and leaves dark panels flat."
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
                    text: Prefs.surfaceTint >= 0 ? "Auto" : "Manual"
                    variant: Prefs.surfaceTint >= 0 ? "tonal" : "filled"
                    onClicked: Prefs.surfaceTint = Prefs.surfaceTint >= 0 ? -1 : (Theme.isLight ? 0.7 : 0.2)
                }

            }

        }

    }

    SettingCard {
        title: "MOTION"

        SettingRow {
            title: "Animation speed"
            resetKey: "motionScale"
            description: "Scales every transition in the shell. 1.00x is the shipped speed; drag to 0 for no animation at all."
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
        title: "DESKTOP"

        SettingRow {
            title: "Selection box"
            resetKey: "desktopSelection"
            description: Prefs.desktopIcons ? "Drag across empty desktop and a translucent box follows the cursor and selects the icons it touches. Hold Ctrl or Shift to add to what is already selected." : "Drag across empty desktop and a translucent box follows the cursor, the way it does on Windows and macOS. Without desktop icons it is decoration only \u2014 nothing gets selected, and dragging inside a window or on a widget is untouched."

            M3Switch {
                checked: Prefs.desktopSelection
                onToggled: (v) => {
                    return Prefs.desktopSelection = v;
                }
            }

        }

        SettingRow {
            title: "Right-click menu"
            resetKey: "desktopMenu"
            description: "Right-click empty desktop for wallpaper and theme, the widgets you have placed, a screenshot and settings."
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
        title: "DESKTOP ICONS"

        SettingRow {
            title: "Show icons"
            resetKey: "desktopIcons"
            description: "What is in your Desktop folder sits on the wallpaper, sharing it with the widgets. A widget always keeps its space: an icon it covers steps to the nearest free cell, and goes back when the widget moves away. Drag icons around, into a folder, onto the trash or out into any app; drop files from a file manager or a browser to put them here. Right-click the desktop to hide them for a while."

            M3Switch {
                checked: Prefs.desktopIcons
                onToggled: (v) => {
                    return Prefs.desktopIcons = v;
                }
            }

        }

        SettingRow {
            title: "Look"
            resetKey: "desktopIconStyle"
            enabled: Prefs.desktopIcons
            disabledReason: "Turn on Show icons first."
            description: Prefs.desktopIconStyle === "shapes" ? "Each icon sits on a shape in a colour of the palette \u2014 folders, apps and files apart at a glance \u2014 and tips toward the pointer. Pictures are prints on paper in the wallpaper's hue, set down slightly askew." : (Prefs.desktopIconStyle === "glass" ? "Every icon on a frosted card of its own, the material the widgets are made of." : "The icons straight on the wallpaper, their names in white.")

            M3Segmented {
                width: 260
                current: Prefs.desktopIconStyle
                options: [{
                    "key": "shapes",
                    "label": "Shapes"
                }, {
                    "key": "glass",
                    "label": "Glass"
                }, {
                    "key": "classic",
                    "label": "Classic"
                }]
                onChosen: (key) => {
                    return Prefs.desktopIconStyle = key;
                }
            }

        }

        SettingRow {
            title: "Shape"
            resetKey: "desktopIconShape"
            enabled: Prefs.desktopIcons && Prefs.desktopIconStyle === "shapes"
            disabledReason: "For the Shapes look."
            description: Prefs.desktopIconShape === "expressive" ? "Material's expressive shapes, one per kind: cookies for folders and the trash, the calendar's rounded pentagon for apps, a squircle for files." : "A square with the shell's own corners, the roundness dial included, that rounds out a little under the pointer."

            M3Segmented {
                width: 260
                current: Prefs.desktopIconShape
                options: [{
                    "key": "square",
                    "label": "Shell square"
                }, {
                    "key": "expressive",
                    "label": "Expressive"
                }]
                onChosen: (key) => {
                    return Prefs.desktopIconShape = key;
                }
            }

        }

        SettingRow {
            title: "Shell colours"
            resetKey: "desktopIconTint"
            enabled: Prefs.desktopIcons
            disabledReason: "Turn on Show icons first."
            description: "Recolour the icon theme's folders, or its file icons too, in the palette, keeping their light and shade. Apps keep their own colours, and pictures are never touched."

            M3Segmented {
                width: 420
                current: Prefs.desktopIconTint
                options: [{
                    "key": "off",
                    "label": "Off"
                }, {
                    "key": "folders",
                    "label": "Folders"
                }, {
                    "key": "all",
                    "label": "Folders and files"
                }]
                onChosen: (key) => {
                    return Prefs.desktopIconTint = key;
                }
            }

        }

        SettingRow {
            title: "Size"
            resetKey: "desktopIconSize"
            enabled: Prefs.desktopIcons
            disabledReason: "Turn on Show icons first."

            M3Segmented {
                width: 240
                current: Prefs.desktopIconSize
                options: [{
                    "key": "small",
                    "label": "Small"
                }, {
                    "key": "medium",
                    "label": "Medium"
                }, {
                    "key": "large",
                    "label": "Large"
                }]
                onChosen: (key) => {
                    return Prefs.desktopIconSize = key;
                }
            }

        }

        SettingRow {
            title: "Start from"
            resetKey: "desktopIconsCorner"
            enabled: Prefs.desktopIcons
            disabledReason: "Turn on Show icons first."
            description: "New icons fill the columns from this side of the screen, top to bottom."

            M3Segmented {
                width: 180
                current: Prefs.desktopIconsCorner
                options: [{
                    "key": "left",
                    "label": "Left"
                }, {
                    "key": "right",
                    "label": "Right"
                }]
                onChosen: (key) => {
                    return Prefs.desktopIconsCorner = key;
                }
            }

        }

        SettingRow {
            title: "Arrange by"
            resetKey: "desktopIconsSort"
            enabled: Prefs.desktopIcons
            disabledReason: "Turn on Show icons first."
            description: "The order new icons take, and the one Arrange Icons (right-click the desktop) puts everything back in. Folders come first."

            M3Segmented {
                width: 260
                current: Prefs.desktopIconsSort
                options: [{
                    "key": "name",
                    "label": "Name"
                }, {
                    "key": "type",
                    "label": "Type"
                }, {
                    "key": "date",
                    "label": "Modified"
                }]
                onChosen: (key) => {
                    Prefs.desktopIconsSort = key;
                    DesktopIcons.arrange();
                }
            }

        }

        SettingRow {
            title: "Open with"
            resetKey: "desktopIconsOpen"
            enabled: Prefs.desktopIcons
            disabledReason: "Turn on Show icons first."

            M3Segmented {
                width: 240
                current: Prefs.desktopIconsOpen
                options: [{
                    "key": "double",
                    "label": "Double click"
                }, {
                    "key": "single",
                    "label": "Single click"
                }]
                onChosen: (key) => {
                    return Prefs.desktopIconsOpen = key;
                }
            }

        }

        SettingRow {
            title: "Previews"
            resetKey: "desktopIconsThumbs"
            enabled: Prefs.desktopIcons
            disabledReason: "Turn on Show icons first."
            description: "Pictures show themselves instead of a generic icon, and so do videos and documents a file manager has already made a thumbnail for."

            M3Switch {
                checked: Prefs.desktopIconsThumbs
                onToggled: (v) => {
                    return Prefs.desktopIconsThumbs = v;
                }
            }

        }

        SettingRow {
            title: "Hidden files"
            resetKey: "desktopIconsHidden"
            enabled: Prefs.desktopIcons
            disabledReason: "Turn on Show icons first."
            description: "Files whose name starts with a dot."

            M3Switch {
                checked: Prefs.desktopIconsHidden
                onToggled: (v) => {
                    return Prefs.desktopIconsHidden = v;
                }
            }

        }

        SettingRow {
            title: "Home folder"
            resetKey: "desktopIconsHome"
            enabled: Prefs.desktopIcons
            disabledReason: "Turn on Show icons first."

            M3Switch {
                checked: Prefs.desktopIconsHome
                onToggled: (v) => {
                    return Prefs.desktopIconsHome = v;
                }
            }

        }

        SettingRow {
            title: "Trash"
            resetKey: "desktopIconsTrash"
            enabled: Prefs.desktopIcons
            disabledReason: "Turn on Show icons first."
            description: "Drop files on it to throw them away; right-click it to empty it."

            M3Switch {
                checked: Prefs.desktopIconsTrash
                onToggled: (v) => {
                    return Prefs.desktopIconsTrash = v;
                }
            }

        }

        SettingRow {
            title: "Add an app"
            enabled: Prefs.desktopIcons
            disabledReason: "Turn on Show icons first."
            description: "Puts a launcher for it on the desktop. Launchers that arrive any other way ask before they run the first time."
            showDivider: false

            M3Button {
                text: "Choose\u2026"
                variant: "tonal"
                enabled: Prefs.desktopIcons
                onClicked: Prefs.appPickerRequested("::desktop")
            }

        }

    }

    SettingCard {
        title: "SCREENSHOTS"

        SettingRow {
            title: "After a capture"
            resetKey: "shotPreview"
            description: Prefs.shotPreview === "preview" ? "A card in the corner shows it, to open, mark up, drag into an app, find in its folder or delete. Recordings get one too." : (Prefs.shotPreview === "notify" ? "A notification says where it went. Screenshots are on the clipboard either way." : "Nothing shows. Screenshots are still copied to the clipboard.")

            M3Segmented {
                width: 300
                current: Prefs.shotPreview
                options: [{
                    "key": "preview",
                    "label": "Preview"
                }, {
                    "key": "notify",
                    "label": "Notification"
                }, {
                    "key": "none",
                    "label": "Nothing"
                }]
                onChosen: (key) => {
                    return Prefs.shotPreview = key;
                }
            }

        }

        SettingRow {
            title: "Preview stays for"
            resetKey: "shotPreviewSeconds"
            enabled: Prefs.shotPreview === "preview"
            description: "Resting the pointer on the card holds it for as long as you like."
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
