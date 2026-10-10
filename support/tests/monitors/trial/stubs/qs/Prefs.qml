// stand-in for the shell's Prefs, with only what Monitors.qml reads
pragma Singleton
import QtQuick
QtObject {
    property bool loaded: true
    property bool barEnabled: true
    property bool barBottom: false
    property string monitorSetups: "{}"
    property string monitorShellScreen: ""
    property string monitorBarScreen: ""
    property string monitorDockScreen: ""
    property string monitorWorkspaces: ""
    function set(key, value) { if (this[key] !== value) this[key] = value }
}
