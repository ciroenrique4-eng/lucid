import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs

Column {
    id: page

    readonly property string home: Quickshell.env("HOME")
    readonly property string currentTheme: Prefs.currentTheme
    readonly property var modeOptions: [{
        "key": "dark",
        "label": I18n.tr("Dark")
    }, {
        "key": "light",
        "label": I18n.tr("Light")
    }]
    // the two wallpaper-derived themes re-extract; everything else is authored
    // dark and gets a light variant built from its own colours
    readonly property string modeHint: page.currentTheme === "matugen" || page.currentTheme === "pywal" ? I18n.tr("Re-derives the palette from your wallpaper in the mode you pick. Applications are asked to match.") : (page.currentTheme === "colour" ? I18n.tr("Builds the palette from your colour again in the mode you pick. Applications are asked to match.") : I18n.tr("Builds a light palette from this theme's own colours. Applications are asked to match."))
    property string appliedWallpaper: ""
    // same folder the dock's wallpaper strip browses
    readonly property string wallpaperDir: Prefs.wallpaperDir
    function applyTheme(id) {
        if (id === page.currentTheme)
            return ;

        Prefs.themeChangeRequested(id);
    }

    function applyWallpaper(path) {
        if (path === "")
            return;

        Quickshell.execDetached([page.home + "/.config/hypr/scripts/wallpaper/set-wallpaper.sh", path]);
    }

    spacing: 26

    onWallpaperDirChanged: wallpaperScan.restart()

    Process {
        id: themeDelete

        stdout: StdioCollector {
            onStreamFinished: Prefs.rescanThemes()
        }

    }

    Connections {
        function onThemeDeleteRequested(id) {
            themeDelete.running = false;
            themeDelete.command = ["sh", "-c", "rm -rf \"" + page.home + "/.config/lucid/themes/" + id + "\"; echo done"];
            themeDelete.running = true;
        }

        target: Prefs
    }

    Process {
        id: wallpaperScan

        function restart() {
            wallpaperScan.running = false;
            wallpaperScan.command = ["sh", "-c", "d=\"" + page.wallpaperDir + "\"; [ -d \"$d\" ] || exit 0; find \"$d\" -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) | sort"];
            wallpaperScan.running = true;
        }

        stdout: StdioCollector {
            onStreamFinished: {
                wallpapers.clear();
                var lines = text.split("\n");
                for (var i = 0; i < lines.length; i++) {
                    var p = lines[i].trim();
                    if (p === "")
                        continue;

                    var base = p.substring(p.lastIndexOf("/") + 1);
                    var dot = base.lastIndexOf(".");
                    wallpapers.append({
                        "path": p,
                        "name": dot > 0 ? base.substring(0, dot) : base
                    });
                }
            }
        }

    }

    Process {
        id: wallpaperPicker

        stdout: StdioCollector {
            onStreamFinished: {
                var chosen = text.trim();
                if (chosen === "")
                    return;

                wallpaperImport.command = ["sh", "-c", "mkdir -p \"" + page.wallpaperDir + "\" && cp -n \"" + chosen + "\" \"" + page.wallpaperDir + "/\" && echo \"" + page.wallpaperDir + "/$(basename \"" + chosen + "\")\""];
                wallpaperImport.running = true;
            }
        }

    }

    Process {
        id: wallpaperImport

        stdout: StdioCollector {
            onStreamFinished: {
                var added = text.trim();
                wallpaperScan.restart();
                Prefs.wallpapersChanged();
                if (added !== "")
                    page.applyWallpaper(added);

            }
        }

    }

    FileView {
        path: page.home + "/.cache/current_wallpaper"
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
        onLoaded: page.appliedWallpaper = text().trim()
    }

    Process {
        id: wallpaperDelete

        stdout: StdioCollector {
            onStreamFinished: {
                wallpaperScan.restart();
                Prefs.wallpapersChanged();
            }
        }

    }

    Connections {
        function onWallpaperDeleteRequested(path) {
            wallpaperDelete.running = false;
            wallpaperDelete.command = ["sh", "-c", "gio trash \"" + path + "\" 2>/dev/null || rm -f \"" + path + "\"; echo done"];
            wallpaperDelete.running = true;
        }

        target: Prefs
    }

    ListModel {
        id: wallpapers
    }

    // the grid reorders this in place, so it cannot just bind to the catalogue
    ListModel {
        id: themeTiles
    }

    function syncThemeTiles() {
        // never yank the tiles out from under a drag in progress
        if (themeGrid.dragging)
            return;

        themeTiles.clear();
        var c = Prefs.themeCatalogue;
        for (var i = 0; i < c.length; i++) {
            themeTiles.append({
                "themeId": c[i].id,
                "themeName": c[i].name,
                "tileBg": c[i].swatchBg,
                "tileAccent": c[i].swatchAccent,
                "isUser": c[i].user === true
            });
        }
    }

    Connections {
        function onThemeCatalogueChanged() {
            page.syncThemeTiles();
        }

        target: Prefs
    }

    Component.onCompleted: {
        wallpaperScan.restart();
        page.syncThemeTiles();
    }

    SettingCard {
        title: I18n.tr("THEME")

        SettingRow {
            title: I18n.tr("Light or dark")
            description: page.modeHint

            M3Segmented {
                width: 200
                current: Prefs.colorMode
                options: page.modeOptions
                onChosen: (key) => {
                    return Prefs.setColorMode(key);
                }
            }

        }

        SettingRow {
            title: I18n.tr("Colour scheme")
            description: I18n.tr("Switching also swaps the wallpaper folder below to that theme's own.")
            showDivider: false
            stacked: true

            Item {
                id: themeGrid

                readonly property int tileW: 150
                readonly property int tileH: 60
                readonly property int gap: 10
                readonly property int perRow: Math.max(1, Math.floor((themeGrid.width + themeGrid.gap) / (themeGrid.tileW + themeGrid.gap)))
                property bool dragging: false

                width: parent.width
                height: Math.max(0, Math.ceil(themeTiles.count / themeGrid.perRow) * (themeGrid.tileH + themeGrid.gap) - themeGrid.gap)

                function commitOrder() {
                    var ids = [];
                    for (var i = 0; i < themeTiles.count; i++) ids.push(themeTiles.get(i).themeId);
                    Prefs.setThemeOrder(ids);
                }

                Repeater {
                    model: themeTiles

                    Rectangle {
                        id: swatch

                        required property string themeId
                        required property string themeName
                        required property string tileBg
                        required property string tileAccent
                        required property bool isUser
                        required property int index

                        readonly property bool selected: page.currentTheme === swatch.themeId
                        readonly property real targetX: (swatch.index % themeGrid.perRow) * (themeGrid.tileW + themeGrid.gap)
                        readonly property real targetY: Math.floor(swatch.index / themeGrid.perRow) * (themeGrid.tileH + themeGrid.gap)

                        // the tile owns x/y while dragging; the Binding takes them back after
                        function reindex() {
                            if (!themeDrag.active)
                                return;

                            var col = Math.round(swatch.x / (themeGrid.tileW + themeGrid.gap));
                            var rowIdx = Math.round(swatch.y / (themeGrid.tileH + themeGrid.gap));
                            col = Math.max(0, Math.min(themeGrid.perRow - 1, col));
                            var candidate = Math.max(0, Math.min(themeTiles.count - 1, rowIdx * themeGrid.perRow + col));
                            if (candidate !== swatch.index)
                                themeTiles.move(swatch.index, candidate, 1);

                        }

                        width: themeGrid.tileW
                        height: themeGrid.tileH
                        radius: Theme.radiusMd
                        z: themeDrag.active ? 10 : 1
                        scale: themeDrag.active ? 1.05 : 1
                        color: swatch.selected ? Theme.accentContainer : (swatchHover.hovered ? Theme.bgHover : Theme.bgSunken)
                        onXChanged: swatch.reindex()
                        onYChanged: swatch.reindex()

                        Binding {
                            target: swatch
                            property: "x"
                            value: swatch.targetX
                            when: !themeDrag.active
                        }

                        Binding {
                            target: swatch
                            property: "y"
                            value: swatch.targetY
                            when: !themeDrag.active
                        }

                        Behavior on x {
                            enabled: !themeDrag.active

                            NumberAnimation {
                                duration: Theme.ms(220)
                                easing.type: Easing.OutCubic
                            }

                        }

                        Behavior on y {
                            enabled: !themeDrag.active

                            NumberAnimation {
                                duration: Theme.ms(220)
                                easing.type: Easing.OutCubic
                            }

                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: Theme.durShort
                                easing.type: Easing.OutCubic
                            }

                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.durShort
                            }

                        }

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10

                            Rectangle {
                                width: 28
                                height: 28
                                radius: Theme.rad(14)
                                anchors.verticalCenter: parent.verticalCenter
                                color: swatch.tileBg

                                Rectangle {
                                    width: 12
                                    height: 12
                                    radius: 6
                                    anchors.centerIn: parent
                                    color: swatch.tileAccent
                                }

                            }

                            Text {
                                width: 90
                                anchors.verticalCenter: parent.verticalCenter
                                text: swatch.themeName
                                color: swatch.selected ? Theme.text : Theme.subtext
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontLabel
                                font.bold: swatch.selected
                                wrapMode: Text.WordWrap
                            }

                        }

                        HoverHandler {
                            id: swatchHover

                            cursorShape: themeDrag.active ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                        }

                        DragHandler {
                            id: themeDrag

                            target: swatch
                            xAxis.minimum: 0
                            xAxis.maximum: Math.max(0, themeGrid.width - themeGrid.tileW)
                            yAxis.minimum: 0
                            yAxis.maximum: Math.max(0, themeGrid.height - themeGrid.tileH)
                            onActiveChanged: {
                                themeGrid.dragging = themeDrag.active;
                                if (!themeDrag.active)
                                    themeGrid.commitOrder();

                            }
                        }

                        TapHandler {
                            onTapped: page.applyTheme(swatch.themeId)
                        }

                        Rectangle {
                            id: themeDel

                            readonly property bool shown: swatch.isUser && swatchHover.hovered && !themeDrag.active

                            width: 22
                            height: 22
                            radius: Theme.rad(11)
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 6
                            color: delHover.hovered ? Theme.error : Theme.alpha(Theme.cShadow, 0.65)
                            opacity: themeDel.shown ? 1 : 0
                            visible: themeDel.opacity > 0.01
                            scale: themeDel.shown ? 1 : 0.7

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: Theme.durQuick
                                }

                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: Theme.durShort
                                    easing.type: Theme.easeEmphasized
                                    easing.overshoot: Theme.emphasizedOvershoot
                                }

                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.durQuick
                                }

                            }

                            Repeater {
                                model: [45, -45]

                                Rectangle {
                                    required property int modelData

                                    width: 10
                                    height: 1.8
                                    radius: 0.9
                                    anchors.centerIn: parent
                                    color: delHover.hovered ? Theme.fgError : "white"
                                    rotation: modelData
                                }

                            }

                            HoverHandler {
                                id: delHover

                                cursorShape: Qt.PointingHandCursor
                            }

                            TapHandler {
                                gesturePolicy: TapHandler.ReleaseWithinBounds
                                onTapped: Prefs.askConfirm(I18n.tr("Remove this theme?"), I18n.tr("\"%1\" and its generated palette are deleted. The wallpaper folder is left alone.", swatch.themeName), I18n.tr("Remove"), "theme:" + swatch.themeId)
                            }

                        }

                    }

                }

            }

        }

    }

    SettingCard {
        title: I18n.tr("MORE ON COLOUR")

        SettingRow {
            title: I18n.tr("Palettes and applications")
            description: I18n.tr("How Matugen and Your colour build a palette, which applications follow it, and templates of your own.")

            M3Button {
                text: I18n.tr("Colours")
                variant: "tonal"
                onClicked: Prefs.settingsRequested("colours")
            }

        }

        SettingRow {
            title: I18n.tr("More themes")
            description: I18n.tr("A gallery of hundreds of schemes, and importing one from a repo or a file.")
            showDivider: false

            M3Button {
                text: I18n.tr("Palettes")
                variant: "tonal"
                onClicked: Prefs.settingsRequested("palettes")
            }

        }

    }

    SettingCard {
        title: I18n.tr("WALLPAPER")

        SettingRow {
            title: I18n.tr("Wallpaper strip")
            description: I18n.tr("%1 in %2", wallpapers.count, page.wallpaperDir.replace(page.home, "~"))
            stacked: true

            Column {
                width: parent.width
                spacing: 14

                Flow {
                    width: parent.width
                    spacing: 10

                    Repeater {
                        model: wallpapers

                        Rectangle {
                            id: tile

                            required property string path
                            required property string name

                            readonly property bool selected: page.appliedWallpaper === tile.path

                            width: 150
                            height: 88
                            radius: Theme.radiusSm
                            color: Theme.bgSunken

                            ClippingRectangle {
                                anchors.fill: parent
                                radius: tile.radius
                                color: "transparent"

                                Image {
                                    id: thumb

                                    anchors.fill: parent
                                    source: "file://" + tile.path
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: true
                                    sourceSize.width: 300
                                    sourceSize.height: 176
                                    visible: thumb.status === Image.Ready
                                }

                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: "transparent"
                                border.width: tile.selected ? 3 : (tileArea.containsMouse ? 2 : 0)
                                border.color: tile.selected ? Theme.accent : Theme.alpha(Theme.text, 0.5)

                                Behavior on border.width {
                                    NumberAnimation {
                                        duration: Theme.durQuick
                                    }

                                }

                            }

                            MouseArea {
                                id: tileArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: page.applyWallpaper(tile.path)
                            }

                            Rectangle {
                                id: delBtn

                                readonly property bool active: tileArea.containsMouse || delArea.containsMouse

                                width: 28
                                height: 28
                                radius: Theme.rad(14)
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 6
                                color: delArea.containsMouse ? Theme.error : Theme.alpha(Theme.cShadow, 0.65)
                                opacity: delBtn.active ? 1 : 0
                                visible: opacity > 0.01
                                scale: delBtn.active ? 1 : 0.7

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: Theme.durQuick
                                    }

                                }

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: Theme.durShort
                                        easing.type: Theme.easeEmphasized
                                        easing.overshoot: Theme.emphasizedOvershoot
                                    }

                                }

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Theme.durQuick
                                    }

                                }

                                Item {
                                    id: bin

                                    readonly property color glyph: delArea.containsMouse ? Theme.fgError : "white"
                                    // authored on a 24x24 grid, drawn at 16
                                    readonly property real unit: 16 / 24
                                    readonly property real stroke: 2.4
                                    property real lidAngle: delArea.containsMouse ? 32 : 0
                                    property real lidLift: delArea.containsMouse ? -1.4 : 0

                                    anchors.centerIn: parent
                                    width: 16
                                    height: 16

                                    Behavior on lidAngle {
                                        NumberAnimation {
                                            duration: Theme.durMedium
                                            easing.type: Theme.easeEmphasized
                                            easing.overshoot: 1.5
                                        }

                                    }

                                    Behavior on lidLift {
                                        NumberAnimation {
                                            duration: Theme.durMedium
                                            easing.type: Theme.easeEmphasized
                                            easing.overshoot: 1.5
                                        }

                                    }

                                    Shape {
                                        anchors.fill: parent
                                        preferredRendererType: Shape.CurveRenderer

                                        ShapePath {
                                            strokeColor: bin.glyph
                                            strokeWidth: bin.stroke
                                            fillColor: "transparent"
                                            capStyle: ShapePath.RoundCap
                                            joinStyle: ShapePath.RoundJoin

                                            PathSvg {
                                                path: "M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6"
                                            }

                                        }

                                        ShapePath {
                                            strokeColor: bin.glyph
                                            strokeWidth: bin.stroke
                                            fillColor: "transparent"
                                            capStyle: ShapePath.RoundCap

                                            PathSvg {
                                                path: "M10 11v6"
                                            }

                                        }

                                        ShapePath {
                                            strokeColor: bin.glyph
                                            strokeWidth: bin.stroke
                                            fillColor: "transparent"
                                            capStyle: ShapePath.RoundCap

                                            PathSvg {
                                                path: "M14 11v6"
                                            }

                                        }

                                        transform: Scale {
                                            xScale: bin.unit
                                            yScale: bin.unit
                                        }

                                    }

                                    Item {
                                        anchors.fill: parent

                                        transform: Rotation {
                                            origin.x: 21 * bin.unit
                                            origin.y: 6 * bin.unit
                                            angle: bin.lidAngle
                                        }

                                        Shape {
                                            anchors.fill: parent
                                            y: bin.lidLift
                                            preferredRendererType: Shape.CurveRenderer

                                            ShapePath {
                                                strokeColor: bin.glyph
                                                strokeWidth: bin.stroke
                                                fillColor: "transparent"
                                                capStyle: ShapePath.RoundCap

                                                PathSvg {
                                                    path: "M3 6h18"
                                                }

                                            }

                                            ShapePath {
                                                strokeColor: bin.glyph
                                                strokeWidth: bin.stroke
                                                fillColor: "transparent"
                                                capStyle: ShapePath.RoundCap
                                                joinStyle: ShapePath.RoundJoin

                                                PathSvg {
                                                    path: "M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"
                                                }

                                            }

                                            transform: Scale {
                                                xScale: bin.unit
                                                yScale: bin.unit
                                            }

                                        }

                                    }

                                }

                                MouseArea {
                                    id: delArea

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Prefs.askConfirm(I18n.tr("Delete this wallpaper?"), I18n.tr("\"%1\" is moved to the trash, so it can be restored from there if you change your mind.", tile.name), I18n.tr("Delete"), "wallpaper:" + tile.path)
                                }

                            }

                        }

                    }

                }

                Text {
                    text: I18n.tr("No images in this folder yet - add one below.")
                    color: Theme.subtext
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                    visible: wallpapers.count === 0
                }

                Row {
                    spacing: 10

                    M3Button {
                        text: I18n.tr("Add wallpaper...")
                        variant: "filled"
                        iconPath: "M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2Z"
                        onClicked: {
                            wallpaperPicker.command = ["sh", "-c", "zenity --file-selection --title='Add wallpaper' --file-filter='Images | *.jpg *.jpeg *.png *.webp *.JPG *.PNG' 2>/dev/null || true"];
                            wallpaperPicker.running = true;
                        }
                    }

                    M3Button {
                        text: I18n.tr("Open folder")
                        onClicked: Quickshell.execDetached(["sh", "-c", "xdg-open '" + page.wallpaperDir + "'"])
                    }

                    M3Button {
                        text: I18n.tr("Rescan")
                        variant: "text"
                        onClicked: wallpaperScan.restart()
                    }

                }

            }

        }

        SettingRow {
            title: I18n.tr("Custom folder")
            description: I18n.tr("Leave empty to follow the current theme's own wallpaper folder.")
            showDivider: false

            M3TextField {
                width: 260
                text: Prefs.wallpaperFolder
                placeholder: "~/Pictures/wallpapers/" + page.currentTheme // i18n-skip
                onAccepted: (v) => {
                    return Prefs.wallpaperFolder = v.trim().replace("~", page.home);
                }
            }

        }

    }

    SettingCard {
        title: I18n.tr("WALLPAPER PICKER")

        SettingRow {
            title: I18n.tr("Picker style")
            description: I18n.tr("How the wallpapers are laid out when you open the picker from the launcher.")
            stacked: true

            Flow {
                width: parent.width
                spacing: 10

                WallpaperStyleThumb {
                    styleId: "strip"
                    label: I18n.tr("Strip")
                }

                WallpaperStyleThumb {
                    styleId: "pills"
                    label: I18n.tr("Pills")
                }

                WallpaperStyleThumb {
                    styleId: "tiles"
                    label: I18n.tr("Tiles")
                }

                WallpaperStyleThumb {
                    styleId: "bento"
                    label: I18n.tr("Bento")
                }

            }

        }

        SettingRow {
            title: I18n.tr("Pill shape")
            description: I18n.tr("How tall the pills are around the open one: all alike, the full height of the panel, or rising to a peak.")
            visible: Prefs.wallpaperPickerStyle === "pills"
            showDivider: false
            stacked: true

            M3Segmented {
                width: Math.min(parent.width, 560)
                current: Prefs.wallpaperPillsShape
                options: [{
                    "key": "uniform",
                    "label": I18n.tr("Uniform")
                }, {
                    "key": "full",
                    "label": I18n.tr("Full height")
                }, {
                    "key": "wave",
                    "label": I18n.tr("Wave")
                }]
                onChosen: (key) => Prefs.wallpaperPillsShape = key
            }

        }

        SettingRow {
            title: I18n.tr("Step")
            description: I18n.tr("How quickly the cards shrink away from the middle one.")
            visible: Prefs.wallpaperPickerStyle === "strip"
            stacked: true

            M3Segmented {
                width: Math.min(parent.width, 420)
                current: Prefs.wallpaperStripSteps
                options: [{
                    "key": "soft",
                    "label": I18n.tr("Soft")
                }, {
                    "key": "normal",
                    "label": I18n.tr("Normal")
                }, {
                    "key": "steep",
                    "label": I18n.tr("Marked")
                }]
                onChosen: (key) => Prefs.wallpaperStripSteps = key
            }

        }

        SettingRow {
            title: I18n.tr("Neighbours")
            description: I18n.tr("How many cards show on each side of the middle one.")
            visible: Prefs.wallpaperPickerStyle === "strip"
            showDivider: false
            stacked: true

            M3Segmented {
                width: Math.min(parent.width, 240)
                current: Prefs.wallpaperStripSides
                options: [{
                    "key": 2,
                    "label": String(2)
                }, {
                    "key": 3,
                    "label": String(3)
                }]
                onChosen: (key) => Prefs.wallpaperStripSides = key
            }

        }

        SettingRow {
            title: I18n.tr("Rows")
            description: I18n.tr("How many rows of tiles the picker shows.")
            visible: Prefs.wallpaperPickerStyle === "tiles"
            stacked: true

            M3Segmented {
                width: Math.min(parent.width, 360)
                current: Math.max(2, Math.min(5, Math.round(Prefs.wallpaperTilesRows) || 2))
                options: [{
                    "key": 2,
                    "label": String(2)
                }, {
                    "key": 3,
                    "label": String(3)
                }, {
                    "key": 4,
                    "label": String(4)
                }, {
                    "key": 5,
                    "label": String(5)
                }]
                onChosen: (key) => Prefs.wallpaperTilesRows = key
            }

        }

        SettingRow {
            title: I18n.tr("Tile shape")
            description: I18n.tr("Square tiles, or wide ones that show more of each picture.")
            visible: Prefs.wallpaperPickerStyle === "tiles"
            showDivider: false
            stacked: true

            M3Segmented {
                width: Math.min(parent.width, 320)
                current: Prefs.wallpaperTilesAspect
                options: [{
                    "key": "square",
                    "label": I18n.tr("Square")
                }, {
                    "key": "wide",
                    "label": I18n.tr("Wide")
                }]
                onChosen: (key) => Prefs.wallpaperTilesAspect = key
            }

        }

        SettingRow {
            title: I18n.tr("Main wallpaper")
            description: I18n.tr("How much of the panel the selected wallpaper takes.")
            visible: Prefs.wallpaperPickerStyle === "bento"
            stacked: true

            M3Segmented {
                width: Math.min(parent.width, 420)
                current: Prefs.wallpaperBentoHero
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
                onChosen: (key) => Prefs.wallpaperBentoHero = key
            }

        }

        SettingRow {
            title: I18n.tr("Show previous")
            description: I18n.tr("Keep the two wallpapers before the selected one at the edge, or give their room to the rest.")
            visible: Prefs.wallpaperPickerStyle === "bento"
            showDivider: false

            M3Switch {
                checked: Prefs.wallpaperBentoPrev
                onToggled: (v) => {
                    return Prefs.wallpaperBentoPrev = v;
                }
            }

        }

    }

    SettingCard {
        id: transCard

        readonly property string type: Prefs.wallTransType
        readonly property bool fades: transCard.type === "none" || transCard.type === "simple"

        title: I18n.tr("WALLPAPER TRANSITION")

        SettingRow {
            title: I18n.tr("Presets")
            description: I18n.tr("A starting point; changing anything below makes it your own.")
            stacked: true

            Flow {
                width: parent.width
                spacing: 10

                Repeater {
                    model: WallTransitions.all

                    WallTransitionTile {
                        required property var modelData

                        preset: modelData
                    }

                }

            }

        }

        SettingRow {
            title: I18n.tr("Effect")
            description: I18n.tr("Fade and Simple blend the two pictures; the others reveal the new one from a side, a line or a circle.")
            stacked: true

            M3Chips {
                width: parent.width
                current: Prefs.wallTransType
                options: [{
                    "key": "fade",
                    "label": I18n.tr("Fade")
                }, {
                    "key": "simple",
                    "label": I18n.tr("Simple")
                }, {
                    "key": "none",
                    "label": I18n.tr("None")
                }, {
                    "key": "left",
                    "label": I18n.tr("From left")
                }, {
                    "key": "right",
                    "label": I18n.tr("From right")
                }, {
                    "key": "top",
                    "label": I18n.tr("From top")
                }, {
                    "key": "bottom",
                    "label": I18n.tr("From bottom")
                }, {
                    "key": "wipe",
                    "label": I18n.tr("Wipe")
                }, {
                    "key": "wave",
                    "label": I18n.tr("Wave")
                }, {
                    "key": "grow",
                    "label": I18n.tr("Grow")
                }, {
                    "key": "outer",
                    "label": I18n.tr("Shrink")
                }, {
                    "key": "random",
                    "label": I18n.tr("Random")
                }]
                onChosen: (key) => WallTransitions.set("type", key)
            }

        }

        SettingRow {
            title: I18n.tr("Duration")
            visible: !transCard.fades
            stacked: true

            M3Slider {
                width: parent.width
                from: 0.2
                to: 5
                stepSize: 0.1
                decimals: 1
                suffix: " s"
                value: Prefs.wallTransDuration
                onMoved: (v) => WallTransitions.set("duration", Math.round(v * 10) / 10)
            }

        }

        SettingRow {
            title: I18n.tr("Angle")
            description: I18n.tr("0° sweeps right to left, 90° top to bottom.")
            visible: transCard.type === "wipe" || transCard.type === "wave"
            stacked: true

            M3Slider {
                width: parent.width
                from: 0
                to: 355
                stepSize: 5
                suffix: "°"
                value: Prefs.wallTransAngle
                onMoved: (v) => WallTransitions.set("angle", Math.round(v))
            }

        }

        SettingRow {
            title: I18n.tr("Wave size")
            visible: transCard.type === "wave"
            stacked: true

            M3Slider {
                width: parent.width
                from: 8
                to: 80
                stepSize: 2
                suffix: " px"
                value: parseInt(Prefs.wallTransWave.split(",")[0]) || 20
                onMoved: (v) => WallTransitions.set("wave", Math.round(v) + "," + Math.round(v))
            }

        }

        SettingRow {
            title: I18n.tr("Starts from")
            description: I18n.tr("Where the circle opens. \"Chosen card\" grows it from the wallpaper you are previewing in the picker.")
            visible: transCard.type === "grow" || transCard.type === "outer"
            stacked: true

            M3Segmented {
                width: Math.min(parent.width, 560)
                current: Prefs.wallTransOrigin
                options: [{
                    "key": "center",
                    "label": I18n.tr("Centre")
                }, {
                    "key": "card",
                    "label": I18n.tr("Chosen card")
                }, {
                    "key": "cursor",
                    "label": I18n.tr("Pointer")
                }]
                onChosen: (key) => WallTransitions.set("origin", key)
            }

        }

        SettingRow {
            title: I18n.tr("Curve")
            description: I18n.tr("How the change speeds up and slows down.")
            visible: !transCard.fades
            stacked: true

            M3Segmented {
                width: Math.min(parent.width, 560)
                current: Prefs.wallTransBezier
                options: [{
                    "key": ".54,0,.34,.99",
                    "label": I18n.tr("Smooth")
                }, {
                    "key": ".05,.7,.1,1",
                    "label": I18n.tr("Snappy")
                }, {
                    "key": ".4,0,.2,1",
                    "label": I18n.tr("Gentle")
                }, {
                    "key": "0,0,1,1",
                    "label": I18n.tr("Linear")
                }]
                onChosen: (key) => WallTransitions.set("bezier", key)
            }

        }

        SettingRow {
            title: I18n.tr("Save as preset")
            description: I18n.tr("Keep the settings above under a name of your own.")

            Row {
                spacing: 10

                M3TextField {
                    id: presetName

                    width: 200
                    placeholder: I18n.tr("Preset name")
                    onAccepted: (v) => {
                        WallTransitions.saveCurrent(v);
                        presetName.text = "";
                    }
                }

                M3Button {
                    text: I18n.tr("Save")
                    variant: "tonal"
                    onClicked: {
                        WallTransitions.saveCurrent(presetName.text);
                        presetName.text = "";
                    }
                }

            }

        }

        SettingRow {
            title: I18n.tr("Try it")
            description: I18n.tr("Plays the transition from a flat colour taken from your wallpaper into it.")
            showDivider: false

            M3Button {
                text: I18n.tr("Try transition")
                variant: "tonal"
                onClicked: {
                    if (page.appliedWallpaper !== "")
                        Quickshell.execDetached(["env", "WALL_DEMO=1", page.home + "/.config/hypr/scripts/wallpaper/set-wallpaper.sh", page.appliedWallpaper]);
                }
            }

        }

    }

}
