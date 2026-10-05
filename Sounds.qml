import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

// the small sounds the shell makes for things the user does: a click on every
// volume or brightness step, a pair for something plugged in and pulled out, a
// pair for locking and unlocking, emptying the trash and taking a screenshot.
// Each event has a few sounds of its own to pick from, or a file the user
// brings, kept under ~/.config/lucid/sounds so it outlives where it came from.
Singleton {
    id: root

    readonly property string assets: Qt.resolvedUrl("assets").toString().replace("file://", "")
    readonly property string customDir: Quickshell.env("HOME") + "/.config/lucid/sounds"
    // per-step clicks, shared by volume and brightness
    readonly property var clickOptions: [{
        "key": "snap",
        "label": I18n.tr("Snap")
    }, {
        "key": "high",
        "label": I18n.tr("High")
    }, {
        "key": "low",
        "label": I18n.tr("Low")
    }, {
        "key": "glass",
        "label": I18n.tr("Glass")
    }]
    // event -> its switch, its choice, the sounds it offers, and its slots: one
    // file each, two for the events that come in pairs
    readonly property var events: ({
        "volume": {
            "on": "soundVolumeFeedback",
            "style": "soundVolumeStyle",
            "options": root.clickOptions,
            "slots": ["volume"],
            "step": true
        },
        "brightness": {
            "on": "soundBrightness",
            "style": "soundBrightnessStyle",
            "options": root.clickOptions,
            "slots": ["brightness"],
            "step": true
        },
        "plug": {
            "on": "soundPlug",
            "style": "soundPlugStyle",
            "options": [{
                "key": "pips",
                "label": I18n.tr("Pips")
            }, {
                "key": "pop",
                "label": I18n.tr("Pop")
            }, {
                "key": "bell",
                "label": I18n.tr("Bell")
            }],
            "slots": ["plugIn", "plugOut"]
        },
        "lock": {
            "on": "soundLock",
            "style": "soundLockStyle",
            "options": [{
                "key": "latch",
                "label": I18n.tr("Latch")
            }, {
                "key": "tone",
                "label": I18n.tr("Tone")
            }, {
                "key": "glide",
                "label": I18n.tr("Glide")
            }],
            "slots": ["lock", "unlock"]
        },
        "trash": {
            "on": "soundTrash",
            "style": "soundTrashStyle",
            "options": [{
                "key": "crunch",
                "label": I18n.tr("Crunch")
            }, {
                "key": "swoosh",
                "label": I18n.tr("Swoosh")
            }, {
                "key": "rattle",
                "label": I18n.tr("Rattle")
            }],
            "slots": ["trash"]
        },
        "capture": {
            "on": "soundCapture",
            "style": "soundCaptureStyle",
            "options": [{
                "key": "pop",
                "label": I18n.tr("Pop")
            }, {
                "key": "sparkle",
                "label": I18n.tr("Sparkle")
            }, {
                "key": "glass",
                "label": I18n.tr("Glass")
            }, {
                "key": "swish",
                "label": I18n.tr("Swish")
            }],
            "slots": ["capture"]
        }
    })
    readonly property var slotEvent: ({
        "volume": "volume",
        "brightness": "brightness",
        "plugIn": "plug",
        "plugOut": "plug",
        "lock": "lock",
        "unlock": "lock",
        "trash": "trash",
        "capture": "capture"
    })
    // what each slot is called next to its file, for the pairs
    readonly property var slotLabel: ({
        "plugIn": I18n.tr("Plugged in"),
        "plugOut": I18n.tr("Pulled out"),
        "lock": I18n.tr("Lock"),
        "unlock": I18n.tr("Unlock")
    })
    // a sound brought for a click plays on every step, so it is cut short
    readonly property real stepLimit: 1.5
    readonly property real eventLimit: 8
    // slot -> when it last played, so a drag ratchets instead of buzzing
    property var lastAt: ({})
    // the slot a file is being chosen for, "" when none
    property string choosing: ""
    // the last file that could not be read, and the slot it was for, for the
    // page to say so
    property string failed: ""
    property string lastChosen: ""

    function customKey(slot) {
        return "soundCustom" + slot.charAt(0).toUpperCase() + slot.substring(1);
    }

    function customFile(slot) {
        return Prefs[root.customKey(slot)] || "";
    }

    // "volume--My click.wav" -> "My click"
    function customName(slot) {
        const f = root.customFile(slot);
        if (f === "")
            return "";

        const base = f.substring(f.lastIndexOf("/") + 1);
        const cut = base.indexOf("--");
        const name = cut >= 0 ? base.substring(cut + 2) : base;
        const dot = name.lastIndexOf(".");
        return dot > 0 ? name.substring(0, dot) : name;
    }

    function style(event) {
        return Prefs[root.events[event].style];
    }

    function builtIn(slot, style) {
        switch (root.slotEvent[slot]) {
        case "volume":
        case "brightness":
            return style === "snap" ? root.assets + "/volume-click.wav" : root.assets + "/sounds/click-" + style + ".wav";
        case "plug":
            return root.assets + "/sounds/plug-" + style + (slot === "plugIn" ? "-in" : "-out") + ".wav";
        default:
            return root.assets + "/sounds/" + slot + "-" + style + ".wav";
        }
    }

    // the file a slot plays now. Custom with nothing chosen for this slot falls
    // back on the other half of the pair, then on the first sound offered
    function fileFor(slot) {
        const ev = root.events[root.slotEvent[slot]];
        const s = Prefs[ev.style];
        if (s !== "custom")
            return root.builtIn(slot, s);

        if (root.customFile(slot) !== "")
            return root.customFile(slot);

        for (const other of ev.slots) {
            if (root.customFile(other) !== "")
                return root.customFile(other);

        }
        return root.builtIn(slot, ev.options[0].key);
    }

    // pw-play takes a linear gain; squared, the slider reads closer to loudness
    function gain() {
        const v = Math.max(0, Math.min(1, Prefs.soundFeedbackVolume));
        return (v * v).toFixed(3);
    }

    function playFile(file) {
        if (file !== "")
            Quickshell.execDetached(["pw-play", "--volume=" + root.gain(), file]);

    }

    // what the shell calls when the thing happens; plays only if the event is on
    function play(slot) {
        const event = root.slotEvent[slot];
        if (!event || !Prefs[root.events[event].on])
            return ;

        const now = Date.now();
        // a click on every step, no more often than every 35 ms; anything
        // else once, however fast its source repeats
        const gap = root.events[event].step ? 35 : 250;
        if (now - (root.lastAt[slot] || 0) < gap)
            return ;

        root.lastAt[slot] = now;
        root.playFile(root.fileFor(slot));
    }

    // Settings' Play: the event as it would sound, both halves of a pair
    function preview(event) {
        const slots = root.events[event].slots;
        root.playFile(root.fileFor(slots[0]));
        if (slots.length > 1)
            pairTimer.restartFor(root.fileFor(slots[1]));

    }

    function previewSlot(slot) {
        root.playFile(root.fileFor(slot));
    }

    // asks for a file for a slot, makes a copy of it of our own and switches
    // the event over to it
    function choose(slot) {
        if (chooser.running)
            return ;

        const event = root.slotEvent[slot];
        root.choosing = slot;
        root.lastChosen = slot;
        root.failed = "";
        const title = I18n.tr("Choose a sound") + (root.slotLabel[slot] ? " · " + root.slotLabel[slot] : "");
        chooser.slot = slot;
        chooser.command = ["sh", "-c", root.chooseScript, "sh", title, root.customDir, slot, String(root.events[event].step ? root.stepLimit : root.eventLimit)];
        chooser.running = true;
    }

    function forget(slot) {
        const f = root.customFile(slot);
        Prefs[root.customKey(slot)] = "";
        if (f.indexOf(root.customDir + "/") === 0)
            Quickshell.execDetached(["rm", "-f", "--", f]);

        const ev = root.events[root.slotEvent[slot]];
        const left = ev.slots.some((s) => {
            return root.customFile(s) !== "";
        });
        if (!left && Prefs[ev.style] === "custom")
            Prefs[ev.style] = ev.options[0].key;

    }

    // zenity for the file; ffmpeg, if it is there, makes it a plain wav pw-play
    // always reads and trims it; without ffmpeg the file is copied as it is.
    // the old copy goes only once the new one is in place
    readonly property string chooseScript: "f=$(zenity --file-selection --title=\"$1\" --file-filter='Sounds | *.wav *.ogg *.oga *.flac *.opus *.mp3 *.m4a *.aac *.WAV *.OGG *.FLAC *.MP3' --file-filter='All files | *' 2>/dev/null) || exit 0\n" + "[ -f \"$f\" ] || exit 0\n" + "mkdir -p \"$2\" || exit 0\n" + "base=$(basename -- \"$f\"); name=${base%.*}; tmp=\"$2/.$3.tmp\"\n" + "if command -v ffmpeg >/dev/null 2>&1; then\n" + "  out=\"$2/$3--$name.wav\"\n" + "  ffmpeg -v error -nostdin -y -i \"$f\" -vn -t \"$4\" -ar 48000 -c:a pcm_s16le -f wav \"$tmp\" 2>/dev/null || { rm -f -- \"$tmp\"; printf 'ERR %s\\n' \"$base\"; exit 0; }\n" + "else\n" + "  out=\"$2/$3--$base\"\n" + "  cp -- \"$f\" \"$tmp\" || exit 0\n" + "fi\n" + "for o in \"$2/$3--\"*; do [ \"$o\" = \"$out\" ] || rm -f -- \"$o\"; done\n" + "mv -f -- \"$tmp\" \"$out\" && printf 'OK %s\\n' \"$out\"\n"

    Process {
        id: chooser

        property string slot: ""

        onExited: root.choosing = ""

        stdout: SplitParser {
            onRead: (line) => {
                if (line.indexOf("ERR ") === 0) {
                    root.failed = line.substring(4);
                    return ;
                }
                if (line.indexOf("OK ") !== 0)
                    return ;

                const file = line.substring(3);
                const ev = root.events[root.slotEvent[chooser.slot]];
                Prefs[root.customKey(chooser.slot)] = file;
                Prefs[ev.style] = "custom";
                root.playFile(file);
            }
        }

    }

    // the trash, watched for going from full to empty: emptied from the
    // desktop's menu, a file manager or gio alike
    property int trashBefore: -1
    readonly property string trashWatch: "import os\n" + "from gi.repository import Gio, GLib\n" + "d = os.path.join(GLib.get_user_data_dir(), 'Trash', 'files')\n" + "os.makedirs(d, exist_ok=True)\n" + "pending = [0]\n" + "def emit():\n" + "    pending[0] = 0\n" + "    try:\n" + "        n = len(os.listdir(d))\n" + "    except OSError:\n" + "        n = 0\n" + "    print(n, flush=True)\n" + "    return False\n" + "def changed(*_):\n" + "    if pending[0]:\n" + "        GLib.source_remove(pending[0])\n" + "    pending[0] = GLib.timeout_add(150, emit)\n" + "m = Gio.File.new_for_path(d).monitor_directory(Gio.FileMonitorFlags.WATCH_MOVES, None)\n" + "m.connect('changed', changed)\n" + "emit()\n" + "GLib.MainLoop().run()\n"

    Process {
        running: Prefs.soundTrash
        command: ["python3", "-c", root.trashWatch]
        onRunningChanged: root.trashBefore = -1

        stdout: SplitParser {
            onRead: (line) => {
                const n = parseInt(line, 10);
                if (isNaN(n))
                    return ;

                if (root.trashBefore > 0 && n === 0)
                    root.play("trash");

                root.trashBefore = n;
            }
        }

    }

    Timer {
        id: pairTimer

        property string file: ""

        function restartFor(f) {
            pairTimer.file = f;
            pairTimer.restart();
        }

        interval: 550
        onTriggered: root.playFile(pairTimer.file)
    }

    IpcHandler {
        target: "sounds"

        // qs ipc call sounds play plugIn - as the event would, switch and all
        function play(slot: string): void {
            root.play(slot);
        }

        function preview(event: string): void {
            if (root.events[event])
                root.preview(event);

        }

    }

}
