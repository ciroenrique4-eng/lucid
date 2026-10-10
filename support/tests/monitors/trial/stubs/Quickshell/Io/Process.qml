// stand-in for Quickshell's Process: never runs anything
import QtQuick
QtObject {
    default property list<QtObject> data
    property bool running: false
    property var command: []
    property QtObject stdout: null
}
