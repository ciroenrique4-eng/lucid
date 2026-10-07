import QtQuick
import qs

Item {
    id: face

    // "apps" | "commands" | "theme" | "wallpaper" | "power" | "clipboard"
    property string mode: "apps"
    property var model: null
    property var wallpaperModel: null
    // Settings -> Theme picks the style; unknown names fall back to the strip
    readonly property var pickerFiles: ({
        "strip": "WallpaperStrip.qml",
        "pills": "WallpaperPills.qml",
        "tiles": "WallpaperTiles.qml",
        "card": "WallpaperCard.qml"
    })
    property int pickerIndex: -1
    readonly property var wallStrip: pickerLoader.item
    property string appliedWallpaper: ""
    property int wallHeroW: 340
    property int wallHeroH: 211
    property int wallMidW: 238
    property int wallMidH: 148
    property int wallSmallW: 150
    property int wallSmallH: 93
    property int wallCardGap: 10
    property alias searchText: searchInput.text
    property string highlightQuery: ""
    readonly property string placeholder: face.displayMode === "clipboard" ? I18n.tr("Search clipboard history") : I18n.tr("Search apps, windows and commands, or type >")
    // power buttons beside the search field
    property bool showPowerChips: false
    // which of them, by id; they keep the order below whatever order these come in
    property var powerButtons: []
    // the power action waiting on its second press, owned by the dock
    property string armedPower: ""
    readonly property var allPowerChips: [{
        "id": "lock",
        "label": I18n.tr("Lock"),
        "confirm": "",
        "glyph": DockIcons.lock,
        "danger": false
    }, {
        "id": "logout",
        "label": I18n.tr("Log out"),
        "confirm": I18n.tr("Log out?"),
        "glyph": DockIcons.logout,
        "danger": true
    }, {
        "id": "suspend",
        "label": I18n.tr("Suspend"),
        "confirm": "",
        "glyph": DockIcons.suspend,
        "danger": false
    }, {
        "id": "hibernate",
        "label": I18n.tr("Hibernate"),
        "confirm": "",
        "glyph": DockIcons.hibernate,
        "danger": false
    }, {
        "id": "reboot",
        "label": I18n.tr("Restart"),
        "confirm": I18n.tr("Restart?"),
        "glyph": DockIcons.reboot,
        "danger": true
    }, {
        "id": "shutdown",
        "label": I18n.tr("Shut down"),
        "confirm": I18n.tr("Shut down?"),
        "glyph": DockIcons.power,
        "danger": true,
        // the one to find at a glance: filled with the palette's primary
        "accent": true
    }]
    readonly property var powerChips: face.allPowerChips.filter((c) => {
        return face.powerButtons.indexOf(c.id) !== -1;
    })
    property real targetWidth: width
    property real targetHeight: height

    readonly property int searchHeight: 44
    readonly property int chromeHeight: face.searchHeight + 12
    readonly property real stableContentHeight: Math.max(0, face.targetHeight - face.chromeHeight)

    property string displayMode: "apps"
    readonly property bool listVisible: face.displayMode !== "wallpaper" && face.displayMode !== "power"
    // clipboard: the first Ctrl+Shift+Del arms clearing everything, a second within 3 s does it
    property bool clearArmed: false
    // bumped whenever the dock rewrites the results, so the preview re-reads the selected row
    property int resultsRevision: 0
    readonly property string clipEntryId: {
        face.resultsRevision;
        const r = face.displayMode === "clipboard" ? resultList.rowAt(resultList.currentIndex) : null;
        return r && r.selectable && r.kind === "clip" ? r.payload : "";
    }
    property bool justOpened: false

    signal activated(int index)
    signal closeRequested()
    signal wallpaperChosen(string path)
    signal wallpaperPreviewed(string path)
    signal powerActionChosen(string id)
    signal backRequested()
    signal deleteRequested(int index)
    signal clearRequested()
    signal favToggleRequested(int index)
    signal appDragStarted()
    signal appDragEnded()
    signal powerChipTapped(string id)

    function rowHeightFor(kind, subtitle) {
        return resultList.heightFor(kind, subtitle);
    }

    function setWallpaperIndex(i) {
        face.pickerIndex = i;
        if (wallStrip)
            wallStrip.setIndexImmediate(i);
    }

    // a picker that was just swapped in (the style changed) starts where the last one was
    function restorePickerIndex() {
        if (wallStrip && face.pickerIndex >= 0)
            wallStrip.setIndexImmediate(face.pickerIndex);
    }

    function resetSelection() {
        resultList.resetSelection();
        powerRow.currentIndex = 0;
    }

    // call before a query rewrites the results, see LauncherList.filtering
    function beginFilter() {
        resultList.beginFilter();
    }

    function resultsChanged() {
        resultList.ensureSelectable();
        face.resultsRevision++;
    }

    function armOrClear() {
        if (face.clearArmed) {
            face.clearArmed = false;
            disarmTimer.stop();
            face.clearRequested();
        } else {
            face.clearArmed = true;
            disarmTimer.restart();
        }
    }

    Timer {
        id: disarmTimer

        interval: 3000
        onTriggered: face.clearArmed = false
    }

    function syncDisplayMode() {
        face.displayMode = face.mode;
        face.clearArmed = false;
        face.resetSelection();
    }

    function requestModeTransition() {
        if (!face.visible || face.justOpened) {
            face.syncDisplayMode();
            return;
        }
        modeFade.restart();
    }

    onModeChanged: face.requestModeTransition()
    onVisibleChanged: {
        if (!face.visible)
            return;

        face.justOpened = true;
        face.syncDisplayMode();
        searchInput.forceActiveFocus();
        face.justOpened = false;
    }

    SequentialAnimation {
        id: modeFade

        NumberAnimation {
            target: contentArea
            property: "opacity"
            to: 0
            duration: Theme.ms(120)
            easing.type: Easing.Bezier
            easing.bezierCurve: Theme.easeEmphasizedAccel
        }

        ScriptAction {
            script: face.syncDisplayMode()
        }

        NumberAnimation {
            target: contentArea
            property: "opacity"
            to: 1
            duration: Theme.ms(240)
            easing.type: Easing.Bezier
            easing.bezierCurve: Theme.easeEmphasizedDecel
        }

    }

    Item {
        id: contentArea

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: searchBar.top
        anchors.bottomMargin: 12
        clip: true

        LauncherList {
            id: resultList

            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            // the clipboard shares the width with its preview
            width: face.displayMode === "clipboard" ? Math.round(parent.width * 0.54) : parent.width
            visible: face.listVisible
            model: face.model
            query: face.highlightQuery
            stableHeight: face.stableContentHeight
            emptyLabel: {
                if (face.displayMode === "commands")
                    return I18n.tr("No commands found");

                if (face.displayMode === "theme")
                    return I18n.tr("No themes found");

                if (face.displayMode === "clipboard")
                    return Clip.available ? I18n.tr("Clipboard history is empty") : I18n.tr("Install cliphist to keep clipboard history");

                return I18n.tr("No apps found");
            }
            onActivated: (index) => face.activated(index)
            onDeleteRequested: (index) => face.deleteRequested(index)
            onFavToggleRequested: (index) => face.favToggleRequested(index)
            onAppDragStarted: face.appDragStarted()
            onAppDragEnded: face.appDragEnded()
        }

        ClipPreview {
            anchors.left: resultList.right
            anchors.leftMargin: 12
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            visible: face.displayMode === "clipboard"
            entryId: face.clipEntryId
            clearArmed: face.clearArmed
        }

        Loader {
            id: pickerLoader

            anchors.fill: parent
            visible: face.displayMode === "wallpaper"
            source: face.pickerFiles[Prefs.wallpaperPickerStyle] || face.pickerFiles.strip
            onLoaded: Qt.callLater(face.restorePickerIndex)
        }

        // the picker styles share one interface; these hand it the panel's numbers
        Binding { target: pickerLoader.item; property: "model"; value: face.wallpaperModel; when: pickerLoader.item !== null }
        Binding { target: pickerLoader.item; property: "heroW"; value: face.wallHeroW; when: pickerLoader.item !== null }
        Binding { target: pickerLoader.item; property: "heroH"; value: face.wallHeroH; when: pickerLoader.item !== null }
        Binding { target: pickerLoader.item; property: "midW"; value: face.wallMidW; when: pickerLoader.item !== null }
        Binding { target: pickerLoader.item; property: "midH"; value: face.wallMidH; when: pickerLoader.item !== null }
        Binding { target: pickerLoader.item; property: "smallW"; value: face.wallSmallW; when: pickerLoader.item !== null }
        Binding { target: pickerLoader.item; property: "smallH"; value: face.wallSmallH; when: pickerLoader.item !== null }
        Binding { target: pickerLoader.item; property: "itemGap"; value: face.wallCardGap; when: pickerLoader.item !== null }
        Binding { target: pickerLoader.item; property: "appliedPath"; value: face.appliedWallpaper; when: pickerLoader.item !== null }
        Binding { target: pickerLoader.item; property: "stableHeight"; value: face.stableContentHeight; when: pickerLoader.item !== null }

        Connections {
            function onChosen(path) {
                face.wallpaperChosen(path);
            }

            function onPreviewed(path) {
                face.wallpaperPreviewed(path);
            }

            function onCurrentIndexChanged() {
                if (pickerLoader.item && !pickerLoader.item.syncing)
                    face.pickerIndex = pickerLoader.item.currentIndex;
            }

            target: pickerLoader.item
            ignoreUnknownSignals: true
        }

        PowerRow {
            id: powerRow

            anchors.fill: parent
            visible: face.displayMode === "power"
            stableHeight: face.stableContentHeight
            onActionChosen: (id) => face.powerActionChosen(id)
        }

    }

    Rectangle {
        id: searchBar

        anchors.left: parent.left
        anchors.right: powerChips.left
        anchors.bottom: parent.bottom
        height: face.searchHeight
        radius: Theme.pill(height)
        color: Theme.withBlur(Theme.bgTile)

        Item {
            id: leadingButton

            readonly property bool isBack: face.mode !== "apps"

            width: 34
            height: 34
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                anchors.fill: parent
                radius: Theme.pill(width)
                color: Theme.text
                opacity: leadingButton.isBack ? (leadTap.pressed ? Theme.statePressed : (leadHover.hovered ? Theme.stateHover : 0)) : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.durQuick
                    }

                }

            }

            DockGlyph {
                anchors.centerIn: parent
                width: 17
                height: 17
                pathData: leadingButton.isBack ? DockIcons.arrowBack : DockIcons.search
                glyphColor: leadingButton.isBack ? Theme.accent : Theme.subtext
            }

            HoverHandler {
                id: leadHover

                enabled: leadingButton.isBack
            }

            TapHandler {
                id: leadTap

                enabled: leadingButton.isBack
                onTapped: face.backRequested()
            }

        }

        TextInput {
            id: searchInput

            anchors.left: leadingButton.right
            anchors.leftMargin: 6
            anchors.right: clearButton.left
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
            font.weight: Font.Medium
            clip: true
            focus: true
            selectByMouse: true
            selectionColor: Theme.alpha(Theme.accent, 0.35)
            selectedTextColor: Theme.text

            onTextChanged: face.resetSelection()
            Keys.onUpPressed: {
                if (face.listVisible)
                    resultList.step(-1);
                else if (face.displayMode === "wallpaper" && wallStrip)
                    wallStrip.stepVertical(-1);

            }
            Keys.onDownPressed: {
                if (face.listVisible)
                    resultList.step(1);
                else if (face.displayMode === "wallpaper" && wallStrip)
                    wallStrip.stepVertical(1);

            }
            Keys.onLeftPressed: (event) => {
                if (face.displayMode === "wallpaper") {
                    if (wallStrip)
                        wallStrip.step(-1);
                    event.accepted = true;
                } else if (face.displayMode === "power") {
                    powerRow.step(-1);
                    event.accepted = true;
                } else {
                    event.accepted = false;
                }
            }
            Keys.onRightPressed: (event) => {
                if (face.displayMode === "wallpaper" && face.wallpaperModel) {
                    if (wallStrip)
                        wallStrip.step(1);
                    event.accepted = true;
                } else if (face.displayMode === "power") {
                    powerRow.step(1);
                    event.accepted = true;
                } else {
                    event.accepted = false;
                }
            }
            Keys.onDeletePressed: (event) => {
                if (face.displayMode === "clipboard" && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier)) {
                    face.armOrClear();
                    event.accepted = true;
                } else if (face.displayMode === "clipboard" && resultList.isSelectable(resultList.currentIndex)) {
                    face.deleteRequested(resultList.currentIndex);
                    event.accepted = true;
                } else {
                    event.accepted = false;
                }
            }
            Keys.onEscapePressed: face.closeRequested()
            Keys.onReturnPressed: face.submit()
            Keys.onEnterPressed: face.submit()

            Text {
                anchors.verticalCenter: parent.verticalCenter
                x: 2
                text: face.placeholder
                color: Theme.subtextDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
                font.weight: Font.Medium
                visible: searchInput.text === ""
                z: -1
            }

        }

        Item {
            id: clearButton

            width: searchInput.text !== "" ? 34 : 0
            height: 34
            anchors.right: parent.right
            anchors.rightMargin: searchInput.text !== "" ? 5 : 0
            anchors.verticalCenter: parent.verticalCenter
            visible: searchInput.text !== ""

            Rectangle {
                anchors.fill: parent
                radius: Theme.pill(height)
                color: Theme.text
                opacity: clearTap.pressed ? Theme.statePressed : (clearHover.hovered ? Theme.stateHover : 0)

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.durQuick
                    }

                }

            }

            DockGlyph {
                anchors.centerIn: parent
                width: 15
                height: 15
                pathData: DockIcons.close
                glyphColor: clearHover.hovered ? Theme.text : Theme.subtext
            }

            HoverHandler {
                id: clearHover
            }

            TapHandler {
                id: clearTap

                onTapped: {
                    searchInput.text = "";
                    searchInput.forceActiveFocus();
                }
            }

            Behavior on width {
                NumberAnimation {
                    duration: Theme.durShort
                    easing.type: Easing.OutCubic
                }

            }

        }

    }

    // beside the search field while it searches; the wider modes take the room back
    Item {
        id: powerChips

        readonly property bool shown: face.showPowerChips && face.powerChips.length > 0 && (face.mode === "apps" || face.mode === "commands")
        property real reveal: powerChips.shown ? 1 : 0

        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: face.searchHeight
        // the gap to the search field folds away with the chips
        width: (chipRow.width + 8) * powerChips.reveal
        visible: powerChips.reveal > 0
        clip: true

        Row {
            id: chipRow

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6
            opacity: powerChips.reveal

            Repeater {
                model: face.powerChips

                delegate: Item {
                    id: chip

                    required property var modelData

                    readonly property bool armed: face.armedPower === chip.modelData.id
                    // the label slides out on hover, and stays out while it waits on a second click
                    readonly property bool open: chipHover.hovered || chip.armed
                    readonly property color tone: chip.modelData.danger ? Theme.error : Theme.accent
                    // armed, it drops the fill so the red confirmation still reads
                    readonly property bool filled: chip.modelData.accent === true && !chip.armed

                    width: face.searchHeight + (chip.open ? chipLabel.implicitWidth + 12 : 0)
                    height: face.searchHeight
                    clip: true

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.pill(height)
                        color: chip.filled ? Theme.accent : Theme.withBlur(Theme.bgTile)

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.durShort
                            }

                        }

                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.pill(height)
                        color: chip.armed ? chip.tone : (chip.filled ? Theme.fgAccent : Theme.text)
                        opacity: chip.armed ? Theme.stateFocus : (chipTap.pressed ? Theme.statePressed : (chipHover.hovered ? Theme.stateHover : 0))

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Theme.durQuick
                            }

                        }

                    }

                    DockGlyph {
                        x: Math.round((face.searchHeight - width) / 2)
                        anchors.verticalCenter: parent.verticalCenter
                        width: 18
                        height: 18
                        pathData: chip.modelData.glyph
                        glyphColor: chip.filled ? Theme.fgAccent : (chip.open ? chip.tone : Theme.subtext)

                        Behavior on glyphColor {
                            ColorAnimation {
                                duration: Theme.durShort
                            }

                        }

                    }

                    Text {
                        id: chipLabel

                        x: face.searchHeight - 6
                        anchors.verticalCenter: parent.verticalCenter
                        text: chip.armed ? chip.modelData.confirm : chip.modelData.label
                        color: chip.armed ? chip.tone : (chip.filled ? Theme.fgAccent : Theme.text)
                        opacity: chip.open ? 1 : 0
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontLabel
                        font.weight: Font.Medium

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Theme.durShort
                            }

                        }

                    }

                    HoverHandler {
                        id: chipHover
                    }

                    TapHandler {
                        id: chipTap

                        onTapped: face.powerChipTapped(chip.modelData.id)
                    }

                    Behavior on width {
                        NumberAnimation {
                            duration: Theme.durShort
                            easing.type: Easing.OutCubic
                        }

                    }

                }

            }

        }

        Behavior on reveal {
            NumberAnimation {
                duration: Theme.durShort
                easing.type: Easing.OutCubic
            }

        }

    }

    function submit() {
        if (face.displayMode === "wallpaper") {
            if (wallStrip)
                wallStrip.activateCurrent();
        }
        else if (face.displayMode === "power")
            powerRow.activateCurrent();
        else
            resultList.activateCurrent();
    }

}
