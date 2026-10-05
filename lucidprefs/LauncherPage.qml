import "../luciddocks"
import QtQuick
import Quickshell
import qs

// everything about the launcher. the list at the end is what it offers: stars put
// an app under Favourites, the eye takes it out for good
Column {
    id: page

    property string query: ""
    // "all" | "fav" | "hidden"
    property string view: "all"

    readonly property var sorted: Apps.list.slice().sort((a, b) => {
        return a.name.toLowerCase().localeCompare(b.name.toLowerCase());
    })
    readonly property int favCount: page.sorted.filter((a) => {
        return Apps.isFav(a);
    }).length
    readonly property int hiddenCount: page.sorted.filter((a) => {
        return Apps.isHidden(a);
    }).length
    readonly property var shown: {
        var q = page.query.trim().toLowerCase();
        return page.sorted.filter((a) => {
            if (page.view === "fav" && !Apps.isFav(a))
                return false;

            if (page.view === "hidden" && !Apps.isHidden(a))
                return false;

            return q === "" || a.name.toLowerCase().indexOf(q) !== -1 || a.base.toLowerCase().indexOf(q) !== -1;
        });
    }

    spacing: 26

    SettingCard {
        title: I18n.tr("LAYOUT")

        SettingRow {
            title: I18n.tr("Launcher width")
            resetKey: "launcherWidth"
            description: I18n.tr("How wide the application launcher opens - also the command, theme and clipboard lists. The wallpaper strip and power menu keep their own size.")
            stacked: true

            M3Slider {
                width: parent.width
                from: 420
                to: 1000
                stepSize: 10
                suffix: " px"
                value: Prefs.launcherWidth
                onMoved: (v) => {
                    return Prefs.launcherWidth = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Visible results")
            resetKey: "launcherMaxRows"
            description: I18n.tr("How many results the launcher shows before the list scrolls. It grows up to that many rows and shrinks when there are fewer.")
            stacked: true

            M3Slider {
                width: parent.width
                from: 3
                to: 12
                stepSize: 1
                suffix: I18n.tr(" rows")
                value: Prefs.launcherMaxRows
                onMoved: (v) => {
                    return Prefs.launcherMaxRows = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("App descriptions")
            resetKey: "launcherAppDescriptions"
            description: I18n.tr("A line under each application saying what it is, taken from its desktop entry.")
            showDivider: false

            M3Switch {
                checked: Prefs.launcherAppDescriptions
                onToggled: (v) => {
                    return Prefs.launcherAppDescriptions = v;
                }
            }

        }

    }

    SettingCard {
        title: I18n.tr("SEARCH")

        SettingRow {
            title: I18n.tr("Open windows in results")
            resetKey: "launcherWindows"
            description: I18n.tr("Searching also finds windows that are already open, by title or application. Return switches to the window instead of starting the app again.")

            M3Switch {
                checked: Prefs.launcherWindows
                onToggled: (v) => {
                    return Prefs.launcherWindows = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Web search")
            resetKey: "launcherWebSearch"
            description: I18n.tr("The last result offers to search the web for what you typed, and an address like example.org opens straight away.")

            M3Switch {
                checked: Prefs.launcherWebSearch
                onToggled: (v) => {
                    return Prefs.launcherWebSearch = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Search address")
            resetKey: "launcherSearchUrl"
            description: I18n.tr("Opened in the default browser, with %s replaced by the search. DuckDuckGo also understands bangs like !yt or !gh.")
            showDivider: false
            stacked: true
            opacity: Prefs.launcherWebSearch ? 1 : 0.5

            M3TextField {
                width: parent.width
                placeholder: I18n.tr("https://duckduckgo.com/?q=%s")
                text: Prefs.launcherSearchUrl
                onAccepted: (v) => {
                    return Prefs.launcherSearchUrl = v;
                }
            }

        }

    }

    SettingCard {
        title: I18n.tr("POWER")

        SettingRow {
            title: I18n.tr("Power buttons")
            resetKey: "launcherPowerChips"
            description: I18n.tr("Buttons next to the search field to lock, suspend, restart or shut down. The ones that end the session ask for a second click.")

            M3Switch {
                checked: Prefs.launcherPowerChips
                onToggled: (v) => {
                    return Prefs.launcherPowerChips = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Buttons to show")
            resetKey: "launcherPowerButtons"
            description: I18n.tr("Each one you pick takes a little room from the search field.")
            stacked: true
            enabled: Prefs.launcherPowerChips
            disabledReason: I18n.tr("Turn on power buttons to choose which ones appear.")

            M3Chips {
                width: parent.width
                multi: true
                enabled: Prefs.launcherPowerChips
                selectedKeys: Prefs.powerButtonList
                options: [{
                    "key": "lock",
                    "label": I18n.tr("Lock")
                }, {
                    "key": "logout",
                    "label": I18n.tr("Log out")
                }, {
                    "key": "suspend",
                    "label": I18n.tr("Suspend")
                }, {
                    "key": "hibernate",
                    "label": I18n.tr("Hibernate")
                }, {
                    "key": "reboot",
                    "label": I18n.tr("Restart")
                }, {
                    "key": "shutdown",
                    "label": I18n.tr("Shut down")
                }]
                onChosen: (k) => {
                    return Prefs.setPowerButton(k, Prefs.powerButtonList.indexOf(k) === -1);
                }
            }

        }

        SettingRow {
            title: I18n.tr("Power actions in search")
            resetKey: "launcherPowerSearch"
            description: I18n.tr("Typing at least three letters of lock, suspend, restart, shut down and the like offers them as results. Restart, shut down and log out still want a second Return.")
            showDivider: false

            M3Switch {
                checked: Prefs.launcherPowerSearch
                onToggled: (v) => {
                    return Prefs.launcherPowerSearch = v;
                }
            }

        }

    }

    SettingCard {
        title: I18n.tr("CLIPBOARD")

        SettingRow {
            title: I18n.tr("Clipboard history")
            description: I18n.tr("Keeps what you copy so the launcher can hand it back. Type > clip in the launcher, or pick Clipboard History from the command list. Needs cliphist installed.")
            enabled: Clip.available
            disabledReason: I18n.tr("cliphist is not installed. Install it and the history starts recording straight away.")

            M3Switch {
                checked: Prefs.clipboardEnabled && Clip.available
                enabled: Clip.available
                onToggled: (v) => {
                    return Prefs.clipboardEnabled = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Clear clipboard history")
            description: I18n.tr("Discards every entry cliphist has stored, including images.")
            enabled: Clip.available
            showDivider: false

            M3Button {
                text: I18n.tr("Clear history")
                variant: "text"
                destructive: true
                enabled: Clip.available
                onClicked: Prefs.askConfirm(I18n.tr("Clear clipboard history?"), I18n.tr("Every entry cliphist has stored is discarded, images included. This cannot be undone."), I18n.tr("Clear"), Prefs.clearClipboardToken)
            }

        }

    }

    SettingCard {
        title: I18n.tr("APPLICATIONS")
        subtitle: I18n.tr("Everything the launcher can open. A starred app is listed first, under Favourites, and wins a search against an equally good match. A hidden one never shows up, not even when you search for it. You can also right-click an app in the launcher to star it.")

        SettingRow {
            title: I18n.tr("Find an application")
            description: I18n.tr("%1 applications  ·  %2 starred  ·  %3 hidden", page.sorted.length, page.favCount, page.hiddenCount)
            stacked: true

            Column {
                width: parent.width
                spacing: 12

                M3TextField {
                    width: parent.width
                    placeholder: I18n.tr("Name or desktop entry")
                    commitOnBlur: false
                    onEdited: (v) => {
                        return page.query = v;
                    }
                }

                M3Chips {
                    width: parent.width
                    current: page.view
                    options: [{
                        "key": "all",
                        "label": I18n.tr("All")
                    }, {
                        "key": "fav",
                        "label": I18n.tr("Favourites")
                    }, {
                        "key": "hidden",
                        "label": I18n.tr("Hidden")
                    }]
                    onChosen: (k) => {
                        return page.view = k;
                    }
                }

            }

        }

    }

    Column {
        width: parent.width
        spacing: 2

        Repeater {
            model: page.shown

            AppRow {
            }

        }

        Text {
            width: parent.width
            visible: page.shown.length === 0
            text: {
                if (Apps.list.length === 0)
                    return I18n.tr("Looking for applications…");

                if (page.query.trim() !== "")
                    return I18n.tr("Nothing here matches “%1”.", page.query.trim());

                if (page.view === "fav")
                    return I18n.tr("No favourites yet. Star an application to list it first in the launcher.");

                if (page.view === "hidden")
                    return I18n.tr("Nothing is hidden. Every application shows up in the launcher.");

                return "";
            }
            color: Theme.subtext
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBodyMd
            wrapMode: Text.WordWrap
            leftPadding: 22
            rightPadding: 22
            topPadding: 8
        }

    }

    component AppRow: Item {
        id: row

        required property var modelData
        readonly property bool fav: Apps.isFav(row.modelData)
        readonly property bool hidden: Apps.isHidden(row.modelData)

        width: parent ? parent.width : 400
        height: 58

        Image {
            id: icon

            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            width: 32
            height: 32
            // resolved like the launcher's rows, so a changed icon theme shows here too
            source: row.modelData.iconName === "" ? "" : (IconTheme.generation >= 0 && IconTheme.pathFor(row.modelData.iconName) !== "" ? IconTheme.pathFor(row.modelData.iconName) : Quickshell.iconPath(row.modelData.iconName, true))
            sourceSize.width: 64
            sourceSize.height: 64
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            smooth: true
            mipmap: true
            opacity: row.hidden ? 0.4 : 1

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.durShort
                }

            }

        }

        Column {
            anchors.left: icon.right
            anchors.leftMargin: 14
            anchors.right: buttons.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                width: parent.width
                text: row.modelData.name
                color: row.hidden ? Theme.subtext : Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBodyLg
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: row.hidden ? I18n.tr("Hidden from the launcher") : (row.modelData.desc !== "" ? row.modelData.desc : row.modelData.base)
                color: row.hidden ? Theme.accentMuted : Theme.subtextDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontLabelSm
                elide: Text.ElideRight
            }

        }

        Row {
            id: buttons

            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            M3IconButton {
                anchors.verticalCenter: parent.verticalCenter
                size: 36
                iconSize: 19
                variant: row.fav ? "tonal" : "standard"
                iconPath: row.fav ? DockIcons.star : DockIcons.starOutline
                onClicked: Apps.setFav(row.modelData.base, !row.fav)
            }

            M3IconButton {
                anchors.verticalCenter: parent.verticalCenter
                size: 36
                iconSize: 19
                variant: row.hidden ? "tonal" : "standard"
                iconPath: row.hidden ? DockIcons.hidden : DockIcons.visible
                onClicked: Apps.setHidden(row.modelData.base, !row.hidden)
            }

        }

    }

}
