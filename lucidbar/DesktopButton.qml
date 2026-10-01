import QtQuick
import qs

// show the desktop: a click sends the windows on the workspace in view away
// and the next brings them back (ShowDesktop). a thin sliver at the end of the
// bar, as on Windows, or an icon
BarPill {
    id: root

    readonly property bool iconFace: Prefs.desktopModuleStyle === "icon"
    readonly property bool away: ShowDesktop.active

    opensOnHover: false
    compactInteractive: false
    compactHovered: deskArea.containsMouse
    shown: Prefs.showDesktop
    compactWidth: root.iconFace ? 36 : 14

    compactContent: [
        Rectangle {
            anchors.centerIn: parent
            width: parent.width - 4
            height: Math.max(0, root.compactHeight - 8)
            radius: Theme.pill(Math.min(width, height))
            color: root.away ? Theme.alpha(Theme.accent, deskArea.pressed ? 0.32 : 0.22) : Theme.alpha(Theme.text, deskArea.pressed ? 0.14 : (deskArea.containsMouse ? 0.08 : 0))

            Behavior on color {
                ColorAnimation {
                    duration: Theme.durShort
                }

            }

        },
        // the sliver: a line on the side facing the rest of the bar
        Rectangle {
            visible: !root.iconFace
            x: 1
            anchors.verticalCenter: parent.verticalCenter
            width: 1
            height: Math.round(root.compactHeight * 0.45)
            color: root.away ? Theme.accent : Theme.alpha(Theme.text, 0.3)
        },
        // the icon: a screen with nothing on it
        Item {
            visible: root.iconFace
            anchors.centerIn: parent
            width: 18
            height: 14

            Rectangle {
                width: parent.width
                height: 11
                radius: 2
                color: "transparent"
                border.width: 1.6
                border.color: root.away ? Theme.accent : Theme.text
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 12
                width: 8
                height: 1.6
                radius: 1
                color: root.away ? Theme.accent : Theme.text
            }

        },
        MouseArea {
            id: deskArea

            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton)
                    Prefs.openBarModule("desktop");
                else
                    ShowDesktop.toggle();
            }
        }
    ]
}
