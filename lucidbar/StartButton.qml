import QtQuick
import QtQuick.Shapes
import qs

// the start button: the launcher, from the bar. a click opens it or puts it
// away; the right click is the module's card, as on every module
BarPill {
    id: root

    property var dockMod: null
    readonly property bool launcherOpen: !!root.dockMod && root.dockMod.menuOpen
    readonly property bool gridFace: Prefs.startModuleStyle === "grid"
    readonly property int glyph: Math.max(16, Math.min(22, root.compactHeight - 14))

    opensOnHover: false
    compactInteractive: false
    compactHovered: startArea.containsMouse
    shown: Prefs.showStart && root.dockMod !== null
    compactWidth: root.glyph + 22

    compactContent: [
        Rectangle {
            anchors.centerIn: parent
            width: parent.width - 4
            height: Math.max(0, root.compactHeight - 8)
            radius: Theme.pill(height)
            color: root.launcherOpen ? Theme.alpha(Theme.accent, startArea.pressed ? 0.3 : 0.2) : Theme.alpha(Theme.text, startArea.pressed ? 0.14 : (startArea.containsMouse ? 0.08 : 0))

            Behavior on color {
                ColorAnimation {
                    duration: Theme.durShort
                }

            }

        },
        // Lucid's mark, as on the dock's launcher button
        Shape {
            visible: !root.gridFace
            anchors.centerIn: parent
            width: root.glyph
            height: root.glyph
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeColor: Theme.accent
                strokeWidth: 3
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                PathSvg {
                    path: root.dockMod ? root.dockMod.lucidaRing : ""
                }

            }

            ShapePath {
                strokeWidth: 0
                fillColor: Theme.text

                PathSvg {
                    path: root.dockMod ? root.dockMod.lucidaStar : ""
                }

            }

            ShapePath {
                strokeWidth: 0
                fillColor: Theme.accent

                PathSvg {
                    path: root.dockMod ? root.dockMod.lucidaCompanion : ""
                }

            }

            transform: Scale {
                xScale: root.glyph / 24
                yScale: root.glyph / 24
            }

        },
        // or a grid of nine
        Grid {
            visible: root.gridFace
            anchors.centerIn: parent
            columns: 3
            spacing: Math.round(root.glyph / 7)

            Repeater {
                model: 9

                Rectangle {
                    width: Math.round(root.glyph / 5)
                    height: width
                    radius: Theme.pill(height)
                    color: index === 4 ? Theme.accent : Theme.text
                }

            }

        },
        MouseArea {
            id: startArea

            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    Prefs.openBarModule("start");
                    return ;
                }
                if (root.launcherOpen)
                    root.dockMod.menuOpen = false;
                else
                    root.dockMod.openLauncher("");
            }
        }
    ]
}
