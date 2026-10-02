import QtQuick
import Quickshell.Hyprland._FocusGrab
import qs

Item {
    id: pill

    property var hostWindow: null
    property bool shown: true
    property bool expanded: false
    property bool altOpen: false
    property int compactWidth: 0
    property int compactHeight: Prefs.barHeight
    property int panelWidth: 320
    property int panelHeight: 200
    property int altWidth: 0
    property int altHeight: 0
    property int expandedRadius: Theme.radiusLg
    // how far the compact face shrinks as the panel opens
    property real compactCollapseScale: 0.82
    property bool compactInteractive: true
    property bool focusGrabs: true
    property bool panelFades: true
    property bool surfaceLayered: false

    signal compactClicked()

    property alias compactContent: compactHolder.data
    property alias altContent: altHolder.data
    property alias panelContent: panelHolder.data
    property alias overlayContent: overlayHolder.data
    property bool overlayOpen: false
    property Item overlayItem: null
    // where the overlay holder sits in the pill, for the input region
    readonly property real overlayY: overlayHolder.y

    readonly property int morphDuration: Theme.barDurEnter
    readonly property var morphEasing: Theme.easeEmphasizedDecel

    // the id the bar knows this pill by
    function moduleId() {
        const map = pill.hostWindow && pill.hostWindow.moduleById ? pill.hostWindow.moduleById : {};
        for (const id in map) {
            if (map[id] === pill)
                return id;

        }
        return "";
    }

    function beginTransition() {
        panelTransitionTimer.restart();
    }

    readonly property bool anyOpen: pill.expanded || pill.altOpen

    property int panelFadePause: 0
    property int panelFadeDuration: Theme.barMs(220)
    property int compactFadePause: 0
    property int compactFadeDuration: Theme.barMs(220)

    function syncFadeTimings() {
        var open = pill.expanded || pill.altOpen;
        pill.panelFadePause = Theme.barMs(pill.expanded ? 150 : 0);
        pill.panelFadeDuration = Theme.barMs(pill.expanded ? 220 : 150);
        pill.compactFadePause = Theme.barMs(open ? 0 : 150);
        pill.compactFadeDuration = Theme.barMs(open ? 150 : 220);
    }

    onExpandedChanged: pill.syncFadeTimings()
    onAltOpenChanged: pill.syncFadeTimings()
    property bool compactHovered: false
    property bool panelTransitioning: false

    readonly property bool hoverLift: Prefs.barHoverGrow > 0 && pill.compactHovered && !pill.anyOpen && pill.shown
    property real hoverGrow: pill.hoverLift ? Math.min(Prefs.barHoverGrow, Math.max(0, Prefs.barSpacing / 2)) : 0

    property int hoverGrowDuration: Theme.barMs(150)

    onCompactHoveredChanged: pill.hoverGrowDuration = Theme.barMs(pill.compactHovered ? 150 : 220)

    Behavior on hoverGrow {
        NumberAnimation {
            duration: pill.hoverGrowDuration
            easing.type: Easing.OutCubic
        }

    }

    // hover to open: the pill unfolds on its own once the pointer rests on it,
    // and folds back when the pointer leaves. Opened this way it deliberately
    // skips the focus grab — that pulls the keyboard off the focused window, and
    // merely passing over the bar must not do that — so a click anywhere on the
    // pill promotes it to an ordinary clicked-open panel, grab and all.
    // off for a module whose face is itself a row of things to click (the apps):
    // its panel would cover them as soon as the pointer rests there
    property bool opensOnHover: true
    readonly property bool hoverOpens: Prefs.barHoverOpen && pill.shown && pill.opensOnHover
    property bool hoverOpen: false
    // false where the panel's own top row answers a right click (the tray's items)
    property bool headerOpensSettings: true
    readonly property bool surfaceHovered: pill.compactHovered || shellHover.hovered || pillHover.hovered

    function openOnHover() {
        if (!pill.hoverOpens || pill.anyOpen)
            return ;

        pill.hoverOpen = true;
        pill.compactClicked();
        pill.expanded = true;
    }

    function closeHoverOpen() {
        if (!pill.hoverOpen)
            return ;

        // collapse first: dropping hoverOpen while still expanded would arm the
        // focus grab for an instant on the way out
        pill.expanded = false;
        pill.hoverOpen = false;
    }

    onSurfaceHoveredChanged: {
        if (pill.surfaceHovered) {
            hoverCloseTimer.stop();
            if (pill.hoverOpens && !pill.anyOpen)
                hoverOpenTimer.restart();

        } else {
            hoverOpenTimer.stop();
            if (pill.hoverOpen)
                hoverCloseTimer.restart();

        }
    }
    onHoverOpensChanged: {
        if (!pill.hoverOpens)
            pill.closeHoverOpen();

    }

    // long enough that sweeping the pointer across the bar opens nothing
    Timer {
        id: hoverOpenTimer

        interval: 180
        onTriggered: pill.openOnHover()
    }

    // in pop-up mode the gap between pill and panel is outside the input region,
    // so crossing it unhovers both; this rides that out
    Timer {
        id: hoverCloseTimer

        interval: 320
        onTriggered: {
            if (!pill.surfaceHovered)
                pill.closeHoverOpen();

        }
    }

    readonly property bool popupMode: Prefs.barPopupMode
    readonly property int openWidth: pill.altOpen ? pill.altWidth : (pill.expanded ? pill.panelWidth : pill.compactWidth)
    readonly property int openHeight: pill.altOpen ? pill.altHeight : (pill.expanded ? pill.panelHeight : pill.compactHeight)
    readonly property int cornerRadius: pill.popupMode ? Math.min(pill.expandedRadius, Math.round(shell.height / 2)) : (pill.anyOpen ? pill.expandedRadius : Prefs.barPillRadius)
    // "top" is the side against the screen edge: the bottom one on a bottom bar
    readonly property bool atBottom: Prefs.barBottom
    readonly property int topRadius: Prefs.barFlush && !pill.popupMode ? 0 : pill.cornerRadius
    readonly property int pillTopRadius: Prefs.barFlush ? 0 : Prefs.barPillRadius
    // on the full bar the strip behind already paints the resting pill, so the
    // pill itself only shows a hover tint
    // (with module backgrounds the layer behind draws that tint, to their shape)
    property bool tintsOnHover: true
    // in a notch it shares with its neighbours, the bar draws the notch and
    // the hover; the pill is see-through until a panel opens out of it
    readonly property bool sharesNotch: Prefs.barNotchGrouping && pill.hostWindow !== null && pill.hostWindow.sharesNotch !== undefined && pill.hostWindow.sharesNotch(pill.moduleId())
    readonly property color restingColor: (Prefs.barFull || pill.sharesNotch) ? Theme.alpha(Theme.text, pill.compactHovered && pill.tintsOnHover && !Prefs.barGrouping ? 0.08 : 0) : Theme.bg
    // still taller than the pill: a closing panel keeps its colour until it has
    // folded away, or on the full bar its fading contents float over the desktop
    readonly property bool surfaceOpen: pill.anyOpen || pill.height > pill.compactHeight + 0.5
    readonly property int barRadius: pill.popupMode ? Prefs.barPillRadius : pill.cornerRadius
    readonly property int barTopRadius: pill.popupMode ? pill.pillTopRadius : pill.topRadius

    property string popupAlign: "left"
    property bool popupIsAlt: false

    onAnyOpenChanged: {
        if (pill.anyOpen)
            pill.popupIsAlt = pill.altOpen && !pill.expanded;
        else
            pill.hoverOpen = false;

        panelTransitionTimer.restart();
    }

    readonly property int popupWidth: pill.popupIsAlt ? pill.altWidth : pill.panelWidth
    readonly property int popupHeight: pill.popupIsAlt ? pill.altHeight : pill.panelHeight
    readonly property real popupX: {
        if (!pill.popupMode)
            return 0;

        if (pill.popupAlign === "right")
            return pill.compactWidth - pill.popupWidth;

        if (pill.popupAlign === "center")
            return (pill.compactWidth - pill.popupWidth) / 2;

        return 0;
    }
    readonly property bool popupExpanding: pill.popupMode && pill.anyOpen
    readonly property bool popupOpen: pill.shown && pill.popupMode && Math.abs(shell.y) > 0.5
    readonly property Item popupItem: shell

    readonly property real surfaceX: -pill.hoverGrow
    readonly property real surfaceY: 0
    readonly property real surfaceWidth: (pill.popupMode ? pill.compactWidth : pill.width) + pill.hoverGrow * 2
    readonly property real surfaceHeight: pill.popupMode ? pill.compactHeight : pill.height
    // how far the surface the pill is wearing reaches from the bar's edge side
    readonly property real surfaceReach: pill.atBottom ? pill.height - pill.popupItem.y : pill.popupItem.y + pill.popupItem.height

    // the y, in overlay coordinates, of something h tall that sits reach px out
    // from the bar's edge side of the pill: below it on a top bar, above it on a
    // bottom one
    function overlayEdgeY(reach, h) {
        return pill.atBottom ? overlayHolder.height - reach - h : reach;
    }

    implicitWidth: !pill.shown ? 0 : (pill.popupMode ? pill.compactWidth : pill.openWidth)
    implicitHeight: !pill.shown ? 0 : (pill.popupMode ? pill.compactHeight : pill.openHeight)
    opacity: pill.shown ? 1 : 0
    scale: pill.shown ? 1 : 0.82
    transformOrigin: Item.Center
    visible: pill.opacity > 0.01
    clip: !pill.popupMode && pill.anyOpen && !pill.overlayOpen
    z: (pill.popupOpen || pill.overlayOpen) ? 100 : 1

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.barMs(180)
            easing.type: Easing.OutCubic
        }

    }

    Behavior on scale {
        NumberAnimation {
            duration: Theme.barMs(260)
            easing.type: pill.shown ? Easing.OutBack : Easing.InCubic
        }

    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: pill.morphDuration
            easing.type: Easing.Bezier
            easing.bezierCurve: pill.morphEasing
        }

    }

    property bool shownTransition: false

    onShownChanged: {
        pill.shownTransition = true;
        shownTransitionTimer.restart();
    }

    Behavior on implicitHeight {
        enabled: !pill.anyOpen || pill.panelTransitioning || pill.shownTransition

        NumberAnimation {
            duration: pill.morphDuration
            easing.type: Easing.Bezier
            easing.bezierCurve: pill.morphEasing
        }

    }

    Item {
        id: overlayHolder

        // from the pill to the far side of the window: down on a top bar, up on
        // a bottom one. Up, it always reaches the window's top, so what sits in it
        // keeps its place on screen while the pill under it grows or shrinks
        readonly property bool reaching: pill.overlayOpen && pill.hostWindow !== null
        readonly property bool reachingUp: pill.atBottom && pill.hostWindow !== null

        x: 0
        y: overlayHolder.reachingUp ? Math.min(0, -pill.y) : 0
        width: overlayHolder.reaching ? Math.max(pill.width, pill.hostWindow.width - pill.x) : pill.width
        height: overlayHolder.reachingUp ? Math.max(pill.height, pill.y + pill.height) : (overlayHolder.reaching ? Math.max(pill.height, pill.hostWindow.height - pill.y) : pill.height)
        z: 200
    }

    Timer {
        id: shownTransitionTimer

        interval: Theme.barMs(420)
        onTriggered: pill.shownTransition = false
    }

    Timer {
        id: panelTransitionTimer

        interval: Theme.barMs(420)
        onTriggered: pill.panelTransitioning = false
        onRunningChanged: {
            if (running)
                pill.panelTransitioning = true;

        }
    }

    Rectangle {
        id: pillRect

        visible: pill.popupMode
        x: pill.surfaceX
        y: pill.surfaceY
        width: pill.compactWidth + pill.hoverGrow * 2
        height: pill.compactHeight
        color: pill.restingColor
        clip: true
        radius: Prefs.barPillRadius
        topLeftRadius: pill.atBottom ? Prefs.barPillRadius : pill.pillTopRadius
        topRightRadius: pill.atBottom ? Prefs.barPillRadius : pill.pillTopRadius
        bottomLeftRadius: pill.atBottom ? pill.pillTopRadius : Prefs.barPillRadius
        bottomRightRadius: pill.atBottom ? pill.pillTopRadius : Prefs.barPillRadius

        HoverHandler {
            id: pillHover

            enabled: pill.popupMode
        }

        // over the contents, not on this rect: see the one on the shell
        Item {
            anchors.fill: parent
            z: 1000

            PointHandler {
                enabled: pill.hoverOpen
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onActiveChanged: {
                    if (active)
                        pill.hoverOpen = false;

                }
            }

        }

        Behavior on color {
            enabled: pill.hostWindow ? pill.hostWindow.laidOut : false

            ColorAnimation {
                duration: Theme.barMs(260)
                easing.type: Easing.OutCubic
            }

        }

    }

    Rectangle {
        id: shell

        width: pill.popupMode ? (pill.anyOpen ? pill.popupWidth : pill.compactWidth + pill.hoverGrow * 2) : pill.width + pill.hoverGrow * 2
        height: pill.popupMode ? (pill.anyOpen ? pill.popupHeight : pill.compactHeight) : pill.height
        x: pill.popupMode && pill.anyOpen ? pill.popupX : pill.surfaceX
        y: pill.popupMode && pill.anyOpen ? (pill.atBottom ? -(pill.popupHeight + Prefs.barPopupGap) : pill.compactHeight + Prefs.barPopupGap) : pill.surfaceY
        visible: !pill.popupMode || Math.abs(shell.y) > 0.5
        color: (pill.popupMode || pill.surfaceOpen) ? Theme.bg : pill.restingColor
        radius: pill.cornerRadius
        topLeftRadius: pill.atBottom ? shell.radius : pill.topRadius
        topRightRadius: pill.atBottom ? shell.radius : pill.topRadius
        bottomLeftRadius: pill.atBottom ? pill.topRadius : shell.radius
        bottomRightRadius: pill.atBottom ? pill.topRadius : shell.radius
        clip: true
        layer.enabled: pill.surfaceLayered
        layer.samples: 4

        // handlers on the surface itself, so hovering the panel's own contents
        // still counts as hovering the pill
        HoverHandler {
            id: shellHover

        }

        // a passive grab, so the panel's buttons and drags keep working. On an
        // item stacked over the contents, not on the shell: a handler on a parent
        // never hears a press a child MouseArea already took (a right-click on a
        // tray item, say), and the panel folded away under the tray's menu
        Item {
            anchors.fill: parent
            z: 1000

            PointHandler {
                id: shellPress

                enabled: pill.hoverOpen
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onActiveChanged: {
                    if (!active)
                        return ;

                    // opened by hover, the compact face is gone before a right
                    // click lands: one on the strip where it sat still opens
                    // this module's card in Settings
                    const y = shellPress.point.position.y;
                    const onStrip = pill.atBottom ? y > shell.height - pill.compactHeight : y < pill.compactHeight;
                    if ((shellPress.point.pressedButtons & Qt.RightButton) && onStrip && pill.headerOpensSettings) {
                        const id = pill.moduleId();
                        if (id !== "") {
                            // the panel folds away, as it would have unopened
                            pill.closeHoverOpen();
                            Prefs.openBarModule(id);
                            return ;
                        }
                    }
                    pill.hoverOpen = false;
                }
            }

        }

        Behavior on x {
            enabled: pill.popupMode

            NumberAnimation {
                duration: pill.popupExpanding ? pill.morphDuration : Theme.barDurExit
                easing.type: Easing.Bezier
                easing.bezierCurve: pill.popupExpanding ? Theme.easeEmphasizedDecel : Theme.easeEmphasizedAccel
            }

        }

        Behavior on y {
            enabled: pill.popupMode

            NumberAnimation {
                duration: pill.popupExpanding ? pill.morphDuration : Theme.barDurExit
                easing.type: Easing.Bezier
                easing.bezierCurve: pill.popupExpanding ? Theme.easeEmphasizedDecel : Theme.easeEmphasizedAccel
            }

        }

        Behavior on width {
            enabled: pill.popupMode

            NumberAnimation {
                duration: pill.popupExpanding ? pill.morphDuration : Theme.barDurExit
                easing.type: Easing.Bezier
                easing.bezierCurve: pill.popupExpanding ? Theme.easeEmphasizedDecel : Theme.easeEmphasizedAccel
            }

        }

        Behavior on height {
            enabled: pill.popupMode

            NumberAnimation {
                duration: pill.popupExpanding ? pill.morphDuration : Theme.barDurExit
                easing.type: Easing.Bezier
                easing.bezierCurve: pill.popupExpanding ? Theme.easeEmphasizedDecel : Theme.easeEmphasizedAccel
            }

        }

        Behavior on radius {
            NumberAnimation {
                duration: Theme.barMs(380)
                easing.type: Easing.OutCubic
            }

        }

        Item {
            id: compactFace

            parent: pill.popupMode ? pillRect : shell
            anchors.fill: parent
            opacity: pill.popupMode || !pill.anyOpen ? 1 : 0
            scale: pill.popupMode || !pill.anyOpen ? 1 : pill.compactCollapseScale
            visible: opacity > 0.01

            MouseArea {
                anchors.fill: parent
                enabled: pill.compactInteractive
                hoverEnabled: pill.compactInteractive
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onEntered: pill.compactHovered = true
                onExited: pill.compactHovered = false
                onClicked: (mouse) => {
                    // a right click opens this module's card in Settings
                    if (mouse.button === Qt.RightButton) {
                        const id = pill.moduleId();
                        if (id !== "")
                            Prefs.openBarModule(id);

                        return ;
                    }
                    pill.hoverOpen = false;
                    pill.compactClicked();
                    pill.expanded = true;
                }
            }

            Item {
                id: compactHolder

                anchors.centerIn: parent
                width: pill.compactWidth
                height: pill.compactHeight
            }

            Behavior on opacity {
                SequentialAnimation {
                    PauseAnimation {
                        duration: pill.compactFadePause
                    }

                    NumberAnimation {
                        duration: pill.compactFadeDuration
                        easing.type: Easing.OutCubic
                    }

                }

            }

            Behavior on scale {
                NumberAnimation {
                    duration: Theme.barMs(220)
                    easing.type: Easing.OutCubic
                }

            }

        }

        Item {
            id: altHolder

            anchors.fill: parent
            opacity: pill.altOpen && !pill.expanded ? 1 : 0
            visible: opacity > 0.01

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.barMs(200)
                    easing.type: Easing.OutCubic
                }

            }

        }

        Item {
            id: panelHolder

            anchors.fill: parent
            opacity: (!pill.panelFades || pill.expanded) ? 1 : 0
            scale: (!pill.panelFades || pill.expanded) ? 1 : 1.04
            visible: opacity > 0.01

            HyprlandFocusGrab {
                active: pill.expanded && pill.focusGrabs && !pill.hoverOpen
                windows: pill.hostWindow ? [pill.hostWindow] : []
                onCleared: pill.expanded = false
            }

            Behavior on opacity {
                SequentialAnimation {
                    PauseAnimation {
                        duration: pill.panelFadePause
                    }

                    NumberAnimation {
                        duration: pill.panelFadeDuration
                        easing.type: Easing.OutCubic
                    }

                }

            }

            Behavior on scale {
                SequentialAnimation {
                    PauseAnimation {
                        duration: pill.panelFadePause
                    }

                    NumberAnimation {
                        duration: Theme.barMs(220)
                        easing.type: Easing.OutCubic
                    }

                }

            }

        }

    }

}
