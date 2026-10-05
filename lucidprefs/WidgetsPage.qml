import QtQuick
import Quickshell
import Quickshell.Io
import qs

Column {
    id: page

    property string filter: "all"
    // the preset previews are drawn over this
    property string wallpaper: ""

    readonly property var shownTypes: page.filter === "all" ? Widgets.catalogue : Widgets.catalogue.filter((t) => {
        return t.id === page.filter;
    })

    // as many columns as fit, every tile the same width
    function tileWidth(grid) {
        return Math.max(0, Math.floor((grid.width - grid.columnSpacing * (grid.columns - 1)) / grid.columns));
    }

    function columnsFor(width) {
        return Math.max(2, Math.floor((width + 10) / 222));
    }

    spacing: 26
    // the header switch turns the whole layer off, so the page has nothing left to set
    enabled: Prefs.widgetsEnabled
    opacity: Prefs.widgetsEnabled ? 1 : 0.38

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.durShort
        }

    }

    FileView {
        path: Quickshell.env("HOME") + "/.cache/current_wallpaper"
        blockLoading: true
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: page.wallpaper = text().trim()
    }

    WidgetsMap {
        width: parent.width
        wallpaper: page.wallpaper
    }

    SettingCard {
        title: I18n.tr("PRESETS")

        SettingRow {
            title: I18n.tr("Start from a layout")
            description: I18n.tr("Each one places a set of widgets and spaces them out for you. Cards you already have slide over to their new spot and keep whatever you wrote in them.")
            showDivider: false
            stacked: true

            Grid {
                id: builtIn

                width: parent.width
                columns: page.columnsFor(builtIn.width)
                columnSpacing: 10
                rowSpacing: 10

                Repeater {
                    model: Widgets.presets

                    PresetTile {
                        required property var modelData

                        width: page.tileWidth(builtIn)
                        title: modelData.name
                        blurb: modelData.blurb
                        cards: Widgets.presetLayout(modelData.id)
                        wallpaper: page.wallpaper
                        selected: Widgets.presetId === modelData.id
                        onChosen: Widgets.applyPreset(modelData.id)
                    }

                }

            }

        }

        SettingRow {
            title: I18n.tr("Your presets")
            description: Widgets.userPresets.length === 0 ? I18n.tr("Arrange the desktop the way you like it, then save it here and switch back to it whenever you want.") : I18n.tr("Saving again under a name you already used updates that preset.")
            showDivider: false
            stacked: true

            Grid {
                id: saved

                width: parent.width
                columns: page.columnsFor(saved.width)
                columnSpacing: 10
                rowSpacing: 10

                PresetSaveTile {
                    width: page.tileWidth(saved)
                    wallpaper: page.wallpaper
                }

                // an arrangement nobody saved, set aside when a preset replaced it
                PresetTile {
                    width: page.tileWidth(saved)
                    visible: Widgets.canRestore
                    title: I18n.tr("Last layout")
                    blurb: I18n.tr("Not saved. What was on your desktop before this preset.")
                    cards: Widgets.lastLayout
                    wallpaper: page.wallpaper
                    mark: "refresh"
                    onChosen: Widgets.restoreLast()
                }

                Repeater {
                    model: Widgets.userPresets

                    PresetTile {
                        required property var modelData

                        width: page.tileWidth(saved)
                        title: modelData.name
                        blurb: I18n.tr("Saved %1", new Date(modelData.saved || 0).toLocaleDateString(I18n.locale, I18n.tr("d MMMM yyyy")))
                        cards: Widgets.presetLayout(modelData.id)
                        wallpaper: page.wallpaper
                        selected: Widgets.presetId === modelData.id
                        removable: true
                        onChosen: Widgets.applyPreset(modelData.id)
                        onRemoveRequested: Prefs.askConfirm(I18n.tr("Delete “%1”?", modelData.name), I18n.tr("The preset goes. The widgets on your desktop stay exactly where they are."), I18n.tr("Delete"), "widget-preset:" + modelData.id)
                    }

                }

            }

        }

    }

    SettingCard {
        title: I18n.tr("ADD A WIDGET")

        SettingRow {
            title: I18n.tr("Pick a look")
            description: Widgets.full ? I18n.tr("The desktop holds %1 widgets, and it is full. Take one off below to make room.", Widgets.capacity) : I18n.tr("Every tile below is the real widget, drawn live. Click one and it lands on the desktop, where you can drag it anywhere and pin it in place.")
            showDivider: false
            stacked: true

            Flow {
                width: parent.width
                spacing: 6

                Repeater {
                    model: [{
                        "id": "all",
                        "name": I18n.tr("All")
                    }].concat(Widgets.catalogue.map((t) => {
                        return ({
                            "id": t.id,
                            "name": t.name
                        });
                    }))

                    Rectangle {
                        id: chip

                        required property var modelData

                        readonly property bool selected: page.filter === chip.modelData.id

                        width: chipLabel.implicitWidth + 26
                        height: 32
                        radius: Theme.rad(16)
                        color: chip.selected ? Theme.accentContainer : (chipArea.containsMouse ? Theme.bgHover : Theme.bgSunken)

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.durShort
                            }

                        }

                        Text {
                            id: chipLabel

                            anchors.centerIn: parent
                            text: chip.modelData.name
                            color: chip.selected ? Theme.fgAccentContainer : Theme.subtext
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontLabel
                            font.bold: chip.selected
                        }

                        MouseArea {
                            id: chipArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: page.filter = chip.modelData.id
                        }

                    }

                }

            }

        }

    }

    Repeater {
        model: page.shownTypes

        SettingCard {
            id: group

            required property var modelData

            title: group.modelData.name.toUpperCase()

            SettingRow {
                title: group.modelData.blurb
                description: I18n.trn("%1 style", "%1 styles", group.modelData.variants.length) + (Widgets.countOfType(group.modelData.id) > 0 ? I18n.tr(" · %1 on the desktop", Widgets.countOfType(group.modelData.id)) : "")
                showDivider: false
                stacked: true

                Flow {
                    width: parent.width
                    spacing: 10

                    Repeater {
                        model: group.modelData.variants

                        WidgetTile {
                            required property var modelData

                            wtype: group.modelData.id
                            variant: modelData
                        }

                    }

                }

            }

        }

    }

    SettingCard {
        title: I18n.tr("BEHAVIOUR")

        SettingRow {
            title: I18n.tr("Snap while dragging")
            resetKey: "widgetSnap"
            description: I18n.tr("Widgets catch on the screen's edges and centre lines, and line up with each other, so a hand-placed arrangement still looks deliberate.")

            M3Switch {
                checked: Prefs.widgetSnap
                onToggled: (v) => {
                    return Prefs.widgetSnap = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Pin everything")
            resetKey: "widgetLockAll"
            description: I18n.tr("Locks every widget where it stands, including the ones that are not individually pinned. Useful once the layout is settled.")

            M3Switch {
                checked: Prefs.widgetLockAll
                onToggled: (v) => {
                    return Prefs.widgetLockAll = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Keep above windows")
            resetKey: "widgetOnTop"
            description: I18n.tr("Off, widgets live on the desktop and windows cover them. On, they float over everything - handy for a clock or a timer you always want in sight.")

            M3Switch {
                checked: Prefs.widgetOnTop
                onToggled: (v) => {
                    return Prefs.widgetOnTop = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Hide for fullscreen windows")
            resetKey: "widgetHideFullscreen"
            description: I18n.tr("Widgets step out of the way while something is running fullscreen, and come back when it is not.")
            showDivider: false

            M3Switch {
                checked: Prefs.widgetHideFullscreen
                onToggled: (v) => {
                    return Prefs.widgetHideFullscreen = v;
                }
            }

        }

    }

}
