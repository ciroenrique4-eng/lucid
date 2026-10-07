import QtQuick
import qs

// one wallpaper transition preset: its name, what it does, and a tick when the
// settings match it. a tap uses it; one of your own also wears a cross to drop it
Rectangle {
    id: tile

    property var preset: null
    readonly property bool selected: tile.preset !== null && Prefs.wallTransPreset === tile.preset.id
    readonly property string summary: tile.preset === null ? "" : (tile.preset.type === "none" || tile.preset.type === "simple" ? tile.preset.type : I18n.tr("%1 · %2 s", tile.preset.type, tile.preset.duration))

    width: 150
    height: 62
    radius: Theme.radiusMd
    color: tile.selected ? Theme.alpha(Theme.accent, 0.14) : (area.containsMouse ? Theme.bgHover : Theme.bgSunken)
    border.width: tile.selected ? 2 : 0
    border.color: Theme.accent
    scale: area.pressed ? 0.97 : 1

    Behavior on color {
        ColorAnimation {
            duration: Theme.durShort
        }

    }

    Behavior on scale {
        NumberAnimation {
            duration: Theme.durQuick
            easing.type: Theme.easeStandard
        }

    }

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 14
        anchors.rightMargin: tile.preset !== null && tile.preset.custom ? 30 : 14
        spacing: 3

        Text {
            width: parent.width
            text: tile.preset === null ? "" : WallTransitions.presetName(tile.preset)
            elide: Text.ElideRight
            color: tile.selected ? Theme.accent : Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
            font.weight: Font.DemiBold
        }

        Text {
            width: parent.width
            text: tile.summary
            elide: Text.ElideRight
            color: Theme.subtext
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontLabel
        }

    }

    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: WallTransitions.apply(tile.preset.id)
    }

    Rectangle {
        id: drop

        visible: tile.preset !== null && tile.preset.custom
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 8
        width: 22
        height: 22
        radius: 11
        color: dropArea.containsMouse ? Theme.bgHover : "transparent"

        Text {
            anchors.centerIn: parent
            text: "✕" // i18n-skip
            color: Theme.subtext
            font.pixelSize: 11
        }

        MouseArea {
            id: dropArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: WallTransitions.deleteCustom(tile.preset.id)
        }

    }

}
