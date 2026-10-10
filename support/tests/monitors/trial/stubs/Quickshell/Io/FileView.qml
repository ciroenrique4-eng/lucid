// stand-in for Quickshell's FileView: nothing on disk, writes kept in memory
import QtQuick
QtObject {
    property string path: ""
    property bool blockLoading: false
    property bool printErrors: true
    property string written: ""
    signal loaded()
    signal loadFailed()
    signal saved()
    signal saveFailed()
    function text() { return "" }
    function setText(t) { written = t; saved() }
    Component.onCompleted: Qt.callLater(loadFailed)
}
