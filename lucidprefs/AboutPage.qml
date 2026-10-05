import QtQuick
import Quickshell
import qs

Column {
    id: page

    readonly property string version: Updates.currentLabel
    readonly property bool beta: true
    readonly property var components: [{
        "name": "lucidbar",
        "desc": I18n.tr("Status bar - workspaces, media, tray, clock, bluetooth, network, notifications, system")
    }, {
        "name": "luciddocks",
        "desc": I18n.tr("Dock, application launcher, wallpaper and theme strips, power menu")
    }, {
        "name": "lucidprefs",
        "desc": I18n.tr("This settings app")
    }, {
        "name": "lucidlock",
        "desc": I18n.tr("Lock screen")
    }, {
        "name": "lucidosd",
        "desc": I18n.tr("Volume and brightness on-screen display")
    }, {
        "name": "lucidshot",
        "desc": I18n.tr("Screenshot overlay and region capture")
    }, {
        "name": "lucidmoji",
        "desc": I18n.tr("Emoji and GIF picker")
    }]
    readonly property var commands: [{
        "cmd": "qs ipc call settings open",
        "desc": I18n.tr("Open this app - also >settings in the launcher")
    }, {
        "cmd": "qs ipc call settings toggle",
        "desc": I18n.tr("Open or close it")
    }, {
        "cmd": "qs ipc call settings bar",
        "desc": I18n.tr("Open straight to a page - also general, dock")
    }, {
        "cmd": "qs ipc call -- settings show about",
        "desc": I18n.tr("Any page by name. The separator before the target is required whenever a function takes an argument.")
    }, {
        "cmd": "qs ipc call launcher toggle",
        "desc": I18n.tr("Application launcher")
    }, {
        "cmd": "qs ipc call launcher wallpaper",
        "desc": I18n.tr("Wallpaper strip")
    }, {
        "cmd": "qs ipc call launcher theme",
        "desc": I18n.tr("Theme strip")
    }, {
        "cmd": "qs ipc call launcher power",
        "desc": I18n.tr("Power menu")
    }]

    spacing: 26

    Rectangle {
        width: parent.width
        height: 164
        radius: Theme.radiusXl
        color: Theme.bgTile

        Row {
            anchors.centerIn: parent
            spacing: 22

            LucidaMark {
                width: 68
                height: 68
                strokeWidth: 2.6
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Row {
                    spacing: 10

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: I18n.tr("CirOShell")
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fs(30)
                        font.bold: true
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: page.beta
                        width: betaLabel.implicitWidth + 16
                        height: 22
                        radius: Theme.rad(11)
                        color: "transparent"
                        border.width: 1
                        border.color: Theme.accent

                        Text {
                            id: betaLabel

                            anchors.centerIn: parent
                            text: I18n.tr("BETA")
                            color: Theme.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fs(10)
                            font.bold: true
                            font.letterSpacing: 1
                        }

                    }

                }

                Row {
                    spacing: 8

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: page.version
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontBody
                        font.bold: true
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "·"
                        color: Theme.subtextDim
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontBody
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: I18n.tr("Built on Lucid by Sn3akyy1.")
                        color: Theme.subtext
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontBody
                    }

                }

            }

        }

    }

    SettingCard {
        title: I18n.tr("UPDATES")

        SettingRow {
            title: Updates.available ? I18n.tr("CirOShell v%1 is out", Updates.latest) : I18n.tr("Version %1", Updates.currentLabel)
            description: Updates.status

            Row {
                spacing: 8

                M3Button {
                    text: Updates.busy ? I18n.tr("Checking…") : I18n.tr("Check now")
                    variant: "tonal"
                    enabled: !Updates.busy && Updates.current !== ""
                    onClicked: Updates.check()
                }

                M3Button {
                    text: I18n.tr("What's new")
                    variant: Updates.available ? "filled" : "outlined"
                    onClicked: Updates.openLatest()
                }

            }

        }

        SettingRow {
            title: Updates.upstreamAhead ? I18n.tr("Lucid v%1 is out upstream", Updates.upstreamLatest) : I18n.tr("Based on Lucid v%1", Updates.base)
            description: (Updates.upstreamAhead ? I18n.tr("Upstream moved ahead of what this is built on. It gets pulled into CirOShell, nothing to do here. ") : "") + I18n.tr("CirOShell is a fork of Lucid by Sn3akyy1, released under the MIT licence.")

            M3Button {
                text: I18n.tr("Lucid releases")
                variant: "outlined"
                onClicked: Updates.openUpstream()
            }

        }

        SettingRow {
            title: I18n.tr("Check for updates")
            resetKey: "updateCheck"
            description: I18n.tr("Once a day CirOShell asks GitHub for the newest release, and tells you once when there is one. The request carries nothing about you or this machine.")
            showDivider: false

            M3Switch {
                checked: Prefs.updateCheck
                onToggled: (v) => {
                    return Prefs.updateCheck = v;
                }
            }

        }

    }

    SettingCard {
        title: I18n.tr("COMMAND LINE")

        Repeater {
            model: page.commands

            SettingRow {
                id: cmdRow

                required property var modelData
                required property int index

                title: cmdRow.modelData.cmd
                monoTitle: true
                description: cmdRow.modelData.desc
                showDivider: cmdRow.index < page.commands.length - 1
            }

        }

    }

    SettingCard {
        title: I18n.tr("COMPONENTS")

        Repeater {
            model: page.components

            SettingRow {
                id: compRow

                required property var modelData
                required property int index

                title: compRow.modelData.name
                description: compRow.modelData.desc
                showDivider: compRow.index < page.components.length - 1
            }

        }

    }

    SettingCard {
        title: I18n.tr("CONFIGURATION")

        SettingRow {
            title: I18n.tr("Settings file")
            description: I18n.tr("~/.config/quickshell/lucidprefs/prefs.json")
            showDivider: false

            M3Button {
                text: I18n.tr("Open folder")
                onClicked: Quickshell.execDetached(["sh", "-c", "xdg-open ~/.config/quickshell/lucidprefs"])
            }

        }

    }

}
