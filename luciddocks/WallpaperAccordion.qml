import QtQuick
import qs

// The wallpaper picker as an accordion: slices of the whole height fill the
// panel from edge to edge, the selected one opens wide and the rest fold into
// slim pills on both sides.
WallpaperSlots {
    id: root

    readonly property int sides: 8
    readonly property real openW: Math.round(root.width * 0.4)
    readonly property real slimW: Math.max(8, ((root.width - root.openW) / 2 - root.sides * root.itemGap) / root.sides)

    slotRect: function (offset) {
        var n = Math.abs(offset);
        var open = offset === 0;
        return {
            "x": root.rowX(offset, root.openW, root.slimW, root.itemGap, root.sides),
            "y": 0,
            "w": open ? root.openW : root.slimW,
            "h": root.stageH,
            "r": open ? Theme.radiusXl : Theme.pill(root.slimW),
            "o": n > root.sides ? 0 : (open ? 1 : Math.max(0.45, 0.9 - 0.06 * (n - 1)))
        };
    }
}
