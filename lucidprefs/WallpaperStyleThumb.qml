import QtQuick
import qs

// one wallpaper picker style as a flat miniature of itself; a tap uses it
Rectangle {
    id: tile

    property string styleId: ""
    property string label: ""
    readonly property bool selected: Prefs.wallpaperPickerStyle === tile.styleId
    readonly property color ink: Theme.alpha(Theme.text, 0.28)

    width: 150
    height: screenBox.height + caption.implicitHeight + 28
    radius: Theme.radiusMd
    color: tile.selected ? Theme.alpha(Theme.accent, 0.14) : (area.containsMouse ? Theme.bgHover : Theme.bgSunken)
    border.width: tile.selected ? 2 : 0
    border.color: Theme.accent

    Behavior on color {
        ColorAnimation {
            duration: Theme.durShort
        }

    }

    Rectangle {
        id: screenBox

        x: 10
        y: 10
        width: parent.width - 20
        height: 58
        radius: Theme.radiusXs
        color: Theme.bgSunken
        clip: true

        // every miniature is drawn from the shell's own radii, so it squares off with them
        // strip: the picked card big, its neighbours stepping down
        Row {
            anchors.centerIn: parent
            spacing: 4
            visible: tile.styleId === "strip"

            Repeater {
                model: [{ "w": 14, "h": 18 }, { "w": 20, "h": 26 }, { "w": 34, "h": 38 }, { "w": 20, "h": 26 }, { "w": 14, "h": 18 }]

                Rectangle {
                    required property var modelData
                    required property int index

                    anchors.verticalCenter: parent.verticalCenter
                    width: modelData.w
                    height: modelData.h
                    radius: Theme.rad(index === 2 ? 6 : 4)
                    color: index === 2 ? Theme.accent : tile.ink
                }

            }

        }

        // pills: narrow pills with one opened into a card
        Row {
            anchors.centerIn: parent
            spacing: 4
            visible: tile.styleId === "pills"

            Repeater {
                model: 7

                Rectangle {
                    required property int index

                    anchors.verticalCenter: parent.verticalCenter
                    width: index === 3 ? 34 : 7
                    height: index === 3 ? 38 : 22
                    radius: index === 3 ? Theme.rad(6) : Theme.pill(7)
                    color: index === 3 ? Theme.accent : tile.ink
                }

            }

        }

        // tiles: two rows of rounded squares, the picked one rounder
        Grid {
            anchors.centerIn: parent
            rows: 2
            flow: Grid.TopToBottom
            spacing: 5
            visible: tile.styleId === "tiles"

            Repeater {
                model: 12

                Rectangle {
                    required property int index

                    width: 18
                    height: 18
                    radius: Theme.rad(index === 5 ? 5 : 3)
                    color: index === 5 ? Theme.accent : tile.ink
                }

            }

        }

        // accordion: slices of the whole height, one opened
        Row {
            anchors.centerIn: parent
            spacing: 3
            visible: tile.styleId === "accordion"

            Repeater {
                model: 11

                Rectangle {
                    required property int index

                    anchors.verticalCenter: parent.verticalCenter
                    width: index === 5 ? 30 : 6
                    height: 50
                    radius: index === 5 ? Theme.rad(8) : Theme.pill(6)
                    color: index === 5 ? Theme.accent : tile.ink
                }

            }

        }

        // wave: pills as tall as a bell around the picked one
        Row {
            anchors.centerIn: parent
            spacing: 3
            visible: tile.styleId === "wave"

            Repeater {
                model: 11

                Rectangle {
                    required property int index

                    anchors.verticalCenter: parent.verticalCenter
                    width: index === 5 ? 26 : 7
                    height: index === 5 ? 50 : Math.round(12 + 26 * Math.exp(-Math.pow(index - 5, 2) / 10))
                    radius: index === 5 ? Theme.rad(8) : Theme.pill(7)
                    color: index === 5 ? Theme.accent : tile.ink
                }

            }

        }

        // bento: the picked one large, the others in tiles of different sizes
        Item {
            anchors.fill: parent
            anchors.margins: 5
            visible: tile.styleId === "bento"

            Rectangle {
                x: 0
                y: 0
                width: 10
                height: 21
                radius: Theme.rad(3)
                color: tile.ink
            }

            Rectangle {
                x: 0
                y: 25
                width: 10
                height: 21
                radius: Theme.rad(3)
                color: tile.ink
            }

            Rectangle {
                x: 14
                y: 0
                width: 36
                height: 46
                radius: Theme.rad(8)
                color: Theme.accent
            }

            Rectangle {
                x: 54
                y: 0
                width: 24
                height: 46
                radius: Theme.rad(5)
                color: tile.ink
            }

            Rectangle {
                x: 82
                y: 0
                width: 18
                height: 27
                radius: Theme.rad(4)
                color: tile.ink
            }

            Rectangle {
                x: 82
                y: 31
                width: 18
                height: 15
                radius: Theme.rad(4)
                color: tile.ink
            }

            Rectangle {
                x: 104
                y: 0
                width: 16
                height: 15
                radius: Theme.rad(4)
                color: tile.ink
            }

            Rectangle {
                x: 104
                y: 19
                width: 16
                height: 27
                radius: Theme.rad(4)
                color: tile.ink
            }

        }

    }

    Text {
        id: caption

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: screenBox.bottom
        anchors.topMargin: 8
        text: tile.label
        color: tile.selected ? Theme.accent : Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontBody
        font.weight: tile.selected ? Font.DemiBold : Font.Medium
    }

    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Prefs.wallpaperPickerStyle = tile.styleId
    }

}
