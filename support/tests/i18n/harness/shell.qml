import QtQuick
import Quickshell
import Quickshell.Io
import qs

// a bare instance with I18n and Prefs and nothing else: run.sh copies the shell
// next to this file under a fake HOME, so nothing here touches the real setup
ShellRoot {
    id: root

    readonly property string probe: I18n.tr("Battery")

    IpcHandler {
        target: "bench"

        function get(): string {
            return root.probe + "|" + I18n.language + "|" + I18n.locale.name;
        }

        function set(lang: string): void {
            Prefs.language = lang;
        }
    }
}
