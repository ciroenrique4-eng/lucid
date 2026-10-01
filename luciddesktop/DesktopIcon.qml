import "../luciddocks"
import QtQuick
import QtQuick.Effects
import Quickshell
import qs

// one icon on the desktop: a picture or a preview, its name under it, and the
// handling for a click, a double click, a right click and a drag
Item {
    id: tile

    required property var modelData

    readonly property string key: tile.modelData.key
    readonly property var spot: DesktopIcons.placed[tile.key] || null
    readonly property bool selected: DesktopIcons.selected[tile.key] === true
    readonly property bool hovered: tileArea.containsMouse
    // a drag is taking this one along: it waits, faded, where it was
    readonly property bool lifted: DesktopIcons.dragKey !== "" && DesktopIcons.dragKeys.indexOf(tile.key) >= 0
    readonly property bool dropTarget: DesktopIcons.dropInto === tile.key
    readonly property int px: DesktopIcons.iconPx
    // pictures show themselves: a cached thumbnail, or the image file itself
    readonly property bool isImage: tile.modelData.mime.indexOf("image/") === 0 && tile.modelData.size < 60000000
    readonly property string preview: {
        if (!Prefs.desktopIconsThumbs)
            return "";

        if (tile.modelData.thumb !== "")
            return "file://" + tile.modelData.thumb;

        return tile.isImage ? tile.modelData.uri : "";
    }
    readonly property string themeIcon: {
        void IconTheme.generation;
        var names = tile.modelData.icons;
        for (var i = 0; i < names.length; i++) {
            var p = IconTheme.resolve(names[i]);
            if (p !== "")
                return p;

        }
        return IconTheme.resolve(tile.modelData.kind === "dir" ? "folder" : "text-x-generic");
    }
    property bool appeared: false

    // shapes | glass | classic
    readonly property string look: Prefs.desktopIconStyle
    readonly property string kind: tile.modelData.kind
    readonly property bool isFolder: tile.kind === "dir" || tile.kind === "home"
    readonly property bool hasThumb: thumb.status === Image.Ready
    // the shell's colours on the icon: never on a picture, never on an app's
    // own icon, which is how people find it
    readonly property bool tinted: !tile.hasThumb && tile.kind !== "app" && (Prefs.desktopIconTint === "all" || (Prefs.desktopIconTint === "folders" && tile.isFolder))
    // each kind wears a palette role: folders the accent, apps the secondary,
    // files and the trash the tertiary
    readonly property color role: tile.isFolder ? Theme.cPrimary : (tile.kind === "app" ? Theme.cSecondary : Theme.cTertiary)
    readonly property color container: tile.isFolder ? Theme.accentContainer : (tile.kind === "app" ? Theme.secondaryContainer : Theme.tertiaryContainer)
    readonly property color onContainer: tile.isFolder ? Theme.fgAccentContainer : (tile.kind === "app" ? Theme.fgSecondaryContainer : Theme.fgTertiaryContainer)
    // a saturated tone of the role: colourising keeps the icon's own light and
    // shade, so a mid tone gives a dark icon its colour without going muddy
    readonly property color tintColor: Theme.atTone(tile.role, Theme.isLight ? 45 : 72)
    // Material's shape library, one per kind: a four-sided cookie for folders,
    // a nine-sided one for apps, a scallop for the trash, a squircle for files.
    // turn is how far it twists under the pointer
    readonly property var shapeSpec: {
        if (tile.isFolder)
            return {
                "form": "lobed",
                "lobes": 4,
                "depth": 0.16,
                "spin": 45,
                "turn": 45
            };

        if (tile.kind === "app")
            return {
                "form": "lobed",
                "lobes": 9,
                "depth": 0.09,
                "spin": -90,
                "turn": 20
            };

        if (tile.kind === "trash")
            return {
                "form": "lobed",
                "lobes": 12,
                "depth": 0.08,
                "spin": 0,
                "turn": 15
            };

        return {
            "form": "squircle",
            "lobes": 0,
            "depth": 0,
            "spin": 0,
            "turn": 8
        };
    }

    function openIt() {
        if (!DesktopIcons.isSelected(tile.key))
            DesktopIcons.selectOnly(tile.key);

        DesktopIcons.openSelection();
    }

    width: DesktopIcons.tileW
    height: DesktopIcons.tileH
    visible: tile.spot !== null
    x: tile.spot ? DesktopIcons.tileX(tile.spot.c) : 0
    y: tile.spot ? DesktopIcons.tileY(tile.spot.r) : 0
    // a selected name may run past the cell, over the one below
    z: tile.selected ? 2 : (tile.hovered ? 1 : 0)
    opacity: tile.appeared ? (tile.lifted ? 0.45 : 1) : 0
    Component.onCompleted: appearTimer.start()

    Timer {
        id: appearTimer

        interval: 20
        onTriggered: tile.appeared = true
    }

    // stepping aside for a widget, and back, slides rather than jumps
    Behavior on x {
        enabled: tile.appeared

        NumberAnimation {
            duration: Theme.durMedium
            easing.type: Theme.easeStandard
        }

    }

    Behavior on y {
        enabled: tile.appeared

        NumberAnimation {
            duration: Theme.durMedium
            easing.type: Theme.easeStandard
        }

    }

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.durShort
        }

    }

    // glass: every icon on a frosted card of its own, the widgets' material;
    // classic: a highlight that only shows under the pointer or when selected
    Rectangle {
        id: plate

        readonly property bool glass: tile.look === "glass"

        x: 4
        y: 2
        width: parent.width - 8
        height: Math.max(parent.height - 4, nameBox.y + nameBox.height + 6 - y)
        radius: plate.glass ? Theme.radiusMd : Theme.radiusSm
        color: {
            if (tile.dropTarget)
                return Theme.alpha(Theme.accent, 0.38);

            if (plate.glass)
                return tile.selected ? Qt.tint(Theme.bg, Theme.alpha(Theme.accent, 0.28)) : Theme.bg;

            return tile.selected ? Theme.alpha(Theme.accent, 0.22) : "#ffffff";
        }
        opacity: {
            if (plate.glass || tile.selected || tile.dropTarget)
                return 1;

            // the shapes carry their own hover, so no box behind them
            if (tile.look === "shapes")
                return 0;

            return tileArea.pressed ? 0.16 : (tile.hovered ? 0.1 : 0);
        }
        visible: tile.look !== "shapes" || tile.dropTarget
        border.width: plate.glass ? (tile.selected ? 2 : 1) : ((tile.selected || tile.dropTarget) ? 1 : 0)
        border.color: plate.glass ? (tile.selected ? Theme.accent : (tile.hovered ? Theme.alpha(Theme.accent, 0.5) : Theme.alpha(Theme.text, 0.08))) : Theme.alpha(Theme.accent, 0.7)
        scale: plate.glass && tile.hovered && !tile.selected ? 1.03 : 1

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.durQuick
            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: Theme.durShort
                easing.type: Easing.OutBack
            }

        }

        Behavior on border.color {
            ColorAnimation {
                duration: Theme.durShort
            }

        }

    }

    Item {
        id: art

        width: tile.px
        height: tile.px
        anchors.horizontalCenter: parent.horizontalCenter
        y: 8
        transformOrigin: Item.Bottom

        // shapes: each kind sits on an expressive shape in its palette role,
        // which breathes and turns a little under the pointer
        IconShape {
            id: shape

            anchors.fill: parent
            visible: tile.look === "shapes" && !tile.hasThumb
            form: tile.shapeSpec.form
            lobes: tile.shapeSpec.lobes
            depth: tile.shapeSpec.depth * (tile.hovered || tile.dropTarget ? 1.8 : 1)
            spin: tile.shapeSpec.spin + (tile.hovered || tile.dropTarget ? tile.shapeSpec.turn : 0)
            fill: (tile.selected || tile.dropTarget) ? Theme.accent : tile.container
            scale: tile.hovered ? 1.06 : 1

            Behavior on depth {
                NumberAnimation {
                    duration: Theme.durMedium
                    easing.type: Easing.OutBack
                    easing.overshoot: 2
                }

            }

            Behavior on spin {
                NumberAnimation {
                    duration: Theme.durMedium * 1.4
                    easing.type: Easing.OutBack
                }

            }

            Behavior on scale {
                NumberAnimation {
                    duration: Theme.durShort
                    easing.type: Easing.OutBack
                }

            }

            Behavior on fill {
                ColorAnimation {
                    duration: Theme.durShort
                }

            }

        }

        // a theme with nothing for it still gets a shape, never a blank
        DockGlyph {
            anchors.centerIn: parent
            width: themed.width * 0.84
            height: width
            visible: tile.themeIcon === "" && !tile.hasThumb
            pathData: tile.isFolder ? (tile.modelData.kind === "home" ? DesktopIcons.glyphs.home : DesktopIcons.glyphs.folder) : (tile.modelData.kind === "trash" ? DesktopIcons.glyphs.trash : DesktopIcons.glyphs.file)
            glyphColor: tile.look === "shapes" ? tile.onContainer : (tile.look === "glass" ? Theme.text : "#ffffff")
            opacity: 0.9
        }

        Image {
            id: themed

            readonly property real side: tile.look === "shapes" ? Math.round(tile.px * 0.62) : tile.px

            anchors.centerIn: parent
            width: themed.side
            height: themed.side
            visible: !tile.hasThumb && tile.themeIcon !== ""
            source: tile.themeIcon
            // rendered at the size it is shown: an svg drawn large and then
            // shrunk (mipmapped, too) comes out soft
            sourceSize.width: themed.side
            sourceSize.height: themed.side
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            smooth: true
            // the shell's colours on the icon, its light and shade kept
            layer.enabled: tile.tinted
            layer.effect: MultiEffect {
                colorization: 0.9
                colorizationColor: tile.tintColor
                brightness: 0.35
                contrast: 0.15
            }
        }

        // a picture: a print with a white border, set down slightly askew,
        // that straightens up under the pointer (shapes); a plain preview with
        // a hairline edge otherwise, so a white picture still reads
        Item {
            id: photo

            readonly property bool framed: tile.look === "shapes"
            readonly property real tilt: {
                var h = 0;
                for (var i = 0; i < tile.key.length; i++)
                    h = (h * 31 + tile.key.charCodeAt(i)) % 997;
                return (h % 9) - 4;
            }
            readonly property real pad: photo.framed ? 3 : 0

            anchors.centerIn: parent
            anchors.verticalCenterOffset: photo.framed ? -2 : 0
            width: thumb.paintedWidth + 2 * photo.pad
            height: thumb.paintedHeight + 2 * photo.pad + (photo.framed ? 5 : 0)
            visible: tile.hasThumb
            rotation: photo.framed && !tile.hovered && !tile.selected ? photo.tilt : 0
            scale: photo.framed && tile.hovered ? 1.08 : 1

            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 2
                anchors.leftMargin: 1
                anchors.rightMargin: -1
                anchors.bottomMargin: -2
                radius: 2
                color: Qt.rgba(0, 0, 0, 0.35)
                visible: photo.framed
                antialiasing: true
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: photo.framed ? 0 : -1
                radius: photo.framed ? 2 : 4
                antialiasing: true
                color: photo.framed ? (tile.selected ? Theme.accent : "#f4f1ea") : "transparent"
                border.width: photo.framed ? 0 : (tile.selected ? 2 : 1)
                border.color: tile.selected ? Theme.accent : Qt.rgba(0, 0, 0, 0.25)
            }

            Behavior on rotation {
                NumberAnimation {
                    duration: Theme.durMedium
                    easing.type: Easing.OutBack
                }

            }

            Behavior on scale {
                NumberAnimation {
                    duration: Theme.durShort
                    easing.type: Easing.OutBack
                }

            }

        }

        Image {
            id: thumb

            x: Math.round((art.width - thumb.width) / 2)
            y: Math.round((art.height - thumb.height) / 2 - (photo.framed ? 4.5 : 0))
            width: art.width - (photo.framed ? 8 : 0)
            height: art.height - (photo.framed ? 13 : 0)
            source: tile.preview
            // the decoder scales the picture down well; the GPU then only
            // turns it, with smoothed edges so the tilt has no jaggies
            sourceSize.width: thumb.width
            sourceSize.height: thumb.height
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            cache: false
            smooth: true
            antialiasing: true
            rotation: photo.rotation
            scale: photo.scale
        }
        // a symbolic link wears a small arrow, the way file managers mark one
        Rectangle {
            visible: tile.modelData.link
            width: Math.round(tile.px * 0.38)
            height: width
            radius: width / 2
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            color: Theme.bg

            DockGlyph {
                anchors.centerIn: parent
                width: parent.width - 4
                height: width
                pathData: DesktopIcons.glyphs.link
                glyphColor: Theme.text
            }

        }

        // a launcher that is not allowed to run yet
        Rectangle {
            visible: tile.modelData.kind === "app" && !tile.modelData.exec
            width: Math.round(tile.px * 0.38)
            height: width
            radius: width / 2
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            color: Theme.bg

            DockGlyph {
                anchors.centerIn: parent
                width: parent.width - 4
                height: width
                pathData: DesktopIcons.glyphs.shield
                glyphColor: Theme.accent
            }

        }

        // opening squashes it a touch and lets it spring back: the click landed
        SequentialAnimation {
            id: bounce

            NumberAnimation {
                target: art
                property: "scale"
                to: 0.84
                duration: 90
                easing.type: Easing.OutQuad
            }

            NumberAnimation {
                target: art
                property: "scale"
                to: 1
                duration: 380
                easing.type: Easing.OutBack
                easing.overshoot: 2.2
            }

        }

    }

    Connections {
        function onLaunchTickChanged() {
            if (DesktopIcons.launched === tile.key)
                bounce.restart();

        }

        target: DesktopIcons
    }

    Item {
        id: nameBox

        readonly property int lines: tile.selected ? 5 : 2

        anchors.horizontalCenter: parent.horizontalCenter
        y: art.y + art.height + 5
        width: parent.width - 12
        height: label.height
        visible: DesktopIcons.renaming !== tile.key

        // the name's backing: the accent once selected, in every look; in
        // shapes a quiet pill of the shell's surface the rest of the time, so
        // it reads on any wallpaper without a shadow
        Rectangle {
            anchors.centerIn: label
            width: Math.min(nameBox.width + 6, label.contentWidth + (tile.look === "shapes" ? 14 : 10))
            height: label.contentHeight + (tile.look === "shapes" ? 4 : 2)
            radius: tile.look === "shapes" ? Math.min(Theme.radiusSm, height / 2) : Math.min(6, height / 2)
            color: tile.selected ? Theme.accent : Theme.bg
            visible: tile.selected ? tile.look !== "glass" : tile.look === "shapes"
        }

        Text {
            x: label.x + 0.5
            y: label.y + 1
            width: label.width
            text: label.text
            visible: tile.look === "classic" && !tile.selected
            color: Qt.rgba(0, 0, 0, 0.6)
            font: label.font
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            maximumLineCount: nameBox.lines
            elide: Text.ElideRight
        }

        Text {
            id: label

            width: parent.width
            text: tile.modelData.label
            color: (tile.selected && tile.look !== "glass") ? Theme.fgAccent : (tile.look === "classic" ? "#ffffff" : Theme.text)
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontLabelMd
            font.weight: Font.Medium
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            maximumLineCount: nameBox.lines
            elide: Text.ElideRight
        }

    }

    // what rides under the pointer in a drag: the picture alone
    Item {
        id: proxy

        width: tile.px
        height: tile.px
        Drag.active: tileArea.drag.active
        Drag.dragType: Drag.Automatic
        Drag.supportedActions: Qt.CopyAction | Qt.MoveAction | Qt.LinkAction
        Drag.proposedAction: Qt.MoveAction
        Drag.hotSpot.x: tile.px / 2
        Drag.hotSpot.y: tile.px / 2
        Drag.onDragStarted: {
            DesktopIcons.dragKeys = DesktopIcons.selectedKeys.slice();
            DesktopIcons.dragKey = tile.key;
        }
        Drag.onDragFinished: (action) => {
            proxy.x = 0;
            proxy.y = 0;
            DesktopIcons.endDrag();
        }
    }

    MouseArea {
        id: tileArea

        // a press on an icon already in the selection keeps the selection (it
        // may be the start of a drag); a release without a drag narrows it
        property bool narrow: false

        x: 4
        y: 2
        width: parent.width - 8
        height: parent.height - 4
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        drag.target: proxy
        drag.threshold: 8
        onPressed: (m) => {
            tile.forceActiveFocus();
            tileArea.narrow = false;
            if (m.button === Qt.RightButton) {
                if (!tile.selected)
                    DesktopIcons.selectOnly(tile.key);

                var p = tileArea.mapToItem(null, m.x, m.y);
                DesktopIcons.openMenu(DesktopIcons.selectedKeys, p.x, p.y);
                return ;
            }
            if (m.modifiers & Qt.ControlModifier)
                DesktopIcons.toggle(tile.key);
            else if (m.modifiers & Qt.ShiftModifier)
                DesktopIcons.selectRange(tile.key);
            else if (!tile.selected)
                DesktopIcons.selectOnly(tile.key);
            else
                tileArea.narrow = true;
            // the drag image, ready by the time the pointer has moved far enough
            art.grabToImage((r) => {
                proxy.Drag.imageSource = r.url;
            }, Qt.size(tile.px, tile.px));
            proxy.Drag.mimeData = DesktopIcons.dragData();
        }
        onReleased: (m) => {
            if (m.button === Qt.LeftButton && tileArea.narrow && !tileArea.drag.active)
                DesktopIcons.selectOnly(tile.key);

        }
        onClicked: (m) => {
            if (m.button === Qt.LeftButton && Prefs.desktopIconsOpen === "single" && !(m.modifiers & (Qt.ControlModifier | Qt.ShiftModifier)))
                tile.openIt();

        }
        onDoubleClicked: (m) => {
            if (m.button === Qt.LeftButton && Prefs.desktopIconsOpen !== "single")
                tile.openIt();

        }
    }

}
