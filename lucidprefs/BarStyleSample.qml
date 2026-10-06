import QtQuick
import QtQuick.Shapes
import qs
import "../lucidbar" as Bar
import "../lucidbar/ClockWords.js" as Words

// a small stand-in for a bar module in one of its styles, drawn with the
// bar's own fonts and colours, for the style tiles on the module's card.
// a module's samples are keyed "<id>/<style>", its panel's "<id>/panel/<style>"
Item {
    id: sample

    property string moduleId: ""
    property string styleKey: ""
    property bool panel: false

    readonly property string sampleKey: sample.moduleId + "/" + (sample.panel ? "panel/" : "") + sample.styleKey
    readonly property var samples: ({
        "clock/inline": clockInline,
        "clock/stacked": clockStacked,
        "clock/accent": clockAccent,
        "clock/analog": clockAnalog,
        "clock/words": clockWords,
        "clock/split": clockSplit,
        "clock/panel/dial": clockPanelDial,
        "clock/panel/world": clockPanelWorld,
        "clock/panel/full": clockPanelFull,
        "clock/panel/calendar": clockPanelCalendar,
        "media/playing": mediaPlaying,
        "media/cover": mediaCover,
        "media/compact": mediaCompact,
        "media/progress": mediaProgress,
        "media/ring": mediaRing,
        "media/controls": mediaControls,
        "media/panel/vinyl": mediaPanelVinyl,
        "media/panel/backdrop": mediaPanelBackdrop,
        "media/panel/mini": mediaPanelMini,
        "media/panel/side": mediaPanelSide,
        "media/panel/cover": mediaPanelCover,
        "workspaces/dots": workspacesDots,
        "workspaces/numbers": workspacesNumbers,
        "workspaces/icons": workspacesIcons,
        "workspaces/track": workspacesTrack,
        "notifications/badge": notificationsBadge,
        "notifications/dot": notificationsDot,
        "notifications/chip": notificationsChip,
        "system/values": systemValues,
        "system/icons": systemIcons,
        "system/rings": systemRings,
        "system/accent": systemAccent,
        "system/battery": systemBattery,
        "tray/collapsed": trayCollapsed,
        "tray/icons": trayIcons,
        "tray/drawer": trayDrawer,
        "tray/dots": trayDots,
        "privacy/marks": privacyMarks,
        "privacy/dot": privacyDot,
        "privacy/chip": privacyChip,
        "privacy/pulse": privacyPulse,
        "power/icon": powerIcon,
        "power/accent": powerAccent,
        "power/panel/list": powerPanelList,
        "power/panel/grid": powerPanelGrid,
        "window/plain": windowPlain,
        "window/chip": windowChip,
        "window/status": windowStatus,
        "window/stacked": windowStacked,
        "window/panel/list": windowPanelList,
        "window/panel/grid": windowPanelGrid,
        "apps/icons": appsIcons,
        "apps/names": appsNames,
        "system/panel/stacked": systemPanelStacked,
        "system/panel/wide": systemPanelWide,
        "system/panel/compact": systemPanelCompact,
        "system/panel/minimal": systemPanelMinimal,
        "start/logo": startLogo,
        "start/grid": startGrid,
        "start/distro": startDistro,
        "start/avatar": startAvatar,
        "start/label": startLabel,
        "desktop/sliver": desktopSliver,
        "desktop/icon": desktopIcon,
        "desktop/windows": desktopWindows,
        "desktop/label": desktopLabel,
        "apps/stack": appsStack
    })
    readonly property string powerPath: "M11 3h2v10h-2V3Zm6.36 2.64 1.42-1.42A9.96 9.96 0 0 1 22 12c0 5.52-4.48 10-10 10S2 17.52 2 12c0-2.76 1.12-5.26 2.93-7.07l1.42 1.42A7.96 7.96 0 0 0 4 12c0 4.42 3.58 8 8 8s8-3.58 8-8c0-2.21-.9-4.21-2.64-5.36Z"
    readonly property string micPath: "M12 14c1.66 0 2.99-1.34 2.99-3L15 5c0-1.66-1.34-3-3-3S9 3.34 9 5v6c0 1.66 1.34 3 3 3zm5.3-3c0 3-2.54 5.1-5.3 5.1S6.7 14 6.7 11H5c0 3.41 2.72 6.23 6 6.72V21h2v-3.28c3.28-.48 6-3.3 6-6.72h-1.7z"
    // what the samples show: the time and date as the bar would
    readonly property string timeText: {
        const now = Loc.now();
        if (Prefs.clock24h)
            return now.toLocaleTimeString(I18n.locale, Prefs.clockSeconds ? "HH:mm:ss" : "HH:mm");

        // h only counts to 12 next to AP; the bar leaves the AM/PM out
        const t = now.toLocaleTimeString(I18n.locale, Prefs.clockSeconds ? "hh:mm:ss AP" : "hh:mm AP");
        return t.replace(now.toLocaleTimeString(I18n.locale, "AP"), "").trim();
    }
    readonly property string dateText: Loc.now().toLocaleDateString(I18n.locale, Prefs.clockDateFormat === "long" ? I18n.tr("ddd d MMM") : (Prefs.clockDateFormat === "numeric" ? I18n.locale.dateFormat(Locale.ShortFormat) : I18n.tr("ddd d")))

    implicitWidth: loader.item ? loader.item.implicitWidth : 0
    implicitHeight: loader.item ? loader.item.implicitHeight : 0

    Loader {
        id: loader

        anchors.centerIn: parent
        sourceComponent: sample.samples[sample.sampleKey] || fallback
    }

    Component {
        id: clockInline

        Row {
            spacing: 8

            BarText {
                text: sample.timeText
            }

            Rectangle {
                visible: Prefs.clockShowDate
                width: 3
                height: 3
                radius: 1.5
                color: Theme.subtextDim
                anchors.verticalCenter: parent.verticalCenter
            }

            BarText {
                visible: Prefs.clockShowDate
                text: sample.dateText
                color: Theme.subtextDim
            }

        }

    }

    Component {
        id: clockAnalog

        Row {
            spacing: 8

            Bar.AnalogDial {
                anchors.verticalCenter: parent.verticalCenter
                width: 20
                height: 20
                date: Loc.now()
                faceColor: Theme.accentContainer
                handColor: Theme.fgAccentContainer
                tickColor: Theme.alpha(Theme.fgAccentContainer, 0.6)
            }

            BarText {
                visible: Prefs.clockAnalogTime
                anchors.verticalCenter: parent.verticalCenter
                text: sample.timeText
            }

        }

    }

    Component {
        id: clockWords

        BarText {
            text: {
                const now = Loc.now();
                const w = Words.words(now.getHours(), now.getMinutes(), I18n.locale.name);
                return w.charAt(0).toUpperCase() + w.slice(1);
            }
        }

    }

    Component {
        id: clockSplit

        Row {
            spacing: 4

            Rectangle {
                width: splitTime.implicitWidth + 16
                height: 24
                radius: Theme.pill(height)
                color: Theme.bgHigh

                BarText {
                    id: splitTime

                    anchors.centerIn: parent
                    text: sample.timeText
                }

            }

            Rectangle {
                visible: Prefs.clockShowDate
                width: splitDate.implicitWidth + 16
                height: 24
                radius: Theme.pill(height)
                color: Theme.bgActive

                BarText {
                    id: splitDate

                    anchors.centerIn: parent
                    text: sample.dateText
                    color: Theme.subtext
                }

            }

        }

    }

    Component {
        id: clockPanelDial

        MiniPanel {
            width: 96

            Column {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6

                Bar.AnalogDial {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 26
                    height: 26
                    detail: true
                    date: Loc.now()
                    faceColor: Theme.alpha(Theme.text, 0.08)
                    handColor: Theme.text
                    tickColor: Theme.subtext
                }

                MiniCalendar {
                    width: parent.width
                    height: parent.height - 32
                }

            }

        }

    }

    Component {
        id: clockPanelWorld

        MiniPanel {
            width: 110

            Column {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                BarText {
                    text: sample.timeText
                    font.pixelSize: Theme.fs(14)
                }

                Repeater {
                    model: 3

                    Rectangle {
                        required property int index

                        width: parent.width
                        height: 14
                        radius: Theme.rad(4)
                        color: Theme.bgHigh

                        Rectangle {
                            x: 5
                            anchors.verticalCenter: parent.verticalCenter
                            width: 5
                            height: 5
                            radius: 2.5
                            color: index === 0 ? Theme.subtext : Theme.accent
                        }

                        Rectangle {
                            anchors.right: parent.right
                            anchors.rightMargin: 5
                            anchors.verticalCenter: parent.verticalCenter
                            width: 22
                            height: 4
                            radius: 2
                            color: Theme.text
                        }

                    }

                }

            }

        }

    }

    Component {
        id: clockStacked

        Column {
            spacing: -2

            BarText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: sample.timeText
                font.pixelSize: Theme.fs(12)
            }

            BarText {
                visible: Prefs.clockShowDate
                anchors.horizontalCenter: parent.horizontalCenter
                text: sample.dateText
                color: Theme.subtextDim
                font.pixelSize: Theme.fs(10)
            }

        }

    }

    Component {
        id: clockAccent

        Row {
            spacing: 8

            Rectangle {
                width: accentTime.implicitWidth + 16
                height: 24
                radius: Theme.pill(height)
                color: Theme.accent

                BarText {
                    id: accentTime

                    anchors.centerIn: parent
                    text: sample.timeText
                    color: Theme.fgAccent
                }

            }

            BarText {
                visible: Prefs.clockShowDate
                anchors.verticalCenter: parent.verticalCenter
                text: sample.dateText
                color: Theme.subtextDim
            }

        }

    }

    Component {
        id: clockPanelFull

        MiniPanel {
            Row {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6

                Column {
                    width: (parent.width - 6) * 0.42
                    spacing: 4

                    Rectangle {
                        width: parent.width
                        height: 30
                        radius: Theme.radiusSm
                        color: Theme.accentContainer
                    }

                    Rectangle {
                        width: parent.width
                        height: 22
                        radius: Theme.radiusSm
                        color: Theme.bgHigh
                    }

                    Rectangle {
                        width: parent.width
                        height: 22
                        radius: Theme.radiusSm
                        color: Theme.bgHigh
                    }

                }

                MiniCalendar {
                    width: (parent.width - 6) * 0.58
                    height: parent.height
                }

            }

        }

    }

    Component {
        id: clockPanelCalendar

        MiniPanel {
            width: 96

            MiniCalendar {
                anchors.fill: parent
                anchors.margins: 8
            }

        }

    }

    Component {
        id: mediaPlaying

        Row {
            spacing: 8

            MiniBars {
                anchors.verticalCenter: parent.verticalCenter
            }

            BarText {
                text: Prefs.mediaArtist ? I18n.tr("Artist  -  Song") : I18n.tr("Song")
            }

            MiniPlay {
                visible: Prefs.mediaPlayButton
                anchors.verticalCenter: parent.verticalCenter
            }

        }

    }

    Component {
        id: mediaCover

        Row {
            spacing: 8

            Rectangle {
                width: 22
                height: 22
                radius: 6
                color: Theme.accentContainer
                anchors.verticalCenter: parent.verticalCenter
            }

            BarText {
                text: Prefs.mediaArtist ? I18n.tr("Artist  -  Song") : I18n.tr("Song")
            }

            MiniPlay {
                visible: Prefs.mediaPlayButton
                anchors.verticalCenter: parent.verticalCenter
            }

        }

    }

    Component {
        id: mediaCompact

        Row {
            spacing: 8

            MiniBars {
                anchors.verticalCenter: parent.verticalCenter
            }

            MiniPlay {
                visible: Prefs.mediaPlayButton
                anchors.verticalCenter: parent.verticalCenter
            }

        }

    }

    Component {
        id: mediaProgress

        Item {
            implicitWidth: progressRow.implicitWidth + 16
            implicitHeight: 24

            Rectangle {
                width: parent.width * 0.45
                height: parent.height
                radius: Theme.pill(height)
                color: Theme.alpha(Theme.accent, 0.28)
            }

            Row {
                id: progressRow

                anchors.centerIn: parent
                spacing: 8

                MiniBars {
                    anchors.verticalCenter: parent.verticalCenter
                }

                BarText {
                    text: I18n.tr("Song")
                }

            }

        }

    }

    Component {
        id: mediaRing

        Row {
            spacing: 8

            Bar.ProgressRing {
                anchors.verticalCenter: parent.verticalCenter
                width: 22
                height: 22
                thickness: 2
                value: 0.45
                duration: 0
                trackColor: Theme.alpha(Theme.text, 0.15)
                ringColor: Theme.accent

                Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    color: Theme.accentContainer
                }

            }

            BarText {
                anchors.verticalCenter: parent.verticalCenter
                text: I18n.tr("Song")
            }

        }

    }

    Component {
        id: mediaControls

        Row {
            spacing: 6

            MiniGlyph {
                anchors.verticalCenter: parent.verticalCenter
                width: 12
                height: 12
                path: "M6 6h2v12H6V6Zm3.5 6 8.5-6v12l-8.5-6Z"
            }

            MiniPlay {
                anchors.verticalCenter: parent.verticalCenter
            }

            MiniGlyph {
                anchors.verticalCenter: parent.verticalCenter
                width: 12
                height: 12
                path: "M18 6h-2v12h2V6Zm-3.5 6L6 6v12l8.5-6Z"
            }

            BarText {
                anchors.verticalCenter: parent.verticalCenter
                leftPadding: 2
                text: I18n.tr("Song")
            }

        }

    }

    Component {
        id: mediaPanelVinyl

        MiniPanel {
            height: 104

            Column {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 50
                    height: 50
                    radius: 25
                    color: "#161616"
                    border.width: 1
                    border.color: Theme.alpha("white", 0.08)

                    Rectangle {
                        anchors.centerIn: parent
                        width: 36
                        height: 36
                        radius: 18
                        color: "transparent"
                        border.width: 1
                        border.color: Theme.alpha("white", 0.06)
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 20
                        height: 20
                        radius: 10
                        color: Theme.accentContainer
                    }

                    // the tonearm, needle down
                    Rectangle {
                        x: 46
                        y: 2
                        width: 2
                        height: 30
                        radius: 1
                        rotation: 20
                        transformOrigin: Item.Top
                        color: Theme.text
                    }

                    Rectangle {
                        x: 42
                        y: -1
                        width: 7
                        height: 7
                        radius: 3.5
                        color: Theme.bgHigh
                        border.width: 1
                        border.color: Theme.subtext
                    }

                }

                MiniLines {
                    width: parent.width
                }

                MiniTrack {
                    width: parent.width
                }

            }

        }

    }

    Component {
        id: mediaPanelBackdrop

        MiniPanel {
            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: Theme.alpha(Theme.accent, 0.45)
                }

                GradientStop {
                    position: 1
                    color: Theme.bg
                }

            }

            Row {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                Rectangle {
                    width: 44
                    height: 44
                    radius: Theme.radiusSm
                    color: Theme.accentContainer
                }

                Column {
                    width: parent.width - 52
                    spacing: 8

                    MiniLines {
                        width: parent.width
                    }

                    MiniTrack {
                        width: parent.width
                    }

                }

            }

        }

    }

    Component {
        id: mediaPanelMini

        MiniPanel {
            width: 120
            height: 70

            Column {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                MiniLines {
                    width: parent.width
                }

                MiniTrack {
                    width: parent.width
                }

            }

        }

    }

    Component {
        id: mediaPanelSide

        MiniPanel {
            Row {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                Rectangle {
                    width: 44
                    height: 44
                    radius: Theme.radiusSm
                    color: Theme.accentContainer
                }

                MiniLines {
                    width: parent.width - 52
                }

            }

            MiniTrack {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 8
            }

        }

    }

    Component {
        id: mediaPanelCover

        MiniPanel {
            height: 104

            Column {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6

                Rectangle {
                    width: parent.width
                    height: 46
                    radius: Theme.radiusSm
                    color: Theme.accentContainer
                }

                MiniLines {
                    width: parent.width
                }

                MiniTrack {
                    width: parent.width
                }

            }

        }

    }

    Component {
        id: workspacesDots

        Row {
            spacing: 6

            Repeater {
                model: Math.min(Prefs.workspacesShown, 6)

                Rectangle {
                    required property int index

                    width: index === 0 ? 24 : 10
                    height: 10
                    radius: Theme.pill(height)
                    color: index === 0 ? Theme.accent : Theme.withBlur(Theme._darken(Theme.subtext, 0.45))
                    anchors.verticalCenter: parent.verticalCenter
                }

            }

        }

    }

    Component {
        id: workspacesNumbers

        Row {
            spacing: 6

            Repeater {
                model: Math.min(Prefs.workspacesShown, 6)

                Rectangle {
                    required property int index

                    width: index === 0 ? 30 : 20
                    height: 20
                    radius: Theme.pill(height)
                    color: index === 0 ? Theme.accent : "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    BarText {
                        anchors.centerIn: parent
                        text: index + 1
                        font.pixelSize: Theme.fs(12)
                        color: index === 0 ? Theme.bgOpaque : Theme.subtext
                        opacity: index < 3 ? 1 : 0.5
                    }

                }

            }

        }

    }

    Component {
        id: workspacesIcons

        Item {
            id: iconsSample

            // a symbol per window: the first is lit, the empty ones are dots
            readonly property var glyphs: [["terminal", "web"], ["code"], [], ["sports_esports"], []]

            implicitWidth: iconsRow.width
            implicitHeight: 18

            Row {
                id: iconsRow

                anchors.verticalCenter: parent.verticalCenter
                spacing: 5

                Repeater {
                    model: Math.min(Prefs.workspacesShown, 5)

                    Rectangle {
                        id: iconSlot

                        required property int index
                        readonly property var glyphs: iconsSample.glyphs[index] || []
                        readonly property int n: iconSlot.glyphs.length

                        width: iconSlot.n === 0 ? 8 : iconSlot.n * 13 + (iconSlot.n - 1) * 2 + (index === 0 ? 14 : 5)
                        height: iconSlot.n > 0 ? 18 : 8
                        radius: Theme.pill(Math.min(width, height))
                        color: index === 0 ? Theme.accent : (iconSlot.n > 0 ? "transparent" : Theme.withBlur(Theme._darken(Theme.subtext, 0.45)))
                        anchors.verticalCenter: parent.verticalCenter

                        Row {
                            anchors.centerIn: parent
                            spacing: 2

                            Repeater {
                                model: iconSlot.n

                                Shape {
                                    id: sampleGlyph

                                    required property int index

                                    width: 13
                                    height: 13
                                    preferredRendererType: Shape.CurveRenderer

                                    ShapePath {
                                        strokeWidth: 0
                                        fillColor: iconSlot.index === 0 ? Theme.bgOpaque : Theme.cSecondary

                                        PathSvg {
                                            path: Specials.glyphPath(iconSlot.glyphs[sampleGlyph.index])
                                        }

                                    }

                                    transform: Scale {
                                        xScale: 13 / 24
                                        yScale: 13 / 24
                                    }

                                }

                            }

                        }

                    }

                }

            }

        }

    }

    Component {
        id: workspacesTrack

        Item {
            id: trackSample

            readonly property int count: Math.min(Prefs.workspacesShown, 6)

            implicitWidth: trackRow.width
            implicitHeight: 10

            Row {
                id: trackRow

                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Repeater {
                    model: trackSample.count

                    Rectangle {
                        required property int index
                        readonly property int seam: Math.min(Theme.rad(1), radius)

                        width: 16
                        height: 6
                        radius: Theme.pill(height)
                        topLeftRadius: index > 0 ? seam : radius
                        bottomLeftRadius: index > 0 ? seam : radius
                        topRightRadius: index < trackSample.count - 1 ? seam : radius
                        bottomRightRadius: index < trackSample.count - 1 ? seam : radius
                        color: Theme.withBlur(index === 2 ? Theme.cSecondary : Theme._darken(Theme.subtext, 0.45))
                    }

                }

            }

            Rectangle {
                x: 18
                anchors.verticalCenter: parent.verticalCenter
                width: 16
                height: 10
                radius: Theme.pill(width < height ? width : height)
                color: Theme.accent
            }

        }

    }

    Component {
        id: notificationsBadge

        Row {
            spacing: 5

            MiniBell {
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                width: 16
                height: 16
                radius: Theme.pill(height)
                color: Theme.accent
                anchors.verticalCenter: parent.verticalCenter

                BarText {
                    anchors.centerIn: parent
                    text: "3"
                    color: Theme.fgAccent
                    font.pixelSize: Theme.fs(11)
                }

            }

        }

    }

    Component {
        id: notificationsDot

        MiniBell {
            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: -1
                width: 7
                height: 7
                radius: 3.5
                color: Theme.accent
                border.width: 1.5
                border.color: Theme.bg
            }

        }

    }

    Component {
        id: notificationsChip

        Rectangle {
            implicitWidth: chipRow.implicitWidth + 14
            implicitHeight: 24
            radius: Theme.pill(height)
            color: Theme.accent

            Row {
                id: chipRow

                anchors.centerIn: parent
                spacing: 5

                MiniBell {
                    ink: Theme.fgAccent
                    anchors.verticalCenter: parent.verticalCenter
                }

                BarText {
                    text: "3"
                    color: Theme.fgAccent
                    font.pixelSize: Theme.fs(12)
                    anchors.verticalCenter: parent.verticalCenter
                }

            }

        }

    }

    // a bell: the notifications module's own glyph
    component MiniBell: Item {
        property color ink: Theme.text

        implicitWidth: 17
        implicitHeight: 17

        Shape {
            width: 24
            height: 24
            scale: 17 / 24
            anchors.centerIn: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                fillColor: ink
                strokeWidth: 0

                PathSvg {
                    path: Notifs.icons.notifications
                }

            }

        }

    }

    Component {
        id: systemValues

        MiniSystem {
            look: "values"
        }

    }

    Component {
        id: systemIcons

        MiniSystem {
            look: "icons"
        }

    }

    Component {
        id: systemRings

        MiniSystem {
            look: "rings"
        }

    }

    Component {
        id: systemAccent

        MiniSystem {
            look: "accent"
        }

    }

    Component {
        id: systemBattery

        MiniSystem {
            look: "battery"
        }

    }

    // the system module's face: volume, microphone and battery, as picked,
    // in one of its looks (values, icons, rings, accent, battery)
    component MiniSystem: Item {
        id: mini

        property bool values: look === "values" || look === "accent"
        property string look: "values"
        readonly property var on: String(Prefs.systemIndicators).split(",")
        readonly property bool ringed: look === "rings"
        readonly property color ink: look === "accent" ? Theme.fgAccent : Theme.text
        readonly property color dim: look === "accent" ? Theme.alpha(Theme.fgAccent, 0.65) : Theme.subtext

        implicitWidth: row.implicitWidth + (look === "accent" ? 16 : 0)
        implicitHeight: 24

        Rectangle {
            visible: mini.look === "accent"
            anchors.fill: parent
            radius: Theme.pill(height)
            color: Theme.accent
        }

        Row {
            id: row

            anchors.centerIn: parent
            spacing: 10

            Row {
                visible: mini.on.indexOf("volume") !== -1
                spacing: 4
                anchors.verticalCenter: parent.verticalCenter

                MiniLevel {
                    ringed: mini.ringed
                    ink: mini.ink
                    level: 0.75
                    path: "M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02z"
                }

                BarText {
                    visible: mini.values
                    text: "75"
                    color: mini.ink
                    font.pixelSize: Theme.fontLabelLg
                }

            }

            Row {
                visible: mini.on.indexOf("mic") !== -1
                spacing: 4
                anchors.verticalCenter: parent.verticalCenter

                MiniLevel {
                    ringed: mini.ringed
                    ink: mini.ink
                    level: 1
                    path: sample.micPath
                }

                BarText {
                    visible: mini.values
                    text: I18n.tr("On")
                    color: mini.ink
                    font.pixelSize: Theme.fontLabelLg
                }

            }

            Row {
                visible: mini.on.indexOf("battery") !== -1
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter

                MiniLevel {
                    visible: mini.ringed
                    ringed: mini.ringed
                    ink: mini.ink
                    level: 0.8
                    path: "M15.67 4H14V2h-4v2H8.33C7.6 4 7 4.6 7 5.33v15.33C7 21.4 7.6 22 8.33 22h7.33c.74 0 1.34-.6 1.34-1.33V5.33C17 4.6 16.4 4 15.67 4z"
                }

                Rectangle {
                    visible: !mini.ringed
                    width: mini.look === "battery" ? 30 : 22
                    height: mini.look === "battery" ? 16 : 12
                    radius: mini.look === "battery" ? Theme.rad(5) : 3
                    color: "transparent"
                    border.width: 1.5
                    border.color: mini.dim
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        x: 2.5
                        y: 2.5
                        width: (parent.width - 5) * 0.8
                        height: parent.height - 5
                        radius: mini.look === "battery" ? Theme.rad(3) : 1
                        color: mini.look === "battery" ? Theme.alpha(mini.dim, 0.4) : mini.dim
                    }

                    BarText {
                        visible: mini.look === "battery"
                        anchors.centerIn: parent
                        text: "80"
                        font.pixelSize: Theme.fs(9)
                    }

                }

                BarText {
                    visible: mini.values
                    text: "80%"
                    color: mini.ink
                    font.pixelSize: Theme.fontLabelLg
                }

            }

        }

    }

    // a glyph, or in the Rings look the glyph inside a ring at its level
    component MiniLevel: Item {
        id: lvl

        property string path: ""
        property real level: 0
        property bool ringed: false
        property color ink: Theme.text

        implicitWidth: lvl.ringed ? 20 : 14
        implicitHeight: lvl.ringed ? 20 : 14
        anchors.verticalCenter: parent.verticalCenter

        Bar.ProgressRing {
            visible: lvl.ringed
            anchors.fill: parent
            value: lvl.level
            thickness: 2
            trackColor: Theme.alpha(Theme.text, 0.15)
            ringColor: Theme.accent
            duration: 0
        }

        MiniGlyph {
            anchors.centerIn: parent
            width: lvl.ringed ? 11 : 14
            height: width
            path: lvl.path
            ink: lvl.ink
        }

    }

    // a 24-unit glyph at the bar's icon size
    component MiniGlyph: Item {
        id: glyph

        property string path: ""
        property color ink: Theme.text

        implicitWidth: 14
        implicitHeight: 14

        Shape {
            width: 24
            height: 24
            scale: glyph.width / 24
            anchors.centerIn: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                fillColor: glyph.ink
                strokeWidth: 0

                PathSvg {
                    path: glyph.path
                }

            }

        }

    }

    Component {
        id: trayCollapsed

        Row {
            spacing: 4

            MiniGlyph {
                path: "M3 13h8V3H3v10Zm0 8h8v-6H3v6Zm10 0h8V11h-8v10Zm0-18v6h8V3h-8Z"
                implicitWidth: 16
                implicitHeight: 16
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                width: 16
                height: 16
                radius: Theme.pill(height)
                color: Theme.accent
                anchors.verticalCenter: parent.verticalCenter

                BarText {
                    anchors.centerIn: parent
                    text: "3"
                    color: Theme.bgOpaque
                    font.pixelSize: Theme.fs(11)
                }

            }

        }

    }

    Component {
        id: trayIcons

        Row {
            spacing: 6

            Repeater {
                model: [Theme.accent, Theme.subtext, Theme.accentContainer]

                Rectangle {
                    required property color modelData

                    width: 16
                    height: 16
                    radius: 4
                    color: modelData
                    anchors.verticalCenter: parent.verticalCenter
                }

            }

        }

    }

    Component {
        id: trayDrawer

        Row {
            spacing: 4

            MiniGlyph {
                path: "M15.41 7.41 14 6l-6 6 6 6 1.41-1.41L10.83 12z"
                implicitWidth: 16
                implicitHeight: 16
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                width: 16
                height: 16
                radius: Theme.pill(height)
                color: Theme.accent
                anchors.verticalCenter: parent.verticalCenter

                BarText {
                    anchors.centerIn: parent
                    text: "3"
                    color: Theme.bgOpaque
                    font.pixelSize: Theme.fs(11)
                }

            }

        }

    }

    Component {
        id: trayDots

        Row {
            spacing: 4

            Repeater {
                model: 3

                Rectangle {
                    required property int index

                    width: 6
                    height: 6
                    radius: 3
                    color: index === 0 ? Theme.accent : Theme.subtext
                }

            }

        }

    }

    Component {
        id: privacyChip

        Rectangle {
            implicitWidth: chipSampleRow.implicitWidth + 18
            implicitHeight: 22
            radius: Theme.pill(height)
            color: Theme.alpha(Theme.warning, 0.2)

            Row {
                id: chipSampleRow

                anchors.centerIn: parent
                spacing: 5

                MiniGlyph {
                    anchors.verticalCenter: parent.verticalCenter
                    implicitWidth: 13
                    implicitHeight: 13
                    path: sample.micPath
                    ink: Theme.warning
                }

                BarText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: I18n.tr("Microphone") + " · App" // i18n-skip
                    color: Theme.warning
                    font.pixelSize: Theme.fs(11)
                }

            }

        }

    }

    Component {
        id: privacyPulse

        Item {
            implicitWidth: 24
            implicitHeight: 24

            Rectangle {
                anchors.centerIn: parent
                width: 22
                height: 22
                radius: 11
                color: "transparent"
                border.width: 2
                border.color: Theme.alpha(Theme.error, 0.4)
            }

            Rectangle {
                anchors.centerIn: parent
                width: 16
                height: 16
                radius: 8
                color: Theme.alpha(Theme.error, 0.25)

                MiniGlyph {
                    anchors.centerIn: parent
                    implicitWidth: 10
                    implicitHeight: 10
                    ink: Theme.error
                    path: "M4 17q-.825 0-1.412-.587T2 15V5q0-.825.588-1.412T4 3h16q.825 0 1.413.588T22 5v10q0 .825-.587 1.413T20 17h-5v2h2v2H7v-2h2v-2H4Z"
                }

            }

        }

    }

    Component {
        id: privacyMarks

        Row {
            spacing: 4

            Repeater {
                model: [{
                    "ink": Theme.warning,
                    "path": sample.micPath
                }, {
                    "ink": Theme.error,
                    "path": "M4 17q-.825 0-1.412-.587T2 15V5q0-.825.588-1.412T4 3h16q.825 0 1.413.588T22 5v10q0 .825-.587 1.413T20 17h-5v2h2v2H7v-2h2v-2H4Z"
                }]

                Rectangle {
                    required property var modelData

                    width: 26
                    height: 22
                    radius: Theme.pill(height)
                    color: Theme.alpha(modelData.ink, 0.2)

                    MiniGlyph {
                        anchors.centerIn: parent
                        path: parent.modelData.path
                        ink: parent.modelData.ink
                    }

                }

            }

        }

    }

    Component {
        id: privacyDot

        Rectangle {
            implicitWidth: 10
            implicitHeight: 10
            radius: 5
            color: Theme.error
        }

    }

    Component {
        id: powerIcon

        MiniGlyph {
            path: sample.powerPath
            implicitWidth: 17
            implicitHeight: 17
        }

    }

    Component {
        id: powerAccent

        Rectangle {
            implicitWidth: 24
            implicitHeight: 24
            radius: Theme.pill(height)
            color: Theme.accent

            MiniGlyph {
                anchors.centerIn: parent
                path: sample.powerPath
                ink: Theme.fgAccent
            }

        }

    }

    Component {
        id: powerPanelList

        MiniPanel {
            width: 110

            Column {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 5

                Repeater {
                    model: 5

                    Row {
                        required property int index

                        spacing: 6

                        Rectangle {
                            width: 11
                            height: 11
                            radius: Theme.pill(height)
                            color: index > 2 ? Theme.errorContainer : Theme.accentContainer
                        }

                        Rectangle {
                            width: 50
                            height: 5
                            radius: 2.5
                            color: Theme.subtextDim
                            anchors.verticalCenter: parent.verticalCenter
                        }

                    }

                }

            }

        }

    }

    Component {
        id: powerPanelGrid

        MiniPanel {
            width: 130
            height: 80

            Grid {
                anchors.centerIn: parent
                columns: 3
                spacing: 8

                Repeater {
                    model: 6

                    Column {
                        required property int index

                        spacing: 4

                        Rectangle {
                            width: 20
                            height: 20
                            radius: Theme.pill(height)
                            color: index > 3 ? Theme.errorContainer : Theme.accentContainer
                        }

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 16
                            height: 4
                            radius: 2
                            color: Theme.subtextDim
                        }

                    }

                }

            }

        }

    }

    // three apps, the middle one in focus, the last one only pinned
    component MiniApp: Item {
        id: miniApp

        property bool named: false
        property string label: ""
        property int windows: 0
        property bool focused: false
        property color tint: Theme.accentContainer

        implicitWidth: miniApp.named ? 17 + 8 + miniLabel.implicitWidth + 16 : 30
        implicitHeight: 28

        Rectangle {
            anchors.fill: parent
            radius: Theme.pill(height)
            color: miniApp.focused ? Theme.alpha(Theme.accent, 0.16) : "transparent"
        }

        Rectangle {
            id: miniIcon

            x: miniApp.named ? 8 : (parent.width - width) / 2
            anchors.verticalCenter: parent.verticalCenter
            width: 17
            height: 17
            radius: 4
            color: miniApp.tint
            opacity: miniApp.windows > 0 ? 1 : 0.72
        }

        BarText {
            id: miniLabel

            visible: miniApp.named
            x: miniIcon.x + miniIcon.width + 8
            anchors.verticalCenter: parent.verticalCenter
            text: miniApp.label
            color: miniApp.windows > 0 ? Theme.text : Theme.subtext
            font.pixelSize: Theme.fontLabelLg
            font.weight: miniApp.focused ? Font.DemiBold : Font.Medium
            font.bold: false
        }

        Row {
            anchors.horizontalCenter: miniIcon.horizontalCenter
            y: Prefs.barBottom ? parent.height - 3 : 0
            spacing: 3
            visible: miniApp.windows > 0

            Repeater {
                model: miniApp.focused ? 1 : miniApp.windows

                Rectangle {
                    width: miniApp.focused ? 14 : 4
                    height: 3
                    radius: height / 2
                    color: miniApp.focused ? Theme.accent : Theme.subtext
                }

            }

        }

    }

    // the control centre, in miniature: tiles, sliders and figures
    component MiniTiles: Grid {
        columns: 2
        spacing: 3

        Repeater {
            model: 4

            Rectangle {
                width: 22
                height: 9
                radius: 3
                color: index === 0 ? Theme.accent : Theme.bgActive
            }

        }

    }

    component MiniFigures: Row {
        spacing: 3

        Repeater {
            model: 3

            Rectangle {
                width: 13
                height: 14
                radius: 3
                color: Theme.bgActive
            }

        }

    }

    Component {
        id: systemPanelStacked

        Column {
            spacing: 4

            MiniTiles {
            }

            Rectangle {
                width: 47
                height: 4
                radius: 2
                color: Theme.accent
            }

            Rectangle {
                width: 47
                height: 4
                radius: 2
                color: Theme.bgActive
            }

            MiniFigures {
            }

        }

    }

    component MiniSquares: Grid {
        columns: 4
        spacing: 3

        Repeater {
            model: 8

            Rectangle {
                width: 10
                height: 10
                radius: 3
                color: index === 0 || index === 4 ? Theme.accent : Theme.bgActive
            }

        }

    }

    component MiniSliders: Column {
        spacing: 3

        Repeater {
            model: 2

            Rectangle {
                width: 49
                height: 4
                radius: 2
                color: Theme.bgActive

                Rectangle {
                    width: parent.width * (index === 0 ? 0.6 : 0.85)
                    height: parent.height
                    radius: 2
                    color: Theme.accent
                }

            }

        }

    }

    Component {
        id: systemPanelCompact

        Column {
            spacing: 4

            MiniSquares {
            }

            MiniSliders {
            }

            Row {
                spacing: 3

                Repeater {
                    model: 3

                    Rectangle {
                        width: 14
                        height: 6
                        radius: 3
                        color: Theme.bgActive
                    }

                }

            }

        }

    }

    Component {
        id: systemPanelMinimal

        Column {
            spacing: 5

            MiniSquares {
            }

            MiniSliders {
            }

        }

    }

    Component {
        id: systemPanelWide

        Row {
            spacing: 5

            MiniFigures {
            }

            MiniTiles {
            }

            Row {
                spacing: 3

                Repeater {
                    model: 2

                    Rectangle {
                        width: 6
                        height: 33
                        radius: 3
                        color: Theme.bgActive

                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: parent.height * (index === 0 ? 0.65 : 0.85)
                            radius: 3
                            color: Theme.accent
                        }

                    }

                }

            }

        }

    }

    Component {
        id: startLogo

        Item {
            implicitWidth: 26
            implicitHeight: 26

            Rectangle {
                anchors.centerIn: parent
                width: 18
                height: 18
                radius: width / 2
                color: "transparent"
                border.width: 3
                border.color: Theme.accent
            }

            Rectangle {
                anchors.centerIn: parent
                width: 6
                height: 6
                radius: 3
                color: Theme.text
            }

        }

    }

    Component {
        id: startGrid

        Grid {
            columns: 3
            spacing: 3

            Repeater {
                model: 9

                Rectangle {
                    width: 4
                    height: 4
                    radius: 2
                    color: index === 4 ? Theme.accent : Theme.text
                }

            }

        }

    }

    Component {
        id: desktopSliver

        Row {
            spacing: 10

            BarText {
                text: "100%"
                font.pixelSize: Theme.fontLabelLg
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: 14
                color: Theme.alpha(Theme.text, 0.3)
            }

            Item {
                width: 4
                height: 1
            }

        }

    }

    Component {
        id: desktopIcon

        Item {
            implicitWidth: 20
            implicitHeight: 16

            Rectangle {
                width: 18
                height: 11
                radius: 2
                color: "transparent"
                border.width: 1.6
                border.color: Theme.text
            }

            Rectangle {
                x: 5
                y: 12
                width: 8
                height: 1.6
                color: Theme.text
            }

        }

    }

    Component {
        id: startDistro

        // a generic peak, in the accent: the real logo is read on the bar
        MiniGlyph {
            implicitWidth: 20
            implicitHeight: 20
            ink: Theme.accent
            path: "M12 2 3 21h4.5L12 11l4.5 10H21Z"
        }

    }

    Component {
        id: startAvatar

        Rectangle {
            implicitWidth: 22
            implicitHeight: 22
            radius: 11
            color: Theme.secondaryContainer

            BarText {
                anchors.centerIn: parent
                text: (Users.me && Users.me.name ? Users.me.name : "U").charAt(0).toUpperCase() // i18n-skip
                color: Theme.fgSecondaryContainer
                font.pixelSize: Theme.fs(11)
            }

        }

    }

    Component {
        id: startLabel

        Rectangle {
            implicitWidth: startLabelText.implicitWidth + 20
            implicitHeight: 24
            radius: Theme.pill(height)
            color: Theme.accent

            BarText {
                id: startLabelText

                anchors.centerIn: parent
                text: I18n.trc("start button", "Start")
                color: Theme.fgAccent
                font.pixelSize: Theme.fs(12)
            }

        }

    }

    Component {
        id: desktopWindows

        Item {
            implicitWidth: 20
            implicitHeight: 16

            Rectangle {
                width: 13
                height: 10
                radius: Theme.rad(2.5)
                color: "transparent"
                border.width: 1.6
                border.color: Theme.text
            }

            Rectangle {
                x: 6
                y: 4
                width: 13
                height: 10
                radius: Theme.rad(2.5)
                color: Theme.alpha(Theme.accent, 0.25)
                border.width: 1.6
                border.color: Theme.accent
            }

            Rectangle {
                y: 14
                width: 20
                height: 2
                radius: 1
                color: Theme.alpha(Theme.text, 0.3)
            }

        }

    }

    Component {
        id: desktopLabel

        Row {
            spacing: 6

            Item {
                anchors.verticalCenter: parent.verticalCenter
                width: 18
                height: 14

                Rectangle {
                    width: 18
                    height: 11
                    radius: 2
                    color: "transparent"
                    border.width: 1.6
                    border.color: Theme.text
                }

                Rectangle {
                    x: 5
                    y: 12
                    width: 8
                    height: 1.6
                    color: Theme.text
                }

            }

            BarText {
                anchors.verticalCenter: parent.verticalCenter
                text: I18n.tr("Desktop")
                font.pixelSize: Theme.fs(12)
            }

        }

    }

    Component {
        id: appsStack

        Row {
            spacing: -12

            Repeater {
                model: [Theme.tertiaryContainer, Theme.accent, Theme.secondaryContainer, Theme.accentContainer]

                Rectangle {
                    required property color modelData

                    width: 26
                    height: 26
                    radius: 13
                    color: Theme.bgHigh
                    border.width: 2
                    border.color: Theme.bgOpaque

                    Rectangle {
                        anchors.centerIn: parent
                        width: 15
                        height: 15
                        radius: 4
                        color: parent.modelData
                    }

                }

            }

        }

    }

    Component {
        id: appsIcons

        Row {
            spacing: 2

            MiniApp {
                windows: 2
                tint: Theme.tertiaryContainer
            }

            MiniApp {
                windows: 1
                focused: true
                tint: Theme.accent
            }

            MiniApp {
                tint: Theme.secondaryContainer
            }

        }

    }

    Component {
        id: appsNames

        Row {
            spacing: 2

            MiniApp {
                named: true
                label: I18n.tr("Files")
                windows: 2
                tint: Theme.tertiaryContainer
            }

            MiniApp {
                named: true
                label: I18n.tr("Browser")
                windows: 1
                focused: true
                tint: Theme.accent
            }

        }

    }

    Component {
        id: windowPlain

        Row {
            spacing: 8

            Rectangle {
                width: 17
                height: 17
                radius: 4
                color: Theme.accentContainer
                anchors.verticalCenter: parent.verticalCenter
            }

            BarText {
                text: Prefs.windowModuleText === "icon" ? "" : I18n.tr("Window title")
                visible: text !== ""
                font.pixelSize: Theme.fontLabelLg
                font.weight: Font.Medium
                font.bold: false
            }

        }

    }

    Component {
        id: windowChip

        Rectangle {
            implicitWidth: chipRow.implicitWidth + (Prefs.windowModuleText === "icon" ? 12 : 18)
            implicitHeight: 26
            radius: Theme.pill(height)
            color: Theme.accentContainer

            Row {
                id: chipRow

                anchors.centerIn: parent
                spacing: 8

                Rectangle {
                    width: 17
                    height: 17
                    radius: 4
                    color: Theme.accent
                    anchors.verticalCenter: parent.verticalCenter
                }

                BarText {
                    text: Prefs.windowModuleText === "icon" ? "" : I18n.tr("Window title")
                    visible: text !== ""
                    color: Theme.fgAccentContainer
                    font.pixelSize: Theme.fontLabelLg
                    font.weight: Font.Medium
                    font.bold: false
                }

            }

        }

    }

    Component {
        id: windowStatus

        Row {
            spacing: 8

            Rectangle {
                width: 17
                height: 17
                radius: 4
                color: Theme.accent
                anchors.verticalCenter: parent.verticalCenter
            }

            MiniGlyph {
                anchors.verticalCenter: parent.verticalCenter
                width: 13
                height: 13
                ink: Theme.accent
                path: "M16 9V4h1c.55 0 1-.45 1-1s-.45-1-1-1H7c-.55 0-1 .45-1 1s.45 1 1 1h1v5c0 1.66-1.34 3-3 3v2h5.97v7l1 1 1-1v-7H19v-2c-1.66 0-3-1.34-3-3z"
            }

            BarText {
                text: I18n.tr("Window title")
                font.pixelSize: Theme.fontLabelLg
                font.weight: Font.Medium
                font.bold: false
            }

        }

    }

    Component {
        id: windowStacked

        Row {
            spacing: 8

            Rectangle {
                width: 17
                height: 17
                radius: 4
                color: Theme.accent
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                spacing: -2
                anchors.verticalCenter: parent.verticalCenter

                BarText {
                    text: I18n.tr("Window title")
                    font.pixelSize: Theme.fs(12)
                    font.weight: Font.Medium
                    font.bold: false
                }

                BarText {
                    text: I18n.tr("App")
                    color: Theme.subtextDim
                    font.pixelSize: Theme.fs(10)
                }

            }

        }

    }

    Component {
        id: windowPanelList

        MiniPanel {
            width: 130
            height: 80

            Column {
                anchors.fill: parent
                anchors.margins: 9
                spacing: 7

                Row {
                    spacing: 6

                    Rectangle {
                        width: 16
                        height: 16
                        radius: 4
                        color: Theme.accentContainer
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 50
                        height: 5
                        radius: 2.5
                        color: Theme.text
                    }

                }

                Row {
                    spacing: 4

                    Repeater {
                        model: 3

                        Rectangle {
                            required property int index

                            width: 30
                            height: 12
                            radius: Theme.pill(height)
                            color: index === 0 ? Theme.accent : Theme.secondaryContainer
                        }

                    }

                }

                Repeater {
                    model: 2

                    Rectangle {
                        width: parent.width
                        height: 10
                        radius: Theme.rad(4)
                        color: Theme.bgHigh
                    }

                }

            }

        }

    }

    Component {
        id: windowPanelGrid

        MiniPanel {
            width: 130
            height: 80

            Column {
                anchors.fill: parent
                anchors.margins: 9
                spacing: 7

                Row {
                    spacing: 6

                    Rectangle {
                        width: 16
                        height: 16
                        radius: 4
                        color: Theme.accentContainer
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 50
                        height: 5
                        radius: 2.5
                        color: Theme.text
                    }

                }

                Row {
                    spacing: 5

                    Repeater {
                        model: 5

                        Rectangle {
                            required property int index

                            width: 18
                            height: 18
                            radius: Theme.rad(5)
                            color: index === 0 ? Theme.accent : (index === 4 ? Theme.errorContainer : Theme.secondaryContainer)
                        }

                    }

                }

                Row {
                    spacing: 5

                    Repeater {
                        model: 3

                        Rectangle {
                            width: 14
                            height: 14
                            radius: Theme.rad(4)
                            color: Theme.bgHigh
                        }

                    }

                }

            }

        }

    }

    // the media module's moving bars, standing still
    component MiniBars: Row {
        spacing: 2.5

        Repeater {
            model: [7, 14, 10]

            Rectangle {
                required property int modelData

                width: 2.5
                height: modelData
                radius: 1.25
                color: Theme.accent
                anchors.verticalCenter: parent.verticalCenter
            }

        }

    }

    // a play button: a triangle on the accent
    component MiniPlay: Rectangle {
        width: 22
        height: 22
        radius: Theme.pill(height)
        color: Theme.accent

        Canvas {
            property color ink: Theme.fgAccent

            anchors.fill: parent
            onInkChanged: requestPaint()
            onPaint: {
                const c = getContext("2d");
                c.reset();
                c.fillStyle = ink;
                c.beginPath();
                c.moveTo(8.5, 6.5);
                c.lineTo(16, 11);
                c.lineTo(8.5, 15.5);
                c.closePath();
                c.fill();
            }
        }

    }

    // a title and a line under it
    component MiniLines: Column {
        spacing: 5

        Rectangle {
            width: parent.width * 0.8
            height: 7
            radius: 3.5
            color: Theme.text
            opacity: 0.8
        }

        Rectangle {
            width: parent.width * 0.5
            height: 6
            radius: 3
            color: Theme.subtextDim
        }

    }

    // a progress track, part played
    component MiniTrack: Rectangle {
        height: 4
        radius: 2
        color: Theme.bgHigh

        Rectangle {
            width: parent.width * 0.4
            height: parent.height
            radius: 2
            color: Theme.accent
        }

    }

    // a panel, shrunk: the frame the panel samples are drawn in
    component MiniPanel: Rectangle {
        width: 150
        height: 90
        radius: Theme.radiusMd
        color: Theme.bg
    }

    // a month, as dots, today in the accent
    component MiniCalendar: Grid {
        columns: 7
        columnSpacing: (width - 7 * 7) / 6
        rowSpacing: (height - 5 * 7) / 4

        Repeater {
            model: 35

            Rectangle {
                required property int index

                width: 7
                height: 7
                radius: 2
                color: index === 17 ? Theme.accent : Theme.bgHigh
            }

        }

    }

    Component {
        id: fallback

        Text {
            text: sample.styleKey
            color: Theme.text
            font.family: Theme.fontFamily
            font.bold: true
            font.pixelSize: Theme.fs(13)
        }

    }

    // a bit of bar text, as the modules set it
    component BarText: Text {
        color: Theme.text
        font.family: Theme.fontFamily
        font.bold: true
        font.pixelSize: Theme.fs(13)
    }

}
