import QtQuick
import qs

// one preset at the top of the Bar page: a small screen with the bar the
// preset makes (its edge, its style, a block for each module it shows, in
// its groups, and the dock if it keeps one), its name and what it is. a tap
// applies it; the one the bar matches right now wears a tick
Rectangle {
    id: tile

    property string presetId: ""
    readonly property var preset: Prefs.barPresetById(tile.presetId)
    readonly property var values: Prefs.barPresetValues(tile.preset)
    readonly property bool active: {
        // re-read when any of the prefs it compares change
        void Prefs.barLayout;
        void Prefs.barPosition;
        void Prefs.barStyle;
        return Prefs.barPresetActive(tile.presetId);
    }
    readonly property bool atBottom: tile.values.barPosition === "bottom"
    readonly property bool full: tile.values.barStyle === "full"
    readonly property bool flush: tile.values.barStyle !== "island"
    // the modules each group shows, by id
    readonly property var groups: {
        const g = Prefs.parseBarLayout(tile.values.barLayout || Prefs.barLayout);
        const shownIds = (ids) => {
            return ids.filter((id) => {
                const m = Prefs.barModuleById[id];
                return m && tile.values[m.key] === true;
            });
        };
        return {
            "left": shownIds(g.left),
            "center": shownIds(g.center),
            "right": shownIds(g.right)
        };
    }
    readonly property bool dock: !tile.atBottom && tile.values.dockEnabled === true

    width: 196
    height: screenBox.height + textCol.implicitHeight + 24
    radius: Theme.radiusMd
    color: tile.active ? Theme.alpha(Theme.accent, 0.14) : (tileArea.containsMouse ? Theme.bgHover : Theme.bgTile)
    border.width: tile.active ? 2 : 0
    border.color: Theme.accent

    Rectangle {
        id: screenBox

        x: 10
        y: 10
        width: parent.width - 20
        height: 96
        radius: Theme.radiusXs
        color: Theme.bgSunken
        clip: true

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: Theme.alpha(Theme.accent, 0.16)
                }

                GradientStop {
                    position: 1
                    color: Theme.alpha(Theme.accent, 0.03)
                }

            }

        }

        // the strip, for the full bar
        Rectangle {
            visible: tile.full
            width: parent.width
            height: 12
            y: tile.atBottom ? parent.height - height : 0
            color: Theme.bgOpaque
        }

        // the modules, a block each, in their three groups
        Repeater {
            model: ["left", "center", "right"]

            Row {
                id: groupRow

                required property string modelData

                spacing: tile.flush ? 2 : 3
                y: tile.atBottom ? screenBox.height - 12 + 2 - (tile.flush ? 0 : 4) : 2 + (tile.flush ? 0 : 4)
                x: groupRow.modelData === "left" ? 6 : (groupRow.modelData === "right" ? screenBox.width - width - 6 : (screenBox.width - width) / 2)

                Repeater {
                    model: tile.groups[groupRow.modelData]

                    Rectangle {
                        required property string modelData

                        // apps run wider, as they do in the bar
                        width: modelData === "apps" ? 26 : (modelData === "workspaces" ? 14 : (modelData === "clock" ? 12 : 7))
                        height: 8
                        radius: 3
                        color: modelData === "apps" || modelData === "start" ? Theme.accent : (tile.full ? Theme.alpha(Theme.text, 0.35) : Theme.bgOpaque)
                    }

                }

            }

        }

        // the dock, for a preset that keeps it
        Rectangle {
            visible: tile.dock
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
            width: 54
            height: 11
            radius: 4
            color: Theme.bgOpaque

            Row {
                anchors.centerIn: parent
                spacing: 3

                Repeater {
                    model: 5

                    Rectangle {
                        width: 6
                        height: 6
                        radius: 2
                        color: index === 0 ? Theme.accent : Theme.alpha(Theme.text, 0.35)
                    }

                }

            }

        }

    }

    Column {
        id: textCol

        x: 12
        y: screenBox.y + screenBox.height + 8
        width: parent.width - 24
        spacing: 2

        Text {
            width: parent.width
            text: tile.preset ? tile.preset.name : ""
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontLabelLg
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            text: tile.preset ? tile.preset.blurb : ""
            color: Theme.subtext
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontLabel
            wrapMode: Text.WordWrap
            maximumLineCount: 3
            elide: Text.ElideRight
        }

    }

    // the tick on the one in use
    Rectangle {
        visible: tile.active
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 14
        width: 20
        height: 20
        radius: Theme.pill(height)
        color: Theme.accent

        Text {
            anchors.centerIn: parent
            text: "✓"
            color: Theme.fgAccent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontLabel
            font.bold: true
        }

    }

    MouseArea {
        id: tileArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Prefs.applyBarPreset(tile.presetId)
    }

    Behavior on color {
        ColorAnimation {
            duration: Theme.durShort
        }

    }

}
