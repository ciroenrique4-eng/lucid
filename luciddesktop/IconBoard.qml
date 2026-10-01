import QtQuick
import qs

// the desktop icons, drawn on the background layer of the main screen: the
// same surface that keeps the selection box and the right-click menu, so a box
// dragged across the icons never changes hands. Widgets never sit over them -
// the icons step aside - so being a layer below the widgets shows nowhere
Item {
    id: board

    // the nearest icon from the last selected one, in a screen direction
    function step(dx, dy) {
        var from = DesktopIcons.placed[DesktopIcons.anchorKey];
        if (!from) {
            if (DesktopIcons.items.length > 0)
                DesktopIcons.selectOnly(DesktopIcons.items[0].key);

            return ;
        }
        var fx = DesktopIcons.cellX(from.c);
        var fy = DesktopIcons.cellY(from.r);
        var best = "";
        var bd = 1e9;
        var keys = Object.keys(DesktopIcons.placed);
        for (var i = 0; i < keys.length; i++) {
            var p = DesktopIcons.placed[keys[i]];
            var ox = (DesktopIcons.cellX(p.c) - fx) / DesktopIcons.cellW;
            var oy = (DesktopIcons.cellY(p.r) - fy) / DesktopIcons.cellH;
            var along = ox * dx + oy * dy;
            if (along <= 0)
                continue;

            var across = Math.abs(ox * dy) + Math.abs(oy * dx);
            var d = along + across * 2;
            if (d < bd) {
                bd = d;
                best = keys[i];
            }
        }
        if (best !== "")
            DesktopIcons.selectOnly(best);

    }

    anchors.fill: parent
    focus: true
    Keys.onPressed: (e) => {
        var ctrl = (e.modifiers & Qt.ControlModifier) !== 0;
        var keys = DesktopIcons.selectedKeys;
        if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
            DesktopIcons.openSelection();
        } else if (e.key === Qt.Key_Delete) {
            DesktopIcons.trash(keys);
        } else if (e.key === Qt.Key_F2) {
            if (keys.length === 1 && DesktopIcons.filesOf(keys).length === 1)
                DesktopIcons.renaming = keys[0];

        } else if (e.key === Qt.Key_Escape) {
            DesktopIcons.clearSelection();
        } else if (ctrl && e.key === Qt.Key_A) {
            DesktopIcons.selectAll();
        } else if (ctrl && e.key === Qt.Key_C) {
            DesktopIcons.copy(keys);
        } else if (ctrl && e.key === Qt.Key_V) {
            // a paste from the keyboard lands in the first free cell
            DesktopIcons.menuX = DesktopIcons.cellX(0) + 1;
            DesktopIcons.menuY = DesktopIcons.cellY(0) + 1;
            DesktopIcons.paste();
        } else if (e.key === Qt.Key_Left) {
            board.step(-1, 0);
        } else if (e.key === Qt.Key_Right) {
            board.step(1, 0);
        } else if (e.key === Qt.Key_Up) {
            board.step(0, -1);
        } else if (e.key === Qt.Key_Down) {
            board.step(0, 1);
        } else {
            return ;
        }
        e.accepted = true;
    }

    Repeater {
        model: DesktopIcons.items

        DesktopIcon {
        }

    }

    // where a drag of our own icons would put each of them
    Repeater {
        model: DesktopIcons.dragOver && DesktopIcons.dragKey !== "" && DesktopIcons.dropInto === "" ? DesktopIcons.dragKeys : []

        Rectangle {
            id: ghost

            required property var modelData

            readonly property var from: DesktopIcons.placed[ghost.modelData] || null
            readonly property var anchorSpot: DesktopIcons.placed[DesktopIcons.dragKey] || null
            readonly property var to: DesktopIcons.cellAt(DesktopIcons.dragX, DesktopIcons.dragY)
            readonly property int c: (ghost.from && ghost.anchorSpot) ? Math.max(0, Math.min(DesktopIcons.cols - 1, ghost.from.c + ghost.to.c - ghost.anchorSpot.c)) : 0
            readonly property int r: (ghost.from && ghost.anchorSpot) ? Math.max(0, Math.min(DesktopIcons.rows - 1, ghost.from.r + ghost.to.r - ghost.anchorSpot.r)) : 0

            visible: ghost.from !== null && ghost.anchorSpot !== null
            x: DesktopIcons.tileX(ghost.c) + 4
            y: DesktopIcons.tileY(ghost.r) + 2
            width: DesktopIcons.tileW - 8
            height: DesktopIcons.tileH - 4
            radius: Theme.radiusSm
            color: Theme.alpha(Theme.accent, 0.12)
            border.width: 1.5
            border.color: Theme.alpha(Theme.accent, 0.75)
        }

    }

    // the selection box, drawn over the icons
    Rectangle {
        x: DesktopIcons.band.x
        y: DesktopIcons.band.y
        width: DesktopIcons.band.width
        height: DesktopIcons.band.height
        visible: DesktopIcons.banding
        z: 10
        radius: Math.min(4, width / 2, height / 2)
        color: Theme.alpha(Theme.accent, 0.16)
        border.width: 1
        border.color: Theme.alpha(Theme.accent, 0.8)
        antialiasing: true
    }

}
