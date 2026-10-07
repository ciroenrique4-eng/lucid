import QtQuick
import qs

// The wallpaper picker as a wave: pills whose height follows a bell around the
// selected one, which stands tallest and opens into a card; the rest shrink
// towards the edges like a level meter.
WallpaperSlots {
    id: root

    readonly property real pillW: 40
    readonly property real openW: Math.round(root.heroW * 0.9)
    readonly property int sides: Math.max(2, Math.floor(((root.width - root.openW) / 2) / (root.pillW + root.itemGap)))

    slotRect: function (offset) {
        var n = Math.abs(offset);
        var open = offset === 0;
        var bell = Math.exp(-(offset * offset) / (2 * 3.2 * 3.2));
        var h = open ? root.stageH : Math.round(root.stageH * (0.2 + 0.58 * bell));
        return {
            "x": root.rowX(offset, root.openW, root.pillW, root.itemGap, root.sides),
            "y": Math.round((root.stageH - h) / 2),
            "w": open ? root.openW : root.pillW,
            "h": h,
            "r": open ? Theme.radiusXl : Theme.pill(root.pillW),
            "o": n > root.sides ? 0 : (open ? 1 : Math.max(0.4, 1 - 0.07 * n))
        };
    }
}
