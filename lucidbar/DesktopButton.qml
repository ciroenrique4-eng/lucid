import QtQuick
import qs

// show the desktop: a click sends the windows on the workspace in view away
// and the next brings them back (ShowDesktop). a thin sliver at the end of the
// bar, as on Windows, or an icon
BarPill {
    id: root

    readonly property bool windowsFace: Prefs.desktopModuleStyle === "windows"
    readonly property bool labelFace: Prefs.desktopModuleStyle === "label"
    // the label look shows the same little screen, with the word after it
    readonly property bool iconFace: Prefs.desktopModuleStyle === "icon" || root.labelFace
    readonly property bool away: ShowDesktop.active

    opensOnHover: false
    compactInteractive: false
    compactHovered: deskArea.containsMouse
    shown: Prefs.showDesktop
    compactWidth: root.labelFace ? deskLabel.implicitWidth + 50 : (root.iconFace || root.windowsFace ? 36 : 14)

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
            visible: !root.iconFace && !root.windowsFace
            x: 1
            anchors.verticalCenter: parent.verticalCenter
            width: 1
            height: Math.round(root.compactHeight * 0.45)
            color: root.away ? Theme.accent : Theme.alpha(Theme.text, 0.3)
        },
        // Windows: two small windows, one over the other; sent away they sink
        // into the bar and fade, brought back they rise again
        Item {
            visible: root.windowsFace
            anchors.centerIn: parent
            width: 20
            height: 16
            clip: true

            Repeater {
                model: 2

                Rectangle {
                    required property int index

                    x: index === 0 ? 0 : 6
                    y: (index === 0 ? 0 : 4) + (root.away ? 16 : 0)
                    width: 13
                    height: 10
                    radius: Theme.rad(2.5)
                    color: index === 1 ? Theme.alpha(Theme.accent, 0.25) : "transparent"
                    border.width: 1.6
                    border.color: index === 1 ? Theme.accent : Theme.text
                    opacity: root.away ? 0 : 1

                    // a title bar
                    Rectangle {
                        x: 0
                        y: 0
                        width: parent.width
                        height: 3
                        radius: parent.radius
                        color: parent.border.color
                    }

                    Behavior on y {
                        NumberAnimation {
                            duration: 320 + index * 80
                            easing.type: Easing.InOutCubic
                        }

                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 320
                        }

                    }

                }

            }

            // the line they sink behind, lit while they're away
            Rectangle {
                y: 14
                width: parent.width
                height: 2
                radius: 1
                color: root.away ? Theme.accent : Theme.alpha(Theme.text, 0.3)
            }

        },
        // the icon: a screen with nothing on it (Label puts the word after it)
        Item {
            visible: root.iconFace
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: root.labelFace ? -(deskLabel.implicitWidth + 6) / 2 : 0
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
        Text {
            id: deskLabel

            visible: root.labelFace
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: (18 + 6) / 2
            text: I18n.tr("Desktop")
            color: root.away ? Theme.accent : Theme.text
            font.family: Theme.fontFamily
            font.bold: true
            font.pixelSize: Theme.fs(12)
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
