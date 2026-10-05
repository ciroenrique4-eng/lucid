import QtQuick
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs

// one bar module's card on the Bar page: whether it shows, where the rest of
// its settings live, and the options it has of its own. every module's rows
// are here; only the picked one's are visible
SettingCard {
    id: card

    property string moduleId: ""
    readonly property var mod: Prefs.barModuleById[card.moduleId] || null
    // what Reset puts back: its own options and its styles
    readonly property var options: card.mod ? (card.mod.options || []).concat(card.mod.style ? [card.mod.style] : [], card.mod.panelStyle ? [card.mod.panelStyle] : []) : []
    readonly property string groupName: {
        const g = Prefs.barLayoutGroups;
        if (g.left.indexOf(card.moduleId) !== -1)
            return "left";

        return g.center.indexOf(card.moduleId) !== -1 ? "centre" : "right";
    }
    readonly property var pageNames: ({
        "workspaces": I18n.tr("Workspaces"),
        "datetime": I18n.tr("Date & Time"),
        "notifications": I18n.tr("Notifications"),
        "dock": I18n.tr("Dock")
    })
    readonly property bool barOn: Prefs.barEnabled
    readonly property bool away: !!card.mod && !!card.mod.when && Prefs.barModulesAway.indexOf(card.moduleId) !== -1
    // the power module's actions: the picked ones in their order, then the rest
    readonly property var powerCatalogue: [{
        "id": "lock",
        "label": I18n.tr("Lock")
    }, {
        "id": "suspend",
        "label": I18n.tr("Suspend")
    }, {
        "id": "hibernate",
        "label": I18n.tr("Hibernate"),
        "note": I18n.tr("only where the machine can")
    }, {
        "id": "logout",
        "label": I18n.tr("Log out")
    }, {
        "id": "reboot",
        "label": I18n.tr("Restart")
    }, {
        "id": "shutdown",
        "label": I18n.tr("Shut down")
    }]
    readonly property var powerOn: String(Prefs.powerModuleActions || "").split(",").filter((id) => {
        return card.powerCatalogue.some((a) => {
            return a.id === id;
        });
    })
    readonly property var powerRows: card.powerOn.concat(card.powerCatalogue.map((a) => {
        return a.id;
    }).filter((id) => {
        return card.powerOn.indexOf(id) === -1;
    }))

    function setPower(list) {
        Prefs.powerModuleActions = list.join(",");
    }

    title: card.mod ? card.mod.name : ""
    subtitle: card.mod ? card.mod.desc : ""
    visible: card.mod !== null

    SettingRow {
        id: showRow

        title: I18n.tr("Show in the bar")
        description: I18n.tr("In the %1 group. Drag it in the arrangement above to move it.", card.groupName) + (card.away ? I18n.tr(" Not in the bar right now: it shows %1.", card.mod.when) : "")
        enabled: card.barOn
        disabledReason: I18n.tr("The bar is switched off, so this module has nothing to appear in.")
        showDivider: false

        M3Switch {
            enabled: showRow.enabled
            checked: card.mod ? Prefs[card.mod.key] === true : false
            onToggled: (v) => {
                if (card.mod)
                    Prefs[card.mod.key] = v;

            }
        }

    }

    // how it looks, closed in the bar and opened; the bar changes as you pick
    SettingRow {
        visible: !!card.mod && !!card.mod.styles
        title: I18n.tr("In the bar")
        description: I18n.tr("How it looks until you open it.")
        stacked: true
        showDivider: false

        Flow {
            width: parent.width
            spacing: 10

            Repeater {
                model: card.mod && card.mod.styles ? card.mod.styles : []

                BarStyleTile {
                    required property var modelData

                    moduleId: card.moduleId
                    prefKey: card.mod ? card.mod.style : ""
                    style: modelData
                }

            }

        }

    }

    SettingRow {
        visible: !!card.mod && !!card.mod.panelStyles
        title: I18n.tr("Opened")
        description: I18n.tr("How its panel looks.")
        stacked: true
        showDivider: false

        Flow {
            width: parent.width
            spacing: 10

            Repeater {
                model: card.mod && card.mod.panelStyles ? card.mod.panelStyles : []

                BarStyleTile {
                    required property var modelData

                    moduleId: card.moduleId
                    prefKey: card.mod ? card.mod.panelStyle : ""
                    style: modelData
                    panel: true
                }

            }

        }

    }

    // workspaces
    SettingRow {
        visible: card.moduleId === "workspaces"
        title: I18n.tr("How many")
        resetKey: "workspacesShown"
        description: I18n.tr("The ones it always shows. A workspace past them still shows up while it exists.")
        stacked: true
        showDivider: false

        M3Slider {
            width: parent.width
            from: 1
            to: 10
            stepSize: 1
            value: Prefs.workspacesShown
            onMoved: (v) => {
                return Prefs.workspacesShown = Math.round(v);
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "workspaces"
        title: I18n.tr("Wheel to switch")
        resetKey: "workspacesWheel"
        description: I18n.tr("The wheel over it moves to the next or the previous workspace.")
        showDivider: false

        M3Switch {
            checked: Prefs.workspacesWheel
            onToggled: (v) => {
                return Prefs.workspacesWheel = v;
            }
        }

    }

    // clock
    SettingRow {
        visible: card.moduleId === "clock"
        title: I18n.tr("Seconds")
        resetKey: "clockSeconds"
        description: I18n.tr("The seconds after the minutes.")
        showDivider: false

        M3Switch {
            checked: Prefs.clockSeconds
            onToggled: (v) => {
                return Prefs.clockSeconds = v;
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "clock"
        title: I18n.tr("Breathing colon")
        resetKey: "clockBlink"
        description: I18n.tr("The colon between the hours and the minutes fades in and out once a second.")
        showDivider: false

        M3Switch {
            checked: Prefs.clockBlink
            onToggled: (v) => {
                return Prefs.clockBlink = v;
            }
        }

    }

    SettingRow {
        id: clockDate

        visible: card.moduleId === "clock"
        title: I18n.tr("Date")
        resetKey: "clockDateFormat"
        description: I18n.tr("How the date reads beside or under the time.")
        enabled: Prefs.clockShowDate
        disabledReason: I18n.tr("The date is switched off on the Date & Time page.")
        stacked: true
        showDivider: false

        M3Segmented {
            width: Math.min(parent.width, 420)
            enabled: clockDate.enabled
            current: Prefs.clockDateFormat
            options: [{
                "key": "short",
                "label": Loc.now().toLocaleDateString(Qt.locale(), I18n.tr("ddd d"))
            }, {
                "key": "long",
                "label": Loc.now().toLocaleDateString(Qt.locale(), I18n.tr("ddd d MMM"))
            }, {
                "key": "numeric",
                "label": Loc.now().toLocaleDateString(Qt.locale(), Qt.locale().dateFormat(Locale.ShortFormat))
            }]
            onChosen: (key) => {
                return Prefs.clockDateFormat = key;
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "clock"
        title: I18n.tr("Temperature")
        resetKey: "clockWeather"
        description: I18n.tr("The temperature outside after the date, from the weather Lucid already reads. One line only: two lines have no room for it.")
        enabled: Prefs.clockStyle !== "stacked"
        disabledReason: I18n.tr("Two lines have no room for it.")
        showDivider: false

        M3Switch {
            checked: Prefs.clockWeather
            onToggled: (v) => {
                return Prefs.clockWeather = v;
            }
        }

    }

    // media
    SettingRow {
        visible: card.moduleId === "media"
        title: I18n.tr("Hide it when nothing plays")
        resetKey: "mediaHideIdle"
        description: I18n.tr("Off, it says Nothing playing; on, it leaves the bar until a player starts.")
        showDivider: false

        M3Switch {
            checked: Prefs.mediaHideIdle
            onToggled: (v) => {
                return Prefs.mediaHideIdle = v;
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "media"
        title: I18n.tr("Artist before the title")
        resetKey: "mediaArtist"
        description: I18n.tr("The panel always names both.")
        showDivider: false

        M3Switch {
            checked: Prefs.mediaArtist
            onToggled: (v) => {
                return Prefs.mediaArtist = v;
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "media"
        title: I18n.tr("Longest the track gets")
        resetKey: "mediaTitleWidth"
        description: I18n.tr("A longer one scrolls while it plays.")
        enabled: Prefs.mediaStyle !== "compact"
        disabledReason: I18n.tr("Compact shows no track.")
        stacked: true
        showDivider: false

        M3Slider {
            width: parent.width
            enabled: Prefs.mediaStyle !== "compact"
            from: 80
            to: 320
            stepSize: 10
            suffix: " px"
            value: Prefs.mediaTitleWidth
            onMoved: (v) => {
                return Prefs.mediaTitleWidth = Math.round(v);
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "media"
        title: I18n.tr("Play button")
        resetKey: "mediaPlayButton"
        description: I18n.tr("Off, a click opens the player and the panel has the buttons.")
        showDivider: false

        M3Switch {
            checked: Prefs.mediaPlayButton
            onToggled: (v) => {
                return Prefs.mediaPlayButton = v;
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "media"
        title: I18n.tr("Wheel for the volume")
        resetKey: "mediaWheelVolume"
        description: I18n.tr("The wheel over it turns the player's own volume up or down.")
        showDivider: false

        M3Switch {
            checked: Prefs.mediaWheelVolume
            onToggled: (v) => {
                return Prefs.mediaWheelVolume = v;
            }
        }

    }

    // notifications
    SettingRow {
        visible: card.moduleId === "notifications"
        title: I18n.tr("Hide it while nothing is waiting")
        resetKey: "notificationsHideEmpty"
        description: I18n.tr("It comes back with the first notification, and stays while Do not disturb is on so you can see it is.")
        showDivider: false

        M3Switch {
            checked: Prefs.notificationsHideEmpty
            onToggled: (v) => {
                return Prefs.notificationsHideEmpty = v;
            }
        }

    }

    // system
    SettingRow {
        visible: card.moduleId === "system"
        title: I18n.tr("Indicators")
        resetKey: "systemIndicators"
        description: I18n.tr("The ones it shows before you open it. The panel has them all either way. At least one stays.")
        stacked: true
        showDivider: false

        M3Chips {
            width: parent.width
            multi: true
            selectedKeys: String(Prefs.systemIndicators).split(",").filter((k) => {
                return k !== "";
            })
            options: [{
                "key": "wifi",
                "label": I18n.tr("Network")
            }, {
                "key": "bluetooth",
                "label": I18n.tr("Bluetooth")
            }, {
                "key": "volume",
                "label": I18n.tr("Volume")
            }, {
                "key": "mic",
                "label": I18n.tr("Microphone")
            }, {
                "key": "battery",
                "label": I18n.tr("Battery")
            }]
            onChosen: (key) => {
                const list = String(Prefs.systemIndicators).split(",").filter((k) => {
                    return k !== "";
                });
                const at = list.indexOf(key);
                if (at === -1)
                    list.push(key);
                else if (list.length > 1)
                    list.splice(at, 1);
                Prefs.systemIndicators = ["wifi", "bluetooth", "volume", "mic", "battery"].filter((k) => {
                    return list.indexOf(k) !== -1;
                }).join(",");
            }
        }

    }

    // system tray
    SettingRow {
        visible: card.moduleId === "tray"
        title: I18n.tr("Icon colours")
        resetKey: "trayIconColor"
        description: I18n.tr("As each app draws them, or in the shell's colours: grey from the text, or one of the palette's colours. Their light and shade stay either way.")
        stacked: true
        showDivider: false

        M3Segmented {
            width: Math.min(parent.width, 600)
            current: Prefs.trayIconColor
            options: [{
                "key": "original",
                "label": I18n.tr("Original")
            }, {
                "key": "grey",
                "label": I18n.tr("Grey")
            }, {
                "key": "secondary",
                "label": I18n.tr("Secondary")
            }, {
                "key": "tertiary",
                "label": I18n.tr("Tertiary")
            }, {
                "key": "accent",
                "label": I18n.tr("Accent")
            }]
            onChosen: (key) => {
                return Prefs.trayIconColor = key;
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "tray"
        title: I18n.tr("Apps in the tray")
        resetKey: "trayHidden"
        description: SystemTray.items.values.length > 0 ? I18n.tr("The ones running now. One switched off stays out of the bar and the panel until you switch it back on.") : I18n.tr("Nothing is in the tray right now. Apps show up here while they run.")
        stacked: true
        showDivider: false

        Column {
            width: parent.width
            spacing: 6

            Repeater {
                model: SystemTray.items.values

                Rectangle {
                    id: trayRow

                    required property var modelData
                    readonly property bool shownInBar: String(Prefs.trayHidden).split(",").indexOf(trayRow.modelData.id) === -1

                    width: parent.width
                    height: 48
                    radius: Theme.radiusMd
                    color: Theme.bgSunken

                    IconImage {
                        id: trayRowIcon

                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20
                        height: 20
                        opacity: trayRow.shownInBar ? 1 : 0.4
                        source: {
                            const raw = trayRow.modelData.icon || "";
                            const q = raw.indexOf("?path=");
                            if (q === -1)
                                return raw;

                            const name = raw.substring(0, q);
                            return "file://" + raw.substring(q + 6) + "/" + name.substring(name.lastIndexOf("/") + 1);
                        }
                        asynchronous: true
                    }

                    Text {
                        anchors.left: trayRowIcon.right
                        anchors.leftMargin: 12
                        anchors.right: trayRowSwitch.left
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: trayRow.modelData.title || trayRow.modelData.tooltipTitle || trayRow.modelData.id
                        color: trayRow.shownInBar ? Theme.text : Theme.subtextDim
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontBodyLg
                        elide: Text.ElideRight
                    }

                    M3Switch {
                        id: trayRowSwitch

                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        checked: trayRow.shownInBar
                        onToggled: (v) => {
                            const list = String(Prefs.trayHidden).split(",").filter((id) => {
                                return id !== "" && id !== trayRow.modelData.id;
                            });
                            if (!v)
                                list.push(trayRow.modelData.id);

                            Prefs.trayHidden = list.join(",");
                        }
                    }

                }

            }

        }

    }

    // privacy
    SettingRow {
        visible: card.moduleId === "privacy"
        title: I18n.tr("Watch")
        resetKey: "privacyWatch"
        description: I18n.tr("What makes the module show up. At least one stays on.")
        stacked: true
        showDivider: false

        M3Chips {
            width: parent.width
            multi: true
            selectedKeys: String(Prefs.privacyWatch).split(",").filter((k) => {
                return k !== "";
            })
            options: [{
                "key": "mic",
                "label": I18n.tr("Microphone")
            }, {
                "key": "camera",
                "label": I18n.tr("Camera")
            }, {
                "key": "screen",
                "label": I18n.tr("Screen")
            }]
            onChosen: (key) => {
                const list = String(Prefs.privacyWatch).split(",").filter((k) => {
                    return k !== "";
                });
                const at = list.indexOf(key);
                if (at === -1)
                    list.push(key);
                else if (list.length > 1)
                    list.splice(at, 1);
                Prefs.privacyWatch = ["mic", "camera", "screen"].filter((k) => {
                    return list.indexOf(k) !== -1;
                }).join(",");
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "privacy"
        title: I18n.tr("Tell me when something starts")
        resetKey: "privacyToast"
        description: I18n.tr("A toast names the app the moment it starts using the microphone, the camera or the screen. Lucid's own recording, which you start yourself, is left out.")
        showDivider: false

        M3Switch {
            checked: Prefs.privacyToast
            onToggled: (v) => {
                return Prefs.privacyToast = v;
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "privacy"
        title: I18n.tr("Keep its place in the bar")
        resetKey: "privacyAlwaysShown"
        description: I18n.tr("A quiet shield stays when nothing is in use, so the modules beside it never shift.")
        showDivider: false

        M3Switch {
            checked: Prefs.privacyAlwaysShown
            onToggled: (v) => {
                return Prefs.privacyAlwaysShown = v;
            }
        }

    }

    // power
    SettingRow {
        visible: card.moduleId === "power"
        title: I18n.tr("Actions")
        resetKey: "powerModuleActions"
        description: I18n.tr("The ones switched on show in the panel, top to bottom in this order. At least one stays.")
        stacked: true
        showDivider: false

        Column {
            width: parent.width
            spacing: 6

            Repeater {
                model: card.powerRows

                Rectangle {
                    id: powerItem

                    required property string modelData
                    required property int index
                    readonly property var action: card.powerCatalogue.find((a) => {
                        return a.id === powerItem.modelData;
                    })
                    readonly property int at: card.powerOn.indexOf(powerItem.modelData)
                    readonly property bool on: powerItem.at !== -1

                    width: parent.width
                    height: 52
                    radius: Theme.radiusMd
                    color: Theme.bgSunken

                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.right: powerTools.left
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 1

                        Text {
                            width: parent.width
                            text: powerItem.action ? powerItem.action.label : powerItem.modelData
                            color: powerItem.on ? Theme.text : Theme.subtextDim
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontBodyLg
                            elide: Text.ElideRight
                        }

                        Text {
                            visible: !!(powerItem.action && powerItem.action.note)
                            width: parent.width
                            text: powerItem.action && powerItem.action.note ? powerItem.action.note : ""
                            color: Theme.subtextDim
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontLabelSm
                        }

                    }

                    Row {
                        id: powerTools

                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        M3IconButton {
                            anchors.verticalCenter: parent.verticalCenter
                            size: 34
                            enabled: powerItem.on && powerItem.at > 0
                            iconPath: "M11 20V7.825l-5.6 5.6L4 12l8-8l8 8l-1.4 1.425l-5.6-5.6V20h-2Z"
                            onClicked: {
                                const l = card.powerOn.slice();
                                l.splice(powerItem.at, 1);
                                l.splice(powerItem.at - 1, 0, powerItem.modelData);
                                card.setPower(l);
                            }
                        }

                        M3IconButton {
                            anchors.verticalCenter: parent.verticalCenter
                            size: 34
                            enabled: powerItem.on && powerItem.at < card.powerOn.length - 1
                            iconPath: "M11 4v12.175l-5.6-5.6L4 12l8 8l8-8l-1.4-1.425l-5.6 5.6V4h-2Z"
                            onClicked: {
                                const l = card.powerOn.slice();
                                l.splice(powerItem.at, 1);
                                l.splice(powerItem.at + 1, 0, powerItem.modelData);
                                card.setPower(l);
                            }
                        }

                        M3Switch {
                            anchors.verticalCenter: parent.verticalCenter
                            enabled: !powerItem.on || card.powerOn.length > 1
                            checked: powerItem.on
                            onToggled: (v) => {
                                const l = card.powerOn.filter((id) => {
                                    return id !== powerItem.modelData;
                                });
                                if (v)
                                    l.push(powerItem.modelData);

                                card.setPower(l);
                            }
                        }

                    }

                }

            }

        }

    }

    SettingRow {
        visible: card.moduleId === "power"
        title: I18n.tr("Ask twice")
        resetKey: "powerModuleConfirm"
        description: I18n.tr("Log out, restart and shut down wait for a second click within three seconds, so a stray one does nothing.")
        showDivider: false

        M3Switch {
            checked: Prefs.powerModuleConfirm
            onToggled: (v) => {
                return Prefs.powerModuleConfirm = v;
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "power"
        title: I18n.tr("Show how long it has been up")
        resetKey: "powerModuleUptime"
        description: I18n.tr("The time since the machine started, at the top of the panel.")
        showDivider: false

        M3Switch {
            checked: Prefs.powerModuleUptime
            onToggled: (v) => {
                return Prefs.powerModuleUptime = v;
            }
        }

    }

    // system
    SettingRow {
        visible: card.moduleId === "system"
        title: I18n.tr("Your picture")
        resetKey: "systemPanelAvatar"
        description: I18n.tr("Your account picture and name at the top of the control centre; a click opens your account.")
        showDivider: false

        M3Switch {
            checked: Prefs.systemPanelAvatar
            onToggled: (v) => {
                return Prefs.systemPanelAvatar = v;
            }
        }

    }

    // active window
    SettingRow {
        id: windowText

        visible: card.moduleId === "window"
        title: I18n.tr("Shows")
        resetKey: "windowModuleText"
        description: I18n.tr("What the pill reads in the bar, or only the app's icon. The panel always has both.")
        stacked: true
        showDivider: false

        M3Segmented {
            width: Math.min(parent.width, 480)
            current: Prefs.windowModuleText
            options: [{
                "key": "title",
                "label": I18n.tr("Title")
            }, {
                "key": "app",
                "label": I18n.tr("App name")
            }, {
                "key": "both",
                "label": I18n.tr("Both")
            }, {
                "key": "icon",
                "label": I18n.tr("Icon only")
            }]
            onChosen: (key) => {
                return Prefs.windowModuleText = key;
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "window"
        title: I18n.tr("Longest it gets")
        resetKey: "windowModuleWidth"
        description: I18n.tr("A longer title is cut short with an ellipsis.")
        enabled: Prefs.windowModuleText !== "icon"
        disabledReason: I18n.tr("It shows only the icon.")
        stacked: true
        showDivider: false

        M3Slider {
            width: parent.width
            enabled: Prefs.windowModuleText !== "icon"
            from: 120
            to: 480
            stepSize: 10
            suffix: " px"
            value: Prefs.windowModuleWidth
            onMoved: (v) => {
                return Prefs.windowModuleWidth = Math.round(v);
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "window"
        title: I18n.tr("Scroll to switch windows")
        resetKey: "windowModuleScroll"
        description: I18n.tr("The wheel over the pill moves the focus through the windows on the workspace.")
        showDivider: false

        M3Switch {
            checked: Prefs.windowModuleScroll
            onToggled: (v) => {
                return Prefs.windowModuleScroll = v;
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "window"
        title: I18n.tr("Middle click closes it")
        resetKey: "windowModuleMiddleClose"
        description: I18n.tr("Like closing a browser tab: the window in focus closes on a middle click on the pill.")
        showDivider: false

        M3Switch {
            checked: Prefs.windowModuleMiddleClose
            onToggled: (v) => {
                return Prefs.windowModuleMiddleClose = v;
            }
        }

    }

    // apps
    SettingRow {
        visible: card.moduleId === "apps"
        title: I18n.tr("Pinned apps")
        resetKey: "appsModulePinned"
        description: I18n.tr("The dock's pinned apps stay in place even with no window open, for a click to start them. Off, only apps with a window show.")
        showDivider: false

        M3Switch {
            checked: Prefs.appsModulePinned
            onToggled: (v) => {
                return Prefs.appsModulePinned = v;
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "apps"
        title: I18n.tr("Windows from")
        resetKey: "appsModuleScope"
        description: I18n.tr("Which windows count: every workspace's, or only those on the one in view.")
        stacked: true
        showDivider: false

        M3Segmented {
            width: Math.min(parent.width, 360)
            current: Prefs.appsModuleScope
            options: [{
                "key": "all",
                "label": I18n.tr("All workspaces")
            }, {
                "key": "workspace",
                "label": I18n.tr("This workspace")
            }]
            onChosen: (key) => {
                return Prefs.appsModuleScope = key;
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "apps"
        title: I18n.tr("Clicking an app with several windows")
        resetKey: "appsModuleClick"
        description: I18n.tr("Lists them to pick one, or moves the focus to the next one each time. An app with one window always goes straight to it.")
        stacked: true
        showDivider: false

        M3Segmented {
            width: Math.min(parent.width, 360)
            current: Prefs.appsModuleClick
            options: [{
                "key": "list",
                "label": I18n.tr("List them")
            }, {
                "key": "cycle",
                "label": I18n.tr("Next one")
            }]
            onChosen: (key) => {
                return Prefs.appsModuleClick = key;
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "apps"
        title: I18n.tr("Scroll through an app's windows")
        resetKey: "appsModuleWheel"
        description: I18n.tr("The wheel over an app's icon moves the focus through its windows.")
        showDivider: false

        M3Switch {
            checked: Prefs.appsModuleWheel
            onToggled: (v) => {
                return Prefs.appsModuleWheel = v;
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "apps"
        title: I18n.tr("Notification counts")
        resetKey: "appsModuleBadges"
        description: I18n.tr("A small count on an app's icon while it has notifications waiting.")
        showDivider: false

        M3Switch {
            checked: Prefs.appsModuleBadges
            onToggled: (v) => {
                return Prefs.appsModuleBadges = v;
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "apps"
        title: I18n.tr("Longest a name gets")
        resetKey: "appsModuleNameWidth"
        description: I18n.tr("In the Names look, a longer name is cut short with an ellipsis.")
        enabled: Prefs.appsModuleStyle === "names"
        disabledReason: I18n.tr("Only the Names look shows the names.")
        stacked: true
        showDivider: false

        M3Slider {
            width: parent.width
            enabled: Prefs.appsModuleStyle === "names"
            from: 60
            to: 240
            stepSize: 10
            suffix: " px"
            value: Prefs.appsModuleNameWidth
            onMoved: (v) => {
                return Prefs.appsModuleNameWidth = Math.round(v);
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "apps"
        title: I18n.tr("Icon size")
        resetKey: "appsModuleIconSize"
        description: I18n.tr("The size of each icon, as the dock's. The bar's height caps it.")
        stacked: true
        showDivider: false

        M3Slider {
            width: parent.width
            from: 16
            to: 40
            stepSize: 1
            suffix: " px"
            value: Prefs.appsModuleIconSize
            onMoved: (v) => {
                return Prefs.appsModuleIconSize = v;
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "apps"
        title: I18n.tr("Icon spacing")
        resetKey: "appsModuleSpacing"
        description: I18n.tr("The gap between neighbouring icons.")
        stacked: true
        showDivider: false

        M3Slider {
            width: parent.width
            from: 0
            to: 20
            stepSize: 1
            suffix: " px"
            value: Prefs.appsModuleSpacing
            onMoved: (v) => {
                return Prefs.appsModuleSpacing = v;
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "apps"
        title: I18n.tr("Show running applications")
        resetKey: "appsModuleShowRunning"
        description: I18n.tr("Apps with a window open show beside the pinned ones. Off, only the pinned apps show (with their windows marked).")
        showDivider: false

        M3Switch {
            checked: Prefs.appsModuleShowRunning
            onToggled: (v) => {
                return Prefs.appsModuleShowRunning = v;
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "apps"
        title: I18n.tr("Icon tiles")
        resetKey: "appsModuleIconTiles"
        description: I18n.tr("A tile behind each icon, as the dock's.")
        showDivider: false

        M3Switch {
            checked: Prefs.appsModuleIconTiles
            onToggled: (v) => {
                return Prefs.appsModuleIconTiles = v;
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "apps"
        title: I18n.tr("Running indicator")
        resetKey: "appsModuleIndicators"
        description: I18n.tr("The marks under an app that has windows.")
        showDivider: false

        M3Switch {
            checked: Prefs.appsModuleIndicators
            onToggled: (v) => {
                return Prefs.appsModuleIndicators = v;
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "apps"
        title: I18n.tr("Tooltips")
        resetKey: "appsModuleTooltips"
        description: I18n.tr("Resting on an icon opens the preview of its windows.")
        showDivider: false

        M3Switch {
            checked: Prefs.appsModuleTooltips
            onToggled: (v) => {
                return Prefs.appsModuleTooltips = v;
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "apps"
        title: I18n.tr("Hover strength")
        resetKey: "appsModuleHoverEffect"
        description: I18n.tr("How far an icon swells under the pointer. At 0 the icons stay put; hovering still highlights them.")
        stacked: true
        showDivider: false

        M3Slider {
            width: parent.width
            from: 0
            to: 2
            stepSize: 0.1
            suffix: "x"
            value: Prefs.appsModuleHoverEffect
            onMoved: (v) => {
                return Prefs.appsModuleHoverEffect = Math.round(v * 10) / 10;
            }
        }

    }

    SettingRow {
        visible: card.moduleId === "apps"
        title: I18n.tr("Magnify on hover")
        resetKey: "appsModuleMagnify"
        description: I18n.tr("Icons swell as the pointer passes over them, and their neighbours follow in a ripple.")
        showDivider: false

        M3Switch {
            checked: Prefs.appsModuleMagnify
            onToggled: (v) => {
                return Prefs.appsModuleMagnify = v;
            }
        }

    }

    SettingRow {
        id: moreRow

        visible: !!card.mod && !!card.mod.more
        title: I18n.tr("More settings")
        description: card.mod && card.mod.more ? card.mod.more : ""
        showDivider: false

        M3Button {
            visible: !!card.mod && !!card.mod.page
            text: card.mod && card.pageNames[card.mod.page] ? I18n.tr("Open %1", card.pageNames[card.mod.page]) : I18n.tr("Open")
            variant: "tonal"
            onClicked: Prefs.settingsRequested(card.mod.page)
        }

    }

    SettingRow {
        visible: card.options.length > 0
        title: I18n.tr("Reset this module")
        description: I18n.tr("Its options above go back to how they ship. Whether it shows and where it sits stay as they are.")
        showDivider: false

        M3Button {
            text: I18n.tr("Reset")
            variant: "text"
            destructive: true
            enabled: card.options.some((k) => {
                return Prefs.isModified(k);
            })
            onClicked: Prefs.resetKeys(card.options)
        }

    }

}
