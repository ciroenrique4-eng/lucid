import "../luciddocks"
import QtQuick
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

    function openIt() {
        if (!DesktopIcons.isSelected(tile.key))
            DesktopIcons.selectOnly(tile.key);

        DesktopIcons.openSelection();
    }

    width: DesktopIcons.cellW
    height: DesktopIcons.cellH
    visible: tile.spot !== null
    x: tile.spot ? DesktopIcons.cellX(tile.spot.c) : 0
    y: tile.spot ? DesktopIcons.cellY(tile.spot.r) : 0
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

    Rectangle {
        id: plate

        x: 4
        y: 2
        width: parent.width - 8
        height: Math.max(parent.height - 4, nameBox.y + nameBox.height + 4 - y)
        radius: Theme.radiusSm
        color: tile.dropTarget ? Theme.alpha(Theme.accent, 0.38) : (tile.selected ? Theme.alpha(Theme.accent, 0.22) : "#ffffff")
        opacity: (tile.selected || tile.dropTarget) ? 1 : (tileArea.pressed ? 0.16 : (tile.hovered ? 0.1 : 0))
        border.width: tile.selected || tile.dropTarget ? 1 : 0
        border.color: Theme.alpha(Theme.accent, 0.7)

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.durQuick
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

        // a theme with nothing for it still gets a shape, never a blank
        DockGlyph {
            anchors.fill: parent
            anchors.margins: tile.px * 0.08
            visible: tile.themeIcon === "" && thumb.status !== Image.Ready
            pathData: tile.modelData.kind === "dir" ? DesktopIcons.glyphs.folder : (tile.modelData.kind === "home" ? DesktopIcons.glyphs.home : (tile.modelData.kind === "trash" ? DesktopIcons.glyphs.trash : DesktopIcons.glyphs.file))
            glyphColor: "#ffffff"
            opacity: 0.9
        }

        Image {
            id: themed

            anchors.fill: parent
            visible: thumb.status !== Image.Ready
            source: tile.themeIcon
            sourceSize.width: tile.px * 2
            sourceSize.height: tile.px * 2
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            smooth: true
            mipmap: true
        }

        // a preview keeps its own shape inside the square, with a hairline
        // edge so a white picture still reads against a white wallpaper
        Item {
            anchors.centerIn: parent
            width: thumb.paintedWidth
            height: thumb.paintedHeight
            visible: thumb.status === Image.Ready

            Rectangle {
                anchors.fill: parent
                anchors.margins: -1
                radius: 4
                color: "transparent"
                border.width: 1
                border.color: Qt.rgba(0, 0, 0, 0.25)
            }

        }

        Image {
            id: thumb

            anchors.fill: parent
            source: tile.preview
            sourceSize.width: tile.px * 2
            sourceSize.height: tile.px * 2
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            cache: false
            smooth: true
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

        // selected, the name sits on the accent so it reads on any wallpaper
        Rectangle {
            anchors.centerIn: label
            width: Math.min(nameBox.width + 6, label.contentWidth + 10)
            height: label.contentHeight + 2
            radius: Math.min(6, height / 2)
            color: Theme.accent
            visible: tile.selected
        }

        Text {
            x: label.x + 0.5
            y: label.y + 1
            width: label.width
            text: label.text
            visible: !tile.selected
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
            color: tile.selected ? Theme.fgAccent : "#ffffff"
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
