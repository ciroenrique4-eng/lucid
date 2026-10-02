import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs

Variants {
    id: variants

    model: Quickshell.screens

    Scope {
        id: unit

        required property var modelData
        // the icons live on the main screen only
        readonly property bool icons: DesktopIcons.live && unit.modelData === DesktopIcons.screen

        function run(id) {
            if (id.indexOf("icon:") === 0 || id === "newFolder" || id === "paste" || id === "arrange" || id === "openDesktop")
                DesktopIcons.runAction(id);
            else if (id === "addWidget")
                Prefs.settingsRequested("widgets");
            else if (id === "settings")
                Prefs.settingsRequested("");
            else if (id === "keyboard")
                Prefs.keyboardRequested();
            else if (id === "hideIcons" || id === "showIcons")
                Prefs.desktopIconsShown = id === "showIcons";
            else if (id === "hideWidgets" || id === "showWidgets")
                Prefs.widgetsEnabled = !Prefs.widgetsEnabled;
            else
                Prefs.desktopActionRequested(id);
        }

        // surfaces on one layer stack in the order they were made, so a wallpaper
        // daemon that starts (or restarts) after the shell would cover the
        // icons. Its surface showing up remaps this one, back on top
        property bool lifting: false

        Connections {
            function onRawEvent(event) {
                if (event.name === "openlayer" && /awww|swww|paper|swaybg|wallpaper/i.test(event.data))
                    liftTimer.restart();

            }

            target: Hyprland
        }

        Timer {
            id: liftTimer

            interval: 400
            onTriggered: {
                unit.lifting = true;
                Qt.callLater(() => {
                    unit.lifting = false;
                });
            }
        }

        PanelWindow {
            id: layer

            screen: unit.modelData
            visible: Prefs.loaded && (Prefs.desktopSelection || Prefs.desktopMenu || unit.icons) && !unit.lifting
            color: "transparent"
            // reserves nothing and refuses to be shrunk into the bar and dock's
            // strips, so the box can be dragged edge to edge
            exclusionMode: ExclusionMode.Ignore
            // the bottom-most layer, so a press only reaches here when nothing —
            // no window, no widget, no panel — is sitting over that pixel
            WlrLayershell.layer: WlrLayer.Background
            // a click on an icon takes the keyboard (Enter, Delete, F2...) and a
            // click on a window gives it straight back
            WlrLayershell.keyboardFocus: unit.icons ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            MouseArea {
                id: field

                // press origin and the live corner, both in layer coordinates
                property real ax: 0
                property real ay: 0
                property real bx: 0
                property real by: 0
                property bool dragging: false
                // only a left press arms the box; a right press opens the menu
                property bool armed: false
                // a plain click should not flash a box, so wait for real travel
                readonly property int threshold: 4

                // with icons, the box selects them, and the icons' board draws it
                // over them; without, this one is the decoration it always was
                property bool additive: false

                function begin() {
                    field.dragging = true;
                    if (unit.icons) {
                        DesktopIcons.beginBand(field.additive);
                        field.track();
                        return ;
                    }
                    fade.stop();
                    box.opacity = 1;
                }

                function track() {
                    if (unit.icons && field.dragging)
                        DesktopIcons.updateBand(Math.min(field.ax, field.bx), Math.min(field.ay, field.by), Math.abs(field.bx - field.ax), Math.abs(field.by - field.ay));

                }

                function finish() {
                    if (field.dragging && !unit.icons)
                        fade.restart();

                    if (unit.icons)
                        DesktopIcons.endBand();

                    field.dragging = false;
                    field.armed = false;
                }

                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onPressed: (m) => {
                    if (m.button === Qt.RightButton) {
                        field.armed = false;
                        if (unit.icons) {
                            DesktopIcons.clearSelection();
                            DesktopIcons.menuX = m.x;
                            DesktopIcons.menuY = m.y;
                            DesktopIcons.probePaste();
                        }
                        if (Prefs.desktopMenu) {
                            menu.custom = null;
                            menu.openAt(m.x, m.y);
                        }
                        return ;
                    }
                    field.additive = (m.modifiers & (Qt.ControlModifier | Qt.ShiftModifier)) !== 0;
                    if (unit.icons) {
                        iconBoard.forceActiveFocus();
                        if (!field.additive)
                            DesktopIcons.clearSelection();

                    }

                    field.armed = Prefs.desktopSelection;
                    field.ax = m.x;
                    field.ay = m.y;
                    field.bx = m.x;
                    field.by = m.y;
                    field.dragging = false;
                }
                // the pointer keeps reporting past the edges once grabbed, so pin the
                // corner to the screen instead of letting the box run off it
                onPositionChanged: (m) => {
                    if (!field.armed)
                        return ;

                    field.bx = Math.max(0, Math.min(field.width, m.x));
                    field.by = Math.max(0, Math.min(field.height, m.y));
                    if (!field.dragging && (Math.abs(field.bx - field.ax) > field.threshold || Math.abs(field.by - field.ay) > field.threshold))
                        field.begin();
                    else
                        field.track();

                }
                onReleased: field.finish()
                onCanceled: field.finish()

                Rectangle {
                    id: box

                    x: Math.min(field.ax, field.bx)
                    y: Math.min(field.ay, field.by)
                    width: Math.abs(field.bx - field.ax)
                    height: Math.abs(field.by - field.ay)
                    radius: Math.min(4, box.width / 2, box.height / 2)
                    color: Theme.alpha(Theme.accent, 0.16)
                    border.width: 1
                    border.color: Theme.alpha(Theme.accent, 0.8)
                    antialiasing: true
                    // set outright on drag start and only ever animated back down,
                    // so the box tracks the cursor from the first frame
                    opacity: 0
                    visible: box.opacity > 0.01

                    NumberAnimation {
                        id: fade

                        target: box
                        property: "opacity"
                        to: 0
                        duration: Theme.durExit
                        easing.type: Easing.OutCubic
                    }

                }

            }

            IconBoard {
                id: iconBoard

                anchors.fill: parent
                visible: unit.icons
                enabled: unit.icons
            }

            // files dragged over the desktop: from a file manager, a
            // browser, the screenshot card, or our own icons being moved
            DropArea {
                anchors.fill: parent
                enabled: unit.icons
                onEntered: (d) => {
                    DesktopIcons.appDrag = d.formats.indexOf(DesktopIcons.appMime) >= 0;
                    d.accept(DesktopIcons.appDrag ? Qt.CopyAction : d.proposedAction);
                }
                onPositionChanged: (d) => {
                    DesktopIcons.hover(d.x, d.y);
                }
                onExited: DesktopIcons.leaveDrag()
                onDropped: (d) => {
                    DesktopIcons.dropped(d);
                }
            }

            // glass icons frost the wallpaper behind each card, like the widgets
            BackgroundEffect.blurRegion: unit.glass ? glassBlur : null

            Region {
                id: glassBlur

                regions: glassCards.instances
            }

        }

        readonly property bool glass: unit.icons && (Prefs.desktopIconStyle === "glass" || Prefs.desktopIconStyle === "objects") && Theme.blurAmount > 0

        Variants {
            id: glassCards

            // every card in the glass look; in the object look only the ones
            // showing, under the pointer, selected or taking a drop
            model: {
                if (!unit.glass)
                    return [];

                if (Prefs.desktopIconStyle === "glass")
                    return DesktopIcons.items.map((i) => {
                    return i.key;
                });

                var keys = DesktopIcons.selectedKeys.slice();
                [DesktopIcons.hoverKey, DesktopIcons.dropInto].forEach((k) => {
                    if (k !== "" && keys.indexOf(k) < 0)
                        keys.push(k);

                });
                return keys;
            }

            // the card's own rectangle, a hair inside it so the frosting's hard
            // edge never shows past the card's rounded one
            Region {
                required property var modelData

                readonly property var spot: DesktopIcons.placed[modelData] || null

                x: spot ? DesktopIcons.tileX(spot.c) + 5 : 0
                y: spot ? DesktopIcons.tileY(spot.r) + 3 : 0
                width: spot ? DesktopIcons.tileW - 10 : 0
                height: spot ? (DesktopIcons.cardH[modelData] || DesktopIcons.tileH - 4) - 2 : 0
                radius: Math.max(0, (Prefs.desktopIconStyle === "objects" ? Theme.radiusLg : Theme.radiusMd) - 1)
            }

        }

        // the icons ask for their menu through here, so there is one menu
        Connections {
            function onMenuRequested(x, y, actions) {
                if (!unit.icons)
                    return ;

                menu.custom = actions;
                menu.openAt(x, y);
            }

            target: DesktopIcons
        }

        // the menu cannot live on the background layer or windows would cover it,
        // so it gets its own overlay that only exists while it is open
        PanelWindow {
            id: menuLayer

            screen: unit.modelData
            // up the moment the menu opens, so the fade-in plays inside a mapped
            // surface, and stays up until the fade-out finishes
            visible: menu.open || menu.visible
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: menu.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            Item {
                anchors.fill: parent
                focus: true
                Keys.onEscapePressed: menu.open = false

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onPressed: menu.open = false
                }

                DesktopMenu {
                    id: menu

                    fieldW: menuLayer.width
                    fieldH: menuLayer.height
                    onChosen: (id) => {
                        return unit.run(id);
                    }
                }

            }

            // no input once the menu starts closing, so the fade-out is never a
            // dead region over the desktop
            mask: Region {
                width: menu.open ? menuLayer.width : 0
                height: menu.open ? menuLayer.height : 0
            }

        }

    }

}
