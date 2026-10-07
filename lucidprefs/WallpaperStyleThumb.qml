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
                    radius: index === 2 ? 6 : 4
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
                    radius: index === 3 ? 6 : 3.5
                    color: index === 3 ? Theme.accent : tile.ink
                }

            }

        }

        // tiles: two rows of circles, the picked one squared off
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
                    radius: index === 5 ? 5 : 9
                    color: index === 5 ? Theme.accent : tile.ink
                }

            }

        }

        // card: one card and its pills
        Rectangle {
            visible: tile.styleId === "card"
            anchors.horizontalCenter: parent.horizontalCenter
            y: 7
            width: 62
            height: 32
            radius: 9
            color: Theme.accent
        }

        Row {
            visible: tile.styleId === "card"
            anchors.horizontalCenter: parent.horizontalCenter
            y: 46
            spacing: 4

            Repeater {
                model: 6

                Rectangle {
                    required property int index

                    width: index === 2 ? 12 : 4
                    height: 4
                    radius: 2
                    color: index === 2 ? Theme.accent : tile.ink
                }

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
