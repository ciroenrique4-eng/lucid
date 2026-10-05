import QtQuick
import Quickshell
import Quickshell.Io
import qs
import "lucidprefs"

// a bare instance with I18n and Prefs and nothing else: run.sh copies the shell
// next to this file under a fake HOME, so nothing here touches the real setup
ShellRoot {
    id: root

    readonly property string probe: I18n.tr("Battery")

    // Settings search over the real General page, the way Settings wires it
    SettingsIndex {
        id: idx

        wanted: true
        pages: [{
            "key": "general",
            "label": "General",
            "title": "General",
            "blurb": "Shape, colour and motion"
        }]
        fileOf: (key) => {
            return "GeneralPage.qml";
        }
    }

    IpcHandler {
        target: "bench"

        function get(): string {
            return root.probe + "|" + I18n.language + "|" + I18n.locale.name;
        }

        // the titles of the rows a search finds, as the results page shows them
        function search(q: string): string {
            return idx.find(q).filter((r) => {
                return r.kind === "row";
            }).map((r) => {
                return r.title;
            }).join(";");
        }

        function set(lang: string): void {
            Prefs.language = lang;
        }
    }
}
