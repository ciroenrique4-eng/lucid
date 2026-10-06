import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import qs
import "../lucidprefs"
import "QuietLooks.js" as Looks

// the start button: the launcher, from the bar. a click opens it or puts it
// away; the right click is the module's card, as on every module
BarPill {
    id: root

    property var dockMod: null
    readonly property bool launcherOpen: !!root.dockMod && root.dockMod.menuOpen
    readonly property bool gridFace: Prefs.startModuleStyle === "grid"
    // the distribution's logo, the account picture, or a word; the logo falls
    // back to Lucid's mark when the system names none or none is found
    property string osReleaseText: ""
    readonly property string osLogo: Looks.osLogo(root.osReleaseText)
    readonly property string osLogoSource: {
        if (root.osLogo === "")
            return "";

        const themed = Quickshell.iconPath(root.osLogo, true);
        return themed !== "" ? themed : "file:///usr/share/pixmaps/" + root.osLogo + ".svg";
    }
    readonly property bool distroFace: Prefs.startModuleStyle === "distro" && distroLogo.status !== Image.Error && root.osLogoSource !== ""
    readonly property bool avatarFace: Prefs.startModuleStyle === "avatar"
    readonly property bool labelFace: Prefs.startModuleStyle === "label"
    readonly property bool markFace: !root.gridFace && !root.distroFace && !root.avatarFace && !root.labelFace
    readonly property int glyph: Math.max(16, Math.min(22, root.compactHeight - 14))

    opensOnHover: false
    compactInteractive: false
    compactHovered: startArea.containsMouse
    shown: Prefs.showStart && root.dockMod !== null
    compactWidth: root.labelFace ? startLabel.implicitWidth + 32 : root.glyph + 22

    FileView {
        id: osRelease

        path: "/etc/os-release"
        onLoaded: root.osReleaseText = osRelease.text()
    }

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
            visible: root.markFace
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
        // Distro: the logo /etc/os-release names, in the accent
        Image {
            id: distroLogo

            visible: false
            width: root.glyph
            height: root.glyph
            source: Prefs.startModuleStyle === "distro" ? root.osLogoSource : ""
            sourceSize.width: root.glyph * 2
            sourceSize.height: root.glyph * 2
            fillMode: Image.PreserveAspectFit
            asynchronous: true
        },
        MultiEffect {
            visible: root.distroFace
            anchors.centerIn: parent
            width: root.glyph
            height: root.glyph
            source: distroLogo
            colorization: 1
            colorizationColor: Theme.accent
            brightness: 0.25
        },
        // Avatar: the account picture, round
        UserAvatar {
            visible: root.avatarFace
            anchors.centerIn: parent
            user: Users.me
            size: root.glyph + 2
        },
        // Label: the word, on a chip in the accent
        Rectangle {
            visible: root.labelFace
            anchors.centerIn: parent
            width: startLabel.implicitWidth + 20
            height: Math.min(24, root.compactHeight - 8)
            radius: Theme.pill(height)
            color: root.launcherOpen ? Theme.accentHover : Theme.accent

            Text {
                id: startLabel

                anchors.centerIn: parent
                text: I18n.trc("start button", "Start")
                color: Theme.fgAccent
                font.family: Theme.fontFamily
                font.bold: true
                font.pixelSize: Theme.fs(12)
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
