import QtQuick
import Quickshell.Widgets
import qs

// The wallpaper picker as one big card with a row of pills under it. Stepping
// squeezes the card, swaps the picture while it is small and lets it spring back;
// the pill for the current wallpaper is the long one. Same interface as
// WallpaperStrip, so the launcher can load either.
Item {
    id: strip

    property var model: null
    property int heroW: 340
    property int heroH: 211
    // the tiers of the strip style; a single card has none, but the launcher sets them
    property int midW: 238
    property int midH: 148
    property int smallW: 150
    property int smallH: 93
    property int itemGap: 10
    property int hoveredIndex: -1
    property int currentIndex: -1
    property string appliedPath: ""
    property real stableHeight: height
    property int previewInterval: 300
    property string pendingPreviewPath: ""
    property bool syncing: false
    property real originX: -1
    property real originY: -1
    // what the card shows right now; it trails currentIndex by half a squeeze
    property string shownPath: ""
    readonly property int count: strip.model ? strip.model.count : 0
    // past this many wallpapers the pills show a window around the current one
    readonly property int maxPills: 12
    readonly property int pillWindow: 9
    readonly property int pillCount: Math.min(strip.count, strip.count > strip.maxPills ? strip.pillWindow : strip.count)
    readonly property int pillFirst: strip.count > strip.maxPills ? Math.max(0, Math.min(strip.count - strip.pillWindow, strip.currentIndex - Math.floor(strip.pillWindow / 2))) : 0
    readonly property real rowHeight: strip.heroH + 62

    signal chosen(string path)
    signal previewed(string path)

    function noteOrigin(item) {
        if (!item || strip.Window.width <= 0 || strip.Window.height <= 0) {
            strip.originX = -1;
            strip.originY = -1;
            return;
        }
        var p = item.mapToItem(null, item.width / 2, item.height / 2);
        strip.originX = p.x / strip.Window.width;
        strip.originY = p.y / strip.Window.height;
    }

    function step(d) {
        if (strip.count > 0)
            strip.currentIndex = Math.max(0, Math.min(strip.count - 1, strip.currentIndex + d));
    }

    function stepVertical(d) {
    }

    function pathAt(i) {
        var item = (strip.model && i >= 0 && i < strip.count) ? strip.model.get(i) : null;
        return item ? item.path : "";
    }

    function activateCurrent() {
        var path = strip.pathAt(strip.currentIndex);
        if (path === "")
            return;

        strip.noteOrigin(card);
        strip.chosen(path);
    }

    function setIndexImmediate(i) {
        strip.syncing = true;
        previewThrottle.stop();
        strip.pendingPreviewPath = "";
        squeeze.stop();
        card.squeezed = 0;
        strip.currentIndex = i;
        strip.shownPath = strip.pathAt(i);
        restoreAnim.restart();
    }

    function emitPreview() {
        if (strip.pendingPreviewPath === "")
            return;

        // the transition can grow from the card being previewed
        strip.noteOrigin(card);
        strip.previewed(strip.pendingPreviewPath);
        strip.pendingPreviewPath = "";
    }

    // the model arrives after the picker does: show whatever is current once it has
    onCountChanged: {
        if (strip.count > 0 && strip.currentIndex < 0)
            strip.currentIndex = 0;

        if (strip.count > 0 && strip.shownPath === "")
            strip.shownPath = strip.pathAt(strip.currentIndex);

    }
    onCurrentIndexChanged: {
        if (strip.syncing || strip.currentIndex < 0 || strip.count === 0)
            return;

        var path = strip.pathAt(strip.currentIndex);
        if (path === "")
            return;

        strip.pendingPreviewPath = path;
        previewThrottle.restart();
        if (strip.shownPath === "")
            strip.shownPath = path;
        else
            squeeze.restart();
    }

    Timer {
        id: restoreAnim

        interval: 120
        onTriggered: strip.syncing = false
    }

    Timer {
        id: previewThrottle

        interval: strip.previewInterval
        onTriggered: strip.emitPreview()
    }

    // squeeze in, swap the picture, spring back; asked again mid-way it simply
    // starts over and swaps to whichever wallpaper is current by then
    SequentialAnimation {
        id: squeeze

        ParallelAnimation {
            NumberAnimation {
                target: card
                property: "squeezed"
                to: 1
                duration: Theme.ms(110)
                easing.type: Easing.OutCubic
            }

        }

        ScriptAction {
            script: strip.shownPath = strip.pathAt(strip.currentIndex)
        }

        NumberAnimation {
            target: card
            property: "squeezed"
            to: 0
            duration: Theme.ms(260)
            easing.type: Easing.OutBack
            easing.overshoot: 1.4
        }

    }

    ClippingRectangle {
        id: card

        // 0 = at rest, 1 = squeezed: a little smaller, a little rounder
        property real squeezed: 0

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Math.max(0, (strip.stableHeight - strip.rowHeight) / 2)
        width: strip.heroW
        height: strip.heroH
        radius: Theme.radiusXl + 14 * card.squeezed
        color: Theme.bgTile
        scale: (cardTap.pressed ? 0.98 : 1) - 0.06 * card.squeezed
        visible: strip.count > 0

        Behavior on scale {
            enabled: !squeeze.running

            NumberAnimation {
                duration: Theme.durShort
                easing.type: Easing.OutCubic
            }

        }

        Image {
            anchors.fill: parent
            source: strip.shownPath === "" ? "" : "file://" + strip.shownPath
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            sourceSize.width: strip.heroW * 2
        }

        Rectangle {
            anchors.fill: parent
            color: Theme.text
            opacity: cardTap.pressed ? Theme.statePressed : (cardHover.hovered ? Theme.stateHover : 0)

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.durShort
                }

            }

        }

        Rectangle {
            anchors.fill: parent
            radius: card.radius
            color: "transparent"
            border.color: Theme.accent
            border.width: 3
        }

        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 10
            width: 24
            height: 24
            radius: Theme.rad(12)
            color: Theme.accent
            opacity: strip.appliedPath !== "" && strip.appliedPath === strip.shownPath ? 1 : 0
            visible: opacity > 0.01

            DockGlyph {
                anchors.centerIn: parent
                width: 15
                height: 15
                pathData: DockIcons.check
                glyphColor: Theme.fgAccent
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.durShort
                }

            }

        }

        HoverHandler {
            id: cardHover

            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            id: cardTap

            onTapped: strip.activateCurrent()
        }

        WheelHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: (event) => {
                strip.step(event.angleDelta.y < 0 || event.angleDelta.x < 0 ? 1 : -1);
            }
        }

    }

    Row {
        id: pills

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: card.bottom
        anchors.topMargin: 14
        spacing: 6
        visible: strip.count > 1

        Repeater {
            model: strip.pillCount

            delegate: Rectangle {
                id: pill

                required property int index
                readonly property int target: strip.pillFirst + pill.index
                readonly property bool isCurrent: pill.target === strip.currentIndex

                width: pill.isCurrent ? 22 : 8
                height: 8
                radius: 4
                color: pill.isCurrent ? Theme.accent : Theme.alpha(Theme.text, pillHover.hovered ? 0.5 : 0.28)

                Behavior on width {
                    NumberAnimation {
                        duration: Theme.ms(300)
                        easing.type: Easing.Bezier
                        easing.bezierCurve: Theme.easeEmphasizedDecel
                    }

                }

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.durShort
                    }

                }

                HoverHandler {
                    id: pillHover

                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: strip.currentIndex = pill.target
                }

            }

        }

    }

    Item {
        id: caption

        anchors.top: pills.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        height: 26
        visible: strip.count > 0

        Row {
            anchors.centerIn: parent
            spacing: 10

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    var item = (strip.model && strip.currentIndex >= 0 && strip.currentIndex < strip.count) ? strip.model.get(strip.currentIndex) : null;
                    return item ? item.name : "";
                }
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
                font.weight: Font.Medium
                elide: Text.ElideRight
                width: Math.min(implicitWidth, strip.width - 200)
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: strip.count > 0 ? (strip.currentIndex + 1) + " / " + strip.count : ""
                color: Theme.subtextDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontLabel
            }

        }

    }

    Column {
        id: emptyState

        anchors.top: parent.top
        anchors.topMargin: Math.max(0, (strip.stableHeight - emptyState.implicitHeight) / 2)
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10
        visible: strip.count === 0

        DockGlyph {
            width: 32
            height: 32
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: 0.5
            pathData: DockIcons.brokenImage
            glyphColor: Theme.subtext
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: I18n.tr("No wallpapers in this folder")
            color: Theme.subtext
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
            font.weight: Font.Medium
        }

    }

}
