import QtQuick
import qs

Column {
    id: page

    property string expandedOut: ""
    property string expandedIn: ""
    property string expandedStream: ""
    readonly property var sink: Audio.sink
    readonly property var source: Audio.source
    // the pane is showing and the settings window is open, which is when the
    // meters are worth a capture stream
    readonly property bool shown: page.visible && page.Window.window !== null && page.Window.window.visible
    readonly property bool sinkBalance: Audio.hasBalance(page.sink)
    readonly property var balanceLabels: {
        const out = [];
        for (let v = -100; v <= 100; v += 5) out.push(v === 0 ? I18n.tr("Centre") : (v < 0 ? I18n.tr("Left %1%", -v) : I18n.tr("Right %1%", v)))
        return out;
    }
    // listening on a Bluetooth headset's microphone flips it into call mode,
    // so there the input meter waits to be asked
    property bool btListen: false
    readonly property var sourceCard: Audio.cardFor(page.source)
    readonly property bool meterWouldSwitch: !!page.source && page.source.name.indexOf("bluez_input.") === 0 && Audio.wp["bluetooth.autoswitch-to-headset-profile"] !== false && !(page.sourceCard && page.sourceCard.active.indexOf("headset") === 0)
    readonly property string outputSummary: {
        if (Audio.outputs.length === 0)
            return I18n.tr("This machine has nothing to play sound through.");

        if (!page.sink)
            return I18n.tr("Nothing is set as the output yet. Pick one below.");

        const detail = Audio.detailOf(page.sink);
        return Audio.label(page.sink) + (detail !== "" ? " · " + detail : "");
    }
    readonly property string inputSummary: {
        if (Audio.inputs.length === 0)
            return I18n.tr("No microphone or other input is plugged into this machine.");

        if (!page.source)
            return I18n.tr("Nothing is set as the input yet. Pick one below.");

        const detail = Audio.detailOf(page.source);
        return Audio.label(page.source) + (detail !== "" ? " · " + detail : "");
    }

    spacing: 26
    onSourceChanged: page.btListen = false
    Component.onCompleted: {
        Audio.refresh();
        Audio.refreshWp();
    }

    SettingCard {
        title: I18n.tr("OUTPUT")

        SettingRow {
            title: I18n.tr("Volume")
            description: page.outputSummary
            enabled: !!page.sink
            disabledReason: page.outputSummary
            warning: Audio.lastError
            stacked: true

            Column {
                width: parent.width
                spacing: 10

                Row {
                    width: parent.width
                    spacing: 12

                    M3IconButton {
                        anchors.verticalCenter: parent.verticalCenter
                        size: 40
                        iconSize: 21
                        variant: Audio.mutedOf(page.sink) ? "tonal" : "standard"
                        enabled: !!page.sink
                        iconPath: Audio.mutedOf(page.sink) ? "M12 4 9.91 6.09 12 8.18V4ZM4.27 3 3 4.27 7.73 9H3v6h4l5 5v-6.73l4.25 4.25c-.67.52-1.42.93-2.25 1.18v2.06a8.94 8.94 0 0 0 3.69-1.81L19.73 21 21 19.73l-9-9L4.27 3ZM19 12c0 .82-.15 1.61-.41 2.34l1.53 1.53A8.9 8.9 0 0 0 21 12c0-4.28-2.99-7.86-7-8.77v2.06c2.89.86 5 3.54 5 6.71Zm-2.5 0c0-1.77-1.02-3.29-2.5-4.03v1.79l2.48 2.48c.01-.08.02-.16.02-.24Z" : "M3 9v6h4l5 5V4L7 9H3Zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02ZM14 3.23v2.06c2.89.86 5 3.54 5 6.71s-2.11 5.85-5 6.71v2.06c4.01-.91 7-4.49 7-8.77s-2.99-7.86-7-8.77Z"
                        onClicked: Audio.toggleMute(page.sink)
                    }

                    M3Slider {
                        width: parent.width - 52
                        anchors.verticalCenter: parent.verticalCenter
                        from: 0
                        to: 100
                        stepSize: 1
                        decimals: 0
                        suffix: "%"
                        enabled: !!page.sink && !Audio.mutedOf(page.sink)
                        value: Audio.volumeOf(page.sink)
                        onMoved: (v) => {
                            return Audio.setVolume(page.sink, v);
                        }
                    }

                }

                LevelMeter {
                    x: 52
                    width: parent.width - 52
                    node: page.sink
                    running: page.shown
                }

            }

        }

        SettingRow {
            title: I18n.tr("Balance")
            enabled: page.sinkBalance
            disabledReason: page.sink ? I18n.tr("This output has a single channel.") : I18n.tr("There is no output.")
            description: I18n.tr("Lean the sound towards the left or the right side.")
            stacked: true

            Row {
                width: parent.width
                spacing: 12

                M3Slider {
                    width: parent.width - centreBtn.width - parent.spacing
                    anchors.verticalCenter: parent.verticalCenter
                    from: -100
                    to: 100
                    stepSize: 5
                    stepLabels: page.balanceLabels
                    enabled: page.sinkBalance
                    value: Math.round(Audio.balanceOf(page.sink) * 20) * 5
                    onMoved: (v) => {
                        return Audio.setBalance(page.sink, v / 100);
                    }
                }

                // back to the centre; the readout already says where it is
                M3IconButton {
                    id: centreBtn

                    anchors.verticalCenter: parent.verticalCenter
                    size: 40
                    iconSize: 20
                    enabled: page.sinkBalance && Math.abs(Audio.balanceOf(page.sink)) > 0.001
                    iconPath: "M17.65 6.35A7.958 7.958 0 0 0 12 4a8 8 0 1 0 7.73 10h-2.08A6 6 0 1 1 12 6c1.66 0 3.14.69 4.22 1.78L13 11h7V4l-2.35 2.35Z"
                    onClicked: Audio.setBalance(page.sink, 0)
                }

            }

        }

        SettingRow {
            title: I18n.tr("Test")
            enabled: !!page.sink
            disabledReason: I18n.tr("There is no output to test.")
            description: page.sinkBalance ? I18n.tr("A voice names each side, so you can tell they are the right way round.") : I18n.tr("Play a short voice clip on this output.")

            Row {
                spacing: 8

                M3Button {
                    variant: "tonal"
                    enabled: !!page.sink
                    text: page.sinkBalance ? I18n.tr("Left") : I18n.tr("Play")
                    onClicked: Audio.testSide(page.sink, page.sinkBalance ? "FL" : "")
                }

                M3Button {
                    variant: "tonal"
                    visible: page.sinkBalance
                    text: I18n.tr("Right")
                    onClicked: Audio.testSide(page.sink, "FR")
                }

            }

        }

        SettingRow {
            title: I18n.tr("Move playing apps with the output")
            resetKey: "audioMoveStreams"
            description: I18n.tr("Picking a different output carries anything already playing across to it. With this off, only apps that have no device of their own follow the change.")
            showDivider: false

            M3Switch {
                checked: Prefs.audioMoveStreams
                onToggled: (v) => {
                    return Prefs.audioMoveStreams = v;
                }
            }

        }

        Column {
            width: parent.width
            topPadding: 4
            bottomPadding: 8
            spacing: 2

            GroupLabel {
                text: I18n.tr("Play sound through")
                visible: Audio.outputs.length > 0
            }

            Repeater {
                model: Audio.outputs

                AudioDeviceRow {
                    expanded: page.expandedOut === modelData.name
                    onExpandRequested: page.expandedOut = expanded ? "" : modelData.name
                }

            }

            Text {
                width: parent.width
                visible: Audio.outputs.length === 0
                horizontalAlignment: Text.AlignHCenter
                topPadding: 18
                bottomPadding: 18
                text: I18n.tr("No outputs. A card switched off in its mode below offers none, and a Bluetooth speaker has to be connected on the Bluetooth page first.")
                color: Theme.subtext
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
                wrapMode: Text.WordWrap
            }

        }

    }

    SettingCard {
        title: I18n.tr("INPUT")

        SettingRow {
            title: I18n.tr("Microphone volume")
            description: page.inputSummary
            enabled: !!page.source
            disabledReason: page.inputSummary
            showDivider: false
            stacked: true

            Column {
                width: parent.width
                spacing: 10

                Row {
                    width: parent.width
                    spacing: 12

                    M3IconButton {
                        anchors.verticalCenter: parent.verticalCenter
                        size: 40
                        iconSize: 21
                        variant: Audio.mutedOf(page.source) ? "tonal" : "standard"
                        enabled: !!page.source
                        iconPath: Audio.mutedOf(page.source) ? "M19 11h-1.7c0 .74-.16 1.43-.43 2.05l1.23 1.23c.56-.98.9-2.09.9-3.28Zm-4.02.17c0-.06.02-.11.02-.17V5a3 3 0 0 0-6 0v.18l5.98 5.99ZM4.27 3 3 4.27l6.01 6.01V11a3 3 0 0 0 3 3c.22 0 .44-.03.65-.08l1.66 1.66c-.71.33-1.5.52-2.31.52a5 5 0 0 1-5-5H5c0 3.03 2.39 5.53 5.4 5.94V21h2v-3.06c.82-.11 1.59-.38 2.29-.77L19.73 21 21 19.73 4.27 3Z" : "M12 14a3 3 0 0 0 3-3V5a3 3 0 0 0-6 0v6a3 3 0 0 0 3 3Zm5.3-3c0 3-2.54 5.1-5.3 5.1S6.7 14 6.7 11H5c0 3.42 2.72 6.23 6 6.72V21h2v-3.28c3.28-.48 6-3.3 6-6.72h-1.7Z"
                        onClicked: Audio.toggleMute(page.source)
                    }

                    M3Slider {
                        width: parent.width - 52
                        anchors.verticalCenter: parent.verticalCenter
                        from: 0
                        to: 100
                        stepSize: 1
                        decimals: 0
                        suffix: "%"
                        enabled: !!page.source && !Audio.mutedOf(page.source)
                        value: Audio.volumeOf(page.source)
                        onMoved: (v) => {
                            return Audio.setVolume(page.source, v);
                        }
                    }

                }

                LevelMeter {
                    x: 52
                    width: parent.width - 52
                    node: page.source
                    running: page.shown && (!page.meterWouldSwitch || page.btListen)
                }

                Item {
                    x: 52
                    width: parent.width - 52
                    height: Math.max(listenText.implicitHeight, listenBtn.height)
                    visible: page.meterWouldSwitch

                    Text {
                        id: listenText

                        anchors.left: parent.left
                        anchors.right: listenBtn.left
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: page.btListen ? I18n.tr("Listening. The headset plays at call quality until you stop.") : I18n.tr("The meter waits here: listening to a Bluetooth headset's microphone switches it to call-quality sound.")
                        color: Theme.subtext
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontBodyMd
                        wrapMode: Text.WordWrap
                    }

                    M3Button {
                        id: listenBtn

                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        variant: page.btListen ? "filled" : "tonal"
                        text: page.btListen ? I18n.tr("Stop") : I18n.tr("Listen")
                        onClicked: page.btListen = !page.btListen
                    }

                }
            }
        }


        Column {
            width: parent.width
            topPadding: 4
            bottomPadding: 8
            spacing: 2

            GroupLabel {
                text: I18n.tr("Record from")
                visible: Audio.inputs.length > 0
            }

            Repeater {
                model: Audio.inputs

                AudioDeviceRow {
                    expanded: page.expandedIn === modelData.name
                    onExpandRequested: page.expandedIn = expanded ? "" : modelData.name
                }

            }

            Text {
                width: parent.width
                visible: Audio.inputs.length === 0
                horizontalAlignment: Text.AlignHCenter
                topPadding: 18
                bottomPadding: 18
                text: I18n.tr("Nothing to record from. A headset has to be in a mode that includes its microphone before it shows up here.")
                color: Theme.subtext
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
                wrapMode: Text.WordWrap
            }

        }


    }

    SettingCard {
        title: I18n.tr("FEEDBACK SOUNDS")
        subtitle: I18n.tr("Short sounds for things you do. Pick one of the shell's own for each, or Custom to bring a file of yours: it is copied into ~/.config/lucid/sounds.")

        SettingRow {
            title: I18n.tr("Volume changes")
            resetKey: "soundVolumeFeedback"
            description: I18n.tr("A click on every step, like turning a dial, from the keys, the bar or anywhere else, so you can hear the new level.")
            stacked: true

            FeedbackSound {
                event: "volume"
            }

        }

        SettingRow {
            title: I18n.tr("Brightness changes")
            resetKey: "soundBrightness"
            description: I18n.tr("A click on every step of the screen's brightness. The dimming before the screen goes idle stays quiet.")
            stacked: true

            FeedbackSound {
                event: "brightness"
            }

        }

        SettingRow {
            title: I18n.tr("Plugging in and pulling out")
            resetKey: "soundPlug"
            description: I18n.tr("The charger, a USB device or a Bluetooth one connecting: a sound going up as it arrives, and down as it leaves.")
            stacked: true

            FeedbackSound {
                event: "plug"
            }

        }

        SettingRow {
            title: I18n.tr("Locking and unlocking")
            resetKey: "soundLock"
            description: I18n.tr("As the lock screen comes up, and again as it lets you in.")
            stacked: true

            FeedbackSound {
                event: "lock"
            }

        }

        SettingRow {
            title: I18n.tr("Emptying the trash")
            resetKey: "soundTrash"
            description: I18n.tr("When the trash goes from full to empty, from the desktop's menu, a file manager or anywhere else.")
            stacked: true

            FeedbackSound {
                event: "trash"
            }

        }

        SettingRow {
            title: I18n.tr("Screenshots")
            resetKey: "soundCapture"
            description: I18n.tr("As a capture is taken, of the screen, a region or a window.")
            stacked: true

            FeedbackSound {
                event: "capture"
            }

        }

        SettingRow {
            title: I18n.tr("Volume")
            resetKey: "soundFeedbackVolume"
            description: I18n.tr("For all of the sounds above, on top of the output's own volume.")
            stacked: true
            showDivider: false

            M3Slider {
                width: parent.width
                from: 10
                to: 100
                stepSize: 5
                suffix: " %"
                value: Math.round(Prefs.soundFeedbackVolume * 100)
                onMoved: (v) => {
                    Prefs.soundFeedbackVolume = v / 100;
                    feedbackVolumeTest.restart();
                }
            }

            // one click once the slider stops, at the new level
            Timer {
                id: feedbackVolumeTest

                interval: 250
                onTriggered: Sounds.playFile(Sounds.fileFor("volume"))
            }

        }

    }

    SettingCard {
        title: I18n.tr("APPLICATIONS")
        subtitle: I18n.tr("Everything making or taking sound right now. Each one keeps its own volume and can be sent to a device of its own.")

        Column {
            width: parent.width
            topPadding: 2
            bottomPadding: 8
            spacing: 2

            GroupLabel {
                text: I18n.tr("Playing")
                visible: Audio.playbackStreams.length > 0
            }

            Repeater {
                model: Audio.playbackStreams

                AudioStreamRow {
                    expanded: page.expandedStream === "out:" + modelData.id
                    onExpandRequested: page.expandedStream = expanded ? "" : "out:" + modelData.id
                }

            }

            GroupLabel {
                text: I18n.tr("Recording")
                visible: Audio.recordStreams.length > 0
            }

            Repeater {
                model: Audio.recordStreams

                AudioStreamRow {
                    expanded: page.expandedStream === "in:" + modelData.id
                    onExpandRequested: page.expandedStream = expanded ? "" : "in:" + modelData.id
                }

            }

            Text {
                width: parent.width
                visible: Audio.playbackStreams.length === 0 && Audio.recordStreams.length === 0
                horizontalAlignment: Text.AlignHCenter
                topPadding: 18
                bottomPadding: 18
                text: I18n.tr("Nothing is playing or recording.")
                color: Theme.subtext
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
            }

        }

    }

    SettingCard {
        title: I18n.tr("BEHAVIOUR")
        subtitle: I18n.tr("Kept by WirePlumber, so they hold for every application and survive a restart.")

        WpSwitchRow {
            wpKey: "node.stream.restore-props"
            title: I18n.tr("Remember each application's volume")
            description: I18n.tr("An application starts at the volume and mute it had the last time.")
        }

        WpSwitchRow {
            wpKey: "node.stream.restore-target"
            title: I18n.tr("Remember where each application plays")
            description: I18n.tr("An application you sent to another device goes back there the next time it starts.")
        }

        WpSwitchRow {
            wpKey: "linking.follow-default-target"
            title: I18n.tr("Move sound along with the default device")
            description: I18n.tr("Applications playing on the default device follow it when you choose another one.")
        }

        WpSwitchRow {
            wpKey: "linking.pause-playback"
            title: I18n.tr("Pause media when its device goes away")
            description: I18n.tr("Players pause when headphones are unplugged or a headset disconnects, instead of carrying on through the speakers.")
        }

        WpSwitchRow {
            wpKey: "bluetooth.autoswitch-to-headset-profile"
            title: I18n.tr("Switch headsets to call mode for their microphone")
            description: I18n.tr("When an application records from a Bluetooth headset, it changes to the headset profile: the microphone works, and playback drops to call quality until the recording stops.")
        }

        SettingRow {
            title: I18n.tr("Bluetooth headsets favour")
            enabled: Audio.wp["bluetooth.profile-preference"] !== undefined
            disabledReason: Audio.wpRead ? I18n.tr("This version of WirePlumber does not have this setting.") : I18n.tr("WirePlumber's settings could not be read. They need wpctl from WirePlumber 0.5 or newer.")
            description: I18n.tr("What WirePlumber leans towards when it picks a headset's mode by itself.")

            M3Segmented {
                width: 240
                enabled: Audio.wp["bluetooth.profile-preference"] !== undefined
                current: Audio.wp["bluetooth.profile-preference"] === "latency" ? "latency" : "quality"
                options: [{
                    "key": "quality",
                    "label": I18n.tr("Quality")
                }, {
                    "key": "latency",
                    "label": I18n.tr("Latency")
                }]
                onChosen: (key) => {
                    return Audio.setWp("bluetooth.profile-preference", key);
                }
            }

        }

        WpSwitchRow {
            wpKey: "node.features.audio.mono"
            title: I18n.tr("Mono audio")
            description: I18n.tr("Play the left and right channels together on every speaker and headphone. Every output restarts for a moment when this changes.")
            showDivider: false
        }

    }

    component WpSwitchRow: SettingRow {
        id: wpRow

        property string wpKey: ""
        readonly property bool known: Audio.wp[wpRow.wpKey] !== undefined

        enabled: wpRow.known
        disabledReason: Audio.wpRead ? I18n.tr("This version of WirePlumber does not have this setting.") : I18n.tr("WirePlumber's settings could not be read. They need wpctl from WirePlumber 0.5 or newer.")

        M3Switch {
            enabled: wpRow.known
            checked: Audio.wp[wpRow.wpKey] === true
            onToggled: (v) => {
                return Audio.setWp(wpRow.wpKey, v);
            }
        }

    }

    component GroupLabel: Text {
        color: Theme.subtext
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontTitleSm
        font.weight: Font.DemiBold
        font.letterSpacing: 0.1
        leftPadding: 22
        topPadding: 14
        bottomPadding: 6
    }

}
