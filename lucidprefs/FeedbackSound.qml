import QtQuick
import qs

// one event's sound in Settings: on or off, which of its sounds, a listen, and
// with Custom picked, the file of the user's own for each half of it
Column {
    id: fb

    // a key of Sounds.events
    required property string event
    readonly property var ev: Sounds.events[fb.event]
    readonly property bool on: Prefs[fb.ev.on] === true
    readonly property string current: Prefs[fb.ev.style]
    readonly property bool custom: fb.current === "custom"
    readonly property var options: fb.ev.options.concat([{
        "key": "custom",
        "label": I18n.tr("Custom")
    }])

    function pick(key) {
        if (key !== "custom") {
            Prefs[fb.ev.style] = key;
            Sounds.preview(fb.event);
            return ;
        }
        // nothing of the user's yet: ask for it, and switch over once it is in
        const any = fb.ev.slots.some((s) => {
            return Sounds.customFile(s) !== "";
        });
        if (!any) {
            Sounds.choose(fb.ev.slots[0]);
            return ;
        }
        Prefs[fb.ev.style] = "custom";
        Sounds.preview(fb.event);
    }

    width: parent ? parent.width : 400
    spacing: 12

    Row {
        spacing: 12

        M3Switch {
            anchors.verticalCenter: parent.verticalCenter
            checked: fb.on
            onToggled: (v) => {
                return Prefs[fb.ev.on] = v;
            }
        }

        M3Segmented {
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(96 * fb.options.length, fb.width - 52 - 52 - 24)
            enabled: fb.on
            current: fb.current
            options: fb.options
            onChosen: (key) => {
                return fb.pick(key);
            }
        }

        M3IconButton {
            anchors.verticalCenter: parent.verticalCenter
            variant: "tonal"
            size: 40
            iconSize: 20
            enabled: fb.on
            iconPath: "M8 5.14v13.72a1 1 0 0 0 1.5.86l11.04-6.86a1 1 0 0 0 0-1.72L9.5 4.28A1 1 0 0 0 8 5.14Z"
            onClicked: Sounds.preview(fb.event)
        }

    }

    Repeater {
        model: fb.custom || Sounds.choosing !== "" && fb.ev.slots.indexOf(Sounds.choosing) >= 0 ? fb.ev.slots : []

        Row {
            id: slotRow

            required property string modelData
            readonly property string name: Sounds.customName(slotRow.modelData)
            readonly property bool busy: Sounds.choosing === slotRow.modelData
            // the other half of a pair, whose file this one borrows while it has none
            readonly property string other: fb.ev.slots.length > 1 ? fb.ev.slots[fb.ev.slots[0] === slotRow.modelData ? 1 : 0] : ""

            spacing: 10
            leftPadding: 64

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: fb.ev.slots.length > 1 ? 90 : 0
                visible: fb.ev.slots.length > 1
                text: Sounds.slotLabel[slotRow.modelData] || ""
                color: Theme.subtext
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: 160
                elide: Text.ElideMiddle
                text: slotRow.busy ? I18n.tr("Choosing…") : (slotRow.name !== "" ? slotRow.name : (slotRow.other !== "" ? I18n.tr("Same as %1", (Sounds.slotLabel[slotRow.other] || "").toLowerCase()) : I18n.tr("Nothing chosen")))
                color: slotRow.name !== "" ? Theme.text : Theme.subtext
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
                font.weight: slotRow.name !== "" ? Font.DemiBold : Font.Normal
            }

            M3Button {
                anchors.verticalCenter: parent.verticalCenter
                width: 112
                variant: "tonal"
                text: slotRow.name !== "" ? I18n.tr("Change…") : I18n.tr("Choose…")
                enabled: Sounds.choosing === ""
                onClicked: Sounds.choose(slotRow.modelData)
            }

            M3IconButton {
                anchors.verticalCenter: parent.verticalCenter
                visible: fb.ev.slots.length > 1
                size: 36
                iconSize: 18
                enabled: fb.on
                iconPath: "M8 5.14v13.72a1 1 0 0 0 1.5.86l11.04-6.86a1 1 0 0 0 0-1.72L9.5 4.28A1 1 0 0 0 8 5.14Z"
                onClicked: Sounds.previewSlot(slotRow.modelData)
            }

            M3IconButton {
                anchors.verticalCenter: parent.verticalCenter
                visible: slotRow.name !== ""
                size: 36
                iconSize: 18
                iconPath: "M19 6.41 17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12Z"
                onClicked: Sounds.forget(slotRow.modelData)
            }

        }

    }

    Text {
        visible: Sounds.failed !== "" && fb.ev.slots.indexOf(Sounds.lastChosen) >= 0
        leftPadding: 64
        width: fb.width
        wrapMode: Text.WordWrap
        text: I18n.tr("\"%1\" could not be read as a sound.", Sounds.failed)
        color: Theme.error
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontBody
    }

}
